const { Router } = require('express');
const authController = require('./auth.controller');
const validate = require('../../middlewares/validate');
const { loginSchema } = require('../../validators/auth.validator');
const authenticate = require('../../middlewares/authenticate'); // <--- OLHA A PEÇA QUE FALTAVA AQUI!

const router = Router();

router.post('/login', validate(loginSchema), authController.login);

// Nova rota para o Miguel bater quando o Token de Acesso morrer
router.post('/refresh', authController.refresh);

// Agora a rota conhece o middleware de proteção!
router.post('/logout', authenticate, authController.logout);

// 👇 NOVA ROTA: Retorna os dados do usuário atualmente logado
router.get('/me', authenticate, authController.me);

// Rota pública
router.post('/recuperar-senha', authController.recuperarSenha.bind(authController));

// Rota protegida (precisa do middleware de validação do token JWT)
router.post('/trocar-senha', authenticate, authController.trocarSenha.bind(authController));

module.exports = router;