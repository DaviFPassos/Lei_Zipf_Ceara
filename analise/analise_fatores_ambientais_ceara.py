"""Seca, sertão, relevo e rios: explicam o tamanho dos municípios cearenses e a distância até polos de 100 mil habitantes?

Usa os dados de data/geografia/ (baixados por coletar_dados_geograficos.py). Para executar, a partir da raiz:

    .venv/bin/python analise/analise_fatores_ambientais_ceara.py
"""
import json
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy import stats

ROOT = Path(__file__).resolve().parent.parent
GEO = ROOT / 'data' / 'geografia'
OUTPUT = ROOT / 'notebook_output' / 'geografia'
OUTPUT.mkdir(parents=True, exist_ok=True)

# Reaproveita o carregamento de municípios do script anterior (sem rodar as análises dele).
fonte = (ROOT / 'analise' / 'analise_geografica_ceara.py').read_text(encoding='utf-8')
espaco = {}
exec(compile(fonte.split('# Lei de potência')[0].replace("ROOT = Path(__file__).resolve().parent.parent", f"ROOT = Path(r'{ROOT}')")
             .replace("OUTPUT.mkdir(parents=True, exist_ok=True)", "pass"), 'carga', 'exec'), espaco)
distancia_km = espaco['distancia_km']
nordeste, _ = espaco['carregar_nordeste']()
populacao = nordeste['pop'].to_numpy(float)
matriz_km = distancia_km(nordeste['lon'].to_numpy()[:, None], nordeste['lat'].to_numpy()[:, None],
                         nordeste['lon'].to_numpy()[None, :], nordeste['lat'].to_numpy()[None, :])
nordeste['d100'] = matriz_km[:, populacao >= 1e5].min(axis=1)

# --- Chuva (NASA POWER, 2001-2023) -------------------------------------------------------------------------
chuva = json.loads((GEO / 'chuva_power_celulas.json').read_text())
def resumo_chuva(serie):
    anual = np.array([v for k, v in serie.items() if k.endswith('13')]) * 365      # mm/ano
    meses = np.array([v for k, v in serie.items() if not k.endswith('13')]).reshape(-1, 12) * 30.4  # mm/mês
    seco = (meses.mean(axis=0) < 30).sum()                                           # meses com menos de 30 mm
    return {'chuva_mm': anual.mean(), 'cv_chuva': anual.std() / anual.mean(), 'meses_secos': seco,
            'anos_secos_pct': 100 * np.mean(anual < 0.75 * anual.mean())}
celula = lambda lat, lon: f'{round(lat / 0.5) * 0.5},{round(lon / 0.625) * 0.625}'
clima = pd.DataFrame([resumo_chuva(chuva[celula(a, o)]) for a, o in zip(nordeste['lat'], nordeste['lon'])])
nordeste = pd.concat([nordeste, clima], axis=1)

# --- Relevo, rios e litoral --------------------------------------------------------------------------------------
elev = pd.read_csv(GEO / 'elevacao_municipios.csv', dtype={'codigo': str}).drop(columns=['UF'])
nordeste = nordeste.merge(elev, on='codigo', how='left')
semiarido_oficial = set(pd.read_csv(GEO / 'semiarido_2022.csv', dtype=str)['codigo'])
nordeste['semiarido'] = nordeste['codigo'].isin(semiarido_oficial)
def distancia_minima(lon, lat, pontos):
    pontos = np.asarray(pontos)
    minimo = np.full(len(lon), np.inf)
    for inicio in range(0, len(pontos), 4000):
        bloco = pontos[inicio:inicio + 4000]
        minimo = np.minimum(minimo, distancia_km(lon[:, None], lat[:, None], bloco[None, :, 0], bloco[None, :, 1]).min(axis=1))
    return minimo
lon, lat = nordeste['lon'].to_numpy(), nordeste['lat'].to_numpy()
litoral = [p for seg in json.loads((GEO / 'litoral_nordeste.json').read_text()) for p in seg]
nordeste['d_litoral'] = distancia_minima(lon, lat, litoral)
rios = json.loads((GEO / 'rios_osm.json').read_text())['elements']
def pontos_rio(nomes, caixa=None):
    pts = [(p['lon'], p['lat']) for e in rios if e['tags'].get('name') in nomes for p in e.get('geometry', [])]
    if caixa:
        pts = [p for p in pts if caixa[0] <= p[0] <= caixa[1] and caixa[2] <= p[1] <= caixa[3]]
    return pts
