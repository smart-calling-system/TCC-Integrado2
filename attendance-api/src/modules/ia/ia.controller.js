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

  // 2. Processa o reconhecimento vindo do Python
  async processarReconhecimento(req, res, next) {
    try {
      // Extraindo os dados do payload
      const { alunoId, turmaId, faceScore, imagemHash } = req.body;
      
      // Usa o iaService importado no topo do arquivo diretamente
      const resultado = await iaService.processarReconhecimento({ 
        alunoId, 
        turmaId, 
        faceScore, 
        imagemHash 
      });

      return res.status(200).json({ status: 'success', data: resultado });
    } catch (error) {
      next(error);
    }
  }

}

module.exports = new IaController();