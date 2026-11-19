"""Cariri x região central do Ceará: economia, serviços, mercado e crescimento (2010-2022).

Usa os dados de data/socioeconomico/ (coletar_dados_socioeconomicos.py) e de data/geografia/. Para executar:

    .venv/bin/python analise/analise_cariri_centro.py
"""
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy import stats

ROOT = Path(__file__).resolve().parent.parent
SOCIO = ROOT / 'data' / 'socioeconomico'
OUTPUT = ROOT / 'notebook_output' / 'geografia'
OUTPUT.mkdir(parents=True, exist_ok=True)

# Funções do script de análise geográfica (carregamento dos municípios e lei de potência), sem rodar as análises dele.
fonte = (ROOT / 'analise' / 'analise_geografica_ceara.py').read_text(encoding='utf-8')
espaco = {}
exec(compile(fonte.split('nordeste, malha_ce = carregar_nordeste()')[0]
             .replace("ROOT = Path(__file__).resolve().parent.parent", f"ROOT = Path(r'{ROOT}')")
             .replace("OUTPUT.mkdir(parents=True, exist_ok=True)", "pass"), 'carga', 'exec'), espaco)
distancia_km = espaco['distancia_km']
estimar_lei_potencia, p_valor_aderencia = espaco['estimar_lei_potencia'], espaco['p_valor_aderencia']
nordeste, _ = espaco['carregar_nordeste']()
populacao = nordeste['pop'].to_numpy(float)
matriz_km = distancia_km(nordeste['lon'].to_numpy()[:, None], nordeste['lat'].to_numpy()[:, None],
                         nordeste['lon'].to_numpy()[None, :], nordeste['lat'].to_numpy()[None, :])
nordeste['d100'] = matriz_km[:, populacao >= 1e5].min(axis=1)

# --- Dados socioeconômicos --------------------------------------------------------------------------------------
pop = pd.read_csv(SOCIO / 'populacao_2010_2022.csv', dtype={'codigo': str}).rename(columns={'v93': 'pop22', 'v5936': 'var_2010', 'v10605': 'taxa_aa'})
pop['pop10'] = pop['pop22'] - pop['var_2010']
pib = pd.read_csv(SOCIO / 'pib_2021.csv', dtype={'codigo': str}).rename(columns={
    'v37': 'pib_mil', 'v498': 'vab', 'v513': 'vab_agro', 'v517': 'vab_ind', 'v6575': 'vab_serv', 'v525': 'vab_adm'})
cempre = pd.read_csv(SOCIO / 'cempre_2022.csv', dtype={'codigo': str}).rename(columns={
    'v706': 'unidades_locais', 'v707': 'pessoal_ocupado', 'v708': 'assalariados', 'v662': 'massa_salarial_mil', 'v10143': 'salario_medio_mensal'})
hosp = pd.read_csv(SOCIO / 'hospitais_ceara_cnes.csv', dtype={'codigo': str})
hosp['ensino'] = hosp['ensino'].astype(str).str.zfill(2).isin(['01', '02', '03'])
hosp_mun = hosp.groupby('codigo').agg(hospitais=('codigo_cnes', 'size'), hosp_cirurgico=('centro_cirurgico', 'sum'), hosp_ensino=('ensino', 'sum')).reset_index()

d = nordeste.merge(pop[['codigo', 'pop10', 'taxa_aa']], on='codigo', how='left').merge(pib.drop(columns=['vab']).assign(vab=pib['vab']), on='codigo', how='left')\
            .merge(cempre, on='codigo', how='left').merge(hosp_mun, on='codigo', how='left')
d[['hospitais', 'hosp_cirurgico', 'hosp_ensino']] = d[['hospitais', 'hosp_cirurgico', 'hosp_ensino']].fillna(0)
d['crescimento_pct'] = 100 * (d['pop'] / d['pop10'] - 1)
d['pib_per_capita'] = d['pib_mil'] * 1000 / d['pop']
d['empregos_por_100hab'] = 100 * d['pessoal_ocupado'] / d['pop']
d['massa_salarial_per_capita'] = d['massa_salarial_mil'] * 1000 / d['pop']
for setor in ['agro', 'ind', 'serv', 'adm']:
    d[f'pct_{setor}'] = 100 * d[f'vab_{setor}'] / d['vab']
