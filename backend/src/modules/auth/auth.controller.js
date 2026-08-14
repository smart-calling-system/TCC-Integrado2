const authService = require('./auth.service');

class AuthController {
  async login(req, res, next) {
    try {
      const { email, senha } = req.body;
      const result = await authService.login(email, senha);

      return res.status(200).json({
        status: 'success',
        data: result
      });
    } catch (error) {
      next(error); 
    }
  }
  
  async refresh(req, res, next) {
    try {
      const { refreshToken } = req.body;
      const tokens = await authService.renovarToken(refreshToken);
      
      return res.status(200).json({ status: 'success', data: tokens });
    } catch (error) {
      next(error);
    }
  }

  async me(req, res, next) {
    try {
      // 👇 BUG MÉDIO CORRIGIDO: Passando a bola para o Service! A arquitetura agradece.
      const usuarioId = req.usuario.id;
      const usuario = await authService.obterPerfil(usuarioId);

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
        await authService.logout(token);
      }
      
      return res.status(200).json({ message: 'Logout realizado com sucesso.' });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new AuthController();