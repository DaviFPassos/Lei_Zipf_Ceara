// Artigo final da disciplina Ciência de Dados Aplicada à Ciência das Cidades.
// Todos os números vêm do notebook Lei_de_Zipf_Ceara_reproducao.ipynb.
// Para compilar, a partir da raiz do projeto (depois de executar o notebook):
//   uvx --from typst python -c "import typst; typst.compile('artigo/artigo.typ', output='pdfs/entrega/trabalho_zipf_ceara_davipassos_v2.pdf', root='.')"

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
#set table(stroke: none, inset: (x: 5pt, y: 3pt))
#show table: set text(size: 9pt)
#set math.equation(numbering: "(1)")

// Linhas horizontais no estilo booktabs.
#let topo = table.hline(stroke: 0.8pt)
#let meio = table.hline(stroke: 0.4pt)
#let fonte(corpo) = align(left, text(size: 8.5pt)[Fonte: #corpo])

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
  *Resumo.* Este trabalho investiga se a população dos 184 municípios do Ceará segue a Lei de Zipf, com dados do Censo Demográfico 2022. Dois métodos são comparados: a regressão rank-size por mínimos quadrados, comum nos estudos urbanos, e o estimador de máxima verossimilhança recomendado por Newman (2005), com o início da cauda escolhido pelo critério de Kolmogorov-Smirnov. A regressão resulta em $q$ = 0,90 ($R^2$ = 0,94) para todos os municípios e $q$ = 0,99 para os 20 maiores. A máxima verossimilhança resulta em $alpha$ = 2,18 ± 0,10 para os 129 municípios com mais de 15 mil habitantes, valor compatível com a Lei de Zipf ($alpha$ = 2). Mesmo assim, o teste de aderência indica que uma única lei de potência descreve mal essa cauda ($p$ = 0,03), por causa da primazia de Fortaleza, que reúne 27,6% da população estadual, e da escassez de cidades médias. A comparação com Bahia, São Paulo e Paraná mostra que a conclusão depende do método: o teste de mínimos quadrados subestima a incerteza e chega a rejeitar a lei no Paraná, onde a máxima verossimilhança encontra o ajuste mais próximo de Zipf entre os quatro estados.

  *Palavras-chave:* Lei de Zipf; lei de potência; hierarquia urbana; máxima verossimilhança; Ceará.
]

= Introdução: qual é o problema?

Muitas grandezas medidas pelos cientistas têm um tamanho típico, como a altura das pessoas. O tamanho das cidades não tem: num mesmo país convivem metrópoles com milhões de habitantes e vilas com algumas centenas. Newman (2005) mostra que, quando o histograma das populações urbanas é desenhado com os dois eixos em escala logarítmica, os pontos se alinham numa reta. Isso significa que a fração de cidades com população $x$ segue uma lei de potência,

$ p(x) = C x^(-alpha), $ <eq:potencia>

em que $alpha$ é o expoente. A regularidade foi notada por Auerbach em 1913 (apud NEWMAN, 2005) e popularizada por Zipf (1949) na forma de ranking: se as cidades são ordenadas da maior para a menor, a população da cidade na posição $r$ é aproximadamente $P_r prop r^(-q)$, com $q approx 1$. Pela forma estrita da lei, a segunda cidade teria metade da população da primeira, a terceira um terço, e assim por diante.

As duas formulações descrevem o mesmo fenômeno. Newman (2005, Apêndice A) mostra que o gráfico de posição contra tamanho é a distribuição cumulativa $P(X >= x)$ desenhada com os eixos trocados. Se a densidade segue a @eq:potencia, a distribuição cumulativa decai com expoente $alpha - 1$, e portanto

$ q = 1 / (alpha - 1) quad <==> quad alpha = 1 + 1/q. $ <eq:relacao>

A Lei de Zipf estrita corresponde a $alpha = 2$. Para as cidades dos Estados Unidos com mais de 40 mil habitantes, Newman estima $alpha$ = 2,30, ou seja, $q approx$ 0,77.

A explicação mais aceita para essa regularidade é um processo de crescimento proporcional. Simon (1955) propôs que cada novo habitante escolhe uma cidade com probabilidade proporcional ao tamanho dela, o mecanismo que Newman chama de processo de Yule ou princípio de Gibrat. Gabaix (1999) mostrou que, se as cidades crescem a taxas aleatórias que não dependem do tamanho, a distribuição resultante tende a $q = 1$. Desvios da lei, portanto, sinalizam que o crescimento urbano não foi proporcional: algumas cidades cresceram mais do que o seu tamanho permitiria prever. Os testes empíricos mostram que a forma estrita é rejeitada em muitos países e que o resultado depende da definição de cidade e do estimador usado (SOO, 2005).

