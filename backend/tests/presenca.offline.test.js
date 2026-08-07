const request = require('supertest');

// 👇 A MÁGICA AQUI: Mockamos o middleware ANTES de carregar o app.js.
// Isso engana o Express, fazendo-o pular a verificação do JWT e injetando um usuário válido.
jest.mock('../src/middlewares/authenticate', () => (req, res, next) => {
  req.usuario = { id: 'fake-admin-123', role: 'ADMIN' }; // Passa pelo 'authorize' se houver
  next(); 
});

const app = require('../src/app'); // Caminho para o seu app.js
const presencaRepository = require('../src/modules/presencas/presenca.repository');

// Finge (Mock) que o banco de dados é falso para não sujar o banco real
jest.mock('../src/modules/presencas/presenca.repository');

describe('Sincronização Offline de Presenças', () => {
  it('Deve ignorar presenças duplicadas no mesmo dia (Bug 3.3 corrigido)', async () => {
    
    // Simulamos que o Repository retornou que 1 foi inserido e 1 foi ignorado
    presencaRepository.sincronizarBatchOffline.mockResolvedValue({
      inseridos: 1,
      ignorados: 1,
      erros: 0
    });

    const mockLote = [
      { alunoId: "123", turmaId: "456", dataHora: "2026-08-03T10:00:00.000Z", status: "PRESENTE" },
      { alunoId: "123", turmaId: "456", dataHora: "2026-08-03T10:00:00.000Z", status: "PRESENTE" } // Duplicado!
    ];

    const response = await request(app)
      .post('/api/v1/presencas/batch') // Sua rota offline
      .set('Authorization', 'Bearer SEU_TOKEN_MOCK_AQUI')
      .send({ lote: mockLote });

    expect(response.status).toBe(200);
    expect(response.body.resumo.inseridos).toBe(1);
    expect(response.body.resumo.ignorados).toBe(1);
  });
});