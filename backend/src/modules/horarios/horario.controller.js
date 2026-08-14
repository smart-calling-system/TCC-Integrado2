const horarioService = require('./horario.service');

class HorarioController {
  async create(req, res, next) {
    try {
      const novoHorario = await horarioService.cadastrarHorario(req.body);
      return res.status(201).json({ status: 'success', data: novoHorario });
    } catch (error) {
      next(error);
    }
  }

  async update(req, res, next) {
    try {
      // 👇 Require duplicado removido
      const horarioAtualizado = await horarioService.atualizarHorario(
        req.params.id, 
        req.body, 
        req.usuario.id // Injetando quem alterou para o log
      );
      return res.status(200).json({ status: 'success', data: horarioAtualizado });
    } catch (error) {
      next(error);
    }
  }

  async delete(req, res, next) {
    try {
      // 👇 Require duplicado removido
      await horarioService.deletarHorario(
        req.params.id, 
        req.usuario.id // Injetando quem apagou para o log
      );
      return res.status(204).send();
    } catch (error) {
      next(error);
    }
  }

  async getAll(req, res, next) {
    try {
      const horarios = await horarioService.listarTodos();
      return res.status(200).json({ status: 'success', data: horarios });
    } catch (error) {
      next(error);
    }
  }

  // GET /grade-horaria/turma/:id/agora
  async buscarAulaAtual(req, res, next) {
    try {
      const { id: turmaId } = req.params;
      
      // 👇 BUG MÉDIO CORRIGIDO: Toda a lógica complexa de datas e banco de dados foi repassada para o Service!
      const aulaAtual = await horarioService.buscarAulaAtual(turmaId);
      
      return res.status(200).json({ status: 'success', data: aulaAtual });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new HorarioController();