const prisma = require('../../database/client');
const dayjs = require('dayjs');

// 👇 CORREÇÃO DO BUG MÉDIO: Travando o fuso horário para evitar faltas no dia errado no Render!
const utc = require('dayjs/plugin/utc');
const timezone = require('dayjs/plugin/timezone');
dayjs.extend(utc);
dayjs.extend(timezone);
dayjs.tz.setDefault('America/Sao_Paulo');

const alunoService = require('../alunos/aluno.service'); // Para reaproveitar a matemática de frequência

class RelatorioService {
  
  // 1. Relatório da Cozinha
  async previsaoCozinha(dataRef) {
    // 👇 Agora sempre usa o horário oficial de Brasília
    const dataBusca = dataRef ? dayjs(dataRef).tz('America/Sao_Paulo') : dayjs().tz('America/Sao_Paulo');
    const inicioDoDia = dataBusca.startOf('day').toDate();
    const fimDoDia = dataBusca.endOf('day').toDate();

    // Pega todo mundo que marcou presença, chegou atrasado ou saiu mais cedo
    const presencas = await prisma.presenca.findMany({
      where: {
        dataHora: { gte: inicioDoDia, lte: fimDoDia },
        status: { in: ['PRESENTE', 'ATRASO', 'SAIDA_ANTECIPADA'] }
      },
      include: { turma: true } // <--- A mágica da normalização aqui!
    });

    const previsao = { MANHA: 0, TARDE: 0, NOITE: 0, INTEGRAL: 0, TOTAL: 0 };

    presencas.forEach(p => {
      if (p.turma && p.turma.turno) {
        previsao[p.turma.turno]++;
        previsao.TOTAL++;
      }
    });

    return { data: dataBusca.format('YYYY-MM-DD'), previsao };
  }

  // 2. Lista de Ausentes por Dia e Turma
  async listarAusentes(turmaId, dataRef) {
    const dataBusca = dataRef ? dayjs(dataRef).tz('America/Sao_Paulo') : dayjs().tz('America/Sao_Paulo');
    const inicioDoDia = dataBusca.startOf('day').toDate();
    const fimDoDia = dataBusca.endOf('day').toDate();

    const faltas = await prisma.presenca.findMany({
      where: {
        turmaId,
        dataHora: { gte: inicioDoDia, lte: fimDoDia },
        status: 'AUSENTE'
      },
      include: { aluno: { select: { id: true, nome: true, matricula: true } } }
    });

    return faltas.map(f => ({
      alunoId: f.aluno.id,
      nome: f.aluno.nome,
      matricula: f.aluno.matricula,
      dataFalta: f.dataHora
    }));
  }

  // 3. Alunos com Baixa Frequência (Filtro Global)
  async listarAlunosBaixaFrequencia(limiar = 75, dataInicio, dataFim) {
    const whereClause = {};
    if (dataInicio || dataFim) {
      whereClause.dataHora = {};
      if (dataInicio) whereClause.dataHora.gte = new Date(dataInicio);
      if (dataFim) whereClause.dataHora.lte = new Date(dataFim);
    }

    // 1 QUERY APENAS: Traz a contagem de faltas/presenças de TODOS os alunos de uma vez
    const contagens = await prisma.presenca.groupBy({
      by: ['alunoId', 'status'],
      where: whereClause,
      _count: { _all: true }
    });

    // 1 QUERY APENAS: Traz os dados básicos dos alunos ativos
    const alunos = await prisma.aluno.findMany({ 
      where: { ativo: true }, 
      select: { id: true, nome: true, matricula: true } 
    });

    const mapaFrequencia = {};
    alunos.forEach(a => {
      mapaFrequencia[a.id] = { ...a, presentes: 0, ausentes: 0, justificados: 0, atrasos: 0, saidasAntecipadas: 0 };
    });

    // Distribui as contagens do banco na memória do Node (Muito mais rápido!)
    contagens.forEach(item => {
      if (mapaFrequencia[item.alunoId]) {
        const status = item.status;
        const qtd = item._count._all;
        if (status === 'PRESENTE') mapaFrequencia[item.alunoId].presentes = qtd;
        if (status === 'AUSENTE') mapaFrequencia[item.alunoId].ausentes = qtd;
        if (status === 'JUSTIFICADO') mapaFrequencia[item.alunoId].justificados = qtd;
        if (status === 'ATRASO') mapaFrequencia[item.alunoId].atrasos = qtd;
        if (status === 'SAIDA_ANTECIPADA') mapaFrequencia[item.alunoId].saidasAntecipadas = qtd;
      }
    });

    const alunosEmRisco = [];

    // Calcula a porcentagem sem bater no banco de dados
    for (const alunoId in mapaFrequencia) {
      const dados = mapaFrequencia[alunoId];
      const total = dados.presentes + dados.ausentes + dados.justificados + dados.atrasos + dados.saidasAntecipadas;
      let frequencia = 100.0;

      if (total > 0) {
        frequencia = ((dados.presentes + dados.justificados + dados.atrasos + dados.saidasAntecipadas) / total) * 100;
      }

      if (frequencia < Number(limiar)) {
        alunosEmRisco.push({
          alunoId,
          nome: dados.nome,
          matricula: dados.matricula,
          frequencia: Number(frequencia.toFixed(2)),
          statusRisco: 'EM_RISCO'
        });
      }
    }

    return alunosEmRisco.sort((a, b) => a.frequencia - b.frequencia);
  }

  // 👇 O CHEFÃO FINAL: 4. Fechamento Mensal Consolidado
  async gerarRelatorioMensal() {
    // Pega exatamente o mês atual no fuso de Brasília
    const hoje = dayjs().tz('America/Sao_Paulo');
    const inicioDoMes = hoje.startOf('month').toDate();
    const fimDoMes = hoje.endOf('month').toDate();

    // Consolida todos os status do mês inteiro em 1 query super rápida
    const contagens = await prisma.presenca.groupBy({
      by: ['status'],
      where: {
        dataHora: { gte: inicioDoMes, lte: fimDoMes }
      },
      _count: { _all: true }
    });

    const resumo = { PRESENTE: 0, AUSENTE: 0, JUSTIFICADO: 0, ATRASO: 0, SAIDA_ANTECIPADA: 0, TOTAL: 0 };
    
    contagens.forEach(item => {
      resumo[item.status] = item._count._all;
      resumo.TOTAL += item._count._all;
    });

    return {
      mes: hoje.format('MM/YYYY'),
      inicio: inicioDoMes,
      fim: fimDoMes,
      estatisticas: resumo
    };
  }
}

module.exports = new RelatorioService();