"""Análise do fator geográfico na rejeição da lei de potência e na distância até polos de 100 mil habitantes.

Reproduz os números do artigo (mesmos dados do IBGE em data/, mesmas funções de máxima verossimilhança e bootstrap
do notebook Lei_de_Zipf_Ceara_v5.ipynb) e acrescenta cinco testes geográficos. Para executar, a partir da raiz do projeto:

    .venv/bin/python analise/analise_geografica_ceara.py

As tabelas e a figura vão para notebook_output/geografia/.
"""
import json
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.collections import PatchCollection
from matplotlib.lines import Line2D
from matplotlib.patches import Patch, Polygon as MplPolygon
from scipy import stats

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / 'data'
OUTPUT = ROOT / 'notebook_output' / 'geografia'
OUTPUT.mkdir(parents=True, exist_ok=True)

UFS = {'MA': 'maranhao', 'PI': 'piaui', 'CE': 'ceara', 'RN': 'rio_grande_do_norte', 'PB': 'paraiba',
       'PE': 'pernambuco', 'AL': 'alagoas', 'SE': 'sergipe', 'BA': 'bahia'}
REPETICOES_BOOTSTRAP = 1000


# --------------------------------------------------------------------------------------------------
# Dados e geometria
# --------------------------------------------------------------------------------------------------
def poligonos(geometria):
    return [geometria['coordinates']] if geometria['type'] == 'Polygon' else geometria['coordinates']


def centroide_e_area(geometria):
    """Centroide do maior polígono e área do município em km² (projeção equirretangular local)."""
    melhor, area_total = None, 0.0
    for poligono in poligonos(geometria):
        x, y = np.asarray(poligono[0], dtype=float).T
        x1, y1 = np.roll(x, -1), np.roll(y, -1)
        produto = x * y1 - x1 * y
        area = produto.sum() / 2
        if melhor is None or abs(area) > melhor[0]:
            melhor = (abs(area), ((x + x1) * produto).sum() / (6 * area), ((y + y1) * produto).sum() / (6 * area))
        kx, ky = 111.32 * np.cos(np.radians(y.mean())), 110.57
        for aro, sinal in [(poligono[0], 1)] + [(buraco, -1) for buraco in poligono[1:]]:
            ax, ay = np.asarray(aro, dtype=float).T * [[kx], [ky]]
            area_total += sinal * abs((ax * np.roll(ay, -1) - np.roll(ax, -1) * ay).sum() / 2)
    return melhor[1], melhor[2], area_total


def distancia_km(lon1, lat1, lon2, lat2):
    lon1, lat1, lon2, lat2 = map(np.radians, (lon1, lat1, lon2, lat2))
    a = np.sin((lat2 - lat1) / 2) ** 2 + np.cos(lat1) * np.cos(lat2) * np.sin((lon2 - lon1) / 2) ** 2
    return 6371 * 2 * np.arcsin(np.sqrt(a))


def carregar_nordeste():
    linhas, malha_ce = [], None
    for uf, nome in UFS.items():
        bruto = json.loads((DATA / f'ibge_populacao_{nome}_2022.json').read_text(encoding='utf-8'))
        populacao = {s['localidade']['id']: (s['localidade']['nome'].rsplit(' - ', 1)[0], int(s['serie']['2022']))
                     for s in bruto[0]['resultados'][0]['series']}
        malha = json.loads((DATA / f'ibge_malha_municipal_{nome}.geojson').read_text(encoding='utf-8'))
        if uf == 'CE':
            malha_ce = malha
        for feature in malha['features']:
            codigo = feature['properties']['codarea']
            lon, lat, area = centroide_e_area(feature['geometry'])
            linhas.append({'UF': uf, 'codigo': codigo, 'municipio': populacao[codigo][0], 'pop': populacao[codigo][1],
                           'lon': lon, 'lat': lat, 'area_km2': area})
    return pd.DataFrame(linhas), malha_ce


