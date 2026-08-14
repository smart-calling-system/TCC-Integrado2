const cron = require('node-cron');
const logger = require('../utils/logger');
const enviarEmail = require('../utils/email');
const presencaService = require('../modules/presencas/presenca.service');
const relatorioService = require('../modules/relatorios/relatorio.service');

const iniciarCronJobs = () => {
  // Configuração global para garantir o fuso horário de Brasília
  const cronOptions = { timezone: 'America/Sao_Paulo' };

  // 1. FALTAS AUTOMÁTICAS: Todo dia útil (Seg-Sex) às 23h00
  cron.schedule('0 23 * * 1-5', async () => {
    try {
      await presencaService.processarFaltasAutomaticasDoDia();
      logger.info('🤖 [CRON] Faltas automáticas processadas.');
    } catch (error) {
      logger.error('🚨 [CRON] Erro nas faltas automáticas: ' + error.message);
    }
  }, cronOptions);

  // 2. RELATÓRIO DA COZINHA: Todo dia útil (Seg-Sex) às 06h00
  cron.schedule('0 6 * * 1-5', async () => {
    try {
      const relatorio = await relatorioService.previsaoCozinha();
      const texto = `Bom dia equipe da Cozinha!\nPrevisão de alunos para hoje:\nManhã: ${relatorio.previsao.MANHA}\nTarde: ${relatorio.previsao.TARDE}\nNoite: ${relatorio.previsao.NOITE}\nTotal: ${relatorio.previsao.TOTAL}`;
      
      // 👇 Alterado para usar Variável de Ambiente
      const emailDestino = process.env.EMAIL_COZINHA || 'cozinha@senai.br';
      await enviarEmail(emailDestino, '🍽️ Previsão de Refeições do Dia', texto);
      
      logger.info('🤖 [CRON] Relatório da cozinha enviado.');
    } catch (error) {
      logger.error('🚨 [CRON] Erro no relatório da cozinha: ' + error.message);
    }
  }, cronOptions);

  // 3. ALERTA DE BAIXA FREQUÊNCIA: Toda Sexta-feira às 18h00
  cron.schedule('0 18 * * 5', async () => {
    try {
      const alunosEmRisco = await relatorioService.listarAlunosBaixaFrequencia(75);
      if (alunosEmRisco.length > 0) {
        const nomes = alunosEmRisco.map(a => `- ${a.nome} (${a.frequencia}%)`).join('\n');
        
        // 👇 Alterado para usar Variável de Ambiente
        const emailDestino = process.env.EMAIL_SECRETARIA || 'secretaria@senai.br';
        await enviarEmail(emailDestino, '⚠️ Alerta Semanal: Alunos em Risco de Retenção', `Os seguintes alunos estão com frequência abaixo de 75%:\n\n${nomes}`);
      }
      logger.info('🤖 [CRON] Alertas semanais de frequência enviados.');
    } catch (error) {
      logger.error('🚨 [CRON] Erro no alerta semanal: ' + error.message);
    }
  }, cronOptions);

  // 4. RELATÓRIO MENSAL CONSOLIDADO: Todo dia 28 às 08h00
  cron.schedule('0 8 28 * *', async () => {
    try {
      logger.info('🤖 [CRON] Iniciando Job: Geração de Relatório Mensal Consolidado...');
      
      const relatorio = await relatorioService.gerarRelatorioMensal();
      logger.info(`🤖 [CRON] Consolidação do Mês de ${relatorio.mes} gerada com sucesso.`);

      // 👇 Alterado para usar Variável de Ambiente
      const emailDestino = process.env.EMAIL_DIRETORIA || 'diretoria@senai.br';
      await enviarEmail(emailDestino, '📊 Fechamento Mensal de Frequência', 'O relatório consolidado do mês já está disponível no painel administrativo para exportação em PDF/CSV.');
      
      logger.info('🤖 [CRON] Aviso de relatório mensal enviado.');
    } catch (error) {
      logger.error('🚨 [CRON] Erro no aviso mensal: ' + error.message);
    }
  }, cronOptions);

  // 5. LIMPEZA DE LOGS DE AUDITORIA: Todo dia 1º do mês às 04h00 da manhã
  cron.schedule('0 4 1 * *', async () => {
    try {
      const dayjs = require('dayjs');
      const prisma = require('../database/client'); 
      
      const dataLimite = dayjs().subtract(3, 'month').toDate();
      
      const apagados = await prisma.auditLog.deleteMany({
        where: {
          criadoEm: {
            lt: dataLimite 
          }
        }
      });
      
      logger.info(`🤖 [CRON PURGE] Limpeza de auditoria: ${apagados.count} logs antigos foram apagados.`);
    } catch (error) {
      logger.error('🚨 [CRON PURGE] Erro ao limpar AuditLogs: ' + error.message);
    }
  }, cronOptions);

  logger.info('⏰ [CRON HUB] Todos os agendamentos ativados (Fuso: America/Sao_Paulo).');
};

module.exports = iniciarCronJobs;