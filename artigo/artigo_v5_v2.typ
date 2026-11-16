// Artigo da disciplina Ciência de Dados Aplicada à Ciência das Cidades, versão 5.2 (5 páginas).
// Versão estendida do artigo_v5.typ. Todos os números vêm do notebook Lei_de_Zipf_Ceara_v5.ipynb.
// Para compilar, a partir da raiz do projeto (depois de executar o notebook):
//   uvx --from typst python -c "import typst; typst.compile('artigo/artigo_v5_v2.typ', output='pdfs/entrega/trabalho_zipf_ceara_davipassos_v5_v2.pdf', root='.')"

#set document(title: "A distribuição populacional dos municípios cearenses segue a Lei de Zipf?", author: "Davi Passos")
#set page(paper: "a4", margin: (x: 2cm, y: 2cm), numbering: "1")
#set text(font: "Libertinus Serif", size: 11pt, lang: "pt", region: "br")
#set par(justify: true, leading: 0.6em, spacing: 0.9em, first-line-indent: (amount: 1.2em, all: true))
#set heading(numbering: "1.")
#show heading: set text(size: 11.5pt)
#show heading: set block(above: 1.3em, below: 0.8em)
#show figure.where(kind: table): set figure.caption(position: top)
#show figure.caption: set text(size: 9.5pt)
#show figure: set block(above: 1.2em, below: 1.2em)
#set figure(placement: auto)
#set table(stroke: none, inset: (x: 4pt, y: 3pt))
#show table: set text(size: 9pt, hyphenate: false)
#show table: set par(justify: false)
#set math.equation(numbering: "(1)")

// Linhas horizontais no estilo booktabs.
#let topo = table.hline(stroke: 0.8pt)
#let meio = table.hline(stroke: 0.4pt)
#let fonte(corpo) = align(left, block(text(size: 8.5pt)[#set par(first-line-indent: 0em); Fonte: #corpo]))

#align(center)[
  #text(size: 15pt, weight: "bold")[A distribuição populacional dos municípios cearenses segue a Lei de Zipf?]
  #v(0.4em)
  Davi Passos \
  #text(size: 9.5pt)[Universidade de Fortaleza | Mestrado em Ciência da Computação | Ciência de Dados Aplicada à Ciência das Cidades]
]

#v(0.6em)
#block(inset: (x: 1.2em))[
  #set par(first-line-indent: 0em)
  #set text(size: 10pt)
  *Resumo.* Este trabalho investiga se a população dos 184 municípios do Ceará segue a Lei de Zipf, com dados do Censo Demográfico 2022, seguindo a sequência proposta por Newman (2005): medir, estimar, testar e interpretar. A regressão rank-size tradicional resulta em $q$ = 0,90 e a máxima verossimilhança, em $alpha$ = 2,18 ± 0,10, valores compatíveis com a Lei de Zipf ($q = 1$, $alpha = 2$). Mesmo assim, o teste de aderência rejeita a lei de potência ($p$ = 0,03), algo que só ocorre no Ceará entre os nove estados do Nordeste. A log-normal é plausível ($p$ = 0,32), mas os dados não distinguem os dois modelos ($p$ = 0,58). O resultado que não depende do modelo é a falta de cidades médias: há 8 municípios com mais de 100 mil habitantes, onde os modelos preveem 13 ou 14. Já o tamanho de Fortaleza é compatível com a lei de potência ($p$ = 0,28) e fica no limite pela log-normal ($p$ = 0,05).

  *Palavras-chave:* Lei de Zipf; lei de potência; log-normal; hierarquia urbana; Ceará.
]

= Qual é o problema?

Muitas grandezas têm um tamanho típico, como a altura das pessoas. O tamanho das cidades não tem: num mesmo estado convivem uma metrópole com milhões de habitantes e municípios com poucos milhares. Newman (2005) mostra que a fração de cidades com população $x$ segue aproximadamente uma lei de potência,

$ p(x) = C x^(-alpha), $ <eq:potencia>