d['log_pop10'] = np.log(d['pop10'])
# Mercado potencial: população do Nordeste a até 50 e 100 km do centro do município (sem contá-lo).
for raio in (50, 100):
    d[f'pop_ate_{raio}km'] = [(populacao[(matriz_km[i] <= raio)].sum() - populacao[i]) for i in range(len(d))]

# --- Grupos do Ceará (mesma definição da análise anterior) -----------------------------------------------------------
ce = d[d['UF'] == 'CE'].copy()
i_fortaleza, i_juazeiro = ce['pop'].idxmax(), ce.index[ce['municipio'] == 'Juazeiro do Norte'][0]
ce['d_fortaleza'] = matriz_km[ce.index, i_fortaleza]
ce['d_juazeiro'] = matriz_km[ce.index, i_juazeiro]
ce['grupo'] = np.where(ce['d_fortaleza'] <= 50, 'RMF', np.where(ce['d_juazeiro'] <= 50, 'Cariri',
                       np.where(ce['d100'] > 100, 'Centro/oeste', 'Demais')))
pd.set_option('display.width', 230)
pd.set_option('display.max_columns', 40)

def agregado(sub):
    return pd.Series({
        'mun': len(sub), 'pop_2010_mil': sub['pop10'].sum() / 1e3, 'pop_2022_mil': sub['pop'].sum() / 1e3,
        'cresc_2010_22_pct': 100 * (sub['pop'].sum() / sub['pop10'].sum() - 1),
        'pib_per_capita_R$': sub['pib_mil'].sum() * 1000 / sub['pop'].sum(),
        'servicos_%': 100 * sub['vab_serv'].sum() / sub['vab'].sum(), 'adm_publica_%': 100 * sub['vab_adm'].sum() / sub['vab'].sum(),
        'industria_%': 100 * sub['vab_ind'].sum() / sub['vab'].sum(), 'agro_%': 100 * sub['vab_agro'].sum() / sub['vab'].sum(),
        'empregos_por_100hab': 100 * sub['pessoal_ocupado'].sum() / sub['pop'].sum(),
        'salario_medio_R$': 1000 * sub['massa_salarial_mil'].sum() / (12 * sub['assalariados'].sum()),
        'hospitais': sub['hospitais'].sum(), 'hospitais_100mil_hab': 1e5 * sub['hospitais'].sum() / sub['pop'].sum(),
        'hosp_com_centro_cirurgico': sub['hosp_cirurgico'].sum(), 'hosp_de_ensino': sub['hosp_ensino'].sum()})

print('=== 1. Grupos do Ceará (valores agregados) ===')
tabela_grupos = ce.groupby('grupo').apply(agregado, include_groups=False).loc[['RMF', 'Cariri', 'Demais', 'Centro/oeste']]
print(tabela_grupos.round(1).T.to_string())
tabela_grupos.to_csv(OUTPUT / 'cariri_centro_grupos.csv', encoding='utf-8-sig')

print('\n=== 2. Cariri x Centro/oeste, município a município (Mann-Whitney) ===')
cariri, centro = ce[ce['grupo'] == 'Cariri'], ce[ce['grupo'] == 'Centro/oeste']
linhas = []
for coluna, nome in [('crescimento_pct', 'crescimento 2010-22 (%)'), ('pib_per_capita', 'PIB per capita (R$)'), ('empregos_por_100hab', 'empregos por 100 hab'),
                     ('salario_medio_mensal', 'salário médio mensal (R$)'), ('pct_serv', 'serviços (% do VAB)'), ('pct_adm', 'adm. pública (% do VAB)'),
                     ('pct_agro', 'agropecuária (% do VAB)'), ('pct_ind', 'indústria (% do VAB)'), ('pop_ate_50km', 'população a até 50 km'),
                     ('pop_ate_100km', 'população a até 100 km')]:
    a, b = cariri[coluna].dropna(), centro[coluna].dropna()
    linhas.append({'medida': nome, 'cariri_mediana': a.median(), 'centro_oeste_mediana': b.median(), 'p_mann_whitney': stats.mannwhitneyu(a, b)[1]})
