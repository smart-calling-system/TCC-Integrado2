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
    if (!lotePresencas || lotePresencas.length === 0) {
      return { inseridos: 0, ignorados: 0, erros: 0 };
    }

    try {
      // 1. Prepara todos os dados em memória usando o map (rápido!)
      const payloadPrisma = lotePresencas.map((item) => {
        // Usa o dayjs para garantir que estamos lidando com a data certinha
        const dataRegistro = item.dataHora ? dayjs(item.dataHora) : dayjs();

        return {
          alunoId: item.alunoId,
          turmaId: item.turmaId,
          disciplinaId: item.disciplinaId || null,
          status: item.status || 'PRESENTE',
          origem: 'OFFLINE',
          faceScore: item.faceScore || null,
          dataHora: dataRegistro.toDate(), // Mantém a hora exata da batida
          data: dataRegistro.startOf('day').toDate() // NOVA COLUNA DA TRAVA DE UNICIDADE
        };
      });

      // 2. Faz o Insert em Lote de uma só vez (Apenas 1 consulta ao banco!)
      // O skipDuplicates: true resolve todos os conflitos automaticamente
      const resultado = await prisma.presenca.createMany({
        data: payloadPrisma,
        skipDuplicates: true 
      });

      // 3. Calcula as métricas matemáticas
      const inseridos = resultado.count;
      const ignorados = lotePresencas.length - inseridos;

      return {
        inseridos,
        ignorados,
        erros: 0
      };
    } catch (err) {
      console.error('🚨 Erro ao sincronizar lote offline:', err.message);
      throw err; // Deixa o erro subir pro Controller tratar no next(error)
    }
  }
}

module.exports = new PresencaRepository();