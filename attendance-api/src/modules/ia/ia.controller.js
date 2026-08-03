const axios = require('axios');
const iaService = require('./ia.service');

class IaController {
  // 1. Monitoramento de Status (Health Check)
  async checkPythonStatus(req, res) {
    try {
      // Ping rápido de 3 segundos para ver se o Python responde
      const response = await axios.get(`${process.env.PYTHON_API_URL}/health`, { timeout: 3000 });
      return res.status(200).json({ 
        status: 'success', 
        message: 'Conexão com a IA estabelecida.', 
        python_data: response.data 
      });
    } catch (error) {
      return res.status(503).json({ 
        status: 'error', 
        message: 'Serviço de reconhecimento facial offline ou inacessível.' 
      });
    }
  }

  // 2. CORRIGIDO: Nome alterado para bater com o ia.routes.js
  async processarReconhecimento(req, res, next) {
    try {
      // CORREÇÃO: Adicionando o imagemHash na extração
      const { alunoId, turmaId, faceScore, imagemHash } = req.body;
      
      const iaService = require('./ia.service');
      const resultado = await iaService.processarReconhecimento({ 
        alunoId, 
        turmaId, 
        faceScore, 
        imagemHash // <-- Passando pra frente!
      });

      return res.status(200).json({ status: 'success', data: resultado });
    } catch (error) {
      next(error);
    }
  }

}

module.exports = new IaController();