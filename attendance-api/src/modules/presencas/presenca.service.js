const presencaRepository = require('./presenca.repository');
const alunoService = require('../alunos/aluno.service');
const turmaService = require('../turmas/turma.service');
const AppError = require('../../utils/AppError');
const dayjs = require('dayjs');
const prisma = require('../../database/client'); // Trazendo pro topo para todo mundo usar

class PresencaService {
  async registrarPresencaManual(payload) {
    const { alunoId, turmaId, disciplinaId, status, origem, faceScore } = payload;

    // 1. Valida se o aluno e a turma existem e estão ativos antes de registrar a presença
    await alunoService.buscarAlunoPorId(alunoId);
    await turmaService.buscarTurmaPorId(turmaId);

    // O início do dia para preencher o novo campo "data" (Trava de unicidade)
    const dataAtual = dayjs().startOf('day').toDate(); 

    try {
      // O ESCUDO AGORA É O BANCO DE DADOS: O Prisma vai tentar inserir.
      // Se já existir para hoje, ele vai gritar um erro (P2002) nativamente.
      return await prisma.presenca.create({
        data: {
          alunoId,
          turmaId,
          disciplinaId,
          status: status || 'PRESENTE',
          origem: origem || 'MANUAL', 
          faceScore: faceScore || null,
          data: dataAtual // <- Aqui usamos o campo novo que garante unicidade
        }
      });
    } catch (error) {
      // P2002 é o código do Prisma para "Unique constraint failed"
      if (error.code === 'P2002') {
        throw new AppError('Este aluno já possui uma presença registrada para esta turma no dia de hoje.', 409);
      }
      throw error; // Se for outro erro de banco, repassa pra frente
    }
  }

  async listarTodas(pagina, limite) {
    return await presencaRepository.findAll(pagina, limite);
  }

  async listarPorAluno(alunoId) {
    await alunoService.buscarAlunoPorId(alunoId);
    return await presencaRepository.findByAlunoId(alunoId);
  }

  async listarPorTurma(turmaId) {
    await turmaService.buscarTurmaPorId(turmaId);
    return await presencaRepository.findByTurmaId(turmaId);
  }

  async listarPresencasHoje() {
    return await presencaRepository.findPresencasDeHoje();
  }

  // ==========================================
  // O Robô da Madrugada: Otimizado (Sem N+1)
  // ==========================================
  async processarFaltasAutomaticasDoDia() {
    const diasSemanaMap = ['DOMINGO', 'SEGUNDA', 'TERCA', 'QUARTA', 'QUINTA', 'SEXTA', 'SABADO'];
    const diaAtualEnum = diasSemanaMap[dayjs().day()];

    if (diaAtualEnum === 'DOMINGO') return; // Não faz nada no domingo

    console.log('🤖 [CRON JOB] Iniciando varredura de faltas automáticas (Lote)...');

    // 1. Busca todas as aulas que aconteceram hoje (Query 1)
    const aulasDeHoje = await prisma.horario.findMany({
      where: { diaSemana: diaAtualEnum, ativo: true },
      include: { turma: { include: { alunos: { include: { aluno: true } } } } }
    });

    if (aulasDeHoje.length === 0) {
      console.log('🤖 [CRON JOB] Nenhuma aula programada para hoje.');
      return;
    }

    // 2. Busca TODAS as presenças já registradas hoje de UMA SÓ VEZ (Query 2)
    const inicioDoDia = dayjs().startOf('day').toDate();
    const fimDoDia = dayjs().endOf('day').toDate();

    const presencasHoje = await prisma.presenca.findMany({
      where: {
        dataHora: { gte: inicioDoDia, lte: fimDoDia }
      },
      select: { alunoId: true, turmaId: true } // Traz só o que precisamos pra não pesar a RAM
    });

    // 3. Cria um "Set" em memória: busca ultra-rápida!
    // Exemplo do Set: ["aluno1-turmaA", "aluno2-turmaA"]
    const presencasMap = new Set(
      presencasHoje.map(p => `${p.alunoId}-${p.turmaId}`)
    );

    const faltasParaInserir = [];
    const dataUnica = dayjs().startOf('day').toDate(); // Para o campo data

    // 4. Cruza os dados EM MEMÓRIA (Zero consultas ao banco aqui dentro)
    for (const aula of aulasDeHoje) {
      const turmaId = aula.turmaId;
      const disciplinaId = aula.disciplinaId;
      const alunosDaTurma = aula.turma.alunos.filter(vinculo => vinculo.aluno.ativo);

      for (const vinculo of alunosDaTurma) {
        const alunoId = vinculo.alunoId;
        const chaveIdentificadora = `${alunoId}-${turmaId}`;

        // Se a chave NÃO existe no nosso Set de presenças de hoje, ele faltou.
        if (!presencasMap.has(chaveIdentificadora)) {
          faltasParaInserir.push({
            alunoId,
            turmaId,
            disciplinaId,
            status: 'AUSENTE',
            origem: 'SISTEMA',
            data: dataUnica
          });
        }
      }
    }

    // 5. BULK INSERT: Salva todas as 400 faltas de uma vez só! (Query 3)
    if (faltasParaInserir.length > 0) {
      await prisma.presenca.createMany({
        data: faltasParaInserir,
        skipDuplicates: true // Segurança máxima do Prisma para não duplicar nada
      });
    }

    console.log(`🤖 [CRON JOB] Varredura concluída. ${faltasParaInserir.length} faltas registradas via Bulk Insert.`);
  }

  // ==========================================
  // REGISTRO DE SAÍDA
  // ==========================================
  async registrarSaida(presencaId, novoStatus) {
    // 1. Garante que a presença existe
    const presenca = await presencaRepository.buscarPorId(presencaId);
    if (!presenca) {
      throw new AppError('Registro de presença não encontrado.', 404);
    }

    // 2. Evita sobrescrever uma saída que já foi dada
    if (presenca.dataHoraSaida) {
      throw new AppError('A saída já foi registrada para este aluno.', 400);
    }

    // 3. Atualiza
    return await presencaRepository.registrarSaida(presencaId, novoStatus);
  }
}

module.exports = new PresencaService();