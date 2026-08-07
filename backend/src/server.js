require('dotenv-safe').config();
const app = require('./app');
const logger = require('./utils/logger'); 
// 👇 1. Importa a função do arquivo index.js da pasta cron
const iniciarCronJobs = require('./cron'); 

const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
  logger.info(`🚀 Servidor rodando na porta ${PORT}`);
  logger.info(`🌍 Ambiente: ${process.env.NODE_ENV}`);
  
  // 👇 2. Executa a função logo depois que o servidor subir!
  iniciarCronJobs(); 
});

// Tratamento de interrupções para desligar o servidor de forma limpa (Graceful Shutdown)
process.on('SIGTERM', () => {
  logger.info('Sinal SIGTERM recebido. Desligando o servidor...');
  server.close(() => {
    logger.info('Processo finalizado.');
  });
});