O Ceará é um caso interessante porque sua rede urbana é dominada por Fortaleza, seguida de longe por Caucaia, Juazeiro do Norte, Maracanaú e Sobral. *O problema investigado é se a distribuição populacional dos municípios cearenses se aproxima da Lei de Zipf e em que medida Fortaleza se diferencia do restante da hierarquia.* A questão importa para o planejamento, porque a concentração da população define a demanda por transporte intermunicipal, hospitais, universidades e saneamento, e a Lei de Zipf funciona como referência para identificar desequilíbrios na rede urbana. Há também uma questão de método: Newman (2005) alerta que o ajuste de uma reta por mínimos quadrados, o procedimento mais usado, produz estimativas enviesadas do expoente. Por isso, o trabalho compara esse procedimento com o estimador de máxima verossimilhança e repete a análise para a Bahia, São Paulo e o Paraná, para saber se o padrão cearense é particular.

= Dados e métodos: o que foi feito?

*Dados.* Foram usados os dados de população residente do Censo Demográfico 2022, tabela 4709, variável 93, do Sistema IBGE de Recuperação Automática (SIDRA), e a malha municipal do IBGE, ambos obtidos pela API de serviços de dados do instituto. A unidade de análise é o município: 184 no Ceará, 417 na Bahia, 645 em São Paulo e 399 no Paraná. A Bahia foi escolhida por ser o estado mais populoso do Nordeste e ter uma capital de porte quase igual ao de Fortaleza; São Paulo, por abrigar a maior metrópole do país; e o Paraná, por representar uma rede urbana do Sul com vários centros regionais.

*Regressão rank-size.* Os municípios de cada estado foram ordenados da maior para a menor população, e estimou-se por mínimos quadrados ordinários a reta $log_10 P_r = a - q log_10 r$. O expoente $q$ é o negativo da inclinação, e o $R^2$ mede quanto da variação de $log_10 P_r$ a reta descreve. O ajuste foi feito com todos os municípios e com os 20 maiores, faixa em que a lei costuma ser mais plausível. A hipótese $q = 1$ foi testada de duas formas: com o erro padrão usual da regressão e com o erro assintótico $q sqrt(2 slash n)$ de Gabaix e Ibragimov (2011). O segundo é necessário porque os pontos de um gráfico de ranking não são independentes, já que a posição de cada cidade depende de todas as maiores do que ela, e o erro usual da regressão fica pequeno demais.

*Máxima verossimilhança.* Seguindo Newman (2005, Eq. 5 e 6), o expoente da @eq:potencia foi estimado por

$ hat(alpha) = 1 + n [sum_(i=1)^n ln(x_i / x_min)]^(-1), quad quad sigma = (hat(alpha) - 1) / sqrt(n), $ <eq:mv>

em que $x_i$ são as populações dos $n$ municípios com pelo menos $x_min$ habitantes. O limite $x_min$ é necessário porque poucas distribuições reais seguem a lei de potência em toda a faixa; ela costuma valer só na cauda superior. Para escolhê-lo sem arbitrariedade, usou-se o critério de Clauset, Shalizi e Newman (2009): cada população observada foi testada como candidata a $x_min$ (com pelo menos 10 municípios na cauda), e escolheu-se a que minimiza a distância de Kolmogorov-Smirnov $D$ entre a distribuição empírica e a ajustada. A aderência foi avaliada por bootstrap paramétrico com 1.000 amostras sintéticas: o $p$ é a fração de amostras, geradas a partir do modelo ajustado, com $D$ maior ou igual ao observado. Pelo critério dos autores, $p < 0,1$ indica que a lei de potência não é plausível. A hipótese $alpha = 2$ foi testada com o erro $sigma$ da @eq:mv.

*Medidas de concentração.* Foram calculados a participação do maior município na população estadual, a razão entre o primeiro e o segundo municípios, o coeficiente de Gini das populações municipais e a parcela da população que vive nos 10% maiores municípios, medida que Newman (2005) estima em cerca de 60% para os Estados Unidos.

Todo o processamento foi feito em Python (pandas, NumPy, SciPy e Matplotlib), num notebook que baixa os dados do IBGE e reproduz todas as tabelas e figuras deste texto.

= Resultados e discussão: o que foi encontrado?

== A hierarquia urbana do Ceará

