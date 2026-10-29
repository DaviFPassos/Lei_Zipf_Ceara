# A distribuição populacional dos municípios cearenses segue a Lei de Zipf?

Trabalho da disciplina **Ciência de Dados Aplicada à Ciência das Cidades**, do Mestrado em Ciência da Computação da Universidade de Fortaleza (Unifor).

**Autor:** Davi Passos

## Sobre o trabalho

O estudo investiga se a hierarquia populacional dos 184 municípios do Ceará segue a Lei de Zipf, segundo a qual a população de uma cidade é inversamente proporcional à sua posição no ranking. Em escala logarítmica, isso produz uma reta de inclinação próxima de −1, e o expoente de Zipf *q* seria próximo de 1.

- **Dados:** população residente do Censo Demográfico 2022 (IBGE, SIDRA, tabela 4709, variável 93) e malha municipal do IBGE.
- **Método:** regressão linear por mínimos quadrados de log₁₀(população) sobre log₁₀(posição), com o expoente *q* = −β. O notebook também calcula o R², o intervalo de confiança de 95% e o teste de H₀: β = −1. Os ajustes são feitos para os 184 municípios e para os 20 maiores.
- **Medidas auxiliares:** participação de Fortaleza na população estadual, razão Fortaleza/Caucaia e coeficiente de Gini das populações municipais.

## Resultados

| Resultado | Valor |
|---|---:|
| Municípios | 184 |
| *q* (184 municípios) | 0,9015 |
| R² (184 municípios) | 0,9403 |
| IC 95% da inclinação (184) | −0,935 a −0,868 |
| *q* (20 maiores) | 0,9883 |
| R² (20 maiores) | 0,8910 |
| IC 95% da inclinação (20 maiores) | −1,159 a −0,817 |
| Participação de Fortaleza | 27,61% |
| Razão Fortaleza/Caucaia | 6,83 |
| Gini das populações municipais | 0,6172 |

**Conclusão:** os 20 maiores municípios são compatíveis com a Lei de Zipf (a hipótese *q* = 1 não é rejeitada, *p* = 0,887). Pelo erro padrão usual da regressão, o conjunto completo tem distribuição mais rasa que a lei estrita (*p* < 0,001), mas esse erro é subestimado; com o erro de Gabaix e Ibragimov (2011), *q* = 1 não é rejeitado (*p* = 0,29). O R² elevado mostra que a relação é bem descrita por uma reta, mas não prova que a distribuição seja uma lei de potência nem que a posição cause o tamanho das cidades.

## Comparação com outros estados

A seção 12 do notebook repete o mesmo estudo para sete estados do Nordeste, do Sudeste e do Sul (Bahia, São Paulo, Rio de Janeiro, Minas Gerais, Paraná, Santa Catarina e Rio Grande do Sul), com os mesmos dados e o mesmo método.

| Resultado | CE | BA | SP | RJ | MG | PR | SC | RS |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Municípios | 184 | 417 | 645 | 92 | 853 | 399 | 295 | 497 |
| Participação da maior cidade | 27,6% | 17,1% | 25,8% | 38,7% | 11,3% | 15,5% | 8,1% | 12,2% |
| Razão 1ª/2ª | 6,83 | 3,92 | 8,87 | 6,93 | 3,25 | 3,19 | 1,15 | 2,88 |
| Gini | 0,617 | 0,584 | 0,802 | 0,769 | 0,693 | 0,709 | 0,703 | 0,740 |
| *q* (todos) | 0,901 | 0,831 | 1,410 | 1,420 | 1,068 | 1,122 | 1,218 | 1,240 |
| *q* (20 maiores) | 0,988 | 0,927 | 0,878 | 1,041 | 0,872 | 0,840 | 0,787 | 0,746 |
| *p* do teste *q* = 1 (20 maiores, erro usual) | 0,887 | 0,207 | 0,199 | 0,540 | < 0,001 | < 0,001 | < 0,001 | < 0,001 |

Na participação da maior cidade, o Ceará só fica atrás do Rio de Janeiro; na razão 1ª/2ª, só São Paulo e Rio de Janeiro superam Fortaleza. Santa Catarina é o estado mais policêntrico (Joinville é só 1,15 vez maior que Florianópolis). Pelo erro usual da regressão, a Lei de Zipf é rejeitada entre os 20 maiores em Minas Gerais, no Paraná, em Santa Catarina e no Rio Grande do Sul, mas esse erro é subestimado (veja a seção seguinte). Com todos os municípios, *q* varia de 0,83 a 1,42, porque depende dos municípios pequenos de cada estado.