# --------------------------------------------------------------------------------------------------
# Lei de potência (mesmas funções do notebook, seções 13 e 15)
# --------------------------------------------------------------------------------------------------
def estimar_lei_potencia(populacoes, n_min=10):
    x = np.sort(np.asarray(populacoes, dtype=float))[::-1]
    melhor = None
    for k in range(n_min, len(x) + 1):
        cauda = x[:k]
        x_min = cauda[-1]
        soma_logs = np.sum(np.log(cauda / x_min))
        if soma_logs <= 0:
            continue
        alfa = 1 + k / soma_logs
        cdf_ajustada = 1 - (cauda[::-1] / x_min) ** (1 - alfa)
        D = np.max(np.abs(cdf_ajustada - np.arange(k) / k))
        if melhor is None or D < melhor['D']:
            melhor = {'x_min': x_min, 'n_cauda': k, 'alfa': alfa, 'D': D}
    return melhor


def p_valor_aderencia(populacoes, ajuste, repeticoes=REPETICOES_BOOTSTRAP, semente=42):
    rng = np.random.default_rng(semente)
    x = np.asarray(populacoes, dtype=float)
    abaixo = x[x < ajuste['x_min']]
    n_total, maiores = len(x), 0
    for _ in range(repeticoes):
        n_cauda = rng.binomial(n_total, ajuste['n_cauda'] / n_total)
        cauda = ajuste['x_min'] * (1 - rng.random(n_cauda)) ** (-1 / (ajuste['alfa'] - 1))
        resto = rng.choice(abaixo, n_total - n_cauda, replace=True)
        maiores += estimar_lei_potencia(np.concatenate([cauda, resto]))['D'] >= ajuste['D']
    return maiores / repeticoes


# --------------------------------------------------------------------------------------------------
# Execução
# --------------------------------------------------------------------------------------------------
nordeste, malha_ce = carregar_nordeste()
populacao = nordeste['pop'].to_numpy(dtype=float)
matriz_km = distancia_km(nordeste['lon'].to_numpy()[:, None], nordeste['lat'].to_numpy()[:, None],
                         nordeste['lon'].to_numpy()[None, :], nordeste['lat'].to_numpy()[None, :])
nordeste['d100'] = matriz_km[:, populacao >= 1e5].min(axis=1)
nordeste['polo_proximo'] = nordeste['municipio'].to_numpy()[populacao >= 1e5][matriz_km[:, populacao >= 1e5].argmin(axis=1)]

ce = nordeste[nordeste['UF'] == 'CE'].copy()
indices_ce = ce.index.to_numpy()
i_fortaleza = ce['pop'].idxmax()
ce['d_fortaleza'] = matriz_km[indices_ce, i_fortaleza]
ce['densidade'] = ce['pop'] / ce['area_km2']
total_ce = ce['pop'].sum()

# 1. Quantos municípios, e quantas pessoas, estão longe de um polo --------------------------------
print('\n=== 1. Distância até o município mais próximo com 100 mil habitantes ===')
distancias = []
for limite in [100, 150, 200]:
    longe = ce[ce['d100'] > limite]
    distancias.append({'mais_de_km': limite, 'municipios': len(longe), 'populacao': int(longe['pop'].sum()),
                       'pct_populacao': 100 * longe['pop'].sum() / total_ce,
                       'pct_area': 100 * longe['area_km2'].sum() / ce['area_km2'].sum()})
distancias = pd.DataFrame(distancias)
print(distancias.round(1).to_string(index=False))
distancias.to_csv(OUTPUT / 'ceara_distancia_resumo.csv', index=False, encoding='utf-8-sig')
mais_150 = ce[ce['d100'] > 150].sort_values('d100', ascending=False)[['municipio', 'pop', 'd100', 'polo_proximo', 'd_fortaleza']]
print(mais_150.round(0).to_string(index=False))
mais_150.to_csv(OUTPUT / 'ceara_municipios_a_mais_de_150km.csv', index=False, encoding='utf-8-sig')

