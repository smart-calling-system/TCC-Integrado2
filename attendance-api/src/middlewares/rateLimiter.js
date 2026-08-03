const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: process.env.RATE_LIMIT_WINDOW_MS || 15 * 60 * 1000, // Usa do .env ou 15 min padrão
  max: process.env.RATE_LIMIT_MAX || 100, // Usa do .env ou 100 padrão
  message: {
    status: 'error',
    message: 'Muitas requisições feitas a partir deste IP. Tente novamente mais tarde.'
  }
});

module.exports = limiter;