## Estimação por máxima verossimilhança (Newman, 2005)

A seção 13 do notebook segue as recomendações de Newman (2005): estima o expoente α da lei de potência p(x) ∝ x^(−α) por máxima verossimilhança, só na cauda acima de x_min, escolhido pelo critério de Kolmogorov-Smirnov, e testa a aderência por bootstrap (Clauset, Shalizi e Newman, 2009). A relação com o expoente de Zipf é *q* = 1/(α − 1), de modo que a Lei de Zipf corresponde a α = 2. A seção também refaz o teste *q* = 1 da regressão com o erro padrão de Gabaix e Ibragimov (2011).

| Resultado | CE | BA | SP | RJ | MG | PR | SC | RS |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| x_min (habitantes) | 15.157 | 24.661 | 16.641 | 116.841 | 10.275 | 10.233 | 9.792 | 2.480 |
| Municípios na cauda | 129 | 123 | 287 | 26 | 364 | 192 | 135 | 414 |
| α (máxima verossimilhança) | 2,18 ± 0,10 | 2,44 ± 0,13 | 1,79 ± 0,05 | 2,12 ± 0,22 | 2,08 ± 0,06 | 2,05 ± 0,08 | 1,95 ± 0,08 | 1,73 ± 0,04 |
| *p* do teste α = 2 | 0,089 | < 0,001 | < 0,001 | 0,580 | 0,158 | 0,539 | 0,553 | < 0,001 |
| *p* de aderência (bootstrap) | 0,033 | 0,728 | 0,000 | 0,412 | 0,227 | 0,663 | 0,380 | 0,012 |
| *p* do teste *q* = 1, 20 maiores, erro de Gabaix-Ibragimov | 0,970 | 0,802 | 0,659 | 0,900 | 0,641 | 0,547 | 0,391 | 0,281 |
| Municípios ≥ 100 mil, previstos / observados | 14,0 / 8 | 16,4 / 18 | 70,2 / 78 | 31,0 / 28 | 31,2 / 34 | 17,7 / 22 | 14,8 / 14 | 27,4 / 19 |

O Ceará é o único dos oito estados em que o expoente é compatível com Zipf, mas a lei de potência é rejeitada (*p* = 0,033), e o que tem a maior falta relativa de cidades médias: 8 municípios acima de 100 mil habitantes, onde o ajuste prevê 14. Com o erro padrão corrigido, nenhum estado rejeita *q* = 1 entre os 20 maiores. A lei de potência é plausível na Bahia, no Rio de Janeiro, em Minas Gerais, no Paraná e em Santa Catarina, e rejeitada em São Paulo e no Rio Grande do Sul. No Rio de Janeiro, a cauda tem só 26 municípios, e o teste tem pouco poder.

## Estrutura do projeto

```
.
├── Lei_de_Zipf_Ceara_reproducao.ipynb   # notebook que reproduz toda a análise
├── pyproject.toml                       # dependências do projeto
├── uv.lock                              # versões exatas das dependências
├── artigo/artigo.typ                    # código-fonte do artigo (Typst)
├── pdfs/entrega/                        # artigo em PDF
├── pdfs/bibliografia/                   # artigo de Newman (2005)
├── data/                                # dados baixados do IBGE (gerado, fora do git)
└── notebook_output/                     # figura, CSVs e JSON de resultados (gerado, fora do git)
```

## Como reproduzir