regularidade notada por Auerbach em 1913 (apud NEWMAN, 2005) e popularizada por Zipf (1949) na forma de ranking: ordenadas da maior para a menor, as cidades seguem $P_r prop r^(-q)$, com $q approx 1$. Pela forma estrita da lei, a segunda cidade teria metade da população da primeira, a terceira um terço, e assim por diante. As duas formulações descrevem o mesmo fenômeno, porque o gráfico de posição contra tamanho é a distribuição cumulativa $P(X >= x)$ com os eixos trocados (NEWMAN, 2005, Apêndice A). Por isso,

$ q = 1 / (alpha - 1) quad <==> quad alpha = 1 + 1/q, $ <eq:relacao>

e a Lei de Zipf estrita corresponde a $alpha = 2$. A explicação mais aceita é o crescimento proporcional: se as cidades crescem a taxas que não dependem do tamanho, a distribuição tende a $q = 1$ (SIMON, 1955; GABAIX, 1999). Os testes empíricos mostram, porém, que a forma estrita é rejeitada em muitos países e que o resultado depende da definição de cidade e do estimador usado (SOO, 2005).

*Este trabalho pergunta se a população dos 184 municípios do Ceará, rede dominada por Fortaleza, segue a Lei de Zipf, e se o padrão cearense é atípico no Nordeste.* A questão importa para o planejamento porque serviços especializados, como hospitais de alta complexidade e universidades, dependem de uma população mínima para existir. Assim, a forma da hierarquia urbana influencia onde a demanda se concentra e quanto a população precisa se deslocar entre municípios. A Lei de Zipf não indica uma distribuição ideal, mas oferece um padrão de comparação para medir esses desvios.

A pergunta tem uma armadilha de método. O procedimento mais comum, ajustar uma reta por mínimos quadrados ao gráfico log-log de posição e tamanho, produz estimativas enviesadas e incertezas pequenas demais, e um $R^2$ alto não prova que os dados sigam uma lei de potência (NEWMAN, 2005; CLAUSET; SHALIZI; NEWMAN, 2009). Por isso, a análise segue a sequência de Newman: medir, estimar, testar e interpretar.

= O que foi feito?

Foram usados os dados de população residente do Censo Demográfico 2022 (IBGE, SIDRA, tabela 4709, variável 93) para os 184 municípios do Ceará e, para comparação, para os 1.794 municípios dos nove estados do Nordeste, que somam 54,7 milhões de habitantes. A região foi escolhida porque seus estados têm história de povoamento e economia mais parecidas entre si e porque o conjunto não depende de escolha do autor. Todo o processamento foi feito em Python (pandas, NumPy, SciPy e Matplotlib), num notebook que baixa os dados do IBGE e reproduz os números e as figuras deste texto.

*Medir.* A distribuição foi representada pela função cumulativa complementar $P(X >= x)$ em escala log-log, que Newman recomenda no lugar do histograma por não depender da escolha de intervalos.

*Estimar.* Como referência, foi feita a regressão tradicional de $log_10 P_r$ sobre $log_10 r$, com todos os municípios e com os 20 maiores. A hipótese $q = 1$ foi testada com o erro usual e com o erro $q sqrt(2 slash n)$ de Gabaix e Ibragimov (2011), necessário porque os pontos de um ranking não são independentes. O método principal é o estimador de máxima verossimilhança (NEWMAN, 2005, Eq. 5 e 6),

$ hat(alpha) = 1 + n [sum_(i=1)^n ln(x_i / x_min)]^(-1), quad quad sigma = (hat(alpha) - 1) / sqrt(n), $ <eq:mv>

aplicado só aos $n$ municípios com pelo menos $x_min$ habitantes, porque a lei de potência costuma valer apenas na cauda. O limite $x_min$ foi escolhido pelo critério de Clauset, Shalizi e Newman (2009): entre todas as populações observadas (com pelo menos 10 municípios na cauda), a que minimiza a distância de Kolmogorov-Smirnov entre a distribuição empírica e a ajustada.

