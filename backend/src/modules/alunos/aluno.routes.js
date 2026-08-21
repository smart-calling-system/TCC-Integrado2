const { Router } = require('express');
const alunoController = require('./aluno.controller');
const authenticate = require('../../middlewares/authenticate');
const authorize = require('../../middlewares/authorize');
const validate = require('../../middlewares/validate');
const { createAlunoSchema, updateAlunoSchema } = require('../../validators/aluno.validator');
const ROLES = require('../../constants/roles');
const upload = require('../../middlewares/upload');

const router = Router();

// 👇 CADEADO GLOBAL ATIVADO: Tudo abaixo daqui precisa de Token!
router.use(authenticate);

// 👇 CORREÇÃO 1 (LGPD): A Rota que antes era livre agora exige Autenticação e Cargo!
router.get('/', authorize([ROLES.ADMIN, ROLES.SECRETARIA, ROLES.PROFESSOR]), alunoController.getAll);

// Rota de checagem
router.get('/check-ra/:ra', alunoController.checkRa.bind(alunoController));

// 👇 ROTAS BLINDADAS: Apenas Admin, Secretaria e Professor podem ver dados específicos e alterar
router.get('/:id', authorize([ROLES.ADMIN, ROLES.SECRETARIA, ROLES.PROFESSOR]), alunoController.getById);
router.get('/:id/frequencia', authorize([ROLES.ADMIN, ROLES.SECRETARIA, ROLES.PROFESSOR]), alunoController.getFrequencia);
router.get('/:id/frequencia/disciplinas', authorize([ROLES.ADMIN, ROLES.SECRETARIA, ROLES.PROFESSOR]), alunoController.getFrequenciaDisciplinas);
router.post('/:id/foto', authorize([ROLES.ADMIN, ROLES.SECRETARIA]), upload.single('foto'), alunoController.uploadFoto);

// Aqui entram os validadores do Zod ANTES do controller
router.post('/', authorize([ROLES.ADMIN, ROLES.SECRETARIA]), validate(createAlunoSchema), alunoController.create);
router.patch('/:id', authorize([ROLES.ADMIN, ROLES.SECRETARIA]), validate(updateAlunoSchema), alunoController.update);
router.delete('/:id', authorize([ROLES.ADMIN, ROLES.SECRETARIA]), alunoController.delete);
router.delete('/:id/lgpd', authorize([ROLES.ADMIN]), alunoController.exclusaoLGPD);

module.exports = router;