nordeste['d_sao_francisco'] = distancia_minima(lon, lat, pontos_rio({'Rio São Francisco'}))
rios_ce = {'Rio Jaguaribe', 'Rio Banabuiú', 'Rio Salgado', 'Rio Acaraú', 'Rio Curu', 'Rio Choró', 'Rio Coreaú'}
nordeste['d_rio_ce'] = distancia_minima(lon, lat, pontos_rio(rios_ce, (-41.5, -37.2, -7.9, -2.7)))

# Município "banhado" por um rio: algum ponto do traçado cai dentro do município (melhor que a distância do centroide).
from matplotlib.path import Path as CaminhoMpl
malhas = {uf: json.loads((ROOT / 'data' / f'ibge_malha_municipal_{nome}.geojson').read_text(encoding='utf-8'))
          for uf, nome in espaco['UFS'].items()}
poligonos_por_codigo = {f['properties']['codarea']: espaco['poligonos'](f['geometry']) for m in malhas.values() for f in m['features']}
def banhado_por(pontos):
    pontos = np.asarray(pontos)
    resultado = []
    for codigo in nordeste['codigo']:
        achou = False
        for pol in poligonos_por_codigo[codigo]:
            anel = np.asarray(pol[0])
            dentro = (pontos[:, 0] >= anel[:, 0].min()) & (pontos[:, 0] <= anel[:, 0].max()) & \
                     (pontos[:, 1] >= anel[:, 1].min()) & (pontos[:, 1] <= anel[:, 1].max())
            if dentro.any() and CaminhoMpl(anel).contains_points(pontos[dentro]).any():
                achou = True
                break
        resultado.append(achou)
    return np.array(resultado)
nordeste['banhado_sao_francisco'] = banhado_por(pontos_rio({'Rio São Francisco'}))
nordeste['banhado_rio_ce'] = banhado_por(pontos_rio(rios_ce, (-41.5, -37.2, -7.9, -2.7))) & (nordeste['UF'] == 'CE')

i_fortaleza = nordeste[nordeste['UF'] == 'CE']['pop'].idxmax()
nordeste['d_fortaleza'] = matriz_km[:, i_fortaleza]
nordeste['log_pop'] = np.log(nordeste['pop'])
nordeste['log_area'] = np.log(nordeste['area_km2'])
ce = nordeste[nordeste['UF'] == 'CE'].copy()
ce['zona'] = np.where(ce['d_fortaleza'] <= 50, '1 RMF', np.where(ce['d100'] > 100, '3 Centro/oeste', '2 Demais'))
ce.drop(columns=['codigo']).to_csv(OUTPUT / 'ceara_fatores_ambientais.csv', index=False, encoding='utf-8-sig')

pd.set_option('display.width', 220)
pd.set_option('display.max_columns', 40)

# ============================================================================================================
print('=== 0. Conferência: grandes cidades cearenses ===')
colunas = ['municipio', 'pop', 'chuva_mm', 'cv_chuva', 'elev_centro_m', 'elev_media_m', 'relevo_m', 'd_litoral', 'd_rio_ce']
print(ce[ce['pop'] >= 7e4].sort_values('pop', ascending=False)[colunas].round(0).to_string(index=False))

print('\n=== 1. Ambiente por zona do Ceará ===')
zona = ce.groupby('zona').agg(mun=('pop', 'size'), chuva_mm=('chuva_mm', 'mean'), cv_chuva=('cv_chuva', 'mean'),
                              meses_secos=('meses_secos', 'mean'), elev_media_m=('elev_media_m', 'mean'),
                              relevo_m=('relevo_m', 'mean'), d_litoral=('d_litoral', 'mean'), d_rio_ce=('d_rio_ce', 'mean'))
print(zona.round(2).to_string())
zona.to_csv(OUTPUT / 'ceara_ambiente_por_zona.csv', encoding='utf-8-sig')
print('Municípios cearenses na lista oficial do semiárido (IBGE/SUDENE 2022):', int(ce['semiarido'].sum()), 'de', len(ce))
print('Chuva (NASA POWER) mediana: semiárido', round(ce.loc[ce['semiarido'], 'chuva_mm'].median()), 'mm | fora do semiárido', round(ce.loc[~ce['semiarido'], 'chuva_mm'].median()), 'mm')