*Testar.* A aderência foi avaliada por bootstrap paramétrico com 1.000 amostras; $p < 0,1$ indica que a lei de potência não é plausível. A alternativa log-normal, também compatível com crescimento proporcional (EECKHOUT, 2004), foi ajustada à mesma cauda, truncada em $x_min$, e comparada pela razão de log-verossimilhança $cal(R)$, com o $p$ de Vuong; $cal(R) > 0$ favorece a lei de potência. Quando a mediana da log-normal ajustada fica abaixo de 1 habitante, o ajuste degenerou para o limite em que ela se confunde com uma lei de potência, e o teste não informa nada. Nos demais casos, a aderência da log-normal foi avaliada por bootstrap, com $x_min$ fixo.

*Interpretar.* Um ponto acima da reta não basta para chamar a capital de anômala, porque o maior valor de uma distribuição de cauda pesada varia muito. Newman (2005, seção III.B) mostra que, se os $n$ municípios da cauda seguem a lei ajustada,

$ P(text("maior") >= x) = 1 - [1 - (x / x_min)^(-(alpha - 1))]^n. $ <eq:maior>

Pela mesma lei, a razão $R$ entre os dois maiores tem $P(R >= r) = r^(-(alpha - 1))$, e o número de municípios com mais de 100 mil habitantes segue uma distribuição binomial com $n$ tentativas e probabilidade $(10^5 slash x_min)^(-(alpha - 1))$. O mesmo cálculo foi repetido com a log-normal no Ceará.

= Quais são os resultados e as conclusões?

== A hierarquia cearense pelos dois métodos

Em 2022, Fortaleza tinha 2.428.708 habitantes, 27,6% da população do estado e 6,83 vezes a de Caucaia, o segundo município (355.679). Os 19 maiores municípios, 10% do total, reúnem 54,1% da população, contra cerca de 60% nos Estados Unidos (NEWMAN, 2005). O mapa da @fig:ceara(a) mostra a concentração na Região Metropolitana de Fortaleza e os polos secundários no norte (Sobral) e no sul (Juazeiro do Norte e Crato).

#figure(
  image("../notebook_output/v5/figura_zipf_ceara.png", width: 100%),
  caption: [(a) População dos municípios do Ceará em 2022, em escala logarítmica; (b) gráfico rank-size com a reta de mínimos quadrados e a Lei de Zipf estrita ancorada em Fortaleza. Fonte: elaboração própria com dados do IBGE.],
) <fig:ceara>

A regressão com os 184 municípios resulta em $q$ = 0,901 e $R^2$ = 0,940 (@fig:ceara(b)). Pelo erro usual, o intervalo de 95% vai de 0,868 a 0,935 e rejeita a Lei de Zipf ($p < 0,001$); com o erro de Gabaix e Ibragimov, vai de 0,72 a 1,09 e inclui 1 ($p$ = 0,29). Entre os 20 maiores, $q$ = 0,988 e $R^2$ = 0,891, compatível com a lei pelos dois critérios ($p$ = 0,887 e 0,970). A máxima verossimilhança escolhe $x_min$ = 15.157 habitantes, com 129 municípios na cauda, e estima $alpha$ = 2,18 ± 0,10, ou seja, $q$ = 0,85 pela @eq:relacao. O valor $alpha = 2$ não é rejeitado ($p$ = 0,089). Os dois métodos concordam: a inclinação da hierarquia cearense é compatível com a de Zipf.

== A forma: lei de potência ou log-normal?

A inclinação compatível não garante a forma. O bootstrap rejeita a lei de potência ($p$ = 0,033). Na @fig:principal(a), os pontos acompanham a reta até cerca de 70 mil habitantes, ficam abaixo dela daí até Caucaia, e Fortaleza fica cerca de três vezes acima. A log-normal truncada, que se curva para baixo, acompanha melhor esse trecho e é plausível ($p$ = 0,32), mas a razão de verossimilhança não distingue os dois modelos ($cal(R)$ = −0,89; $p$ = 0,58). A @tab:ceara resume esses testes.

