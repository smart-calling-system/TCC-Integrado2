// ==========================================
// ⚙️ CONFIGURAÇÕES DA API (O QUARTEL GENERAL)
// ==========================================
const IP_SERVIDOR = '10.133.101.30'; // Mude AQUI no dia do TCC!
const NODE_API = `http://${IP_SERVIDOR}:3000/api/v1`;
const PYTHON_API = `http://${IP_SERVIDOR}:5000`;

// Como trancamos a rota de alunos por causa da LGPD, coloque um Token JWT válido aqui
const TOKEN = localStorage.getItem('token') || 'COLOQUE_SEU_TOKEN_GERADO_AQUI'; 

const video = document.getElementById('webcam');
const canvas = document.getElementById('canvas');
const btnCapturar = document.getElementById('btnCapturar');
const btnCadastrar = document.getElementById('btnCadastrar');
const alunoSelect = document.getElementById('alunoSelect');

const tabPresenca = document.getElementById('tabPresenca');
const tabCadastro = document.getElementById('tabCadastro');
const containerPresenca = document.getElementById('containerPresenca');
const containerCadastro = document.getElementById('containerCadastro');

const faceMask = document.getElementById('faceMask');
const laserLine = document.getElementById('laserLine');
const centerIcon = document.getElementById('centerIcon');
const statusIcon = document.getElementById('statusIcon');
const instructionText = document.getElementById('instructionText');
const subInstructionText = document.getElementById('subInstructionText');

const resultCard = document.getElementById('resultCard');
const resultTitle = document.getElementById('resultTitle');
const resultMsg = document.getElementById('resultMsg');
const resultIconBox = document.getElementById('resultIconBox');
const resultIcon = document.getElementById('resultIcon');

navigator.mediaDevices.getUserMedia({ video: true })
    .then(stream => { video.srcObject = stream; })
    .catch(err => { console.error("Erro na webcam:", err); });

function resetGeral() {
    btnCadastrar.disabled = false;
    alunoSelect.disabled = false;
    ocultarPopupResultado();
    resetFaceMask();
}

tabPresenca.addEventListener('click', () => {
    resetGeral();
    tabPresenca.className = "flex-1 py-3 rounded-xl text-xs font-bold transition-all duration-300 bg-slate-850 text-indigo-400 shadow-lg shadow-black/20 border border-slate-800/50 cursor-pointer";
    tabCadastro.className = "flex-1 py-3 rounded-xl text-xs font-bold transition-all duration-300 text-slate-400 hover:text-slate-200 cursor-pointer";
    containerPresenca.classList.remove('hidden');
    containerCadastro.classList.add('hidden');
    updateInstructions("Posicione seu rosto dentro do círculo", "Fique imóvel e olhe para a câmera");
});

tabCadastro.addEventListener('click', () => {
    resetGeral();
    tabCadastro.className = "flex-1 py-3 rounded-xl text-xs font-bold transition-all duration-300 bg-slate-850 text-emerald-400 shadow-lg shadow-black/20 border border-slate-800/50 cursor-pointer";
    tabPresenca.className = "flex-1 py-3 rounded-xl text-xs font-bold transition-all duration-300 text-slate-400 hover:text-slate-200 cursor-pointer";
    containerCadastro.classList.remove('hidden');
    containerPresenca.classList.add('hidden');
    updateInstructions("Módulo de Cadastro", "Selecione o aluno na lista para iniciar");
    
    // 👇 Puxa a lista de alunos do Node.js quando clica na aba!
    carregarAlunosDoBanco();
});

