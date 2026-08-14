const prisma = require('../../database/client');
const dayjs = require('dayjs');

class PresencaRepository {
  async create(data) {
    return await prisma.presenca.create({ 
      data,
      include: { aluno: true, turma: true } 
    });
  }

  async findAll(pagina = 1, limite = 10) {
    const skip = (pagina - 1) * limite;
    const take = Number(limite);

    const [presencas, total] = await prisma.$transaction([
      prisma.presenca.findMany({
        skip,
        take,
        include: { aluno: true, turma: true },
        orderBy: { dataHora: 'desc' }
      }),
      prisma.presenca.count()
    ]);

    const totalPaginas = Math.ceil(total / take);

    return {
      dados: presencas,
      meta: {
        total,
        paginaAtual: Number(pagina),
        totalPaginas,
        itensPorPagina: take
      }
    };
  }

  async findByAlunoId(alunoId) {
    return await prisma.presenca.findMany({
      where: { alunoId },
      include: { turma: true, disciplina: true },
      orderBy: { dataHora: 'desc' }
    });
  }

  async findByTurmaId(turmaId) {
    return await prisma.presenca.findMany({
      where: { turmaId },
      include: { aluno: true },
      orderBy: { dataHora: 'desc' }
    });
  }

  async findPresencasDeHoje() {
    const inicioDoDia = dayjs().startOf('day').toDate();
    const fimDoDia = dayjs().endOf('day').toDate();

    return await prisma.presenca.findMany({
      where: {
        dataHora: {
          gte: inicioDoDia,
          lte: fimDoDia
        }
      },
      include: { aluno: true, turma: true },
      orderBy: { dataHora: 'desc' }
    });
  }

  async countByStatusAndAluno(alunoId, dataInicio, dataFim) {
    const whereClause = { alunoId };

    if (dataInicio || dataFim) {
      whereClause.dataHora = {};
      if (dataInicio) whereClause.dataHora.gte = new Date(dataInicio); 
      if (dataFim) whereClause.dataHora.lte = new Date(dataFim);       
    }

    return await prisma.presenca.groupBy({
      by: ['status'],
      where: whereClause,
      _count: {
        _all: true
      }
    });
  }

  async verificarPresencaExistenteHoje(alunoId, turmaId) {
    const inicioDoDia = dayjs().startOf('day').toDate();
    const fimDoDia = dayjs().endOf('day').toDate();

    const presenca = await prisma.presenca.findFirst({
      where: {
        alunoId,
        turmaId,
        dataHora: {
          gte: inicioDoDia,
          lte: fimDoDia
        }
      }
    });

    return !!presenca; 
  }

  async buscarPresencaCompletaDeHoje(alunoId, turmaId) {
    const inicioDoDia = dayjs().startOf('day').toDate();
    const fimDoDia = dayjs().endOf('day').toDate();

    return await prisma.presenca.findFirst({
      where: {
        alunoId,
        turmaId,
        dataHora: { 
          gte: inicioDoDia,
          lte: fimDoDia 
        }
      }
    });
  }

  async buscarPresencaDeHojePorDisciplina(alunoId, turmaId, disciplinaId) {
    const inicioDoDia = dayjs().startOf('day').toDate();
    const fimDoDia = dayjs().endOf('day').toDate();

    return await prisma.presenca.findFirst({
      where: {
        alunoId,
        turmaId,
        disciplinaId, 
        dataHora: { 
          gte: inicioDoDia,
          lte: fimDoDia 
        }
      }
    });
  }

  async registrarSaida(presencaId, novoStatus = null) {
    const dataUpdate = { dataHoraSaida: new Date() };

    if (novoStatus) {
      dataUpdate.status = novoStatus;
    }

    return await prisma.presenca.update({
      where: { id: presencaId },
      data: dataUpdate
    });
  }

  async countAgrupadoPorDisciplina(alunoId, dataInicio, dataFim) {
    const whereClause = { alunoId };

    if (dataInicio || dataFim) {
      whereClause.dataHora = {};
      if (dataInicio) whereClause.dataHora.gte = new Date(dataInicio);
      if (dataFim) whereClause.dataHora.lte = new Date(dataFim);
    }

    return await prisma.presenca.groupBy({
      by: ['disciplinaId', 'status'],
      where: whereClause,
      _count: { _all: true }
    });
  }

  async countConsolidadoPorTurma(turmaId, dataInicio, dataFim) {
    const whereClause = { turmaId };

    if (dataInicio || dataFim) {
      whereClause.dataHora = {};
      if (dataInicio) whereClause.dataHora.gte = new Date(dataInicio);
      if (dataFim) whereClause.dataHora.lte = new Date(dataFim);
    }

    return await prisma.presenca.groupBy({
      by: ['alunoId', 'status'],
      where: whereClause,
      _count: { _all: true }
    });
  }

  // ==========================================
  // SYNC OFFLINE: REFEITO COM BULK INSERT 🚀
  // ==========================================
  async sincronizarBatchOffline(lotePresencas) {
    let sucesso = 0;
    let falha = 0;

    // 👇 Usando upsert isolado. Se a FK estiver errada, falha só uma, mas salva o resto!
    const operacoes = lotePresencas.map(p => {
      return prisma.presenca.upsert({
        where: {
          aluno_turma_data_unica: {
            alunoId: p.alunoId,
            turmaId: p.turmaId,
            data: new Date(p.dataHora) 
          }
        },
        update: {}, // Idempotência: não faz nada se a presença já estiver registrada
        create: {
          alunoId: p.alunoId,
          turmaId: p.turmaId,
          origem: 'OFFLINE',
          dataHora: new Date(p.dataHora),
          data: new Date(p.dataHora)
        }
      });
    });

    // Roda tudo em paralelo. O que der erro, a gente joga pro contador de falhas.
    const resultados = await Promise.allSettled(operacoes);
    
    resultados.forEach(res => {
      if (res.status === 'fulfilled') sucesso++;
      else falha++;
    });

    return { sucesso, falha, total: lotePresencas.length };
  }
}

module.exports = new PresencaRepository();