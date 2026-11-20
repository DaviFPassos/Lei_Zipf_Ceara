"""Baixa os dados geográficos usados em analise_fatores_ambientais_ceara.py e guarda em data/geografia/.

Fontes (todas abertas):
- Elevação: SRTM 30 m, via API do OpenTopoData (https://www.opentopodata.org).
- Chuva: NASA POWER (MERRA-2), médias mensais de 2001 a 2023, na grade nativa de 0,5° x 0,625°.
- Rios: OpenStreetMap, via Overpass API (rios Jaguaribe, Banabuiú, Salgado, Acaraú, Curu, Choró, Coreaú, Poti, Parnaíba e São Francisco).
- Litoral: Natural Earth 1:10 milhões.
- Açudes e lagos: OpenStreetMap (centroide e área de cada corpo d'água) e todos os trechos de rio (waterway=river), de qualquer nome.
- Semiárido: lista oficial de 1.477 municípios (IBGE/SUDENE, situação em 2022).
Para executar, a partir da raiz do projeto: .venv/bin/python analise/coletar_dados_geograficos.py
"""
import json
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
ROOT = Path(__file__).resolve().parent.parent
DEST = ROOT / 'data' / 'geografia'
DEST.mkdir(parents=True, exist_ok=True)
CABECALHO = {'User-Agent': 'academic-geo-analysis/1.0', 'Accept': '*/*'}


def baixar(url, dados=None, tentativas=4):
    for tentativa in range(tentativas):
        try:
            with urlopen(Request(url, data=dados, headers=CABECALHO), timeout=90) as resposta:
                return resposta.read()
        except Exception as erro:  # a API pode limitar a taxa de chamadas
            time.sleep(2 * (tentativa + 1))
            ultimo = erro
    raise ultimo


# Municípios (mesmas funções do script de análise geográfica, sem executar as análises).
import importlib.util
import re
fonte = (Path(__file__).resolve().parent / 'analise_geografica_ceara.py').read_text(encoding='utf-8')
modulo_carga = fonte.split('# Lei de potência')[0]
espaco = {}
exec(compile(modulo_carga.replace("ROOT = Path(__file__).resolve().parent.parent", f"ROOT = Path(r'{ROOT}')")
             .replace("OUTPUT.mkdir(parents=True, exist_ok=True)", "pass"), 'carga', 'exec'), espaco)
nordeste, _ = espaco['carregar_nordeste']()

# 1. Elevação -------------------------------------------------------------------------------------------
destino_elev = DEST / 'elevacao_municipios.csv'
if not destino_elev.exists():
    pontos = []
    for i, linha in nordeste.iterrows():
        pontos.append((i, 'c', linha['lat'], linha['lon']))
        if linha['UF'] == 'CE':   # no Ceará, quatro pontos ao redor medem o relevo dentro do município
            for rotulo, dlat, dlon in [('n', 0.08, 0), ('s', -0.08, 0), ('l', 0, 0.08), ('o', 0, -0.08)]:
                pontos.append((i, rotulo, linha['lat'] + dlat, linha['lon'] + dlon))
    resultados = []
    for inicio in range(0, len(pontos), 100):
        lote = pontos[inicio:inicio + 100]
        consulta = '|'.join(f'{lat:.5f},{lon:.5f}' for _, _, lat, lon in lote)
        resposta = json.loads(baixar('https://api.opentopodata.org/v1/srtm30m?' + urlencode({'locations': consulta})))
        for (i, rotulo, _, _), r in zip(lote, resposta['results']):
            resultados.append({'indice': i, 'ponto': rotulo, 'elevacao_m': r['elevation']})
        time.sleep(1.2)
        print(f'elevação: {inicio + len(lote)}/{len(pontos)}', end='\r')
    elev = pd.DataFrame(resultados).pivot(index='indice', columns='ponto', values='elevacao_m')
    saida = pd.DataFrame({'codigo': nordeste['codigo'], 'UF': nordeste['UF'], 'elev_centro_m': elev['c']})
    outros = elev[['n', 's', 'l', 'o']]
    saida['elev_media_m'] = elev[['c', 'n', 's', 'l', 'o']].mean(axis=1).where(nordeste['UF'] == 'CE')
    saida['relevo_m'] = (elev[['c', 'n', 's', 'l', 'o']].max(axis=1) - elev[['c', 'n', 's', 'l', 'o']].min(axis=1)).where(nordeste['UF'] == 'CE')
    saida.to_csv(destino_elev, index=False)
print('\nelevação pronta')

# 2. Chuva ---------------------------------------------------------------------------------------------------
destino_chuva = DEST / 'chuva_power_celulas.json'
celulas = sorted({(round(lat / 0.5) * 0.5, round(lon / 0.625) * 0.625) for lat, lon in zip(nordeste['lat'], nordeste['lon'])})
chuva = json.loads(destino_chuva.read_text()) if destino_chuva.exists() else {}
pendentes = [c for c in celulas if f'{c[0]},{c[1]}' not in chuva]

def baixar_celula(celula):
    lat, lon = celula
    url = ('https://power.larc.nasa.gov/api/temporal/monthly/point?parameters=PRECTOTCORR&community=AG'
           f'&longitude={lon}&latitude={lat}&start=2001&end=2023&format=JSON')
    serie = json.loads(baixar(url))['properties']['parameter']['PRECTOTCORR']
    return f'{lat},{lon}', serie

with ThreadPoolExecutor(max_workers=4) as pool:
    for k, (chave, serie) in enumerate(pool.map(baixar_celula, pendentes), 1):
        chuva[chave] = serie
        if k % 25 == 0:
            destino_chuva.write_text(json.dumps(chuva))
            print(f'chuva: {k}/{len(pendentes)}', end='\r')
