const authService = require('./auth.service');

class AuthController {
  // Função que o Express vai chamar quando bater na rota
  async login(req, res, next) {
    try {
      const { email, senha } = req.body;

      const result = await authService.login(email, senha);

      return res.status(200).json({
        status: 'success',
        data: result
      });
    } catch (error) {
      // Passa o erro para o nosso errorHandler global
      next(error); 
    }
  }
  
  async refresh(req, res, next) {
    try {
      // O frontend deve mandar o refresh token no corpo da requisição
      const { refreshToken } = req.body;
      const tokens = await authService.renovarToken(refreshToken);
      
      return res.status(200).json({ status: 'success', data: tokens });
    } catch (error) {
      next(error);
    }
  }

  // Adicione isso junto aos métodos de login, logout e refresh
  async me(req, res, next) {
    try {
      // O Prisma é chamado para buscar os dados frescos no banco
      const prisma = require('../../database/client'); 
      const usuarioId = req.usuario.id;

      const usuario = await prisma.usuario.findUnique({
        where: { id: usuarioId },
        select: {
          id: true,
          nome: true,
          email: true,
          role: true,
          ativo: true
          // 🔒 A senha ficou de fora de propósito!
        }
      });

      if (!usuario) {
        return res.status(404).json({ status: 'error', message: 'Usuário não encontrado.' });
      }

      return res.status(200).json({
        status: 'success',
        data: usuario
      });
    } catch (error) {
      next(error);
    }
  }

  async logout(req, res, next) {
    try {
      const authHeader = req.headers.authorization;
      
      if (authHeader) {
        const token = authHeader.split(' ')[1];
        
        // Passamos a responsabilidade de salvar no banco para o service
        await authService.logout(token);
      }
      
      return res.status(200).json({ message: 'Logout realizado com sucesso.' });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new AuthController();