#figure(
  image("../notebook_output/v5/figura_artigo_v5.png", width: 100%),
  caption: [(a) Distribuição cumulativa complementar das populações municipais do Ceará em 2022, com a lei de potência de máxima verossimilhança, a Lei de Zipf ($alpha = 2$) e a log-normal truncada, ajustadas à cauda acima de $x_min$ (linha pontilhada vertical). A faixa cinza marca 100 mil a 400 mil habitantes. (b) Expoente $alpha$ nos nove estados do Nordeste por máxima verossimilhança (com intervalo de 95%) e pela regressão com todos os municípios ($alpha = 1 + 1 slash q$). Fonte: elaboração própria com dados do IBGE.],
) <fig:principal>

#figure(
  [#table(
    columns: (1fr, auto, auto),
    align: (left, right, right),
    topo,
    table.header([*Teste na cauda cearense*], [*Lei de potência*], [*Log-normal truncada*]),
    meio,
    [$p$ de aderência (bootstrap)], [0,033], [0,318],
    [Razão de verossimilhança $cal(R)$ ($p$ de Vuong)], table.cell(colspan: 2, align: center)[−0,89 (0,584)],
    [Municípios ≥ 100 mil previstos (observados: 8)], [14,0], [13,1],
    [$p$ de falta de cidades médias (binomial)], [0,051], [0,083],
    [$P$(maior ≥ Fortaleza)], [0,281], [0,050],
    topo,
  )
  #fonte[elaboração própria com dados do IBGE.]],
  kind: table,
  caption: [Lei de potência e log-normal na cauda da distribuição cearense ($x >=$ 15.157 habitantes, 129 municípios).],
) <tab:ceara>

== Faltam cidades médias; o tamanho de Fortaleza depende do modelo

Pela lei de potência ajustada, a mediana esperada do maior município é 1,29 milhão, e a probabilidade de ele ter 2,43 milhões ou mais é 0,28 (@eq:maior); a razão de 6,83 entre os dois primeiros também não é significativa ($p$ = 0,10). Pela log-normal, cuja cauda é mais leve, a probabilidade cai para 0,05. Como os dados não distinguem os dois modelos, não é possível afirmar que Fortaleza é grande demais, nem descartar essa hipótese. O resultado que não depende do modelo está abaixo da capital: a lei de potência prevê 14 e a log-normal 13 municípios com mais de 100 mil habitantes, e o Ceará tem 8 ($p$ = 0,051 e 0,083).

== Comparação com o Nordeste

A @tab:nordeste repete a análise nos nove estados. Na participação da maior cidade, o Ceará (27,6%) só fica atrás de Alagoas (30,6%); na razão entre os dois primeiros municípios, é o primeiro (6,83), seguido do Piauí (5,34). Pela máxima verossimilhança, $hat(alpha)$ vai de 2,18 (Ceará, o mais próximo de Zipf) a 2,50 (Alagoas), sempre acima de 2 (@fig:principal(b)): na região, as cidades grandes são mais raras em relação às médias do que a lei estrita prevê. O valor $alpha = 2$ é rejeitado a 5% no Maranhão, no Piauí, na Paraíba, em Alagoas e na Bahia.