# ============================================================================================================
print('\n=== 2. O que se associa ao tamanho do município no Ceará? (Spearman, log da população) ===')
fatores = {'chuva_mm': 'chuva anual', 'cv_chuva': 'variabilidade da chuva', 'elev_media_m': 'altitude média', 'relevo_m': 'relevo interno',
           'd_litoral': 'distância ao litoral', 'd_rio_ce': 'distância a rio principal', 'd_fortaleza': 'distância a Fortaleza',
           'log_area': 'área do município'}
linhas = []
for rotulo, sub in [('Ceará (184)', ce), ('Ceará fora da RMF', ce[ce['d_fortaleza'] > 50])]:
    for coluna, nome in fatores.items():
        rho, p = stats.spearmanr(sub[coluna], sub['log_pop'])
        linhas.append({'amostra': rotulo, 'fator': nome, 'rho': rho, 'p': p})
spearman = pd.DataFrame(linhas).pivot(index='fator', columns='amostra', values=['rho', 'p']).round(3)
print(spearman.to_string())
spearman.to_csv(OUTPUT / 'ceara_spearman_fatores.csv', encoding='utf-8-sig')

def mqo(y, X, nomes):
    """Mínimos quadrados com variáveis padronizadas e erro robusto (HC1)."""
    Xp = (X - X.mean(axis=0)) / X.std(axis=0)
    A = np.column_stack([np.ones(len(y)), Xp])
    beta = np.linalg.lstsq(A, y, rcond=None)[0]
    res = y - A @ beta
    bread = np.linalg.inv(A.T @ A)
    cov = bread @ (A.T * res ** 2) @ A @ bread * len(y) / (len(y) - A.shape[1])
    erro = np.sqrt(np.diag(cov))
    r2 = 1 - res.var() / y.var()
    return pd.DataFrame({'coef_por_desvio_padrao': beta[1:], 'erro': erro[1:], 'p': 2 * stats.norm.sf(np.abs(beta[1:] / erro[1:]))}, index=nomes), r2
print('\nRegressão de log(população) em fatores padronizados (erro robusto):')
cols = ['log_area', 'chuva_mm', 'elev_media_m', 'd_litoral', 'd_rio_ce']
nomes = ['área (log)', 'chuva', 'altitude', 'dist. litoral', 'dist. rio']
saidas = []
for rotulo, sub in [('Ceará (184)', ce), ('Ceará fora da RMF', ce[ce['d_fortaleza'] > 50])]:
    tabela, r2 = mqo(sub['log_pop'].to_numpy(), sub[cols].to_numpy(float), nomes)
    print(f'{rotulo}: R² = {r2:.3f}'); print(tabela.round(3).to_string())
    saidas.append(tabela.assign(amostra=rotulo, r2=r2))
pd.concat(saidas).to_csv(OUTPUT / 'ceara_regressao_fatores.csv', encoding='utf-8-sig')
print('\nMesma regressão, trocando a distância ao rio por "banhado por rio principal" (controla a área, porque municípios maiores têm mais chance de conter um rio):')
cols2 = ['log_area', 'chuva_mm', 'elev_media_m', 'd_litoral', 'banhado_rio_ce']
nomes2 = ['área (log)', 'chuva', 'altitude', 'dist. litoral', 'banhado por rio']
for rotulo, sub in [('Ceará (184)', ce), ('Ceará fora da RMF', ce[ce['d_fortaleza'] > 50])]:
    tabela, r2 = mqo(sub['log_pop'].to_numpy(), sub[cols2].to_numpy(float), nomes2)
    print(f'{rotulo}: R² = {r2:.3f}'); print(tabela.round(3).to_string())
dp = ce[ce['d_fortaleza'] > 50]
A = np.column_stack([np.ones(len(dp)), dp['log_area'], dp['chuva_mm'] / 100, dp['d_litoral'] / 100])
beta = np.linalg.lstsq(A, dp['log_pop'].to_numpy(), rcond=None)[0]
print(f'Fora da RMF, com a área e a distância ao litoral controladas: +100 mm de chuva anual = {100 * (np.exp(beta[2]) - 1):.0f}% mais população (mediana)')
u, p_banhado = stats.mannwhitneyu(ce.loc[ce['banhado_rio_ce'], 'pop'], ce.loc[~ce['banhado_rio_ce'], 'pop'])
print(f'Banhados por rio principal x demais (população, Mann-Whitney): p = {p_banhado:.3f}')
print('Correlação entre os fatores (Ceará):')
print(ce[cols[1:]].corr(method='spearman').round(2).to_string())

