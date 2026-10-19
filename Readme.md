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

**Conclusão:** os 20 maiores municípios são compatíveis com a Lei de Zipf (a hipótese *q* = 1 não é rejeitada, *p* = 0,887). O conjunto completo tem distribuição mais rasa que a lei estrita (*p* < 0,001), com forte primazia de Fortaleza. O R² elevado mostra boa aderência a uma lei de potência, mas não prova que a posição cause o tamanho das cidades.

## Comparação com outros estados

A seção 12 do notebook repete o mesmo estudo para a Bahia, São Paulo e o Paraná, com os mesmos dados e o mesmo método.

| Resultado | Ceará | Bahia | São Paulo | Paraná |
|---|---:|---:|---:|---:|
| Municípios | 184 | 417 | 645 | 399 |
| Participação da maior cidade | 27,6% | 17,1% | 25,8% | 15,5% |
| Razão 1ª/2ª | 6,83 | 3,92 | 8,87 | 3,19 |
| Gini | 0,617 | 0,584 | 0,802 | 0,709 |
| *q* (todos) | 0,901 | 0,831 | 1,410 | 1,122 |
| *q* (20 maiores) | 0,988 | 0,927 | 0,878 | 0,840 |
| *p* do teste *q* = 1 (20 maiores) | 0,887 | 0,207 | 0,199 | 0,001 |

Entre os 20 maiores, o Ceará tem o expoente mais próximo de 1, e o Paraná é o único estado em que a Lei de Zipf é rejeitada. A primazia de Fortaleza só é superada pela de São Paulo. Com todos os municípios, *q* varia muito entre os estados (de 0,83 a 1,41), porque depende do número de municípios pequenos de cada um.

## Estrutura do projeto

```
.
├── Lei_de_Zipf_Ceara_reproducao.ipynb   # notebook que reproduz toda a análise
├── pyproject.toml                       # dependências do projeto
├── uv.lock                              # versões exatas das dependências
├── pdfs/                                # artigo em PDF
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
| `figura_zipf_outros_estados.png` | mapas e gráficos rank-size da Bahia, de São Paulo e do Paraná |
| `figura_comparacao_estados.png` | curvas rank-size dos quatro estados e expoentes *q* com IC de 95% |
| `comparacao_estados_concentracao.csv` | participação da maior cidade, razão 1ª/2ª e Gini por estado |
| `comparacao_estados_regressao.csv` | regressões de cada estado (todos os municípios e 20 maiores) |
| `municipios_<estado>_populacao_2022.csv` | população e posição dos municípios da Bahia, de São Paulo e do Paraná |

Os valores esperados estão nas seções 11 (Ceará) e 12 (comparação) do notebook. Para recomeçar do zero, apague `data/` e `notebook_output/` e execute tudo de novo.

## Limitações

- A unidade de análise é o município, que inclui áreas rurais e não coincide com a mancha urbana nem com a região metropolitana funcional.
- Só o Censo de 2022 é usado, então não é possível saber se a concentração aumentou ou diminuiu ao longo do tempo.
- O resultado depende do número de cidades incluídas, como mostra a diferença entre os 184 municípios e os 20 maiores.

## Referências

- GABAIX, X. Zipf's law for cities: an explanation. *The Quarterly Journal of Economics*, v. 114, n. 3, p. 739-767, 1999. https://doi.org/10.1162/003355399556133
- IBGE. *Censo Demográfico 2022: população residente, variação absoluta e taxa de crescimento geométrico*. SIDRA, tabela 4709, 2023. https://sidra.ibge.gov.br/tabela/4709
- SOO, K. T. Zipf's law for cities: a cross-country investigation. *Regional Science and Urban Economics*, v. 35, n. 3, p. 239-263, 2005. https://doi.org/10.1016/j.regsciurbeco.2004.04.004
- ZIPF, G. K. *Human behavior and the principle of least effort*. Cambridge: Addison-Wesley, 1949.
