"""Amostra de propriedades do solo (SoilGrids, ISRIC) nos municípios do Cariri e da região central do Ceará.

SoilGrids é um mapa estatístico de 250 m (valores previstos por modelo, não medidos em campo) e tem lacunas em áreas
urbanas, então, quando o centroide não tem dado, a função tenta quatro pontos a 5 km. Limite da API: cerca de 5 chamadas por minuto.
Para executar, a partir da raiz: .venv/bin/python analise/coletar_solo_amostra.py
"""
import json
import time
from pathlib import Path
from urllib.request import Request, urlopen

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
DEST = ROOT / 'data' / 'geografia' / 'solo_amostra.csv'
fonte = (ROOT / 'analise' / 'analise_geografica_ceara.py').read_text(encoding='utf-8')
espaco = {}
exec(compile(fonte.split('# Lei de potência')[0].replace("ROOT = Path(__file__).resolve().parent.parent", f"ROOT = Path(r'{ROOT}')")
             .replace("OUTPUT.mkdir(parents=True, exist_ok=True)", "pass"), 'carga', 'exec'), espaco)
nordeste, _ = espaco['carregar_nordeste']()
dist = espaco['distancia_km']
pop = nordeste['pop'].to_numpy(float)
M = dist(nordeste['lon'].to_numpy()[:, None], nordeste['lat'].to_numpy()[:, None], nordeste['lon'].to_numpy()[None, :], nordeste['lat'].to_numpy()[None, :])
nordeste['d100'] = M[:, pop >= 1e5].min(axis=1)
ce = nordeste[nordeste['UF'] == 'CE'].copy()
i_j = ce.index[ce['municipio'] == 'Juazeiro do Norte'][0]
i_f = ce['pop'].idxmax()
ce['grupo'] = np.where(M[ce.index, i_f] <= 50, 'RMF', np.where(M[ce.index, i_j] <= 50, 'Cariri', np.where(ce['d100'] > 100, 'Centro/oeste', 'Demais')))
cariri = ce[ce['grupo'] == 'Cariri']
centro = ce[ce['grupo'] == 'Centro/oeste'].sample(14, random_state=42)
amostra = pd.concat([cariri, centro])

PROPRIEDADES = ['clay', 'sand', 'soc', 'phh2o', 'cec']
def consultar(lon, lat):
    url = ('https://rest.isric.org/soilgrids/v2.0/properties/query?' + f'lon={lon:.5f}&lat={lat:.5f}'
           + ''.join(f'&property={p}' for p in PROPRIEDADES) + '&depth=5-15cm&value=mean')
    for tentativa in range(4):
        try:
            with urlopen(Request(url, headers={'User-Agent': 'academic-geo-analysis/1.0'}), timeout=90) as r:
                camadas = json.loads(r.read())['properties']['layers']
            return {c['name']: c['depths'][0]['values']['mean'] for c in camadas}
        except Exception:
            time.sleep(15 * (tentativa + 1))
    return {}

linhas = []
for _, m in amostra.iterrows():
    for dlon, dlat in [(0, 0), (0.05, 0), (-0.05, 0), (0, 0.05), (0, -0.05)]:
        valores = consultar(m['lon'] + dlon, m['lat'] + dlat)
        time.sleep(13)
        if valores and all(valores.get(p) is not None for p in PROPRIEDADES):
            linhas.append({'municipio': m['municipio'], 'grupo': m['grupo'], 'pop': m['pop'], 'ponto_deslocado': (dlon, dlat) != (0, 0),
                           'argila_pct': valores['clay'] / 10, 'areia_pct': valores['sand'] / 10, 'carbono_organico_g_kg': valores['soc'] / 10,
                           'ph': valores['phh2o'] / 10, 'ctc_cmolc_kg': valores['cec'] / 10})
            break
    pd.DataFrame(linhas).to_csv(DEST, index=False)
    print(m['municipio'], 'ok' if linhas and linhas[-1]['municipio'] == m['municipio'] else 'sem dado', flush=True)
print('amostra de solo pronta:', len(linhas), 'municípios')