# ============================================================================================================
print('\n=== 3. Serras úmidas e vales: cidades de 50 mil ou mais no Ceará ===')
ce['grande'] = ce['pop'] >= 5e4
ce['serra'] = ce['elev_media_m'] >= 500
ce['vale'] = ce['banhado_rio_ce']
ce['terco_seco'] = ce['chuva_mm'] <= ce['chuva_mm'].quantile(1 / 3)
for nome in ['serra', 'vale', 'semiarido', 'terco_seco']:
    g = ce.groupby(nome).agg(mun=('pop', 'size'), com_50mil=('grande', 'sum'), pop_mediana=('pop', 'median'), pop_total=('pop', 'sum'))
    g['pct_com_50mil'] = 100 * g['com_50mil'] / g['mun']
    print(f'\n{nome}:'); print(g.round(1).to_string())
print('\nMunicípios de serra (altitude média >= 500 m):')
print(ce[ce['serra']].sort_values('pop', ascending=False)[['municipio', 'pop', 'elev_media_m', 'chuva_mm']].round(0).head(15).to_string(index=False))

print('\nMaior município do Ceará por faixa de chuva anual (NASA POWER):')
ce['faixa_chuva'] = pd.cut(ce['chuva_mm'], [0, 750, 850, 950, 1050, 5000], labels=['até 750', '750-850', '850-950', '950-1050', 'mais de 1050'])
faixas = ce.groupby('faixa_chuva', observed=True).apply(lambda g: pd.Series({
    'municipios': len(g), 'com_50mil': int((g['pop'] >= 5e4).sum()), 'com_100mil': int((g['pop'] >= 1e5).sum()),
    'maior': g.loc[g['pop'].idxmax(), 'municipio'], 'pop_maior': int(g['pop'].max())}), include_groups=False)
print(faixas.to_string())
faixas.to_csv(OUTPUT / 'ceara_maior_cidade_por_faixa_de_chuva.csv', encoding='utf-8-sig')
dp = ce[ce['d_fortaleza'] > 50]
sd_chuva = dp['chuva_mm'].std()
coef = np.polyfit(dp['chuva_mm'] / sd_chuva, dp['log_pop'], 1)[0]
print(f'Fora da RMF, +1 desvio-padrão de chuva ({sd_chuva:.0f} mm) se associa a {100 * (np.exp(coef) - 1):.0f}% mais população (sem controles).')

# ============================================================================================================
print('\n=== 4. A região a mais de 100 km de um polo: é mais seca, mais alta, mais longe do litoral e dos rios? ===')
for coluna in ['chuva_mm', 'cv_chuva', 'elev_media_m', 'd_litoral', 'd_rio_ce']:
    centro, resto = ce.loc[ce['zona'] == '3 Centro/oeste', coluna], ce.loc[ce['zona'] == '2 Demais', coluna]
    u, p = stats.mannwhitneyu(centro, resto)
    print(f'{coluna:>12}: centro/oeste mediana {centro.median():8.1f} | demais {resto.median():8.1f} | Mann-Whitney p = {p:.4f}')
rho, p = stats.spearmanr(ce['d_litoral'], ce['d100'])
print(f'Spearman distância ao litoral x distância a um polo: rho = {rho:.2f}, p = {p:.3g}')

# ============================================================================================================
print('\n=== 5. O Ceará é diferente de outros estados com semiárido? (lista oficial IBGE/SUDENE 2022) ===')
linhas = []
for uf, sub in nordeste.groupby('UF'):
    semi = sub[sub['semiarido']]
    linhas.append({'UF': uf, 'municipios': len(sub), 'pct_municipios_semiaridos': 100 * len(semi) / len(sub),
                   'pop_semiarida_mil': semi['pop'].sum() / 1e3,
                   'polos_100mil_no_semiarido': int((semi['pop'] >= 1e5).sum()),
                   'pct_pop_semiarida_em_polos_100mil': 100 * semi.loc[semi['pop'] >= 1e5, 'pop'].sum() / max(semi['pop'].sum(), 1),
                   'pct_pop_semiarida_a_mais_de_100km_de_polo': 100 * semi.loc[semi['d100'] > 100, 'pop'].sum() / max(semi['pop'].sum(), 1),
                   'chuva_media_ponderada_mm': np.average(sub['chuva_mm'], weights=sub['pop'])})
