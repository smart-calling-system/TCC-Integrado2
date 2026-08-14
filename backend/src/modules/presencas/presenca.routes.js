const { Router } = require('express');
const presencaController = require('./presenca.controller');
const justificativaController = require('../justificativas/justificativa.controller'); 
const authenticate = require('../../middlewares/authenticate');
const authorize = require('../../middlewares/authorize');
const validate = require('../../middlewares/validate');
const { registrarPresencaSchema } = require('../../validators/presenca.validator');
const ROLES = require('../../constants/roles');
const presencaValidator = require('../../validators/presenca.validator');

const router = Router();

router.use(authenticate);

router.get('/', presencaController.getAll);
router.get('/hoje', presencaController.getHoje);
router.get('/aluno/:id', presencaController.getByAluno);
router.get('/turma/:id', presencaController.getByTurma);

// ROTA MANUAL (Com validador Zod injetado)
router.post('/', 
  authorize([ROLES.ADMIN, ROLES.SECRETARIA, ROLES.PROFESSOR]), 
  validate(registrarPresencaSchema), 
  presencaController.registrarPresencaManual
);

// ----------------------------------------------------
// 🔥 AS DUAS ROTAS NOVAS AQUI! (Sync e Saída)
// ----------------------------------------------------
router.post('/batch', authorize([ROLES.PROFESSOR, ROLES.ADMIN]), validate(presencaValidator.batchSchema), presencaController.sincronizarBatch);
router.patch('/:id/saida', authorize([ROLES.ADMIN, ROLES.SECRETARIA]), presencaController.registrarSaida);


module.exports = router;