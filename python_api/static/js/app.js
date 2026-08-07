const video = document.getElementById('webcam');
const canvas = document.getElementById('canvas');
const btnCapturar = document.getElementById('btnCapturar');
const btnCadastrar = document.getElementById('btnCadastrar');
const nomeAlunoInput = document.getElementById('nomeAluno');

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
    .catch(err => { console.error(err); });

nomeAlunoInput.addEventListener('input', () => { nomeAlunoInput.value = nomeAlunoInput.value.toUpperCase(); });

function resetGeral() {
    btnCadastrar.disabled = false;
    nomeAlunoInput.disabled = false;
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
    updateInstructions("Módulo de Cadastro", "Insira o nome do aluno para iniciar");
});

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

// CHAMADA
btnCapturar.addEventListener('click', async () => {
    resetFaceMask();
    ativarLaser('indigo');
    btnCapturar.disabled = true;

    updateInstructions("Reconhecendo...", "Aguarde o processamento da biometria", "scan");

    if (resultIcon) {
        resultIcon.className = "fa-solid fa-circle-notch animate-spin";
    }
    if (resultIconBox) {
        resultIconBox.className = "w-12 h-12 rounded-xl flex items-center justify-center text-xl shadow-inner text-indigo-400";
    }

    try {
        const respostaHttp = await fetch('/reconhecer', {
            method: 'POST',
            body: obterFormDataParaChamada()
        });

        let data;
        try {
            data = await respostaHttp.json();
        } catch (_) {
            throw new Error(`A API respondeu em formato inválido (HTTP ${respostaHttp.status}).`);
        }

        // Rosto não reconhecido: não é erro de conexão, apenas tentativa sem identificação.
        if (data.status === 'sucesso' && data.reconhecido === false) {
            updateInstructions("Não Identificado", "Tente posicionar o rosto novamente", "erro");
            exibirPopupResultado("Rosto não reconhecido", data.mensagem || "Não foi possível identificar o aluno.", "erro");
            return;
        }

        // O Python reconheceu o aluno, mas o Node não confirmou o registro.
        if (data.status === 'erro') {
            const reconheceu = data.reconhecido === true;
            updateInstructions(
                reconheceu ? "Identidade Confirmada" : "Erro no Reconhecimento",
                reconheceu ? "Falha ao registrar no sistema escolar" : "Não foi possível concluir a chamada",
                "erro"
            );
            exibirPopupResultado(
                reconheceu ? "Presença não registrada" : "Erro",
                data.mensagem || "Não foi possível concluir a operação.",
                "erro"
            );
            return;
        }

        if (data.status === 'sucesso' && data.reconhecido === true) {
            switch (data.evento) {
                case 'ENTRADA_REGISTRADA':
                    updateInstructions("Entrada Confirmada", "Presença registrada no banco", "sucesso");
                    exibirPopupResultado("Presença Confirmada", `Bem-vindo, ${data.aluno}!`, "sucesso");
                    break;

                case 'SAIDA_REGISTRADA':
                    updateInstructions("Saída Confirmada", "Registro atualizado no banco", "sucesso");
                    exibirPopupResultado("Saída Confirmada", `Até mais, ${data.aluno}!`, "sucesso");
                    break;

                case 'SAIDA_ANTECIPADA_REGISTRADA':
                    updateInstructions("Saída Antecipada", "Registro atualizado no banco", "sucesso");
                    exibirPopupResultado("Saída Registrada", `${data.aluno}: saída antecipada registrada.`, "sucesso");
                    break;

                case 'IGNORADO':
                    updateInstructions("Chamada já concluída", "Nenhum novo registro foi criado", "sucesso");
                    exibirPopupResultado("Registro já concluído", data.mensagem || `${data.aluno} já concluiu o ciclo de hoje.`, "sucesso");
                    break;

                default:
                    if (data.presenca_registrada) {
                        updateInstructions("Registro Confirmado", "Backend confirmou a operação", "sucesso");
                        exibirPopupResultado("Registro Confirmado", data.mensagem || `Aluno: ${data.aluno}`, "sucesso");
                    } else {
                        updateInstructions("Reconhecimento concluído", "Nenhum novo registro foi criado", "sucesso");
                        exibirPopupResultado("Reconhecimento concluído", data.mensagem || `Aluno: ${data.aluno}`, "sucesso");
                    }
            }
            return;
        }

        throw new Error(data.mensagem || "Resposta inesperada da API.");

    } catch (error) {
        console.error(error);
        updateInstructions("Erro de Conexão", "Servidor indisponível", "erro");
        exibirPopupResultado("Erro", error.message || "Não foi possível se comunicar com o sistema.", "erro");
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

// CADASTRO AUTOMÁTICO 
btnCadastrar.addEventListener('click', async () => {
    let nomeOriginal = nomeAlunoInput.value.trim();
    if (!nomeOriginal) { alert("Insira o nome completo."); return; }
    let nomeLimpo = nomeOriginal.normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/[^a-zA-Z0-9 ]/g, "").replace(/\s+/g, " ").trim();

    btnCadastrar.disabled = true;
    nomeAlunoInput.disabled = true;
    ocultarPopupResultado();
    resetFaceMask();

    faceMask.className = "w-64 h-64 rounded-full border-4 border-solid border-amber-500 p-1 relative flex items-center justify-center bg-slate-950 shadow-[0_0_25px_rgba(245,158,11,0.2)] transition-all duration-500 overflow-hidden";
    
    const etapas = [
        { num: "1", icone: "fa-user-gear", texto: "FOTO 1/3: OLHE DE FRENTE", sub: "Fique de frente para a câmera" },
        { num: "2", icone: "fa-arrow-left", texto: "FOTO 2/3: GIRE PARA A ESQUERDA", sub: "Vire o rosto para a esquerda" },
        { num: "3", icone: "fa-arrow-right", texto: "FOTO 3/3: GIRE PARA A DIREITA", sub: "Vire o rosto para a direita" }
    ];

    try {
        for (let i = 0; i < etapas.length; i++) {
            const etapa = etapas[i];
            statusIcon.className = `fa-solid ${etapa.icone} text-4xl text-amber-400`;
            centerIcon.className = "absolute inset-0 flex items-center justify-center bg-slate-950/80 rounded-full opacity-100 scale-100 transition-all duration-200";
            ativarLaser('laranja');

            for (let c = 3; c > 0; c--) {
                updateInstructions(etapa.texto, `${etapa.sub} em ${c}...`, "scan");
                await esperar(1000);
            }

            // Garante a troca síncrona do texto no milissegundo zero da terceira foto
            if (etapa.num === "3") {
                updateInstructions("SALVANDO NO BANCO DE DADOS...", "Processando perfil biométrico...", "scan");
            } else {
                updateInstructions(etapa.texto, "Capturando...", "scan");
            }

            centerIcon.className = "absolute inset-0 flex items-center justify-center bg-slate-950/80 rounded-full opacity-0 scale-75 transition-all duration-75 pointer-events-none";
            await esperar(200);

            dispararFlash();
            
            let resposta = await enviarFotoCadastro(nomeLimpo, etapa.num);
            
            if (resposta.status === 'erro') {
                throw new Error(resposta.mensagem);
            }
        }

        resetFaceMask();
        updateInstructions("Mapeamento Completo!", "Perfil biométrico salvo.", "sucesso");
        exibirPopupResultado("Cadastro Efetuado", `O aluno "${nomeLimpo}" foi registrado com sucesso.`, "sucesso");

    } catch (error) {
        resetFaceMask();
        updateInstructions("Cadastro Cancelado", "Posição incorreta detectada", "erro");
        exibirPopupResultado("Erro no Scanner", error.message, "erro");
    } finally {
        btnCadastrar.disabled = false;
        nomeAlunoInput.disabled = false;
        nomeAlunoInput.value = "";
    }
});

function enviarFotoCadastro(nome, numero) {
    const context = canvas.getContext('2d');
    canvas.width = video.videoWidth || 640;
    canvas.height = video.videoHeight || 480;
    context.drawImage(video, 0, 0, canvas.width, canvas.height);
    
    const dataUrl = canvas.toDataURL('image/jpeg');
    const blob = dataURItoBlob(dataUrl);

    const formData = new FormData();
    formData.append('nome', nome);
    formData.append('numero_foto', numero);
    formData.append('file', blob, `scan_${numero}.jpg`);

    return fetch('/cadastrar', { method: 'POST', body: formData })
        .then(res => res.json())
        .catch(() => { return { status: 'erro', mensagem: "Erro de conexão com o servidor." }; });
}