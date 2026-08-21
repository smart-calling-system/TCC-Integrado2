from fastapi import FastAPI, UploadFile, File, Request, Form
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware

import face_recognition
import cv2
import numpy as np
import os
import json
import logging
import requests
import io

from PIL import Image, ImageOps  # 👇 A BLINDAGEM DO LUKA AQUI
from uuid import UUID
from dotenv import load_dotenv

load_dotenv()

# ============================================================
# CONFIGURAÇÃO GERAL
# ============================================================

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s"
)
logger = logging.getLogger("tcc-face")

app = FastAPI(
    title="API de Reconhecimento Facial - TCC",
    version="1.1.0"
)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PASTA_STATIC = os.path.join(BASE_DIR, "static")
PASTA_BANCO = os.path.join(BASE_DIR, "banco_alunos")
CAMINHO_MAPEAMENTO = os.path.join(BASE_DIR, "mapeamento_alunos.json")

for pasta in [PASTA_STATIC, PASTA_BANCO]:
    os.makedirs(pasta, exist_ok=True)

app.mount("/static", StaticFiles(directory=PASTA_STATIC), name="static")
templates = Jinja2Templates(directory=os.path.join(BASE_DIR, "templates"))

# CORS: útil caso o Miguel rode o Flutter também como Web durante os testes.
# No APK/mobile o CORS do navegador não se aplica.
cors_env = os.getenv(
    "CORS_ORIGINS",
    "http://localhost:3000,http://localhost:5173,http://localhost:8080"
)
origens_cors = [origem.strip() for origem in cors_env.split(",") if origem.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origens_cors,
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)

# ============================================================
# INTEGRAÇÃO COM O BACKEND NODE DO NEIL
# ============================================================

def normalizar_node_api_url(url: str) -> str:
    """
    Aceita tanto:
      http://localhost:3000
    quanto:
      http://localhost:3000/api/v1

    e sempre devolve uma base terminando em /api/v1.
    Isso evita o 404 que existia na integração anterior.
    """
    url = (url or "http://localhost:3000").strip().rstrip("/")
    if not url.endswith("/api/v1"):
        url = f"{url}/api/v1"
    return url

NODE_API_URL = normalizar_node_api_url(
    os.getenv("NODE_API_URL", "http://localhost:3000")
)
IA_API_KEY = (os.getenv("IA_API_KEY") or "").strip()
NODE_TIMEOUT_SEGUNDOS = float(os.getenv("NODE_TIMEOUT_SEGUNDOS", "10"))

# O backend do Neil usa 0.85 por padrão. O score abaixo é NORMALIZADO:
NODE_MIN_FACE_SCORE = float(os.getenv("NODE_MIN_FACE_SCORE", "0.85"))
NODE_MIN_FACE_SCORE = max(0.0, min(1.0, NODE_MIN_FACE_SCORE))

# ============================================================
# CONFIGURAÇÃO DO RECONHECIMENTO
# ============================================================

rostos_conhecidos_encodings = []
rostos_conhecidos_nomes = []

TOLERANCIA_RECONHECIMENTO = float(os.getenv("FACE_TOLERANCE", "0.46"))
MARGEM_MINIMA_CONFIANCA = float(os.getenv("FACE_MARGIN", "0.05"))
NUM_JITTERS_CADASTRO = int(os.getenv("FACE_NUM_JITTERS", "1"))

# ============================================================
# MAPEAMENTO ALUNO -> UUIDs DO POSTGRES
# ============================================================

def carregar_mapeamento():
    if not os.path.exists(CAMINHO_MAPEAMENTO):
        logger.warning("mapeamento_alunos.json não encontrado.")
        return {}

    try:
        with open(CAMINHO_MAPEAMENTO, "r", encoding="utf-8") as arquivo:
            dados = json.load(arquivo)
            return dados if isinstance(dados, dict) else {}
    except (json.JSONDecodeError, OSError) as erro:
        logger.error("Erro ao carregar mapeamento_alunos.json: %s", erro)
        return {}

def uuid_valido(valor) -> bool:
    try:
        UUID(str(valor))
        return True
    except (ValueError, TypeError, AttributeError):
        return False