Em 2022, Fortaleza tinha 2.428.708 habitantes, 27,6% da população do estado e 6,83 vezes a de Caucaia, o segundo município (355.679). Os 19 maiores municípios, 10% do total, reúnem 54,1% da população, e o Gini das populações municipais é 0,617. O mapa da @fig:ceara(a) mostra a concentração na Região Metropolitana de Fortaleza e os polos secundários no norte (Sobral) e no sul (Juazeiro do Norte e Crato).

#figure(
  image("../notebook_output/figura_zipf_ceara_reproduzida.png", width: 100%),
  caption: [(a) População dos municípios do Ceará em 2022, em escala logarítmica; (b) gráfico rank-size com a reta de mínimos quadrados e a Lei de Zipf estrita ancorada em Fortaleza. Fonte: elaboração própria com dados do IBGE.],
) <fig:ceara>

A regressão rank-size com os 184 municípios resulta em $q$ = 0,901 e $R^2$ = 0,940 (@fig:ceara(b)). Pelo erro padrão usual, o intervalo de 95% de $q$ vai de 0,868 a 0,935 e rejeita a Lei de Zipf ($p < 0,001$). Com o erro de Gabaix e Ibragimov (0,094), porém, o intervalo vai de 0,72 a 1,09 e inclui 1 ($p$ = 0,29). Entre os 20 maiores, $q$ = 0,988 e $R^2$ = 0,891, compatível com a lei pelos dois critérios ($p$ = 0,887 e $p$ = 0,970). O $R^2$ alto mostra que a relação é bem descrita por uma reta, mas não diz se a inclinação é igual a −1 nem se a distribuição é de fato uma lei de potência (CLAUSET; SHALIZI; NEWMAN, 2009). A reta ajustada aos 184 municípios prevê 1,10 milhão de habitantes para a primeira posição, menos da metade da população real de Fortaleza.

A máxima verossimilhança escolhe $x_min$ = 15.157 habitantes, de modo que a cauda reúne 129 municípios, 70% do total. O expoente estimado é $alpha$ = 2,18 ± 0,10 (intervalo de 95% de 1,97 a 2,38), o que equivale a $q$ = 0,85 pela @eq:relacao. O valor de Zipf, $alpha = 2$, fica dentro do intervalo ($p$ = 0,089). O teste de aderência, porém, resulta em $p$ = 0,033, abaixo do limite de 0,1: uma única lei de potência não descreve bem a cauda cearense. A @fig:mv(a) mostra por quê. A curva acompanha a reta até cerca de 60 mil habitantes, mas cai abaixo dela entre 70 mil e 400 mil, e Fortaleza fica muito acima. A lei ajustada prevê 14 municípios com mais de 100 mil habitantes, e o Ceará tem apenas 8. A rede cearense combina, portanto, uma capital grande demais com poucas cidades médias.

#figure(
  image("../notebook_output/figura_maxima_verossimilhanca.png", width: 100%),
  caption: [(a)–(d) Distribuição cumulativa complementar $P(X >= x)$ das populações municipais em 2022. Os pontos cinza ficam abaixo de $x_min$; a linha cheia é a lei de potência estimada por máxima verossimilhança e a tracejada é a Lei de Zipf ($alpha = 2$) com o mesmo ponto de partida. (e) Expoente $alpha$ com intervalo de 95% pelos dois métodos; para os mínimos quadrados, $alpha = 1 + 1 slash q$ com o intervalo da regressão. Fonte: elaboração própria com dados do IBGE.],
) <fig:mv>

== Comparação com outros estados

A @tab:comparacao resume os quatro estados. Salvador e Fortaleza têm praticamente a mesma população, mas Salvador reúne 17,1% da população baiana e é 3,92 vezes maior que Feira de Santana. A Bahia tem 18 municípios com mais de 100 mil habitantes, contra 8 no Ceará. O Paraná é o estado menos concentrado no topo (15,5% e razão 3,19), e São Paulo é o único com primazia mais forte que a do Ceará (razão 8,87). O Gini conta outra história, porque mede a desigualdade entre todos os municípios: São Paulo (0,802) e Paraná (0,709) superam o Ceará (0,617) porque têm muitos municípios muito pequenos (150 e 102 com menos de 5 mil habitantes, contra 1 no Ceará).