comparacao = pd.DataFrame(linhas)
print(comparacao.round(3).to_string(index=False))
comparacao.to_csv(OUTPUT / 'cariri_centro_testes.csv', index=False, encoding='utf-8-sig')

print('\nMunicípios que perderam população entre 2010 e 2022:')
for g in ['RMF', 'Cariri', 'Demais', 'Centro/oeste']:
    sub = ce[ce['grupo'] == g]
    print(f'  {g}: {int((sub["crescimento_pct"] < 0).sum())} de {len(sub)}')
print('Juazeiro do Norte + Crato + Barbalha:', int(ce[ce['municipio'].isin(['Juazeiro do Norte', 'Crato', 'Barbalha'])]['pop'].sum()))

print('\n=== 3. As cidades que disputam o papel de polo ===')
cidades = ['Juazeiro do Norte', 'Crato', 'Barbalha', 'Sobral', 'Itapipoca', 'Iguatu', 'Quixadá', 'Quixeramobim', 'Crateús', 'Tauá', 'Russas', 'Canindé', 'Limoeiro do Norte', 'Morada Nova']
polos = ce[ce['municipio'].isin(cidades)].set_index('municipio').loc[cidades]
cols = ['grupo', 'pop', 'crescimento_pct', 'pib_per_capita', 'empregos_por_100hab', 'salario_medio_mensal', 'pct_serv', 'pct_adm', 'hospitais', 'hosp_cirurgico', 'hosp_ensino', 'pop_ate_50km', 'pop_ate_100km']
print(polos[cols].round(1).to_string())
polos[cols].to_csv(OUTPUT / 'cariri_centro_cidades.csv', encoding='utf-8-sig')

print('\n=== 4. Crescimento proporcional (lei de Gibrat): o crescimento 2010-2022 depende do tamanho em 2010? ===')
rho, p = stats.spearmanr(ce['log_pop10'], ce['crescimento_pct'])
print(f'Ceará (184): Spearman tamanho x crescimento: rho = {rho:.3f}, p = {p:.3f}')
fora = ce[ce['grupo'] != 'RMF']
rho2, p2 = stats.spearmanr(fora['log_pop10'], fora['crescimento_pct'])
print(f'Ceará fora da RMF ({len(fora)}): rho = {rho2:.3f}, p = {p2:.3f}')
classes = pd.cut(ce['pop10'], [0, 1e4, 2e4, 5e4, 7e4, 1e5, 2e5, 5e6], labels=['<10 mil', '10-20 mil', '20-50 mil', '50-70 mil', '70-100 mil', '100-200 mil', '200 mil+'])
cresc_classe = ce.groupby(classes, observed=True)['crescimento_pct'].agg(['count', 'median', 'mean']).round(1)
print('Crescimento 2010-22 por faixa de tamanho em 2010:'); print(cresc_classe.to_string())
cresc_classe.to_csv(OUTPUT / 'ceara_crescimento_por_faixa.csv', encoding='utf-8-sig')
for uf in ['CE', 'PE', 'BA', 'PB', 'RN', 'PI', 'MA', 'AL', 'SE']:
    sub = d[d['UF'] == uf]
    rho_uf, p_uf = stats.spearmanr(sub['log_pop10'], sub['crescimento_pct'])
    print(f'  {uf}: rho = {rho_uf:+.3f} (p = {p_uf:.3f}); crescimento mediano dos municípios com 50 mil+ em 2010: {sub.loc[sub["pop10"] >= 5e4, "crescimento_pct"].median():.1f}% | dos menores de 20 mil: {sub.loc[sub["pop10"] < 2e4, "crescimento_pct"].median():.1f}%')
