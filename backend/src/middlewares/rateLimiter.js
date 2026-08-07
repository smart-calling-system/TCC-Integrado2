const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS, 10) || 15 * 60 * 1000, 
  max: parseInt(process.env.RATE_LIMIT_MAX, 10) || 100, 
  
  keyGenerator: (req) => {
    if (req.usuario && req.usuario.id) {
      return req.usuario.id;
    }
    return req.ip;
  },

  // 👇 A MÁGICA AQUI: Desliga a validação rigorosa de IPv6
  validate: {
    keyGeneratorIpFallback: false
  },

  message: {
    status: 'error',
    message: 'Muitas requisições feitas a partir deste usuário ou IP. Tente novamente mais tarde.'
  }
});

module.exports = limiter;