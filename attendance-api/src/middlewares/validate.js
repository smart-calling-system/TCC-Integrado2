const AppError = require('../utils/AppError');

// Melhoria: Aceitar não apenas o body, mas 'query' ou 'params' (se especificado)
// O padrão ainda é validar o body caso nada seja passado
const validate = (schema, property = 'body') => (req, res, next) => {
  try {
    // 1. Valida e sanitiza os dados
    // O Zod retorna os dados limpos (parse), convertendo tipos quando necessário
    const validData = schema.parse(req[property]);
    
    // 2. Substitui os dados brutos da requisição pelos dados validados/limpos pelo Zod
    req[property] = validData;
    
    next();
  } catch (error) {
    // Verifica se o erro veio da validação do Zod
    if (error.issues) {
      const mensagensErro = error.issues.map((issue) => {
        const campo = issue.path.length > 0 ? `${issue.path.join('.')} - ` : '';
        return `${campo}${issue.message}`;
      });

      // Retorna 400 Bad Request direto, não precisa instanciar AppError aqui, 
      // já que a formatação é muito específica e imediata pro front-end
      return res.status(400).json({
        status: 'error',
        message: 'Falha na validação dos dados enviados.',
        erros: mensagensErro
      });
    }
    
    // Se não for do Zod, repassa pro AppError / Error Handler Global
    next(error);
  }
};

module.exports = validate;