# 2. Zonas: região metropolitana, centro/oeste e demais ------------------------------------------
print('\n=== 2. Zonas do Ceará ===')
ce['zona'] = np.where(ce['d_fortaleza'] <= 50, 'RMF (até 50 km de Fortaleza)',
                      np.where(ce['d100'] > 100, 'Centro/oeste (a mais de 100 km de um polo)', 'Demais (a até 100 km de um polo)'))
zonas = ce.groupby('zona').agg(municipios=('pop', 'size'), populacao=('pop', 'sum'), area_km2=('area_km2', 'sum'),
                               maior_municipio=('pop', 'max'), area_media_municipio=('area_km2', 'mean'))
zonas['pct_populacao'] = 100 * zonas['populacao'] / zonas['populacao'].sum()
zonas['pct_area'] = 100 * zonas['area_km2'] / zonas['area_km2'].sum()
zonas['hab_por_km2'] = zonas['populacao'] / zonas['area_km2']
print(zonas.round(1).to_string())
zonas.to_csv(OUTPUT / 'ceara_zonas.csv', encoding='utf-8-sig')
faixa = ce[(ce['pop'] >= 7e4) & (ce['pop'] < 8.5e4)].sort_values('pop', ascending=False)
print('\nMunicípios de 70 mil a 85 mil habitantes e distância ao polo mais próximo:')
print(faixa[['municipio', 'pop', 'd_fortaleza', 'd100']].round(0).to_string(index=False))
print('A menos de 50 km de um polo de 100 mil:', int((faixa['d100'] <= 50).sum()), 'de', len(faixa))
print('Faixa 50-100 mil: Ceará', int(((ce['pop'] >= 5e4) & (ce['pop'] < 1e5)).sum()),
      '| Pernambuco', int(((nordeste['UF'] == 'PE') & nordeste['pop'].between(5e4, 1e5 - 1)).sum()))

# 3. Existe gradiente com a distância à capital? Moran de I -----------------------------------------
print('\n=== 3. Gradiente espacial do tamanho dos municípios ===')
fora_rmf = ce[ce['d_fortaleza'] > 50]
rho, p_rho = stats.spearmanr(fora_rmf['d_fortaleza'], fora_rmf['pop'])
print(f'Spearman população x distância a Fortaleza (fora da RMF): rho = {rho:.3f}, p = {p_rho:.3f}')
rng = np.random.default_rng(0)
for rotulo, sub in [('Ceará inteiro', ce), ('Ceará fora da RMF', fora_rmf)]:
    d = matriz_km[np.ix_(sub.index.to_numpy(), sub.index.to_numpy())]
    pesos = ((d <= 100) & (d > 0)).astype(float)
    z = np.log(sub['pop'].to_numpy())
    z = z - z.mean()
    moran = lambda v: len(v) / pesos.sum() * (v @ pesos @ v) / (v @ v)
    observado = moran(z)
    p_moran = np.mean([moran(rng.permutation(z)) >= observado for _ in range(5000)])
    print(f'Moran I de log(população), vizinhos a até 100 km, {rotulo}: I = {observado:.3f}, p = {p_moran:.3f}')

# 4. A distância vem do número de polos ou de onde eles estão? ---------------------------------------
print('\n=== 4. Número de polos x localização ===')
polos_fora = np.flatnonzero((nordeste['UF'] != 'CE').to_numpy() & (populacao >= 1e5))
distancias_ce = matriz_km[np.ix_(indices_ce, np.arange(len(nordeste)))]
pop_ce = ce['pop'].to_numpy(dtype=float)

def pct_longe(polos_ce, limite=100):
    polos = np.concatenate([polos_fora, indices_ce[np.asarray(polos_ce, dtype=int)]])
    return 100 * pop_ce[distancias_ce[:, polos].min(axis=1) > limite].sum() / total_ce

