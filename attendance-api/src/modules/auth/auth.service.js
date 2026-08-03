const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { promisify } = require('util');
const prisma = require('../../database/client');
const authConfig = require('../../config/auth.config');
const AppError = require('../../utils/AppError');

class AuthService {
  // Função auxiliar interna para não repetir código
  _gerarTokens(usuario) {
    const token = jwt.sign({ id: usuario.id, role: usuario.role }, authConfig.secret, {
      expiresIn: authConfig.expiresIn
    });

    const refreshToken = jwt.sign({ id: usuario.id }, authConfig.refreshSecret, {
      expiresIn: authConfig.refreshExpiresIn
    });

    return { token, refreshToken };
  }

  async login(email, senha) {
    // 1. Busca o usuário
    const usuario = await prisma.usuario.findUnique({ where: { email } });
    
    if (!usuario) {
      throw new AppError('Credenciais inválidas.', 401);
    }

    // 2. Trava de segurança: Usuário inativo não entra!
    if (!usuario.ativo) {
      throw new AppError('Esta conta foi desativada. Procure a administração.', 403); // 403 = Forbidden
    }

    // 3. Verifica a senha uma única vez
    const senhaValida = await bcrypt.compare(senha, usuario.senha);
    if (!senhaValida) {
      throw new AppError('Credenciais inválidas.', 401);
    }

    // 4. Gera e devolve os tokens
    const { token, refreshToken } = this._gerarTokens(usuario);

    return {
      usuario: { id: usuario.id, nome: usuario.nome, email: usuario.email, role: usuario.role },
      token,
      refreshToken
    };
  }

  async renovarToken(tokenAntigo) {
    if (!tokenAntigo) {
      throw new AppError('Refresh Token não fornecido.', 401);
    }

    try {
      // Verifica se o refresh token é válido e ainda não expirou
      const decoded = await promisify(jwt.verify)(tokenAntigo, authConfig.refreshSecret);

      // Busca o usuário de novo para garantir que ele não foi deletado
      const usuario = await prisma.usuario.findUnique({ where: { id: decoded.id } });

      if (!usuario) {
        throw new AppError('Usuário não encontrado.', 401);
      }

      // Trava extra: Vai que o usuário foi desativado enquanto o token antigo ainda era válido?
      if (!usuario.ativo) {
        throw new AppError('Sua conta foi desativada. Acesso negado.', 403);
      }

      // Devolve um novo par de tokens
      return this._gerarTokens(usuario);
    } catch (error) {
      throw new AppError('Refresh Token inválido ou expirado. Faça login novamente.', 401);
    }
  }

  // Adicionando um logout limpo para o controller não quebrar (Correção 5.5)
  async logout() {
    // Sem escrever no disco!
    // Numa arquitetura stateless (JWT), o front-end simplesmente apaga o token da tela do celular/navegador.
    return { message: 'Logout processado com sucesso. Token invalidado no cliente.' };
  }
}

module.exports = new AuthService();