// ==========================================
// 📡 COMUNICAÇÃO COM O NODE.JS (POSTGRES)
// ==========================================
async function carregarAlunosDoBanco() {
    alunoSelect.innerHTML = '<option value="">CARREGANDO BANCO DE DADOS...</option>';
    try {
        const res = await fetch(`${NODE_API}/alunos`, {
            headers: { 'Authorization': `Bearer ${TOKEN}` }
        });
        const json = await res.json();
        alunoSelect.innerHTML = '<option value="">SELECIONE UM ALUNO</option>';
        
        if(json.data && json.data.dados) {
            json.data.dados.forEach(aluno => {
                const opt = document.createElement('option');
                opt.value = aluno.id; // O UUID real do Postgres
                opt.dataset.nome = aluno.nome; // O Nome pro Python
                opt.textContent = aluno.nome;
                alunoSelect.appendChild(opt);
            });
        }
    } catch (e) {
        alunoSelect.innerHTML = '<option value="">ERRO DE CONEXÃO COM O NODE</option>';
        console.error(e);
    }
}

// O resto das funções visuais do Pietro (updateInstructions, ativarLaser, resetFaceMask, exibirPopupResultado) continuam iguais!
function updateInstructions(main, sub, status = "") {
    instructionText.textContent = main;
    subInstructionText.textContent = sub;
    if (status === "sucesso") {
        instructionText.className = "text-sm font-black text-emerald-400 tracking-wide";
        subInstructionText.className = "text-xs text-emerald-500/80 font-semibold mt-1";
    } else if (status === "erro") {
        instructionText.className = "text-sm font-black text-rose-400 tracking-wide";
        subInstructionText.className = "text-xs text-rose-500/80 font-semibold mt-1";
    } else if (status === "scan") {
        instructionText.className = "text-sm font-black text-amber-400 tracking-wide animate-pulse";
        subInstructionText.className = "text-xs text-amber-500/80 font-semibold mt-1";
    } else {
        instructionText.className = "text-sm font-bold text-slate-200 tracking-wide";
        subInstructionText.className = "text-xs text-slate-500 mt-1 font-medium";
    }
}

function ativarLaser(cor) {
    laserLine.classList.remove('hidden');
    laserLine.className = `absolute left-0 right-0 h-0.5 bg-gradient-to-r from-transparent via-${cor}-400 to-transparent top-0 animate-[bounce_1.5s_infinite]`;
}

function resetFaceMask() {
    faceMask.className = "w-64 h-64 rounded-full border-4 border-dashed p-1 relative flex items-center justify-center bg-slate-950 shadow-2xl transition-all duration-500 overflow-hidden mask-idle";
    laserLine.classList.add('hidden');
    centerIcon.className = "absolute inset-0 flex items-center justify-center bg-slate-950/80 rounded-full opacity-0 pointer-events-none scale-90";
    video.classList.remove('blur-sm');
}

function exibirPopupResultado(titulo, msg, tipo) {
    resultCard.classList.remove('hidden');
    setTimeout(() => resultCard.classList.remove('scale-95', 'opacity-0'), 10);
    resultTitle.textContent = titulo;
    resultMsg.textContent = msg;
    
    const iconeAlvo = document.getElementById('resultIcon');
    if (tipo === 'sucesso') {
        resultCard.className = "mt-6 p-4 rounded-2xl border border-emerald-500/20 bg-emerald-950/20 text-emerald-400 backdrop-blur-xl transition-all duration-500";
        if (resultIconBox) resultIconBox.className = "w-12 h-12 rounded-xl flex items-center justify-center text-xl shadow-inner bg-emerald-500/10 text-emerald-400";
        if (iconeAlvo) iconeAlvo.className = "fa-solid fa-circle-check";
    } else {
        resultCard.className = "mt-6 p-4 rounded-2xl border border-rose-500/20 bg-rose-950/20 text-rose-400 backdrop-blur-xl transition-all duration-500";
        if (resultIconBox) resultIconBox.className = "w-12 h-12 rounded-xl flex items-center justify-center text-xl shadow-inner bg-rose-500/10 text-rose-400";
        if (iconeAlvo) iconeAlvo.className = "fa-solid fa-circle-xmark";
    }
}

function ocultarPopupResultado() {
    resultCard.classList.add('scale-95', 'opacity-0');
    setTimeout(() => resultCard.classList.add('hidden'), 300);
}