print('\nFaixa 70-130 mil em 2022 (o degrau):')
faixa = ce[(ce['pop'] >= 7e4) & (ce['pop'] < 1.3e5)].sort_values('pop', ascending=False)
print(faixa[['municipio', 'grupo', 'pop10', 'pop', 'crescimento_pct']].round(1).to_string(index=False))

print('\n=== 5. A lei de potência em 2010: o Ceará já era rejeitado? ===')
linhas_2010 = []
for uf in ['CE', 'PE', 'BA', 'PB', 'RN', 'PI', 'MA', 'AL', 'SE']:
    sub = d[d['UF'] == uf]
    for ano, coluna in [(2010, 'pop10'), (2022, 'pop')]:
        valores = sub[coluna].to_numpy(float)
        ajuste = estimar_lei_potencia(valores)
        p_aderencia = p_valor_aderencia(valores, ajuste)
        linhas_2010.append({'UF': uf, 'ano': ano, 'alfa': ajuste['alfa'], 'x_min': int(ajuste['x_min']), 'n_cauda': ajuste['n_cauda'],
                            'p_aderencia': p_aderencia, 'acima_100_mil': int((valores >= 1e5).sum()), 'maior_municipio': int(valores.max())})
zipf_anos = pd.DataFrame(linhas_2010)
print(zipf_anos.pivot(index='UF', columns='ano', values=['alfa', 'p_aderencia', 'acima_100_mil']).round(3).to_string())
zipf_anos.to_csv(OUTPUT / 'zipf_2010_2022.csv', index=False, encoding='utf-8-sig')

# --- Figura ------------------------------------------------------------------------------------------------------
cores = {'RMF': '#D1495B', 'Cariri': '#E9A23B', 'Demais': '#9DB7D5', 'Centro/oeste': '#2B6CB0'}
fig, eixos = plt.subplots(1, 3, figsize=(14, 4.4))
for g, sub in ce.groupby('grupo'):
    eixos[0].scatter(sub['pop'], sub['empregos_por_100hab'], s=18, color=cores[g], alpha=0.85, label=g)
eixos[0].set_xscale('log')
eixos[0].set_xlabel('população em 2022')
eixos[0].set_ylabel('empregos por 100 habitantes (CEMPRE)')
eixos[0].set_title('(a) Empregos e tamanho', loc='left', fontweight='bold', fontsize=10)
eixos[0].legend(frameon=False, fontsize=8)
grandes = ce[ce['pop'] >= 4e4]
for g, sub in grandes.groupby('grupo'):
    eixos[1].scatter(sub['pop_ate_100km'] / 1e3, sub['pop'], s=24, color=cores[g], alpha=0.9)
for nome in ['Juazeiro do Norte', 'Crato', 'Sobral', 'Iguatu', 'Quixadá', 'Quixeramobim', 'Crateús', 'Itapipoca']:
    linha = ce[ce['municipio'] == nome].iloc[0]
    eixos[1].annotate(nome, (linha['pop_ate_100km'] / 1e3, linha['pop']), xytext=(4, 3), textcoords='offset points', fontsize=7.5)
eixos[1].set_yscale('log')
eixos[1].set_xlabel('população do Nordeste a até 100 km (mil)')
eixos[1].set_ylabel('população do município')
eixos[1].set_title('(b) Mercado ao redor (municípios de 40 mil+)', loc='left', fontweight='bold', fontsize=10)
posicoes = np.arange(len(cresc_classe))
eixos[2].bar(posicoes, cresc_classe['median'], color='#2B6CB0')
eixos[2].set_xticks(posicoes, cresc_classe.index, rotation=35, ha='right', fontsize=8)
eixos[2].set_ylabel('crescimento mediano 2010-2022 (%)')
eixos[2].set_title('(c) Crescimento por tamanho em 2010', loc='left', fontweight='bold', fontsize=10)
for ax in eixos:
    for lado in ['top', 'right']:
        ax.spines[lado].set_visible(False)
fig.tight_layout()
fig.savefig(OUTPUT / 'figura_cariri_centro.png', dpi=200, bbox_inches='tight')
print('\nSaídas em', OUTPUT)