def obter_mapeamento_aluno(nome_aluno):
    mapeamento = carregar_mapeamento()
    info = mapeamento.get(nome_aluno)

    if not info:
        return None, (
            f"Aluno '{nome_aluno}' foi reconhecido, mas não existe no "
            "mapeamento_alunos.json."
        )

    aluno_id = info.get("alunoId")
    turma_id = info.get("turmaId")

    if not uuid_valido(aluno_id) or not uuid_valido(turma_id):
        return None, (
            f"O mapeamento de '{nome_aluno}' ainda possui alunoId/turmaId inválido. "
            "Substitua pelos UUIDs reais do PostgreSQL do backend."
        )

    return {"alunoId": aluno_id, "turmaId": turma_id}, None

# ============================================================
# BANCO FACIAL LOCAL
# ============================================================

def carregar_banco_local():
    rostos_conhecidos_encodings.clear()
    rostos_conhecidos_nomes.clear()

    arquivos = os.listdir(PASTA_BANCO)
    if not arquivos:
        logger.info("Banco facial local vazio.")
        return

    logger.info("Carregando banco facial local...")

    for arquivo in arquivos:
        if not arquivo.lower().endswith((".jpg", ".jpeg", ".png")):
            continue

        caminho = os.path.join(PASTA_BANCO, arquivo)

        try:
            imagem = face_recognition.load_image_file(caminho)
            encodings = face_recognition.face_encodings(
                imagem,
                num_jitters=NUM_JITTERS_CADASTRO
            )

            if not encodings:
                logger.warning("Nenhum rosto utilizável em %s", arquivo)
                continue

            nome_base = os.path.splitext(arquivo)[0]
            partes = nome_base.rsplit("_", 1)
            nome_aluno = partes[0] if len(partes) == 2 else nome_base

            rostos_conhecidos_encodings.append(encodings[0])
            rostos_conhecidos_nomes.append(nome_aluno)
            logger.info("Face carregada: %s", arquivo)

        except Exception as erro:
            logger.exception("Erro ao carregar %s: %s", arquivo, erro)

    logger.info("Banco facial carregado: %s fotos.", len(rostos_conhecidos_nomes))

carregar_banco_local()

# ============================================================
# ROTAS DE STATUS / INTERFACE LOCAL
# ============================================================

@app.get("/", response_class=HTMLResponse)
async def interface_teste(request: Request):
    return templates.TemplateResponse(request=request, name="index.html")

@app.get("/health")
async def health_check():
    mapeamento = carregar_mapeamento()
    return {
        "status": "ok",
        "servico": "python-face-api",
        "alunos_carregados": len(set(rostos_conhecidos_nomes)),
        "fotos_carregadas": len(rostos_conhecidos_nomes),
        "alunos_mapeados": len(mapeamento),
        "node_api_url": NODE_API_URL,
        "ia_api_key_configurada": bool(IA_API_KEY),
    }

@app.get("/health/node")
def health_node():
    """Teste rápido da ponte Python -> Node sem registrar presença."""
    url = f"{NODE_API_URL}/ia/health"

    try:
        resposta = requests.get(url, timeout=NODE_TIMEOUT_SEGUNDOS)
        try:
            corpo = resposta.json()
        except ValueError:
            corpo = resposta.text[:500]

        return {
            "status": "ok" if resposta.ok else "erro",
            "http_status": resposta.status_code,
            "url": url,
            "backend": corpo,
        }
    except requests.exceptions.Timeout:
        return {
            "status": "erro",
            "url": url,
            "mensagem": "Timeout ao tentar alcançar o backend Node."
        }
    except requests.exceptions.ConnectionError as erro:
        return {
            "status": "erro",
            "url": url,
            "mensagem": f"Não foi possível conectar ao backend Node: {erro}"
        }

# ============================================================
# CADASTRO FACIAL
# ============================================================

def limpar_fotos_parciais(nome_aluno):
    try:
        for numero in ["1", "2", "3"]:
            caminho = os.path.join(PASTA_BANCO, f"{nome_aluno}_{numero}.jpg")
            if os.path.exists(caminho):
                os.remove(caminho)
    except Exception as erro:
        logger.warning("Erro ao limpar fotos parciais: %s", erro)