function dispararFlash() {
    const flash = document.createElement('div');
    flash.className = "fixed inset-0 bg-white z-50 opacity-90 transition-opacity duration-200 pointer-events-none";
    document.body.appendChild(flash);
    setTimeout(() => {
        flash.style.opacity = '0';
        setTimeout(() => flash.remove(), 200);
    }, 50);
}

const esperar = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// ==========================================
// 🚀 BOTÃO DE CHAMADA (BATE NO PYTHON)
// ==========================================
btnCapturar.addEventListener('click', async () => {
    resetFaceMask();
    ativarLaser('indigo');
    btnCapturar.disabled = true;

    updateInstructions("Reconhecendo...", "Aguarde o processamento da biometria", "scan");

    try {
        // 👇 Bate direto na API do Python (Porta 5000)
        const respostaHttp = await fetch(`${PYTHON_API}/reconhecer`, {
            method: 'POST',
            body: obterFormDataParaChamada()
        });

        const data = await respostaHttp.json();

        if (data.status === 'sucesso' && data.reconhecido === false) {
            updateInstructions("Não Identificado", "Tente posicionar o rosto novamente", "erro");
            exibirPopupResultado("Rosto não reconhecido", data.mensagem || "Não foi possível identificar.", "erro");
            return;
        }

        if (data.status === 'sucesso' && data.reconhecido === true) {
            updateInstructions("Identidade Confirmada", "Presença registrada", "sucesso");
            exibirPopupResultado("Presença Confirmada", `Aluno: ${data.aluno}`, "sucesso");
            return;
        }

        throw new Error(data.mensagem || "Resposta inesperada da API.");

    } catch (error) {
        console.error(error);
        updateInstructions("Erro de Conexão", "Servidor indisponível", "erro");
        exibirPopupResultado("Erro", error.message, "erro");
    } finally {
        btnCapturar.disabled = false;
    }
});

function obterFormDataParaChamada() {
    const context = canvas.getContext('2d');
    canvas.width = video.videoWidth || 640;
    canvas.height = video.videoHeight || 480;
    context.drawImage(video, 0, 0, canvas.width, canvas.height);
    
    const dataUrl = canvas.toDataURL('image/jpeg');
    const blob = dataURItoBlob(dataUrl);
    const formData = new FormData();
    formData.append('file', blob, 'chamada.jpg');
    return formData;
}

function dataURItoBlob(dataURI) {
    const byteString = atob(dataURI.split(',')[1]);
    const mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];
    const ab = new ArrayBuffer(byteString.length);
    const ia = new Uint8Array(ab);
    for (let i = 0; i < byteString.length; i++) ia[i] = byteString.charCodeAt(i);
    return new Blob([ab], {type: mimeString});
}

