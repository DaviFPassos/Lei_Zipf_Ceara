"""Baixa dados socioeconômicos por município para comparar o Cariri com a região central do Ceará.

Fontes:
- IBGE, SIDRA tabela 4709: população de 2022, variação absoluta desde 2010 (compatibilizada) e taxa de crescimento.
- IBGE, SIDRA tabela 5938: PIB e valor adicionado por setor (2021, último ano com setores).
- IBGE, SIDRA tabela 9509: Cadastro Central de Empresas (unidades locais, pessoal ocupado, salário médio), 2022.
- Ministério da Saúde, CNES (API de dados abertos): hospitais gerais e especializados do Ceará.
Dados de ensino superior (INEP) não puderam ser baixados neste ambiente.

Para executar, a partir da raiz do projeto: .venv/bin/python analise/coletar_dados_socioeconomicos.py
"""
import json
import time
from pathlib import Path
from urllib.request import Request, urlopen

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
DEST = ROOT / 'data' / 'socioeconomico'
DEST.mkdir(parents=True, exist_ok=True)
CABECALHO = {'User-Agent': 'academic-geo-analysis/1.0', 'Accept': '*/*'}
UFS_NE = '21,22,23,24,25,26,27,28,29'


def baixar_json(url, tentativas=4):
    for tentativa in range(tentativas):
        try:
            with urlopen(Request(url, headers=CABECALHO), timeout=120) as resposta:
                return json.loads(resposta.read())
        except Exception as erro:
            time.sleep(3 * (tentativa + 1))
            ultimo = erro
    raise ultimo


def sidra(tabela, periodo, variaveis, nome_arquivo):
    destino = DEST / nome_arquivo
    if destino.exists():
        return pd.read_csv(destino, dtype={'codigo': str})
    url = (f'https://servicodados.ibge.gov.br/api/v3/agregados/{tabela}/periodos/{periodo}/variaveis/'
           f'{"|".join(str(v) for v in variaveis)}?localidades=N6[N3[{UFS_NE}]]')
    linhas = {}
    for variavel in baixar_json(url):
        for resultado in variavel['resultados']:
            for serie in resultado['series']:
                codigo = serie['localidade']['id']
                valor = serie['serie'].get(str(periodo))
                linhas.setdefault(codigo, {'codigo': codigo})[f"v{variavel['id']}"] = pd.to_numeric(valor, errors='coerce')
    tabela_df = pd.DataFrame(linhas.values())
    tabela_df.to_csv(destino, index=False)
    print(nome_arquivo, len(tabela_df), 'municípios')
    return tabela_df


sidra(4709, 2022, [93, 5936, 10605], 'populacao_2010_2022.csv')
sidra(5938, 2021, [37, 498, 513, 517, 6575, 525], 'pib_2021.csv')
sidra(9509, 2022, [706, 367, 707, 708, 662, 10143], 'cempre_2022.csv')

# Hospitais do Ceará (CNES): tipo 5 = hospital geral, 7 = hospital especializado. A API limita a 20 por página
# e só pagina bem com filtro de município, então a busca é feita município a município.
destino_hosp = DEST / 'hospitais_ceara_cnes.csv'
if not destino_hosp.exists():
    codigos_ce = [c for c in pd.read_csv(DEST / 'populacao_2010_2022.csv', dtype={'codigo': str})['codigo'] if c.startswith('23')]
    linhas = []
    for codigo in codigos_ce:
        for tipo in (5, 7):
            deslocamento = 0
            while True:
                url = ('https://apidadosabertos.saude.gov.br/cnes/estabelecimentos?'
                       f'codigo_municipio={codigo[:6]}&codigo_tipo_unidade={tipo}&limit=20&offset={deslocamento}')
                lote = baixar_json(url)['estabelecimentos']
                linhas += [{'codigo_cnes': e['codigo_cnes'], 'nome': e['nome_fantasia'], 'tipo_unidade': tipo,
                            'codigo': codigo, 'centro_cirurgico': e['estabelecimento_possui_centro_cirurgico'],
                            'atendimento_hospitalar': e['estabelecimento_possui_atendimento_hospitalar'],
                            'ensino': e['codigo_atividade_ensino_unidade'], 'esfera': e['descricao_esfera_administrativa']}
                           for e in lote]
                if len(lote) < 20:
                    break
                deslocamento += 20
            time.sleep(0.15)
    pd.DataFrame(linhas).drop_duplicates('codigo_cnes').to_csv(destino_hosp, index=False)
    print('hospitais:', len(linhas))
print('dados socioeconômicos prontos em', DEST)