Requisitos: [uv](https://docs.astral.sh/uv/) e acesso à internet na primeira execução, para baixar os dados do IBGE. O uv instala o Python 3.12 ou superior caso ele não esteja disponível.

```bash
git clone <url-do-repositorio>
cd ciencia_cidades
uv sync
```

Depois, abra o notebook no VS Code, escolha o kernel `.venv` criado pelo uv e execute as células em ordem com **Shift + Enter**. Para usar o Jupyter no navegador:

```bash
uv run jupyter lab
```

As células baixam os dados para `data/` (e reutilizam os arquivos nas execuções seguintes) e gravam os resultados em `notebook_output/`:

| Arquivo | Conteúdo |
|---|---|
| `figura_zipf_ceara_reproduzida.png` | mapa da população e gráfico rank-size |
| `municipios_ceara_populacao_2022.csv` | população, posição e logaritmos de cada município |
| `resultados_regressao.csv` | resultados das duas regressões |
| `resultados_resumo.json` | resumo completo, incluindo as estatísticas auxiliares |
| `figura_zipf_outros_estados.png` | mapas e gráficos rank-size dos outros sete estados |
| `figura_comparacao_estados.png` | curvas rank-size dos oito estados e expoentes *q* com IC de 95% |
| `comparacao_estados_concentracao.csv` | participação da maior cidade, razão 1ª/2ª e Gini por estado |
| `comparacao_estados_regressao.csv` | regressões de cada estado (todos os municípios e 20 maiores) |
| `municipios_<estado>_populacao_2022.csv` | população e posição dos municípios de cada um dos outros sete estados |
| `maxima_verossimilhanca_estados.csv` | x_min, α, erro padrão, testes e participação dos 10% maiores por estado |
| `erro_padrao_gabaix_ibragimov.csv` | teste *q* = 1 da regressão com o erro padrão de Gabaix e Ibragimov |
| `figura_maxima_verossimilhanca.png` | distribuições cumulativas dos oito estados e α por método |

Os valores esperados estão nas seções 11 (Ceará), 12 (comparação) e 13 (máxima verossimilhança) do notebook. Para recomeçar do zero, apague `data/` e `notebook_output/` e execute tudo de novo.

### Gerar o PDF do artigo

O artigo é escrito em [Typst](https://typst.app/) e usa as figuras de `notebook_output/`, então o notebook precisa ter sido executado antes. Na raiz do projeto:

```bash
uvx --from typst python -c "import typst; typst.compile('artigo/artigo.typ', output='pdfs/entrega/trabalho_zipf_ceara_davipassos_v3.pdf', root='.')"
```

## Limitações

- A unidade de análise é o município, que inclui áreas rurais e não coincide com a mancha urbana nem com a região metropolitana funcional.
- Só o Censo de 2022 é usado, então não é possível saber se a concentração aumentou ou diminuiu ao longo do tempo.
- O resultado depende do número de cidades incluídas, como mostra a diferença entre os 184 municípios e os 20 maiores.
- A distribuição log-normal, alternativa à lei de potência, não foi testada.

## Referências

- CLAUSET, A.; SHALIZI, C. R.; NEWMAN, M. E. J. Power-law distributions in empirical data. *SIAM Review*, v. 51, n. 4, p. 661-703, 2009. https://doi.org/10.1137/070710111
- EECKHOUT, J. Gibrat's law for (all) cities. *American Economic Review*, v. 94, n. 5, p. 1429-1451, 2004. https://doi.org/10.1257/0002828043052303
- GABAIX, X. Zipf's law for cities: an explanation. *The Quarterly Journal of Economics*, v. 114, n. 3, p. 739-767, 1999. https://doi.org/10.1162/003355399556133
- GABAIX, X.; IBRAGIMOV, R. Rank − 1/2: a simple way to improve the OLS estimation of tail exponents. *Journal of Business & Economic Statistics*, v. 29, n. 1, p. 24-39, 2011. https://doi.org/10.1198/jbes.2009.06157
- IBGE. *Censo Demográfico 2022: população residente, variação absoluta e taxa de crescimento geométrico*. SIDRA, tabela 4709, 2023. https://sidra.ibge.gov.br/tabela/4709
- NEWMAN, M. E. J. Power laws, Pareto distributions and Zipf's law. *Contemporary Physics*, v. 46, n. 5, p. 323-351, 2005. https://doi.org/10.1080/00107510500052444
- SIMON, H. A. On a class of skew distribution functions. *Biometrika*, v. 42, n. 3/4, p. 425-440, 1955. https://doi.org/10.2307/2333389
- SOO, K. T. Zipf's law for cities: a cross-country investigation. *Regional Science and Urban Economics*, v. 35, n. 3, p. 239-263, 2005. https://doi.org/10.1016/j.regsciurbeco.2004.04.004
- ZIPF, G. K. *Human behavior and the principle of least effort*. Cambridge: Addison-Wesley, 1949.