def checar_nitidez(imagem_bgr, limite=80.0):
    cinza = cv2.cvtColor(imagem_bgr, cv2.COLOR_BGR2GRAY)
    variancia = cv2.Laplacian(cinza, cv2.CV_64F).var()
    return variancia >= limite

@app.post("/cadastrar")
async def cadastrar_aluno(
    nome: str = Form(...),
    numero_foto: str = Form(...),
    file: UploadFile = File(...)
):
    nome_limpo = " ".join(nome.strip().split()).upper()

    if numero_foto not in {"1", "2", "3"}:
        return {"status": "erro", "mensagem": "numero_foto deve ser 1, 2 ou 3."}

    try:
        conteudo = await file.read()
        
        # 🔥 INÍCIO DA BLINDAGEM MÁXIMA DO LUKA 🔥
        try:
            # 1. Lê os bytes via Pillow e corrige a rotação fantasma (EXIF) de celulares/tablets
            imagem_pil = Image.open(io.BytesIO(conteudo))
            imagem_pil = ImageOps.exif_transpose(imagem_pil)
            
            # 2. Força o formato RGB e garante que o bloco de memória seja contíguo (Isso evita o crash fatal do dlib)
            imagem_rgb_pil = imagem_pil.convert("RGB")
            imagem_array = np.array(imagem_rgb_pil)
            imagem_array = np.ascontiguousarray(imagem_array, dtype=np.uint8)
            
            # 3. Volta a imagem para o padrão BGR que o OpenCV ama e usa pro resto da lógica
            imagem_bgr = cv2.cvtColor(imagem_array, cv2.COLOR_RGB2BGR)
        except Exception as e:
            logger.warning(f"Erro na decodificação blindada: {e}")
            imagem_bgr = None
        # 🔥 FIM DA BLINDAGEM 🔥

        if imagem_bgr is None:
            limpar_fotos_parciais(nome_limpo)
            return {"status": "erro", "mensagem": "Imagem inválida ou corrompida."}

        # O OpenCV (cv2) checa a nitidez usando a imagem BGR perfeitamente
        if not checar_nitidez(imagem_bgr):
            limpar_fotos_parciais(nome_limpo)
            return {
                "status": "erro",
                "mensagem": "Imagem muito borrada. Fique parado e tente novamente."
            }

        # Converte pro face_recognition achar os rostos (ele exige RGB)
        imagem_rgb = cv2.cvtColor(imagem_bgr, cv2.COLOR_BGR2RGB)
        locais = face_recognition.face_locations(imagem_rgb)

        if not locais:
            limpar_fotos_parciais(nome_limpo)
            return {
                "status": "erro",
                "mensagem": "Nenhum rosto detectado. Centralize-se na câmera."
            }

        if len(locais) > 1:
            limpar_fotos_parciais(nome_limpo)
            return {
                "status": "erro",
                "mensagem": "Mais de um rosto detectado. Cadastre um aluno por vez."
            }

        marcas = face_recognition.face_landmarks(imagem_rgb, locais)
        if marcas:
            pontos = marcas[0]
            nariz_x = pontos["nose_bridge"][0][0]
            olho_esq_x = pontos["left_eye"][0][0]
            olho_dir_x = pontos["right_eye"][0][0]

            proporcao = (nariz_x - olho_esq_x) / (olho_dir_x - olho_esq_x + 1e-6)

            if numero_foto == "1" and (proporcao < 0.15 or proporcao > 0.85):
                limpar_fotos_parciais(nome_limpo)
                return {"status": "erro", "mensagem": "Fique mais de frente para a foto 1."}

            if numero_foto == "2" and proporcao < 0.44:
                limpar_fotos_parciais(nome_limpo)
                return {"status": "erro", "mensagem": "Gire a cabeça um pouco para a ESQUERDA."}

            if numero_foto == "3" and proporcao > 0.56:
                limpar_fotos_parciais(nome_limpo)
                return {"status": "erro", "mensagem": "Gire a cabeça um pouco para a DIREITA."}

        # Se passou em tudo, salva a imagem (agora endireitada e limpa) no disco
        nome_arquivo = f"{nome_limpo}_{numero_foto}.jpg"
        caminho_destino = os.path.join(PASTA_BANCO, nome_arquivo)

        if not cv2.imwrite(caminho_destino, imagem_bgr):
            raise RuntimeError("Não foi possível salvar a imagem no banco facial.")

        if numero_foto == "3":
            carregar_banco_local()

        return {
            "status": "sucesso",
            "mensagem": f"Foto {numero_foto} salva!",
            "aluno": nome_limpo
        }

    except Exception as erro:
        logger.exception("Erro durante cadastro facial: %s", erro)
        limpar_fotos_parciais(nome_limpo)
        return {"status": "erro", "mensagem": f"Erro no servidor: {erro}"}
