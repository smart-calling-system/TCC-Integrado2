const { Router } = require('express');
const relatorioController = require('./relatorio.controller');
const authenticate = require('../../middlewares/authenticate');
const authorize = require('../../middlewares/authorize');
const ROLES = require('../../constants/roles'); // 👇 Voltamos pro seu jeito original, sem as chaves!

const router = Router();

// Apenas usuários logados e com nível administrativo podem tirar relatórios gerenciais
router.use(authenticate);
router.use(authorize([ROLES.ADMIN, ROLES.SECRETARIA, ROLES.COZINHA]));

// Endpoints exatamente como o Claude pediu
// 👇 Com o nome da função certinho batendo com o Controller!
router.get('/mensal', authorize([ROLES.ADMIN, ROLES.SECRETARIA]), relatorioController.getRelatorioMensal);
router.get('/cozinha', relatorioController.getCozinha);
router.get('/secretaria/ausentes', relatorioController.getAusentes);
router.get('/secretaria/baixa-frequencia', relatorioController.getBaixaFrequencia);

module.exports = router;