#figure(
  [#table(
    columns: (auto, 1fr, 1fr, 1fr, 2.1fr, 1fr, 1fr, 1fr, 1.2fr, 1fr),
    align: (left, right, right, right, right, right, right, right, right, right),
    topo,
    table.header(
      [*Estado*], [*Mun.*], [*Maior cidade*], [*Razão 1ª/2ª*], [*$alpha$ ± erro (cauda)*], [*$p$ de $alpha = 2$*], [*$p$ ader.*], [*$P$(maior ≥ obs.)*], [*≥ 100 mil prev./obs.*], [*$p$ de falta*],
    ),
    meio,
    [Maranhão], [217], [15,3%], [3,80], [2,48 ± 0,13 (121)], [< 0,001], [0,690], [0,231], [8,3 / 10], [0,793],
    [Piauí], [224], [26,5%], [5,34], [2,24 ± 0,09 (189)], [0,008], [0,885], [0,209], [3,4 / 2], [0,337],
    [*Ceará*], [*184*], [*27,6%*], [*6,83*], [*2,18 ± 0,10 (129)*], [*0,089*], [*0,033*], [*0,281*], [*14,0 / 8*], [*0,051*],
    [Rio Grande do Norte], [167], [22,7%], [2,84], [2,24 ± 0,24 (27)], [0,319], [0,900], [0,284], [4,0 / 4], [0,623],
    [Paraíba], [223], [21,0%], [1,99], [2,49 ± 0,18 (68)], [0,007], [0,435], [0,129], [3,2 / 4], [0,778],
    [Pernambuco], [185], [16,4%], [2,31], [2,21 ± 0,14 (78)], [0,120], [0,836], [0,416], [14,2 / 12], [0,316],
    [Alagoas], [102], [30,6%], [4,08], [2,50 ± 0,20 (54)], [0,014], [0,180], [0,101], [3,1 / 2], [0,384],
    [Sergipe], [75], [27,3%], [3,13], [2,33 ± 0,23 (34)], [0,148], [0,926], [0,234], [2,9 / 4], [0,840],
    [Bahia], [417], [17,1%], [3,92], [2,44 ± 0,13 (123)], [< 0,001], [0,728], [0,153], [16,4 / 18], [0,722],
    topo,
  )
  #fonte[elaboração própria com dados do IBGE. Mun.: municípios; ader.: aderência (bootstrap). "Maior cidade" é a participação do maior município na população estadual; entre parênteses, o número de municípios na cauda. As três últimas colunas usam a lei de potência ajustada a cada estado.]],
  kind: table,
  caption: [Concentração, expoente e testes da lei de potência nos estados do Nordeste em 2022.],
) <tab:nordeste>

O caso cearense é único na região em três aspectos. A lei de potência é plausível em todos os outros estados ($p$ de aderência entre 0,18 e 0,93), e neles o ajuste da log-normal converge para a própria lei de potência, de modo que o teste não acrescenta informação. Nenhuma capital é anômala pela lei ajustada ($P$ entre 0,10 e 0,42). E a falta de cidades médias só se aproxima da significância no Ceará ($p$ = 0,051; nos demais, $p >= 0,31$), que tem a menor proporção entre municípios observados e previstos acima de 100 mil habitantes (0,57). Piauí e Alagoas têm proporções parecidas, mas com 2 municípios observados e 3 previstos, diferença que não se distingue do acaso.

O método muda as conclusões. Com todos os municípios, o $q$ da regressão vai de 0,83 (Bahia) a 1,10 (Sergipe), e o erro usual rejeita $q = 1$ em oito dos nove estados; com o erro de Gabaix e Ibragimov, a rejeição a 5% fica só na Bahia. Entre os 20 maiores, o erro usual rejeita a lei no Maranhão ($p$ = 0,001), e o erro corrigido não a rejeita em nenhum estado ($p >= 0,55$).

== Interpretação

Se o crescimento fosse proporcional, como no mecanismo de Simon (1955) e Gabaix (1999), seria de esperar uma cauda sem o degrau observado no Ceará. Pernambuco é o melhor contraponto: tem quase o mesmo número de municípios (185) e de habitantes (9,06 milhões), mas 12 municípios acima de 100 mil, perto dos 14,2 previstos. Oito deles, porém, estão na Região Metropolitana do Recife (Recife, Jaboatão dos Guararapes, Olinda, Paulista, Cabo de Santo Agostinho, Camaragibe, Igarassu e São Lourenço da Mata), enquanto no Ceará são quatro (Fortaleza, Caucaia, Maracanaú e Maranguape). Parte da diferença pode vir, portanto, da forma como cada aglomeração é dividida em municípios, e não só de uma diferença real na rede de cidades médias; este trabalho não separa as duas explicações. Para o planejamento, o resultado sugere olhar para os polos regionais (Juazeiro do Norte, Crato, Sobral e Iguatu) e para a periferia metropolitana, mais do que para a capital.