# ============================================================
# RECONHECIMENTO FACIAL
# ============================================================

def calcular_face_score(distancia):
    """
    O face_recognition fornece DISTÂNCIA, não uma probabilidade de confiança.
    """
    if distancia is None:
        return 0.0

    distancia = max(0.0, float(distancia))
    qualidade_relativa = 1.0 - min(distancia / TOLERANCIA_RECONHECIMENTO, 1.0)
    score = NODE_MIN_FACE_SCORE + qualidade_relativa * (1.0 - NODE_MIN_FACE_SCORE)
    return round(max(0.0, min(1.0, score)), 4)

def extrair_mensagem_backend(corpo, fallback):
    if isinstance(corpo, dict):
        return (
            corpo.get("message")
            or corpo.get("mensagem")
            or (corpo.get("error") if isinstance(corpo.get("error"), str) else None)
            or fallback
        )
    return fallback

def registrar_presenca_no_node(nome_aluno, distancia):
    """Envia o reconhecimento validado para o backend Node."""
    info, erro_mapeamento = obter_mapeamento_aluno(nome_aluno)

    if erro_mapeamento:
        logger.error(erro_mapeamento)
        return {
            "ok": False,
            "status": "erro",
            "tipo": "MAPEAMENTO_INVALIDO",
            "mensagem": erro_mapeamento
        }

    if not IA_API_KEY:
        mensagem = (
            "IA_API_KEY não está configurada na API Python. "
            "Use a mesma chave configurada no backend Node."
        )
        logger.error(mensagem)
        return {
            "ok": False,
            "status": "erro",
            "tipo": "CONFIGURACAO",
            "mensagem": mensagem
        }

    face_score = calcular_face_score(distancia)
    url = f"{NODE_API_URL}/ia/registrar-presenca"
    payload = {
        "alunoId": info["alunoId"],
        "turmaId": info["turmaId"],
        "faceScore": face_score
    }

    logger.info("Enviando reconhecimento ao Node: aluno=%s score=%.4f url=%s", nome_aluno, face_score, url)

    try:
        resposta = requests.post(
            url,
            json=payload,
            headers={
                "x-api-key": IA_API_KEY,
                "Accept": "application/json"
            },
            timeout=NODE_TIMEOUT_SEGUNDOS
        )

        try:
            corpo = resposta.json()
        except ValueError:
            corpo = {"message": resposta.text[:1000] or "Resposta não-JSON do backend."}

        logger.info("Resposta Node: HTTP %s | %s", resposta.status_code, corpo)

        if resposta.ok:
            return {
                "ok": True,
                "status": "sucesso",
                "http_status": resposta.status_code,
                "faceScore": face_score,
                "data": corpo
            }

        mapa_erros = {
            400: "REQUISICAO_INVALIDA",
            401: "API_KEY_INVALIDA",
            403: "SEM_PERMISSAO",
            404: "ROTA_NAO_ENCONTRADA",
            409: "CONFLITO",
            422: "RECONHECIMENTO_REJEITADO",
            429: "RATE_LIMIT",
        }

        tipo = mapa_erros.get(resposta.status_code, "ERRO_BACKEND")
        mensagem = extrair_mensagem_backend(
            corpo,
            f"Backend respondeu HTTP {resposta.status_code}."
        )

        return {
            "ok": False,
            "status": "erro",
            "tipo": tipo,
            "http_status": resposta.status_code,
            "faceScore": face_score,
            "mensagem": mensagem,
            "data": corpo
        }

    except requests.exceptions.Timeout:
        return {
            "ok": False,
            "status": "erro",
            "tipo": "TIMEOUT",
            "faceScore": face_score,
            "mensagem": "O backend demorou demais para responder. Tente novamente."
        }
    except requests.exceptions.ConnectionError as erro:
        logger.error("Falha de conexão com Node: %s", erro)
        return {
            "ok": False,
            "status": "erro",
            "tipo": "BACKEND_INDISPONIVEL",
            "faceScore": face_score,
            "mensagem": "Não foi possível conectar ao backend Node."
        }
    except requests.exceptions.RequestException as erro:
        logger.exception("Erro HTTP ao falar com Node: %s", erro)
        return {
            "ok": False,
            "status": "erro",
            "tipo": "ERRO_COMUNICACAO",
            "faceScore": face_score,
            "mensagem": f"Falha ao comunicar com o backend: {erro}"
        }