estados_semi = pd.DataFrame(linhas).round(1)
print(estados_semi.to_string(index=False))
estados_semi.to_csv(OUTPUT / 'nordeste_semiarido_por_estado.csv', index=False, encoding='utf-8-sig')

print('\nMunicípios do Nordeste com 100 mil ou mais e chuva anual (NASA POWER) até 850 mm:')
secas = nordeste[(nordeste['pop'] >= 1e5) & (nordeste['chuva_mm'] <= 850)].sort_values('pop', ascending=False)
print(secas[['UF', 'municipio', 'pop', 'chuva_mm', 'banhado_sao_francisco']].round(0).to_string(index=False))
print('Por estado: municípios ≥100 mil com chuva ≤ 850 mm:', secas['UF'].value_counts().to_dict())
secos = nordeste[nordeste['chuva_mm'] <= 850]
ce_seco, fora_seco = secos[secos['UF'] == 'CE'], secos[secos['UF'] != 'CE']
tabela_f = [[int((ce_seco['pop'] >= 1e5).sum()), int((ce_seco['pop'] < 1e5).sum())],
            [int((fora_seco['pop'] >= 1e5).sum()), int((fora_seco['pop'] < 1e5).sum())]]
print(f'Municípios secos (chuva <= 850 mm) com 100 mil+: Ceará {tabela_f[0][0]} de {len(ce_seco)} | resto do Nordeste {tabela_f[1][0]} de {len(fora_seco)}; '
      f'Fisher p = {stats.fisher_exact(tabela_f)[1]:.2f}')
tabela_f50 = [[int((ce_seco['pop'] >= 5e4).sum()), int((ce_seco['pop'] < 5e4).sum())],
              [int((fora_seco['pop'] >= 5e4).sum()), int((fora_seco['pop'] < 5e4).sum())]]
print(f'Municípios secos com 50 mil+: Ceará {tabela_f50[0][0]} de {len(ce_seco)} | resto {tabela_f50[1][0]} de {len(fora_seco)}; Fisher p = {stats.fisher_exact(tabela_f50)[1]:.2f}')

# ============================================================================================================
print('\n=== 6. Rio São Francisco ===')
sf = nordeste.sort_values('d_sao_francisco')
mais_perto = ce.sort_values('d_sao_francisco').iloc[0]
print('Município cearense mais próximo do rio:', mais_perto['municipio'], round(mais_perto['d_sao_francisco']), 'km')
print('Menor distância ao rio por estado (km):')
print(nordeste.groupby('UF')['d_sao_francisco'].min().round(0).to_string())
beira = nordeste[nordeste['banhado_sao_francisco'] & (nordeste['pop'] >= 5e4)].sort_values('pop', ascending=False)
print('\nMunicípios com 50 mil ou mais banhados pelo São Francisco:')
print(beira[['UF', 'municipio', 'pop', 'chuva_mm']].round(0).to_string(index=False))
sem = nordeste[nordeste['semiarido']]
banh, resto = sem[sem['banhado_sao_francisco']], sem[~sem['banhado_sao_francisco']]
print(f'Semiárido, banhados pelo rio: {len(banh)} mun., mediana {banh["pop"].median():.0f}, {100 * (banh["pop"] >= 5e4).mean():.1f}% com 50 mil+, '
      f'{100 * (banh["pop"] >= 1e5).mean():.1f}% com 100 mil+ | demais: {len(resto)} mun., mediana {resto["pop"].median():.0f}, '
      f'{100 * (resto["pop"] >= 5e4).mean():.1f}% com 50 mil+, {100 * (resto["pop"] >= 1e5).mean():.1f}% com 100 mil+')
tab_sf = [[int((banh['pop'] >= 1e5).sum()), int((banh['pop'] < 1e5).sum())], [int((resto['pop'] >= 1e5).sum()), int((resto['pop'] < 1e5).sum())]]
print(f'Semiárido, 100 mil+: banhados pelo São Francisco {tab_sf[0][0]} de {len(banh)} | demais {tab_sf[1][0]} de {len(resto)}; Fisher p = {stats.fisher_exact(tab_sf)[1]:.3f}')
banh_ce = ce[ce['banhado_rio_ce']]
print(f'Ceará: {len(banh_ce)} municípios banhados por rios principais (Jaguaribe, Banabuiú, Salgado, Acaraú, Curu, Choró, Coreaú); '
      f'mediana {banh_ce["pop"].median():.0f} contra {ce.loc[~ce["banhado_rio_ce"], "pop"].median():.0f} dos demais; '
      f'{100 * (banh_ce["pop"] >= 5e4).mean():.1f}% contra {100 * (ce.loc[~ce["banhado_rio_ce"], "pop"] >= 5e4).mean():.1f}% com 50 mil+')