== Limitações

A unidade de análise é o município, que inclui áreas rurais e não coincide com a mancha urbana; como mostra o caso de Pernambuco, a divisão municipal das regiões metropolitanas afeta a contagem de cidades médias, e os arranjos populacionais do IBGE seriam uma unidade mais adequada. O estudo usa só o Censo de 2022, o que impede testar diretamente o crescimento proporcional. A escolha de $x_min$ é objetiva, mas outras escolhas mudam $alpha$, e nos estados com caudas curtas (27 municípios no Rio Grande do Norte, 34 em Sergipe) os testes têm pouco poder. Os testes do maior município e das cidades médias usam parâmetros estimados com os mesmos dados e são, por isso, aproximados. A comparação vale para o Nordeste e não deve ser generalizada para o país. Trabalhos futuros podem usar arranjos populacionais e testar o crescimento proporcional com os censos de 2010 e 2022.

== Conclusão

A hierarquia cearense tem a inclinação da Lei de Zipf, mas não a sua forma. Pela regressão, $q$ = 0,90 para os 184 municípios e 0,99 para os 20 maiores; pela máxima verossimilhança, $alpha$ = 2,18 ± 0,10, o valor mais próximo de 2 no Nordeste. O Ceará é, porém, o único estado da região em que a lei de potência é rejeitada ($p$ = 0,03). Faltam cidades entre 100 mil e 400 mil habitantes abaixo da capital, resultado que aparece nos dois modelos; já o tamanho de Fortaleza só fica no limite de ser anômalo se a distribuição for log-normal. A lição de método é a de Newman (2005): o $R^2$ de uma reta log-log não prova a lei, o erro da regressão subestima a incerteza, e a primazia deve ser julgada pela variabilidade do maior valor, que depende do modelo.

#v(0.5em)
#heading(numbering: none)[Referências]

#set par(first-line-indent: 0em, hanging-indent: 1.2em, justify: false, spacing: 0.6em)
#set text(size: 9.5pt)

CLAUSET, A.; SHALIZI, C. R.; NEWMAN, M. E. J. Power-law distributions in empirical data. *SIAM Review*, v. 51, n. 4, p. 661-703, 2009. https://doi.org/10.1137/070710111.

EECKHOUT, J. Gibrat's law for (all) cities. *American Economic Review*, v. 94, n. 5, p. 1429-1451, 2004. https://doi.org/10.1257/0002828043052303.

GABAIX, X. Zipf's law for cities: an explanation. *The Quarterly Journal of Economics*, v. 114, n. 3, p. 739-767, 1999. https://doi.org/10.1162/003355399556133.

GABAIX, X.; IBRAGIMOV, R. Rank − 1/2: a simple way to improve the OLS estimation of tail exponents. *Journal of Business & Economic Statistics*, v. 29, n. 1, p. 24-39, 2011. https://doi.org/10.1198/jbes.2009.06157.

IBGE. *Censo Demográfico 2022: população residente, variação absoluta e taxa de crescimento geométrico*. SIDRA, tabela 4709, 2023. Disponível em: https://sidra.ibge.gov.br/tabela/4709. Acesso em: 3 nov. 2026.

NEWMAN, M. E. J. Power laws, Pareto distributions and Zipf's law. *Contemporary Physics*, v. 46, n. 5, p. 323-351, 2005. https://doi.org/10.1080/00107510500052444.

SIMON, H. A. On a class of skew distribution functions. *Biometrika*, v. 42, n. 3/4, p. 425-440, 1955. https://doi.org/10.2307/2333389.

SOO, K. T. Zipf's law for cities: a cross-country investigation. *Regional Science and Urban Economics*, v. 35, n. 3, p. 239-263, 2005. https://doi.org/10.1016/j.regsciurbeco.2004.04.004.

ZIPF, G. K. *Human behavior and the principle of least effort*. Cambridge: Addison-Wesley, 1949.