destino_chuva.write_text(json.dumps(chuva))
print(f'\nchuva pronta ({len(chuva)} células)')

# 3. Rios e litoral ------------------------------------------------------------------------------------------
destino_rios = DEST / 'rios_osm.json'
if not destino_rios.exists():
    consulta = ('[out:json][timeout:90];way["waterway"="river"]["name"~"^Rio (S[aã]o Francisco|Jaguaribe|Banabui[uú]|Salgado|'
                'Acara[uú]|Curu|Cho[ro][oó]|Coreaú|Poti|Parna[ií]ba)$"](-10.5,-43.5,-2.5,-34.5);out geom;')
    destino_rios.write_bytes(baixar('https://overpass-api.de/api/interpreter', urlencode({'data': consulta}).encode()))
destino_litoral = DEST / 'litoral_nordeste.json'
if not destino_litoral.exists():
    bruto = json.loads(baixar('https://cdn.jsdelivr.net/gh/nvkelso/natural-earth-vector@master/geojson/ne_10m_coastline.geojson'))
    segmentos = []
    for feature in bruto['features']:
        geometria = feature['geometry']
        linhas = geometria['coordinates'] if geometria['type'] == 'MultiLineString' else [geometria['coordinates']]
        for linha in linhas:
            pts = [p for p in linha if -43.5 <= p[0] <= -34.0 and -19.0 <= p[1] <= -1.5]
            if len(pts) > 1:
                segmentos.append(pts)
    destino_litoral.write_text(json.dumps(segmentos))
print('rios e litoral prontos')

# 4. Municípios do semiárido (lista oficial do IBGE/SUDENE, 2022) -----------------------------------------------
destino_semi = DEST / 'semiarido_2022.csv'
if not destino_semi.exists():
    import io
    import zipfile
    xlsx = baixar('https://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/semiarido_brasileiro/'
                  'Situacao_2022/lista_municipios_Semiarido_2022.xlsx')
    planilha = zipfile.ZipFile(io.BytesIO(xlsx)).read('xl/worksheets/sheet1.xml').decode('utf-8')
    codigos = re.findall(r'<c r="A\d+"[^>]*><v>(\d{7})</v>', planilha)
    destino_semi.write_text('codigo\n' + '\n'.join(codigos) + '\n')
    print(len(codigos), 'municípios do semiárido')
print('semiárido pronto')

# 5. Açudes, lagos e todos os trechos de rio do Ceará (OpenStreetMap) ----------------------------------------------
CAIXA_CE = (-7.9, -41.5, -2.7, -37.2)   # sul, oeste, norte, leste

def overpass(consulta, tentativas=5):
    for tentativa in range(tentativas):
        try:
            return json.loads(baixar('https://overpass-api.de/api/interpreter', urlencode({'data': consulta}).encode()))
        except Exception:
            time.sleep(20 * (tentativa + 1))
    raise RuntimeError('Overpass indisponível')

def area_km2(pontos):
    lon, lat = np.asarray(pontos, dtype=float).T
    x, y = lon * 111.32 * np.cos(np.radians(lat.mean())), lat * 110.57
    return abs((x * np.roll(y, -1) - np.roll(x, -1) * y).sum() / 2)

destino_acudes = DEST / 'acudes_osm.csv'
if not destino_acudes.exists():
    s_, o_, n_, l_ = CAIXA_CE
    bruto = overpass(f'[out:json][timeout:180];(way["natural"="water"]["water"~"reservoir|lake|pond"]({s_},{o_},{n_},{l_});'
                     f'way["landuse"="reservoir"]({s_},{o_},{n_},{l_});'
                     f'relation["natural"="water"]["water"~"reservoir|lake"]({s_},{o_},{n_},{l_});'
                     f'relation["landuse"="reservoir"]({s_},{o_},{n_},{l_}););out geom;')
    linhas = []
    for e in bruto['elements']:
        aneis = []
        if e['type'] == 'way':
            aneis = [[(p['lon'], p['lat']) for p in e.get('geometry', [])]]
        else:
            aneis = [[(p['lon'], p['lat']) for p in m.get('geometry', [])] for m in e.get('members', []) if m.get('role') == 'outer']
        aneis = [a for a in aneis if len(a) >= 4 and a[0] == a[-1]]
        if not aneis:
            continue
        pts = [p for a in aneis for p in a]
        linhas.append({'nome': e.get('tags', {}).get('name', ''), 'lon': np.mean([p[0] for p in pts]), 'lat': np.mean([p[1] for p in pts]),
                       'area_km2': sum(area_km2(a) for a in aneis)})
    pd.DataFrame(linhas).to_csv(destino_acudes, index=False)
    print(len(linhas), 'corpos d\'água')
destino_rios_todos = DEST / 'rios_todos_ceara.json'
if not destino_rios_todos.exists():
    s_, o_, n_, l_ = CAIXA_CE
    trechos, meio_lat, meio_lon = [], (s_ + n_) / 2, (o_ + l_) / 2
    for (a, b, c, d) in [(s_, o_, meio_lat, meio_lon), (s_, meio_lon, meio_lat, l_), (meio_lat, o_, n_, meio_lon), (meio_lat, meio_lon, n_, l_)]:
        bruto = overpass(f'[out:json][timeout:180];way["waterway"="river"]({a},{b},{c},{d});out geom;')
        trechos += [[(p['lon'], p['lat']) for p in e.get('geometry', [])] for e in bruto['elements']]
        time.sleep(5)
    destino_rios_todos.write_text(json.dumps(trechos))
    print(len(trechos), 'trechos de rio')
print('açudes e rios completos prontos')