# ============================================================================================================
print('\n=== 7. Água: todos os trechos de rio e açudes (OpenStreetMap) no Cariri e na região central ===')
trechos = json.loads((GEO / 'rios_todos_ceara.json').read_text())
meios, comprimentos = [], []
for trecho in trechos:
    t = np.asarray(trecho)
    if len(t) < 2:
        continue
    meios.append((t[1:] + t[:-1]) / 2)
    comprimentos.append(distancia_km(t[1:, 0], t[1:, 1], t[:-1, 0], t[:-1, 1]))
meios, comprimentos = np.vstack(meios), np.concatenate(comprimentos)
acudes = pd.read_csv(GEO / 'acudes_osm.csv')
acudes = acudes[acudes['area_km2'] >= 0.05]          # ignora tanques e poças menores que 5 hectares
pontos_acudes = acudes[['lon', 'lat']].to_numpy()
rio_km, acude_n, acude_km2, acude_grande = [], [], [], []
for codigo in ce['codigo']:
    dentro_rio = np.zeros(len(meios), dtype=bool)
    dentro_acude = np.zeros(len(acudes), dtype=bool)
    for pol in poligonos_por_codigo[codigo]:
        anel = np.asarray(pol[0])
        caixa = lambda pts: (pts[:, 0] >= anel[:, 0].min()) & (pts[:, 0] <= anel[:, 0].max()) & (pts[:, 1] >= anel[:, 1].min()) & (pts[:, 1] <= anel[:, 1].max())
        for pts, dentro in [(meios, dentro_rio), (pontos_acudes, dentro_acude)]:
            candidatos = np.flatnonzero(caixa(pts))
            if len(candidatos):
                dentro[candidatos[CaminhoMpl(anel).contains_points(pts[candidatos])]] = True
    rio_km.append(comprimentos[dentro_rio].sum())
    acude_n.append(int(dentro_acude.sum()))
    acude_km2.append(acudes.loc[dentro_acude, 'area_km2'].sum())
    acude_grande.append(int((acudes.loc[dentro_acude, 'area_km2'] >= 5).sum()))
ce['rio_km_por_100km2'] = 100 * np.array(rio_km) / ce['area_km2'].to_numpy()
ce['acudes'] = acude_n
ce['espelho_dagua_pct_area'] = 100 * np.array(acude_km2) / ce['area_km2'].to_numpy()
ce['acudes_5km2'] = acude_grande
ce['log_espelho'] = np.log1p(np.array(acude_km2))

d_juazeiro = matriz_km[ce.index.to_numpy(), nordeste.index[(nordeste['municipio'] == 'Juazeiro do Norte') & (nordeste['UF'] == 'CE')][0]]
ce['grupo'] = np.where(d_juazeiro <= 50, 'Cariri (até 50 km de Juazeiro do Norte)',
                       np.where(ce['zona'] == '3 Centro/oeste', 'Centro/oeste (a mais de 100 km de um polo)',
                                np.where(ce['zona'] == '1 RMF', 'RMF', 'Demais')))
agua = ce.groupby('grupo').agg(mun=('pop', 'size'), pop_mediana=('pop', 'median'), pop_total=('pop', 'sum'), chuva_mm=('chuva_mm', 'mean'),
                               rio_km_por_100km2=('rio_km_por_100km2', 'mean'), banhados_por_rio_principal=('banhado_rio_ce', 'sum'),
                               acudes=('acudes', 'sum'), acudes_5km2=('acudes_5km2', 'sum'),
                               espelho_dagua_pct_area=('espelho_dagua_pct_area', 'mean'))
