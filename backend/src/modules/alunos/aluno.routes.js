const { Router } = require('express');
const alunoController = require('./aluno.controller');
const authenticate = require('../../middlewares/authenticate');
const authorize = require('../../middlewares/authorize');
const validate = require('../../middlewares/validate');
const { createAlunoSchema, updateAlunoSchema } = require('../../validators/aluno.validator');
const ROLES = require('../../constants/roles');

const router = Router();

// Garante que o usuário está logado
router.use(authenticate);

// 👇 ROTAS BLINDADAS: Apenas Admin, Secretaria e Professor podem listar e ver dados de alunos
router.get('/', authorize([ROLES.ADMIN, ROLES.SECRETARIA, ROLES.PROFESSOR]), alunoController.getAll);
router.get('/:id', authorize([ROLES.ADMIN, ROLES.SECRETARIA, ROLES.PROFESSOR]), alunoController.getById);
router.get('/:id/frequencia', authorize([ROLES.ADMIN, ROLES.SECRETARIA, ROLES.PROFESSOR]), alunoController.getFrequencia);
router.get('/:id/frequencia/disciplinas', authorize([ROLES.ADMIN, ROLES.SECRETARIA, ROLES.PROFESSOR]), alunoController.getFrequenciaDisciplinas);

// Aqui entram os validadores do Zod ANTES do controller
router.post('/', authorize([ROLES.ADMIN, ROLES.SECRETARIA]), validate(createAlunoSchema), alunoController.create);
router.patch('/:id', authorize([ROLES.ADMIN, ROLES.SECRETARIA]), validate(updateAlunoSchema), alunoController.update);
router.delete('/:id', authorize([ROLES.ADMIN, ROLES.SECRETARIA]), alunoController.delete);

module.exports = router;