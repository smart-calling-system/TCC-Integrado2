const prisma = require('../../database/client');

class AuthRepository {
  // Busca o usuário pelo e-mail
  async findUserByEmail(email) {
    return await prisma.usuario.findUnique({
      where: { email }
    });
  }

  // 👇 O MÉTODO NOVO QUE O AUDITOR COBROU! Resolvendo o bug do /auth/me
  async findById(id) {
    return await prisma.usuario.findUnique({
      where: { id: id },
      // Omitindo a senha por segurança ao retornar o perfil
      select: {
        id: true,
        nome: true,
        email: true,
        role: true,
        ativo: true,
        criadoEm: true
      }
    });
  }
}

module.exports = new AuthRepository();