reais = np.flatnonzero(pop_ce >= 1e5)
observado = pct_longe(reais)
print(f'Observado, com os {len(reais)} polos cearenses reais: {observado:.1f}% a mais de 100 km')
pesos_pop = pop_ce / pop_ce.sum()
linhas_sorteio = []
for k in [8, 14]:
    for nome, pesos in [('uniforme', None), ('ponderado pela população', pesos_pop)]:
        sorteios = np.array([pct_longe(rng.choice(184, k, replace=False, p=pesos)) for _ in range(5000)])
        linhas_sorteio.append({'polos': k, 'sorteio': nome, 'media_pct_longe': sorteios.mean(),
                               'p5': np.percentile(sorteios, 5), 'p95': np.percentile(sorteios, 95),
                               'prob_sorteio_menor_ou_igual_observado': np.mean(sorteios <= observado)})
        if k == 8 and pesos is not None:
            sorteios_8 = sorteios
        if k == 14 and pesos is not None:
            sorteios_14 = sorteios
sorteios_resumo = pd.DataFrame(linhas_sorteio)
print(sorteios_resumo.round(3).to_string(index=False))
sorteios_resumo.to_csv(OUTPUT / 'ceara_sorteio_de_polos.csv', index=False, encoding='utf-8-sig')

nomes = ce['municipio'].to_numpy()
rmf_satelites = [i for i in reais if nomes[i] in ('Caucaia', 'Maracanaú', 'Maranguape')]
sem_satelites = [i for i in reais if i not in rmf_satelites]
independentes = [i for i in reais if nomes[i] in ('Fortaleza', 'Sobral', 'Juazeiro do Norte', 'Itapipoca')]
print(f'Sem Caucaia, Maracanaú e Maranguape (satélites de Fortaleza): {pct_longe(sem_satelites):.1f}%')
print(f'Só Fortaleza, Sobral, Juazeiro do Norte e Itapipoca: {pct_longe(independentes):.1f}%')
escolhidos = []
for _ in range(8):
    escolhidos.append(min((c for c in range(184) if c not in escolhidos), key=lambda c: pct_longe(escolhidos + [c])))
print('Melhor posição possível para 8 polos (guloso):', f'{pct_longe(escolhidos):.1f}%')

# 5. A rejeição depende de onde termina a região metropolitana? ----------------------------------------
print('\n=== 5. Região metropolitana unida em um só município (raio a partir do maior município) ===')
def agregar(sub, raio):
    sub = sub.sort_values('pop', ascending=False).reset_index(drop=True)
    dentro = distancia_km(sub['lon'], sub['lat'], sub.loc[0, 'lon'], sub.loc[0, 'lat']) <= raio
    return np.array(list(sub.loc[~dentro, 'pop']) + [sub.loc[dentro, 'pop'].sum()], dtype=float), int(dentro.sum())

linhas_agregacao = []
for uf in UFS:
    sub = nordeste[nordeste['UF'] == uf]
    for raio in [0, 30, 50, 70]:
        pop, n_unidos = agregar(sub, raio) if raio else (sub['pop'].to_numpy(dtype=float), 0)
        ajuste = estimar_lei_potencia(pop)
        n, x_min, alfa = ajuste['n_cauda'], ajuste['x_min'], ajuste['alfa']
        p100 = (1e5 / x_min) ** (1 - alfa)
        observados = int((pop >= 1e5).sum())
        linhas_agregacao.append({'UF': uf, 'raio_km': raio, 'municipios_unidos': n_unidos, 'unidades': len(pop),
                                 'maior_unidade': int(pop.max()), 'alfa': alfa, 'x_min': int(x_min), 'n_cauda': n,
                                 'p_aderencia': p_valor_aderencia(pop, ajuste),
                                 'acima_100_mil_observados': observados, 'acima_100_mil_previstos': n * p100,
                                 'p_falta_cidades_medias': stats.binom.cdf(observados, n, p100)})
