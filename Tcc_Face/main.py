from fastapi import FastAPI, UploadFile, File, Request, Form
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
import face_recognition
import cv2
import numpy as np
import os
import json
import requests
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="API de Reconhecimento Facial Profissional")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PASTA_STATIC = os.path.join(BASE_DIR, "static")
PASTA_BANCO = os.path.join(BASE_DIR, "banco_alunos")

# Integração com o backend Node
NODE_API_URL = os.getenv("NODE_API_URL", "http://localhost:3000")
IA_API_KEY = os.getenv("IA_API_KEY")
CAMINHO_MAPEAMENTO = os.path.join(BASE_DIR, "mapeamento_alunos.json")


def carregar_mapeamento():
    if not os.path.exists(CAMINHO_MAPEAMENTO):
        return {}
    with open(CAMINHO_MAPEAMENTO, "r", encoding="utf-8") as f:
        return json.load(f)


mapeamento_alunos = carregar_mapeamento()

for pasta in [PASTA_STATIC, PASTA_BANCO]:
    if not os.path.exists(pasta):
        os.makedirs(pasta)

app.mount("/static", StaticFiles(directory=PASTA_STATIC), name="static")
templates = Jinja2Templates(directory=os.path.join(BASE_DIR, "templates"))

rostos_conhecidos_encodings = []
rostos_conhecidos_nomes = []

# Quanto menor, mais rigoroso o reconhecimento (menos falsos positivos,
# porém mais chance de não reconhecer em fotos ruins).
TOLERANCIA_RECONHECIMENTO = 0.46

# Diferença mínima aceitável entre a 1ª e a 2ª menor distância.
# Se for menor que isso, consideramos ambíguo e não reconhecemos ninguém.
MARGEM_MINIMA_CONFIANCA = 0.05

# Quantidade de reamostragens da imagem no cadastro para gerar um encoding
# mais preciso. Quanto maior, mais lento.
NUM_JITTERS_CADASTRO = 1


# O nome do aluno é usado como identificador do arquivo/cadastro. Alunos com
# nome completo idêntico vão sobrescrever o cadastro um do outro.


def carregar_banco_local():
    rostos_conhecidos_encodings.clear()
    rostos_conhecidos_nomes.clear()
    if not os.listdir(PASTA_BANCO):
        return
    print("Carregando banco de rostos, aguarde...")
    for arquivo in os.listdir(PASTA_BANCO):
        if arquivo.lower().endswith((".jpg", ".jpeg", ".png")):
            try:
                imagem = face_recognition.load_image_file(os.path.join(PASTA_BANCO, arquivo))
                encodings = face_recognition.face_encodings(imagem, num_jitters=NUM_JITTERS_CADASTRO)
                if len(encodings) > 0:
                    nome_base = os.path.splitext(arquivo)[0]
                    partes = nome_base.rsplit("_", 1)
                    nome_aluno = partes[0] if len(partes) == 2 else nome_base
                    rostos_conhecidos_encodings.append(encodings[0])
                    rostos_conhecidos_nomes.append(nome_aluno)
                    print(f"  OK: {arquivo} carregado")
            except Exception as e:
                print(f"Erro ao ler {arquivo}: {e}")
    print(f"Banco carregado: {len(rostos_conhecidos_nomes)} fotos.")


carregar_banco_local()


@app.get("/", response_class=HTMLResponse)
async def interface_teste(request: Request):
    return templates.TemplateResponse(request=request, name="index.html")


@app.get("/health")
async def health_check():
    return {"status": "ok", "alunos_carregados": len(rostos_conhecidos_nomes)}


def limpar_fotos_parciais(nome_aluno):
    try:
        for numero in ["1", "2", "3"]:
            caminho_arquivo = os.path.join(PASTA_BANCO, f"{nome_aluno}_{numero}.jpg")
            if os.path.exists(caminho_arquivo):
                os.remove(caminho_arquivo)
    except Exception as e:
        print(f"Erro na limpeza: {e}")


def checar_nitidez(imagem_bgr, limite=80.0):
    """
    Verifica se a imagem está nítida o suficiente usando a variância do Laplaciano.
    Quanto menor o valor, mais borrada a imagem está.
    """
    cinza = cv2.cvtColor(imagem_bgr, cv2.COLOR_BGR2GRAY)
    variancia = cv2.Laplacian(cinza, cv2.CV_64F).var()
    return variancia >= limite


