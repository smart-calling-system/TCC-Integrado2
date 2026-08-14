const dayjs = require('dayjs');
const utc = require('dayjs/plugin/utc');
const timezone = require('dayjs/plugin/timezone');

// Estende o dayjs com os plugins de fuso horário
dayjs.extend(utc);
dayjs.extend(timezone);

// Trava o relógio do servidor no fuso de Brasília, independente de onde o Node.js for hospedado (ex: Render)
dayjs.tz.setDefault('America/Sao_Paulo');

/**
 * Utilitário para centralizar a manipulação de datas na aplicação.
 */
class DateHelpers {
  /**
   * Retorna a data e hora atual no fuso do Brasil.
   */
  static agora() {
    return dayjs.tz().toDate();
  }

  /**
   * Retorna o exato primeiro segundo do dia de hoje (00:00:00) no fuso do Brasil.
   */
  static inicioDoDiaAtual() {
    return dayjs.tz().startOf('day').toDate();
  }

  /**
   * Retorna o exato último segundo do dia de hoje (23:59:59) no fuso do Brasil.
   */
  static fimDoDiaAtual() {
    return dayjs.tz().endOf('day').toDate();
  }

  /**
   * Formata uma data do banco para o padrão brasileiro de exibição no Dashboard.
   * Exemplo: '31/12/2026'
   */
  static formatarDataBr(data) {
    return dayjs.tz(data).format('DD/MM/YYYY');
  }

  /**
   * Formata data e hora para o padrão brasileiro completo.
   * Exemplo: '31/12/2026 14:30:00'
   */
  static formatarDataHoraBr(data) {
    return dayjs.tz(data).format('DD/MM/YYYY HH:mm:ss');
  }

  /**
   * Retorna a data atual marcando o horário limite da cozinha (10:00 AM) no fuso do Brasil.
   */
  static horarioDeCorteCozinha() {
    return dayjs.tz().hour(10).minute(0).second(0).toDate();
  }
}

module.exports = DateHelpers;