// ==========================================
// 📸 BOTÃO DE CADASTRO 3D (PYTHON + POSTGRES)
// ==========================================
btnCadastrar.addEventListener('click', async () => {
    if (!alunoSelect.value) { 
        alert("Selecione um aluno da lista primeiro!"); 
        return; 
    }
    
    // Pega o UUID pro Node e o Nome pro Python!
    const alunoId = alunoSelect.value;
    const nomeOriginal = alunoSelect.options[alunoSelect.selectedIndex].dataset.nome;
    let nomeLimpo = nomeOriginal.normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/[^a-zA-Z0-9 ]/g, "").replace(/\s+/g, " ").trim().toUpperCase();

    btnCadastrar.disabled = true;
    alunoSelect.disabled = true;
    ocultarPopupResultado();
    resetFaceMask();

    faceMask.className = "w-64 h-64 rounded-full border-4 border-solid border-amber-500 p-1 relative flex items-center justify-center bg-slate-950 shadow-[0_0_25px_rgba(245,158,11,0.2)] transition-all duration-500 overflow-hidden";
    
    const etapas = [
        { num: "1", icone: "fa-user-gear", texto: "FOTO 1/3: OLHE DE FRENTE", sub: "Fique de frente para a câmera" },
        { num: "2", icone: "fa-arrow-left", texto: "FOTO 2/3: GIRE PARA A ESQUERDA", sub: "Vire o rosto para a esquerda" },
        { num: "3", icone: "fa-arrow-right", texto: "FOTO 3/3: GIRE PARA A DIREITA", sub: "Vire o rosto para a direita" }
    ];

    try {
        let formDataDaUltimaFoto = null;

        for (let i = 0; i < etapas.length; i++) {
            const etapa = etapas[i];
            statusIcon.className = `fa-solid ${etapa.icone} text-4xl text-amber-400`;
            centerIcon.className = "absolute inset-0 flex items-center justify-center bg-slate-950/80 rounded-full opacity-100 scale-100 transition-all duration-200";
            ativarLaser('laranja');

            for (let c = 3; c > 0; c--) {
                updateInstructions(etapa.texto, `${etapa.sub} em ${c}...`, "scan");
                await esperar(1000);
            }

            if (etapa.num === "3") {
                updateInstructions("SALVANDO NO BANCO DE DADOS...", "Avisando o servidor Node.js...", "scan");
            } else {
                updateInstructions(etapa.texto, "Capturando...", "scan");
            }

            centerIcon.className = "absolute inset-0 flex items-center justify-center bg-slate-950/80 rounded-full opacity-0 scale-75 transition-all duration-75 pointer-events-none";
            await esperar(200);
            dispararFlash();
            
            // 1. Manda a foto pro Python treinar a IA
            const resultadoImg = obterFormDataParaCadastro(nomeLimpo, etapa.num);
            let resposta = await fetch(`${PYTHON_API}/cadastrar`, { method: 'POST', body: resultadoImg.formDataParaPython }).then(r => r.json());
            
            if (resposta.status === 'erro') throw new Error(resposta.mensagem);

            // Guarda a última foto gerada para mandar pro Node!
            if(etapa.num === "3") {
                formDataDaUltimaFoto = resultadoImg.formDataParaNode;
            }
        }

        // 👇 2. O PULO DO GATO: As 3 fotos passaram no Python? Agora avisa o POSTGRES!
        const resNode = await fetch(`${NODE_API}/alunos/${alunoId}/foto`, { 
            method: 'POST', 
            headers: { 'Authorization': `Bearer ${TOKEN}` },
            body: formDataDaUltimaFoto 
        });

        if(!resNode.ok) throw new Error("O Python salvou, mas falhou ao gravar no Postgres.");

        resetFaceMask();
        updateInstructions("Mapeamento Completo!", "Perfil salvo com sucesso no banco de dados.", "sucesso");
        exibirPopupResultado("Cadastro Efetuado", `O aluno "${nomeOriginal}" foi sincronizado.`, "sucesso");

    } catch (error) {
        resetFaceMask();
        updateInstructions("Cadastro Cancelado", "Posição incorreta ou falha de rede", "erro");
        exibirPopupResultado("Erro no Scanner", error.message, "erro");
    } finally {
        btnCadastrar.disabled = false;
        alunoSelect.disabled = false;
        alunoSelect.value = "";
    }
});

function obterFormDataParaCadastro(nome, numero) {
    const context = canvas.getContext('2d');
    canvas.width = video.videoWidth || 640;
    canvas.height = video.videoHeight || 480;
    context.drawImage(video, 0, 0, canvas.width, canvas.height);
    
    const blob = dataURItoBlob(canvas.toDataURL('image/jpeg'));

    // Monta os dados para o Python (ele exige 'nome', 'numero_foto' e 'file')
    const fdPython = new FormData();
    fdPython.append('nome', nome);
    fdPython.append('numero_foto', numero);
    fdPython.append('file', blob, `scan_${numero}.jpg`);

    // Monta os dados para o Node.js (o Multer lá exige apenas o campo 'foto')
    const fdNode = new FormData();
    fdNode.append('foto', blob, 'foto_treinamento.jpg');

    return { formDataParaPython: fdPython, formDataParaNode: fdNode };
}