@app.post("/cadastrar")
async def cadastrar_aluno(nome: str = Form(...), numero_foto: str = Form(...), file: UploadFile = File(...)):
    nome_limpo = " ".join(nome.strip().split())

    try:
        conteudo = await file.read()
        nparr = np.frombuffer(conteudo, np.uint8)
        imagem_bgr = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if imagem_bgr is None:
            limpar_fotos_parciais(nome_limpo)
            return {"status": "erro", "mensagem": "Imagem inválida ou corrompida."}

        if not checar_nitidez(imagem_bgr):
            limpar_fotos_parciais(nome_limpo)
            return {"status": "erro", "mensagem": "Imagem muito borrada. Fique parado e tente novamente."}

        imagem_rgb = cv2.cvtColor(imagem_bgr, cv2.COLOR_BGR2RGB)
        locais = face_recognition.face_locations(imagem_rgb)

        if not locais:
            limpar_fotos_parciais(nome_limpo)
            return {"status": "erro", "mensagem": "Nenhum rosto detectado! Centralize-se na câmera."}

        if len(locais) > 1:
            limpar_fotos_parciais(nome_limpo)
            return {"status": "erro", "mensagem": "Mais de um rosto detectado. Cadastre um aluno por vez."}

        marcas = face_recognition.face_landmarks(imagem_rgb, locais)
        if marcas:
            pontos = marcas[0]
            nariz_x = pontos['nose_bridge'][0][0]
            olho_esq_x = pontos['left_eye'][0][0]
            olho_dir_x = pontos['right_eye'][0][0]

            proporcao = (nariz_x - olho_esq_x) / (olho_dir_x - olho_esq_x + 1e-6)

            if numero_foto == "1":
                if proporcao < 0.15 or proporcao > 0.85:
                    limpar_fotos_parciais(nome_limpo)
                    return {"status": "erro", "mensagem": "Fique mais de frente para a foto 1."}

            elif numero_foto == "2":
                if proporcao < 0.44:
                    limpar_fotos_parciais(nome_limpo)
                    return {"status": "erro", "mensagem": "Gire a cabeça um pouco para a ESQUERDA."}

            elif numero_foto == "3":
                if proporcao > 0.56:
                    limpar_fotos_parciais(nome_limpo)
                    return {"status": "erro", "mensagem": "Gire a cabeça um pouco para a DIREITA."}

        nome_arquivo = f"{nome_limpo}_{numero_foto}.jpg"
        cv2.imwrite(os.path.join(PASTA_BANCO, nome_arquivo), imagem_bgr)

        if numero_foto == "3":
            carregar_banco_local()

        return {"status": "sucesso", "mensagem": f"Foto {numero_foto} salva!"}

    except Exception as e:
        limpar_fotos_parciais(nome_limpo)
        return {"status": "erro", "mensagem": f"Erro no servidor: {str(e)}"}


def registrar_presenca_no_node(nome_aluno, distancia):
    """
    Envia o reconhecimento pro backend Node, que decide se é entrada, saída
    ou ciclo já concluído, comparando com o que já existe hoje no Postgres
    para aquele aluno/turma.
    """
    info = mapeamento_alunos.get(nome_aluno)
    if not info:
        return {
            "status": "erro",
            "mensagem": f"Aluno '{nome_aluno}' reconhecido, mas sem alunoId/turmaId em mapeamento_alunos.json."
        }

    face_score = max(0.0, 1 - (distancia / TOLERANCIA_RECONHECIMENTO))

    try:
        resposta = requests.post(
            f"{NODE_API_URL}/ia/registrar-presenca",
            json={
                "alunoId": info["alunoId"],
                "turmaId": info["turmaId"],
                "faceScore": round(face_score, 2)
            },
            headers={"x-api-key": IA_API_KEY},
            timeout=5
        )
        return resposta.json()
    except requests.exceptions.RequestException as e:
        return {"status": "erro", "mensagem": f"Falha ao comunicar com o backend: {str(e)}"}


def reconhecer_face_no_frame(imagem_bgr):
    """
    Recebe uma imagem BGR e retorna (nome, distancia) do aluno mais próximo.
    Retorna (None, None) se não achar rosto, banco vazio, distância acima da
    tolerância, ou se o resultado for ambíguo (dois ou mais alunos muito parecidos).
    """
    imagem_menor = cv2.resize(imagem_bgr, (0, 0), fx=0.25, fy=0.25)
    imagem_rgb = cv2.cvtColor(imagem_menor, cv2.COLOR_BGR2RGB)

    locais = face_recognition.face_locations(imagem_rgb)
    encodings = face_recognition.face_encodings(imagem_rgb, locais)

    if not encodings:
        return None, None
    if not rostos_conhecidos_encodings:
        return None, None

    distancias = face_recognition.face_distance(rostos_conhecidos_encodings, encodings[0])

    candidatos_validos = [
        (nome, dist) for nome, dist in zip(rostos_conhecidos_nomes, distancias)
        if dist <= TOLERANCIA_RECONHECIMENTO
    ]

    if not candidatos_validos:
        return None, None

    candidatos_validos.sort(key=lambda item: item[1])
    melhor_nome, melhor_distancia = candidatos_validos[0]

    if len(candidatos_validos) > 1:
        _, segunda_distancia = candidatos_validos[1]
        if (segunda_distancia - melhor_distancia) < MARGEM_MINIMA_CONFIANCA:
            return None, None

    return melhor_nome, melhor_distancia


@app.post("/reconhecer")
async def reconhecer_rosto(file: UploadFile = File(...)):
    """
    Reconhece o rosto e repassa pro Node via registrar_presenca_no_node().
    Quem decide se é ENTRADA_REGISTRADA, SAIDA_REGISTRADA, SAIDA_ANTECIPADA
    ou IGNORADO é sempre o backend Node.
    """
    try:
        conteudo = await file.read()
        nparr = np.frombuffer(conteudo, np.uint8)
        imagem_bgr = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if imagem_bgr is None:
            return {"status": "erro", "mensagem": "Erro ao decodificar a imagem."}

        nome, distancia = reconhecer_face_no_frame(imagem_bgr)

        if nome is None:
            if not rostos_conhecidos_encodings:
                return {"status": "erro", "mensagem": "Banco de dados vazio."}
            return {"status": "sucesso", "reconhecido": False, "mensagem": "Rosto desconhecido."}

        resultado_node = registrar_presenca_no_node(nome, distancia)
        return {
            "status": "sucesso",
            "reconhecido": True,
            "aluno": nome,
            "backend": resultado_node
        }

    except Exception as e:
        return {"status": "erro", "mensagem": str(e)}