#figure(
  [#table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, right, right, right, right),
    topo,
    table.header([], [*Ceará*], [*Bahia*], [*São Paulo*], [*Paraná*]),
    meio,
    [Municípios], [184], [417], [645], [399],
    [Participação da maior cidade], [27,6%], [17,1%], [25,8%], [15,5%],
    [Razão 1ª/2ª], [6,83], [3,92], [8,87], [3,19],
    [Gini das populações], [0,617], [0,584], [0,802], [0,709],
    [População nos 10% maiores], [54,1%], [52,7%], [72,2%], [64,3%],
    meio,
    table.cell(colspan: 5, align: left)[_Mínimos quadrados_],
    [$q$ (todos)], [0,901], [0,831], [1,410], [1,122],
    [$p$ de $q = 1$, erro usual / Gabaix-Ibragimov], [< 0,001 / 0,295], [< 0,001 / 0,003], [< 0,001 / < 0,001], [< 0,001 / 0,124],
    [$q$ (20 maiores)], [0,988], [0,927], [0,878], [0,840],
    [$p$ de $q = 1$, erro usual / Gabaix-Ibragimov], [0,887 / 0,970], [0,207 / 0,802], [0,199 / 0,661], [0,001 / 0,548],
    meio,
    table.cell(colspan: 5, align: left)[_Máxima verossimilhança_],
    [$x_min$ (habitantes)], [15.157], [24.661], [16.641], [10.233],
    [Municípios na cauda], [129], [123], [287], [192],
    [$alpha$ ± erro padrão], [2,18 ± 0,10], [2,44 ± 0,13], [1,79 ± 0,05], [2,05 ± 0,08],
    [$q = 1 slash (alpha - 1)$], [0,85], [0,69], [1,27], [0,96],
    [$p$ de $alpha = 2$], [0,089], [< 0,001], [< 0,001], [0,539],
    [$p$ de aderência (bootstrap)], [0,033], [0,728], [0,000], [0,663],
    topo,
  )
  #fonte[elaboração própria com dados do IBGE.]],
  kind: table,
  caption: [Concentração populacional e expoentes de Zipf nos quatro estados em 2022.],
) <tab:comparacao>

A comparação deixa claro que a conclusão depende do método. Com todos os municípios, o $q$ da regressão varia de 0,83 a 1,41, porque é dominado pela cauda de municípios pequenos, que não segue lei de potência (os pontos cinza da @fig:mv). O erro usual rejeita $q = 1$ nos quatro estados, mas o de Gabaix e Ibragimov não rejeita no Ceará nem no Paraná. Entre os 20 maiores, a regressão rejeita a lei no Paraná ($p$ = 0,001), mas o erro corrigido mostra que nenhum estado é rejeitado. Com só 20 pontos, o intervalo de $q$ tem cerca de ±0,5 a ±0,6, e o teste quase não tem poder para distinguir estados. A @fig:mv(e) mostra o mesmo problema: os intervalos de mínimos quadrados são de 5 a 10 vezes mais estreitos que os de máxima verossimilhança, e as estimativas dos dois métodos diferem em até 0,24 (Bahia).

Pela máxima verossimilhança, o Paraná é o estado mais próximo da Lei de Zipf: $alpha$ = 2,05 ± 0,08, com aderência plausível ($p$ = 0,66), justamente o caso que a regressão dos 20 maiores rejeitava. A Bahia também segue uma lei de potência ($p$ = 0,73), mas mais íngreme que a de Zipf ($alpha$ = 2,44, $q$ = 0,69), ou seja, sua população se distribui mais entre cidades médias. Em São Paulo, a lei de potência é rejeitada ($p$ < 0,001): a curva da @fig:mv(c) é côncava e, acima de 100 mil habitantes, cai mais rápido que a reta, ou seja, há menos cidades muito grandes do que o modelo prevê. O Ceará fica entre esses casos: tem expoente compatível com 2, mas os desvios no topo da hierarquia impedem que uma única lei de potência o descreva.

== Interpretação

Os resultados respondem à pergunta inicial em duas partes. No conjunto, a hierarquia cearense tem a inclinação da Lei de Zipf: os dois métodos dão $q$ entre 0,85 e 0,99, com intervalos que incluem 1 quando a incerteza é calculada corretamente. A forma da distribuição, porém, não é a de uma lei de potência, porque Fortaleza é grande demais e faltam cidades entre 100 mil e 400 mil habitantes. Se o crescimento fosse proporcional ao tamanho, como no mecanismo de Simon (1955) e Gabaix (1999), seria de esperar uma cauda contínua e mais municípios médios. O desvio é coerente com uma história de crescimento concentrado na capital, mas este trabalho não testa essa explicação. A comparação mostra que a primazia de Fortaleza não é comum entre os estados brasileiros: a Bahia, com uma capital do mesmo porte, tem mais que o dobro de municípios acima de 100 mil habitantes. Para o planejamento, isso reforça a importância de fortalecer os polos regionais (Juazeiro do Norte, Crato, Sobral e Iguatu) ao lado das ações metropolitanas.