def reconhecer_face_com_rgb(imagem_rgb):
    """
    Função dedicada para processar o array RGB já normalizado e contíguo.
    Com blindagem contra fotos deitadas enviadas pelo sensor de tablets!
    """
    # Tenta achar o rosto na imagem como ela chegou
    locais = face_recognition.face_locations(imagem_rgb)

    # 👇 BLINDAGEM LUKA: Se não achou, a foto do tablet pode estar deitada em 90 graus!
    if not locais:
        logger.info("Nenhum rosto achado na posição original. Tentando girar a foto...")
        
        # Tenta girar 90 graus (retrato normal se o tablet mandou paisagem)
        img_90 = cv2.rotate(imagem_rgb, cv2.ROTATE_90_CLOCKWISE)
        locais = face_recognition.face_locations(img_90)
        
        if locais:
            imagem_rgb = img_90
            logger.info("Rosto encontrado após girar 90 graus (Horário)!")
        else:
            # Se ainda não achou, tenta girar pro outro lado
            img_270 = cv2.rotate(imagem_rgb, cv2.ROTATE_90_COUNTERCLOCKWISE)
            locais = face_recognition.face_locations(img_270)
            if locais:
                imagem_rgb = img_270
                logger.info("Rosto encontrado após girar 90 graus (Anti-Horário)!")

    # Retorna vazio se mesmo girando não achou ninguém (provavelmente não tem ninguem na frente)
    if not locais:
        return None, None

    encodings = face_recognition.face_encodings(imagem_rgb, locais)

    if len(encodings) != 1:
        return None, None

    if not rostos_conhecidos_encodings:
        return None, None

    distancias = face_recognition.face_distance(
        rostos_conhecidos_encodings,
        encodings[0]
    )

    melhor_por_aluno = {}
    for nome, distancia in zip(rostos_conhecidos_nomes, distancias):
        distancia = float(distancia)
        if distancia > TOLERANCIA_RECONHECIMENTO:
            continue

        if nome not in melhor_por_aluno or distancia < melhor_por_aluno[nome]:
            melhor_por_aluno[nome] = distancia

    if not melhor_por_aluno:
        return None, None

    candidatos = sorted(melhor_por_aluno.items(), key=lambda item: item[1])
    melhor_nome, melhor_distancia = candidatos[0]

    if len(candidatos) > 1:
        segunda_distancia = candidatos[1][1]
        if (segunda_distancia - melhor_distancia) < MARGEM_MINIMA_CONFIANCA:
            logger.warning(
                "Reconhecimento ambíguo: %s=%.4f / %s=%.4f",
                melhor_nome,
                melhor_distancia,
                candidatos[1][0],
                segunda_distancia
            )
            return None, None

    return melhor_nome, melhor_distancia

