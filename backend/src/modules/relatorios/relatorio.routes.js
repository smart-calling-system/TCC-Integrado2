const { Router } = require('express');
const relatorioController = require('./relatorio.controller');
const authenticate = require('../../middlewares/authenticate');
const authorize = require('../../middlewares/authorize');
const ROLES = require('../../constants/roles'); 

const router = Router();

// 👇 Mantemos apenas a exigência de estar logado globalmente
router.use(authenticate);

// 👇 Agora cada rota tem o seu próprio "segurança na porta"

// Apenas Admin e Secretaria
router.get('/mensal', authorize([ROLES.ADMIN, ROLES.SECRETARIA]), relatorioController.getRelatorioMensal);

// Cozinha, Admin e Secretaria podem ver a listagem de merenda
router.get('/cozinha', authorize([ROLES.ADMIN, ROLES.SECRETARIA, ROLES.COZINHA]), relatorioController.getCozinha);

// 👇 ROTAS BLINDADAS! A Cozinha não entra mais aqui!
router.get('/secretaria/ausentes', authorize([ROLES.ADMIN, ROLES.SECRETARIA]), relatorioController.getAusentes);
router.get('/secretaria/baixa-frequencia', authorize([ROLES.ADMIN, ROLES.SECRETARIA]), relatorioController.getBaixaFrequencia);

module.exports = router;