= Limitações

A unidade de análise é o município, que inclui áreas rurais e não coincide com a mancha urbana. Fortaleza, Caucaia e Maracanaú formam uma única aglomeração, e tratá-las separadamente aumenta a primazia aparente da capital; os arranjos populacionais do IBGE seriam uma unidade mais adequada. O estudo usa só o Censo de 2022, o que não permite saber se a concentração aumentou ou diminuiu nem testar diretamente o crescimento proporcional. A escolha de $x_min$ pelo critério de Kolmogorov-Smirnov é objetiva, mas outras escolhas mudam $alpha$; com 20 municípios, nenhum teste tem poder suficiente para separar estados. Por fim, uma distribuição pode parecer lei de potência sem sê-lo: a distribuição log-normal também é compatível com crescimento proporcional (EECKHOUT, 2004) e não foi testada aqui. Trabalhos futuros podem comparar os censos de 2000, 2010 e 2022, usar arranjos populacionais e aplicar o teste da razão de verossimilhança entre lei de potência e log-normal proposto por Clauset, Shalizi e Newman (2009).

= Conclusão

A hierarquia populacional do Ceará é compatível com a inclinação da Lei de Zipf, mas não com a sua forma. Pela regressão, $q$ = 0,90 para os 184 municípios e 0,99 para os 20 maiores; pela máxima verossimilhança, $alpha$ = 2,18 ± 0,10 na cauda acima de 15 mil habitantes, valores compatíveis com $q = 1$ e $alpha = 2$. O teste de aderência, no entanto, rejeita uma lei de potência única ($p$ = 0,03), porque Fortaleza concentra 27,6% da população estadual e há apenas 8 municípios com mais de 100 mil habitantes, onde o modelo prevê 14. Entre os quatro estados, só São Paulo tem primazia mais forte, e o Paraná é o que mais se aproxima da Lei de Zipf. A principal lição de método é a de Newman (2005): o $R^2$ alto de uma reta em escala log-log não prova a lei, o erro padrão da regressão subestima a incerteza, e a mudança de método basta para inverter a conclusão sobre um estado. A Lei de Zipf é útil como referência para comparar redes urbanas, desde que o expoente seja estimado com o método adequado e lido junto com medidas de primazia.

#v(0.5em)
#heading(numbering: none)[Referências]

#set par(first-line-indent: 0em, hanging-indent: 1.2em, justify: false)
#set text(size: 9.5pt)

CLAUSET, A.; SHALIZI, C. R.; NEWMAN, M. E. J. Power-law distributions in empirical data. *SIAM Review*, v. 51, n. 4, p. 661-703, 2009. https://doi.org/10.1137/070710111.

EECKHOUT, J. Gibrat's law for (all) cities. *American Economic Review*, v. 94, n. 5, p. 1429-1451, 2004. https://doi.org/10.1257/0002828043052303.

GABAIX, X. Zipf's law for cities: an explanation. *The Quarterly Journal of Economics*, v. 114, n. 3, p. 739-767, 1999. https://doi.org/10.1162/003355399556133.

GABAIX, X.; IBRAGIMOV, R. Rank − 1/2: a simple way to improve the OLS estimation of tail exponents. *Journal of Business & Economic Statistics*, v. 29, n. 1, p. 24-39, 2011. https://doi.org/10.1198/jbes.2009.06157.

IBGE. *Censo Demográfico 2022: população residente, variação absoluta e taxa de crescimento geométrico*. SIDRA, tabela 4709, 2023. Disponível em: https://sidra.ibge.gov.br/tabela/4709. Acesso em: 29 out. 2026.

NEWMAN, M. E. J. Power laws, Pareto distributions and Zipf's law. *Contemporary Physics*, v. 46, n. 5, p. 323-351, 2005. https://doi.org/10.1080/00107510500052444.

SIMON, H. A. On a class of skew distribution functions. *Biometrika*, v. 42, n. 3/4, p. 425-440, 1955. https://doi.org/10.2307/2333389.

SOO, K. T. Zipf's law for cities: a cross-country investigation. *Regional Science and Urban Economics*, v. 35, n. 3, p. 239-263, 2005. https://doi.org/10.1016/j.regsciurbeco.2004.04.004.

ZIPF, G. K. *Human behavior and the principle of least effort*. Cambridge: Addison-Wesley, 1949.