print(agua.round(2).to_string())
agua.to_csv(OUTPUT / 'ceara_agua_por_grupo.csv', encoding='utf-8-sig')
cariri_ce, centro_ce = ce[ce['grupo'].str.startswith('Cariri')], ce[ce['grupo'].str.startswith('Centro')]
print('\nCariri x região central (Mann-Whitney):')
for coluna in ['chuva_mm', 'rio_km_por_100km2', 'espelho_dagua_pct_area', 'acudes', 'banhado_rio_ce']:
    print(f'{coluna:>24}: Cariri média {cariri_ce[coluna].mean():7.2f} | centro/oeste {centro_ce[coluna].mean():7.2f} | p = {stats.mannwhitneyu(cariri_ce[coluna], centro_ce[coluna])[1]:.3f}')
print('\nMaiores açudes (OSM) por grupo (nome, km²):')
acudes['no_grupo'] = ''
for grupo, sub in ce.groupby('grupo'):
    nomes_grandes = []
    for codigo in sub['codigo']:
        for pol in poligonos_por_codigo[codigo]:
            anel = np.asarray(pol[0])
            m = acudes[(acudes['lon'] >= anel[:, 0].min()) & (acudes['lon'] <= anel[:, 0].max()) & (acudes['lat'] >= anel[:, 1].min()) & (acudes['lat'] <= anel[:, 1].max())]
            m = m[CaminhoMpl(anel).contains_points(m[['lon', 'lat']].to_numpy())] if len(m) else m
            nomes_grandes += [(r['nome'] or '(sem nome)', round(r['area_km2'], 1)) for _, r in m[m['area_km2'] >= 10].iterrows()]
    print(f'  {grupo}:', sorted(nomes_grandes, key=lambda t: -t[1])[:6])
print('\nRegressão (fora da RMF): log(população) em área, chuva, litoral, rios e açudes (padronizados, erro robusto)')
sub = ce[ce['zona'] != '1 RMF']
cols3 = ['log_area', 'chuva_mm', 'd_litoral', 'rio_km_por_100km2', 'log_espelho']
tabela, r2 = mqo(sub['log_pop'].to_numpy(), sub[cols3].to_numpy(float), ['área (log)', 'chuva', 'dist. litoral', 'rios (km/100 km²)', 'açudes (log área)'])
print(f'R² = {r2:.3f}'); print(tabela.round(3).to_string())
tabela.to_csv(OUTPUT / 'ceara_regressao_agua.csv', encoding='utf-8-sig')
for coluna in ['rio_km_por_100km2', 'espelho_dagua_pct_area']:
    rho, p = stats.spearmanr(sub[coluna], sub['log_pop'])
    print(f'Spearman {coluna} x log(população), fora da RMF: rho = {rho:.3f}, p = {p:.3f}')

# --- Figura ------------------------------------------------------------------------------------------------------
fig, eixos = plt.subplots(1, 3, figsize=(13, 4.3))
cor_zona = {'1 RMF': '#D1495B', '2 Demais': '#9DB7D5', '3 Centro/oeste': '#2B6CB0'}
for z, sub in ce.groupby('zona'):
    eixos[0].scatter(sub['d_litoral'], sub['chuva_mm'], s=14 + sub['pop'] / 8000, color=cor_zona[z], alpha=0.8, label=z[2:])
eixos[0].set_xlabel('distância ao litoral (km)')
eixos[0].set_ylabel('chuva anual (mm)')
eixos[0].set_title('(a) Chuva e litoral (tamanho = população)', loc='left', fontweight='bold', fontsize=10)
eixos[0].legend(frameon=False, fontsize=8)
for z, sub in ce.groupby('zona'):
    eixos[1].scatter(sub['elev_media_m'], sub['pop'], s=16, color=cor_zona[z], alpha=0.8)
eixos[1].set_yscale('log')
eixos[1].set_xlabel('altitude média do município (m)')
eixos[1].set_ylabel('população')
eixos[1].set_title('(b) Altitude e população', loc='left', fontweight='bold', fontsize=10)
for z, sub in ce.groupby('zona'):
    eixos[2].scatter(sub['d_rio_ce'], sub['pop'], s=16, color=cor_zona[z], alpha=0.8)
eixos[2].set_yscale('log')
eixos[2].set_xlabel('distância a um rio principal (km)')
eixos[2].set_title('(c) Rios e população', loc='left', fontweight='bold', fontsize=10)
for ax in eixos:
    for lado in ['top', 'right']:
        ax.spines[lado].set_visible(False)
fig.tight_layout()
fig.savefig(OUTPUT / 'figura_fatores_ambientais_ceara.png', dpi=200, bbox_inches='tight')
print('\nSaídas em', OUTPUT)
