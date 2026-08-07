const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Iniciando o seed do banco de dados...');

  // ==========================================
  // 1. CRIANDO A TURMA 3 A
  // ==========================================
  console.log('🏫 Verificando a Turma 3 A...');
  
  // Busca a turma para não duplicar se você rodar o seed duas vezes
  let turma3A = await prisma.turma.findFirst({
    where: { nome: '3 A', anoLetivo: 2026 }
  });

  if (!turma3A) {
    turma3A = await prisma.turma.create({
      data: {
        nome: '3 A',
        anoLetivo: 2026,
        turno: 'MANHA', // Você pode alterar para TARDE ou NOITE se precisar
        ativo: true
      }
    });
    console.log('✅ Turma 3 A (2026) criada com sucesso!');
  } else {
    console.log('✅ Turma 3 A já existia no banco.');
  }

  // ==========================================
  // 2. CRIANDO E MATRICULANDO OS ALUNOS
  // ==========================================
  const alunosNomes = [
    "ANA BEATRIZ PEREIRA DOS SANTOS",
    "ANA CLARA DE CARVALHO NASCIMENTO",
    "ANNA LUIZA GOMES SILVA",
    "AQUILES LUIZ NUNES BASTOS",
    "CAINAN BASTOS DA SILVA",
    "DERICK LUIZ CAETANO MIGUEL",
    "ESTELLA DE ALMEIDA ROSA",
    "FRANCISCO GABRIEL DE OLIVEIRA PASSOS",
    "GLORIA MARIA MOURA BRUNO DE CARVALHO",
    "HELOISA FRANCISCO DIONISIO",
    "HENRY GUIMARÃES ALVES",
    "INGRID RANI FORTUNATO DOS SANTOS",
    "JOÃO GABRIEL DA SILVA PEREIRA",
    "JOÃO PEDRO DE AQUINO HONORATO",
    "JOÃO PEDRO MARTINS LIGABO",
    "JOÃO PEDRO RODRIGUES DOS SANTOS",
    "JUAN PEDRO DE MIRANDA",
    "JULIA DE MOURA LOPES DA SILVA",
    "MARCOS VINICIUS SORIANO GUATURA",
    "MARIA EDUARDA FELIX INOCENCIO",
    "MARIA ISABEL DA SILVA COSTA BORGES",
    "MARIANA DE SOUZA MARTINS DOS SANTOS",
    "MARIANA SILVA DE ANDRADE",
    "MIGUEL ARAUJO DE GODOI FREITAS",
    "NATHALIA ALVES ABDO REZENDE",
    "NEIL LOPES JOÃO FILHO",
    "NICOLAS FELIPE DO NASCIMENTO ROSA",
    "PIETRO HENRIQUE GOMES DE ANDRADE",
    "SAMUEL RODRIGUES COSTA FREIRE",
    "VICTOR HUGO DO CARMO DE JESUS"
  ];

  console.log(`👨‍🎓 Inserindo e matriculando ${alunosNomes.length} alunos na Turma 3 A...`);

  for (let i = 0; i < alunosNomes.length; i++) {
    const nome = alunosNomes[i];
    const numeroChamada = (i + 1).toString().padStart(3, '0');
    const matriculaGerada = `2026${numeroChamada}`;

    // Passo A: Cria ou Atualiza o Aluno
    const aluno = await prisma.aluno.upsert({
      where: { matricula: matriculaGerada },
      update: { nome: nome },
      create: {
        nome: nome,
        matricula: matriculaGerada,
        ativo: true
      }
    });

    // Passo B: Cria o Vínculo (Matrícula) na tabela TurmaAluno
    await prisma.turmaAluno.upsert({
      where: {
        alunoId_turmaId: {
          alunoId: aluno.id,
          turmaId: turma3A.id
        }
      },
      update: { ativo: true },
      create: {
        alunoId: aluno.id,
        turmaId: turma3A.id,
        ativo: true
      }
    });
  }

  console.log('✅ Todos os alunos foram cadastrados e vinculados à Turma 3 A com sucesso!');
}

main()
  .catch((e) => {
    console.error('🚨 Erro ao rodar o seed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });