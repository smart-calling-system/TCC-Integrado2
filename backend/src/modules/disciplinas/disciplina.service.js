const disciplinaRepository = require('./disciplina.repository');
const auditService = require('../auditoria/audit.service'); // Importa o serviço de auditoria
const AppError = require('../../utils/AppError');

class DisciplinaService {
  async createDisciplina(data, userId = null) {
    const disciplinaExistente = await disciplinaRepository.findByCodigo(data.codigo);
    if (disciplinaExistente) {
      throw new AppError('Já existe uma disciplina cadastrada com este código.', 400);
    }

    const novaDisciplina = await disciplinaRepository.create(data);

    // Registra a auditoria de criação
    await auditService.registrar({
      usuarioId: userId,
      acao: 'CREATE',
      entidade: 'Disciplina',
      entidadeId: novaDisciplina.id,
      dadosNovos: novaDisciplina
    });

    return novaDisciplina;
  }

  async listarDisciplinas() {
    return await disciplinaRepository.findAll();
  }

  async buscarDisciplinaPorId(id) {
    const disciplina = await disciplinaRepository.findById(id);
    if (!disciplina) {
      throw new AppError('Disciplina não encontrada.', 404);
    }
    return disciplina;
  }

  async atualizarDisciplina(id, data, userId = null) {
    const disciplinaAntiga = await this.buscarDisciplinaPorId(id);

    if (data.codigo) {
      const disciplinaExistente = await disciplinaRepository.findByCodigo(data.codigo);
      if (disciplinaExistente && disciplinaExistente.id !== id) {
        throw new AppError('Este código já está em uso por outra disciplina.', 400);
      }
    }

    const disciplinaAtualizada = await disciplinaRepository.update(id, data);

    // Registra a auditoria de atualização
    await auditService.registrar({
      usuarioId: userId,
      acao: 'UPDATE',
      entidade: 'Disciplina',
      entidadeId: id,
      dadosAntigos: disciplinaAntiga,
      dadosNovos: disciplinaAtualizada
    });

    return disciplinaAtualizada;
  }

  async deletarDisciplina(id, userId = null) {
    const disciplina = await this.buscarDisciplinaPorId(id);
    
    await disciplinaRepository.delete(id);

    // Registra a auditoria de exclusão
    await auditService.registrar({
      usuarioId: userId,
      acao: 'DELETE',
      entidade: 'Disciplina',
      entidadeId: id,
      dadosAntigos: disciplina
    });

    return { message: 'Disciplina deletada com sucesso.' };
  }
}

module.exports = new DisciplinaService();