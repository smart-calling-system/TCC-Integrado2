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
      throw new AppError('Esta conta foi desativada. Procure a administração.', 403);
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

  // Adicione dentro do seu AuthService:
  async obterPerfil(usuarioId) {
    const AppError = require('../../utils/AppError');
    const authRepository = require('./auth.repository');

    // 👇 Usando o repositório que estava abandonado!
    const usuario = await authRepository.findById(usuarioId);

    if (!usuario) {
      throw new AppError('Usuário não encontrado.', 404);
    }

    // Removendo a senha da resposta por segurança
    const { senha, ...dadosSeguros } = usuario;
    return dadosSeguros;
  }

  // 👇 1. Simulação do envio de e-mail (Salva horas de TCC)
  async recuperarSenha(email) {
    console.log(`[SISTEMA] Simulação: E-mail de redefinição solicitado para: ${email}`);
    return true; 
  }

  // 👇 2. Troca de senha real com criptografia
  async trocarSenha(usuarioId, senhaAtual, novaSenha) {
    const bcrypt = require('bcrypt'); // ou bcryptjs, dependendo do que usou
    const prisma = require('../../database/client');

    const usuario = await prisma.usuario.findUnique({ where: { id: usuarioId } });
    if (!usuario) throw new Error('Usuário não encontrado');

    const senhaValida = await bcrypt.compare(senhaAtual, usuario.senha);
    if (!senhaValida) {
      throw new Error('Senha atual incorreta');
    }

    const novaSenhaHash = await bcrypt.hash(novaSenha, 10);
    await prisma.usuario.update({
      where: { id: usuarioId },
      data: { senha: novaSenhaHash }
    });
    
    return true;
  }

  // Logout persistido no Banco via Prisma
  async logout(token) {
    if (!token) return;

    const decoded = jwt.decode(token);

    if (decoded && decoded.exp) {
      const expiresAt = new Date(decoded.exp * 1000);

      try {
        await prisma.jwtBlacklist.create({
          data: {
            token,
            expiresAt
          }
        });
      } catch (error) {
        // Se o token já tiver sido deslogado anteriormente (erro de Unique constraint P2002), ignora suavemente
        if (error.code !== 'P2002') {
          throw error;
        }
      }
    }

    return { message: 'Logout realizado com sucesso.' };
  }
}

module.exports = new AuthService();