agregacao = pd.DataFrame(linhas_agregacao)
agregacao.to_csv(OUTPUT / 'agregacao_metropolitana.csv', index=False, encoding='utf-8-sig')
print(agregacao[agregacao['UF'].isin(['CE', 'PE', 'PB'])].round(3).to_string(index=False))

# Figura ----------------------------------------------------------------------------------------------
CORES_ZONA = {'RMF (até 50 km de Fortaleza)': '#D1495B', 'Demais (a até 100 km de um polo)': '#CFE1F4',
              'Centro/oeste (a mais de 100 km de um polo)': '#2B6CB0'}
cor_por_codigo = dict(zip(ce['codigo'], ce['zona'].map(CORES_ZONA)))
fig, (ax_mapa, ax_sorteio) = plt.subplots(1, 2, figsize=(11.5, 5), gridspec_kw={'width_ratios': [1.1, 1]})
partes, cores = [], []
for feature in malha_ce['features']:
    for pol in poligonos(feature['geometry']):
        partes.append(MplPolygon(np.asarray(pol[0]), closed=True))
        cores.append(cor_por_codigo[feature['properties']['codarea']])
ax_mapa.add_collection(PatchCollection(partes, facecolor=cores, edgecolor='white', linewidth=0.3))
polos_ce = ce[ce['pop'] >= 1e5]
ax_mapa.scatter(polos_ce['lon'], polos_ce['lat'], s=28, color='#222222', edgecolor='white', linewidth=0.7, zorder=3)
for _, linha in polos_ce[polos_ce['municipio'].isin(['Fortaleza', 'Sobral', 'Juazeiro do Norte', 'Itapipoca'])].iterrows():
    ax_mapa.annotate(linha['municipio'], (linha['lon'], linha['lat']), xytext=(6, 4), textcoords='offset points', fontsize=8)
ax_mapa.autoscale_view()
ax_mapa.set_aspect('equal')
ax_mapa.axis('off')
ax_mapa.set_title('(a) Zonas do Ceará e municípios com 100 mil ou mais', loc='left', fontweight='bold', fontsize=10)
legenda = [Patch(facecolor=c, label=z) for z, c in CORES_ZONA.items()]
legenda.append(Line2D([], [], marker='o', linestyle='', markerfacecolor='#222222', markeredgecolor='white', label='Município com 100 mil ou mais'))
ax_mapa.legend(handles=legenda, frameon=False, fontsize=8, loc='upper center', bbox_to_anchor=(0.5, 0.0), ncols=1)

faixas = np.arange(0, 60, 2.5)
ax_sorteio.hist(sorteios_14, bins=faixas, color='#9DB7D5', label='14 polos sorteados (previsto pela lei)', alpha=0.9)
ax_sorteio.hist(sorteios_8, bins=faixas, color='#E4A6AE', label='8 polos sorteados (número observado)', alpha=0.75)
ax_sorteio.axvline(observado, color='#222222', linewidth=1.6)
ax_sorteio.annotate(f'observado: {observado:.1f}%', (observado, ax_sorteio.get_ylim()[1] * 0.92), xytext=(5, 0),
                    textcoords='offset points', fontsize=9)
ax_sorteio.set_xlabel('população a mais de 100 km de um município com 100 mil (%)')
ax_sorteio.set_ylabel('sorteios (de 5.000)')
ax_sorteio.set_title('(b) Polos sorteados ao acaso, com probabilidade proporcional à população', loc='left', fontweight='bold', fontsize=10)
ax_sorteio.legend(frameon=False, fontsize=8.5)
for lado in ['top', 'right']:
    ax_sorteio.spines[lado].set_visible(False)
fig.tight_layout()
fig.savefig(OUTPUT / 'figura_geografia_ceara.png', dpi=200, bbox_inches='tight')
print('\nSaídas em', OUTPUT)