@app.post("/reconhecer")
async def reconhecer_rosto(file: UploadFile = File(...)):
    try:
        conteudo = await file.read()

        if not conteudo:
            return {
                "status": "erro",
                "reconhecido": False,
                "presenca_registrada": False,
                "mensagem": "Arquivo de imagem vazio."
            }

        # 👇 A BLINDAGEM MÁXIMA DO LUKA USANDO PILLOW (PIL)
        try:
            # 1. Carrega a imagem direto da memória, bypassando o cv2.imdecode
            pil_image = Image.open(io.BytesIO(conteudo))
            
            # 2. Limpa qualquer rotação oculta (EXIF) que o Android embute e quebra o numpy
            pil_image = ImageOps.exif_transpose(pil_image)
            
            # 3. Força estritamente para o padrão RGB de 8-bits, removendo canais Alpha ou paletas estranhas
            pil_image = pil_image.convert("RGB")
            
            # 4. Converte para matriz do NumPy
            imagem_rgb = np.array(pil_image)
            
            # 5. Redimensiona para não sobrecarregar a IA caso a foto do tablet seja gigantesca
            altura, largura = imagem_rgb.shape[:2]
            if largura > 1200:
                imagem_menor = cv2.resize(imagem_rgb, (largura // 2, altura // 2))
                imagem_rgb = np.array(imagem_menor)

            # 6. O toque final de mestre: forçar o alinhamento da memória para o dlib em C++ aceitar
            imagem_rgb = np.ascontiguousarray(imagem_rgb, dtype=np.uint8)

        except Exception as e:
            logger.error(f"Erro ao limpar imagem com PIL: {e}")
            return {
                "status": "erro",
                "reconhecido": False,
                "presenca_registrada": False,
                "mensagem": "Formato de imagem ilegível pelo sistema."
            }

        # Chama a função dedicada
        nome, distancia = reconhecer_face_com_rgb(imagem_rgb)

        if nome is None:
            if not rostos_conhecidos_encodings:
                return {
                    "status": "erro",
                    "reconhecido": False,
                    "presenca_registrada": False,
                    "mensagem": "Banco facial vazio. Cadastre um aluno primeiro."
                }

            return {
                "status": "sucesso",
                "reconhecido": False,
                "presenca_registrada": False,
                "mensagem": "Rosto não reconhecido ou reconhecimento ambíguo."
            }

        logger.info("Rosto reconhecido localmente: %s | distância=%.4f", nome, distancia)

        resultado_node = registrar_presenca_no_node(nome, distancia)

        if not resultado_node.get("ok"):
            return {
                "status": "erro",
                "reconhecido": True,
                "presenca_registrada": False,
                "aluno": nome,
                "faceScore": resultado_node.get("faceScore"),
                "tipo_erro": resultado_node.get("tipo"),
                "mensagem": resultado_node.get(
                    "mensagem",
                    "Rosto reconhecido, mas o backend não confirmou a presença."
                ),
                "backend": resultado_node
            }

        resposta_node = resultado_node.get("data") or {}
        dados_evento = resposta_node.get("data") if isinstance(resposta_node, dict) else None
        dados_evento = dados_evento if isinstance(dados_evento, dict) else {}
        evento = dados_evento.get("status")

        registro_novo = evento != "IGNORADO"

        mensagens_evento = {
            "ENTRADA_REGISTRADA": "Entrada registrada com sucesso.",
            "SAIDA_REGISTRADA": "Saída registrada com sucesso.",
            "SAIDA_ANTECIPADA_REGISTRADA": "Saída antecipada registrada.",
            "IGNORADO": dados_evento.get("mensagem", "O ciclo de presença de hoje já foi concluído.")
        }

        return {
            "status": "sucesso",
            "reconhecido": True,
            "presenca_registrada": registro_novo,
            "aluno": nome,
            "faceScore": resultado_node.get("faceScore"),
            "evento": evento,
            "mensagem": mensagens_evento.get(
                evento,
                resposta_node.get("message", "Reconhecimento processado pelo backend.")
                if isinstance(resposta_node, dict)
                else "Reconhecimento processado pelo backend."
            ),
            "backend": resposta_node
        }

    except Exception as erro:
        logger.exception("Erro inesperado no reconhecimento: %s", erro)
        return {
            "status": "erro",
            "reconhecido": False,
            "presenca_registrada": False,
            "mensagem": f"Erro no servidor de reconhecimento: {erro}"
        }