// Artigo da disciplina Ciência de Dados Aplicada à Ciência das Cidades, versão 4 (comparação com o Nordeste).
// Todos os números vêm do notebook Lei_de_Zipf_Nordeste_v4.ipynb.
// Para compilar, a partir da raiz do projeto (depois de executar o notebook):
//   uvx --from typst python -c "import typst; typst.compile('artigo/artigo_v4.typ', output='pdfs/entrega/trabalho_zipf_ceara_davipassos_v4.pdf', root='.')"

#set document(title: "A distribuição populacional dos municípios cearenses segue a Lei de Zipf? Uma comparação com o Nordeste", author: "Davi Passos")
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
#show table: set text(size: 9pt, hyphenate: false)
#show table: set par(justify: false)
#set math.equation(numbering: "(1)")

// Linhas horizontais no estilo booktabs.
#let topo = table.hline(stroke: 0.8pt)
#let meio = table.hline(stroke: 0.4pt)
#let fonte(corpo) = align(left, block(text(size: 8.5pt)[#set par(first-line-indent: 0em); Fonte: #corpo]))

#align(center)[
  #text(size: 15pt, weight: "bold")[A distribuição populacional dos municípios cearenses segue a Lei de Zipf? Uma comparação com o Nordeste]
  #v(0.4em)
  Davi Passos \
  #text(size: 9.5pt)[Universidade de Fortaleza | Mestrado em Ciência da Computação | Ciência de Dados Aplicada à Ciência das Cidades]
]

#v(0.6em)
#block(inset: (x: 1.2em))[
  #set par(first-line-indent: 0em)
  #set text(size: 10pt)
  *Resumo.* Este trabalho investiga se a população dos 184 municípios do Ceará segue a Lei de Zipf e compara o resultado com os outros oito estados do Nordeste, com dados do Censo Demográfico 2022. Dois métodos são usados: a regressão rank-size por mínimos quadrados, comum nos estudos urbanos, e o estimador de máxima verossimilhança recomendado por Newman (2005), com o início da cauda escolhido pelo critério de Kolmogorov-Smirnov. No Ceará, a regressão resulta em $q$ = 0,90 para todos os municípios e $q$ = 0,99 para os 20 maiores, e a máxima verossimilhança resulta em $alpha$ = 2,18 ± 0,10, o valor mais próximo da Lei de Zipf ($alpha$ = 2) na região. Mesmo assim, o Ceará é o único estado do Nordeste em que o teste de aderência rejeita a lei de potência ($p$ = 0,03). A distribuição do maior valor mostra que o tamanho de Fortaleza é compatível com a lei ajustada ($p$ = 0,28); o desvio vem da falta de cidades médias: há 8 municípios com mais de 100 mil habitantes, onde a lei prevê 14 ($p$ = 0,05), a menor proporção da região. A comparação mostra também que o erro padrão usual da regressão subestima a incerteza e leva a rejeições que desaparecem com o erro corrigido.

  *Palavras-chave:* Lei de Zipf; lei de potência; hierarquia urbana; máxima verossimilhança; Ceará; Nordeste.
]

= Introdução: qual é o problema?

Muitas grandezas medidas pelos cientistas têm um tamanho típico, como a altura das pessoas. O tamanho das cidades não tem: num mesmo país convivem metrópoles com milhões de habitantes e vilas com algumas centenas. Newman (2005) mostra que, quando o histograma das populações urbanas é desenhado com os dois eixos em escala logarítmica, os pontos se alinham numa reta. Isso significa que a fração de cidades com população $x$ segue uma lei de potência,

$ p(x) = C x^(-alpha), $ <eq:potencia>

em que $alpha$ é o expoente. A regularidade foi notada por Auerbach em 1913 (apud NEWMAN, 2005) e popularizada por Zipf (1949) na forma de ranking: se as cidades são ordenadas da maior para a menor, a população da cidade na posição $r$ é aproximadamente $P_r prop r^(-q)$, com $q approx 1$. Pela forma estrita da lei, a segunda cidade teria metade da população da primeira, a terceira um terço, e assim por diante.

As duas formulações descrevem o mesmo fenômeno. Newman (2005, Apêndice A) mostra que o gráfico de posição contra tamanho é a distribuição cumulativa $P(X >= x)$ desenhada com os eixos trocados. Se a densidade segue a @eq:potencia, a distribuição cumulativa decai com expoente $alpha - 1$, e portanto

$ q = 1 / (alpha - 1) quad <==> quad alpha = 1 + 1/q. $ <eq:relacao>

A Lei de Zipf estrita corresponde a $alpha = 2$. Para as cidades dos Estados Unidos com mais de 40 mil habitantes, Newman estima $alpha$ = 2,30, ou seja, $q approx$ 0,77.

A explicação mais aceita para essa regularidade é um processo de crescimento proporcional. Simon (1955) propôs que cada novo habitante escolhe uma cidade com probabilidade proporcional ao tamanho dela, o mecanismo que Newman chama de processo de Yule ou princípio de Gibrat. Gabaix (1999) mostrou que, se as cidades crescem a taxas aleatórias que não dependem do tamanho, a distribuição resultante tende a $q = 1$. Os testes empíricos mostram que a forma estrita é rejeitada em muitos países e que o resultado depende da definição de cidade e do estimador usado (SOO, 2005).

O Ceará é um caso interessante porque sua rede urbana é dominada por Fortaleza, seguida de longe por Caucaia, Juazeiro do Norte, Maracanaú e Sobral. *O problema investigado é se a distribuição populacional dos municípios cearenses se aproxima da Lei de Zipf e se o padrão cearense é atípico dentro do Nordeste.* A questão importa para o planejamento porque serviços especializados, como hospitais de alta complexidade e universidades, dependem de uma população mínima para existir. Assim, a forma da hierarquia urbana influencia onde a demanda se concentra e quanto a população precisa se deslocar entre municípios. A Lei de Zipf não indica uma distribuição ideal, mas oferece um padrão de comparação que permite medir o tamanho desses desvios. A comparação é feita com os nove estados da região, que têm história de povoamento e economia mais parecidas entre si e formam um conjunto que não depende de escolha do autor. Há também uma questão de método: Newman (2005) alerta que o ajuste de uma reta por mínimos quadrados, o procedimento mais usado, produz estimativas enviesadas do expoente. Por isso, o trabalho compara esse procedimento com o estimador de máxima verossimilhança.

= Dados e métodos: o que foi feito?

*Dados.* Foram usados os dados de população residente do Censo Demográfico 2022, tabela 4709, variável 93, do Sistema IBGE de Recuperação Automática (SIDRA), e a malha municipal do IBGE, ambos obtidos pela API de serviços de dados do instituto. A unidade de análise é o município: 1.794 no Nordeste, com 54,7 milhões de habitantes, dos quais 184 no Ceará. Os outros estados têm entre 75 (Sergipe) e 417 municípios (Bahia).

*Regressão rank-size.* Os municípios de cada estado foram ordenados da maior para a menor população, e estimou-se por mínimos quadrados ordinários a reta $log_10 P_r = a - q log_10 r$. O ajuste foi feito com todos os municípios e com os 20 maiores, faixa em que a lei costuma ser mais plausível. A hipótese $q = 1$ foi testada com o erro padrão usual da regressão e com o erro assintótico $q sqrt(2 slash n)$ de Gabaix e Ibragimov (2011). O segundo é necessário porque os pontos de um gráfico de ranking não são independentes, já que a posição de cada cidade depende de todas as maiores do que ela, e o erro usual fica pequeno demais.

*Máxima verossimilhança.* Seguindo Newman (2005, Eq. 5 e 6), o expoente da @eq:potencia foi estimado por

$ hat(alpha) = 1 + n [sum_(i=1)^n ln(x_i / x_min)]^(-1), quad quad sigma = (hat(alpha) - 1) / sqrt(n), $ <eq:mv>

em que $x_i$ são as populações dos $n$ municípios com pelo menos $x_min$ habitantes. O limite $x_min$ é necessário porque a lei de potência costuma valer só na cauda superior. Para escolhê-lo, usou-se o critério de Clauset, Shalizi e Newman (2009): cada população observada foi testada como candidata a $x_min$ (com pelo menos 10 municípios na cauda), e escolheu-se a que minimiza a distância de Kolmogorov-Smirnov $D$ entre a distribuição empírica e a ajustada. A aderência foi avaliada por bootstrap paramétrico com 1.000 amostras sintéticas: o $p$ é a fração de amostras, geradas a partir do modelo ajustado, com $D$ maior ou igual ao observado. Pelo critério dos autores, $p < 0,1$ indica que a lei de potência não é plausível.

*Maior município e cidades médias.* Um ponto acima da reta não basta para dizer que a capital é grande demais, porque o maior valor de uma lei de potência varia muito de uma amostra para outra. Newman (2005, seção III.B) mostra que, se os $n$ municípios da cauda seguem a lei ajustada,

$ P(text("maior") >= x) = 1 - [1 - (x / x_min)^(-(alpha - 1))]^n. $ <eq:maior>

Pela mesma lei, a razão $R$ entre os dois maiores municípios tem $P(R >= r) = r^(-(alpha - 1))$, independentemente de $n$, e o número de municípios com mais de 100 mil habitantes segue uma distribuição binomial com $n$ tentativas e probabilidade $(10^5 slash x_min)^(-(alpha - 1))$. Esses três cálculos dizem, respectivamente, se a capital, a primazia ou a quantidade de cidades médias destoam do modelo.

*Medidas de concentração.* Foram calculados a participação do maior município na população estadual, a razão entre o primeiro e o segundo municípios, o coeficiente de Gini das populações municipais e a parcela da população que vive nos 10% maiores municípios. Todo o processamento foi feito em Python (pandas, NumPy, SciPy e Matplotlib), num notebook que baixa os dados do IBGE e reproduz todas as tabelas e figuras deste texto.

= Resultados e discussão: o que foi encontrado?

== A hierarquia urbana do Ceará

Em 2022, Fortaleza tinha 2.428.708 habitantes, 27,6% da população do estado e 6,83 vezes a de Caucaia, o segundo município (355.679). Os 19 maiores municípios, 10% do total, reúnem 54,1% da população, e o Gini das populações municipais é 0,617. O mapa da @fig:ceara(a) mostra a concentração na Região Metropolitana de Fortaleza e os polos secundários no norte (Sobral) e no sul (Juazeiro do Norte e Crato).

#figure(
  image("../notebook_output/v4/figura_zipf_ceara.png", width: 100%),
  caption: [(a) População dos municípios do Ceará em 2022, em escala logarítmica; (b) gráfico rank-size com a reta de mínimos quadrados e a Lei de Zipf estrita ancorada em Fortaleza. Fonte: elaboração própria com dados do IBGE.],
) <fig:ceara>

A regressão rank-size com os 184 municípios resulta em $q$ = 0,901 e $R^2$ = 0,940 (@fig:ceara(b)). Pelo erro padrão usual, o intervalo de 95% de $q$ vai de 0,868 a 0,935 e rejeita a Lei de Zipf ($p < 0,001$). Com o erro de Gabaix e Ibragimov, porém, o intervalo vai de 0,72 a 1,09 e inclui 1 ($p$ = 0,29). Entre os 20 maiores, $q$ = 0,988 e $R^2$ = 0,891, compatível com a lei pelos dois critérios ($p$ = 0,887 e $p$ = 0,970). O $R^2$ alto mostra que a relação é bem descrita por uma reta, mas não diz se a inclinação é igual a −1 nem se a distribuição é de fato uma lei de potência (CLAUSET; SHALIZI; NEWMAN, 2009).

A máxima verossimilhança escolhe $x_min$ = 15.157 habitantes, de modo que a cauda reúne 129 municípios, 70% do total. O expoente estimado é $alpha$ = 2,18 ± 0,10 (intervalo de 95% de 1,97 a 2,38), o que equivale a $q$ = 0,85 pela @eq:relacao. O valor de Zipf, $alpha = 2$, fica dentro do intervalo ($p$ = 0,089). O teste de aderência, porém, resulta em $p$ = 0,033: uma única lei de potência não descreve bem a cauda cearense. A @fig:mv(c) mostra por quê. A curva acompanha a reta até cerca de 60 mil habitantes, mas cai abaixo dela entre 70 mil e 400 mil, e só volta a ela em Fortaleza.

Parece natural concluir que Fortaleza é grande demais, mas a @eq:maior não sustenta essa leitura. Com o expoente ajustado, a mediana esperada do maior município da cauda é 1,29 milhão, e a probabilidade de ele ter 2,43 milhões ou mais é 0,28: o tamanho da capital está dentro do que a lei prevê. A primazia medida pela razão 1ª/2ª também não é significativa ($P(R >= 6,83)$ = 0,10). O desvio está abaixo da capital: a lei prevê 14,0 municípios com mais de 100 mil habitantes, e o Ceará tem 8, um resultado com probabilidade de 0,051 pela distribuição binomial. A razão de 6,83 entre Fortaleza e Caucaia vem, portanto, mais de o segundo município ser pequeno do que de o primeiro ser grande.

== Comparação com o Nordeste

A @tab:concentracao e a @fig:nordeste resumem a concentração nos nove estados. Fortaleza é o maior município da região, com praticamente a mesma população de Salvador. Na participação da maior cidade, o Ceará (27,6%) só fica atrás de Alagoas (30,6%), e Sergipe (27,3%) e Piauí (26,5%) estão logo depois; na razão entre os dois primeiros municípios, o Ceará (6,83) é o primeiro, seguido do Piauí (5,34). Na @fig:nordeste(b), a curva cearense é a que mais cai da primeira para a segunda posição. O Gini e a parcela dos 10% maiores, que medem a desigualdade entre todos os municípios, variam pouco na região (de 0,547 a 0,670 e de 48% a 61%), e o Ceará fica abaixo da mediana regional nas duas (0,617 e 54,1%), porque quase não tem municípios muito pequenos: só 1 tem menos de 5 mil habitantes, contra 84 no Piauí.

#figure(
  [#table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: (left, right, right, right, right, right),
    topo,
    table.header([*Estado*], [*Municípios*], [*População (milhões)*], [*Participação da maior cidade*], [*Gini*], [*População nos 10% maiores*]),
    meio,
    [Maranhão], [217], [6,78], [15,3%], [0,547], [48,3%],
    [Piauí], [224], [3,27], [26,5%], [0,622], [57,4%],
    [*Ceará*], [*184*], [*8,79*], [*27,6%*], [*0,617*], [*54,1%*],
    [Rio Grande do Norte], [167], [3,30], [22,7%], [0,670], [61,1%],
    [Paraíba], [223], [3,97], [21,0%], [0,648], [58,1%],
    [Pernambuco], [185], [9,06], [16,4%], [0,622], [56,1%],
    [Alagoas], [102], [3,13], [30,6%], [0,611], [55,5%],
    [Sergipe], [75], [2,21], [27,3%], [0,635], [56,8%],
    [Bahia], [417], [14,14], [17,1%], [0,584], [52,7%],
    topo,
  )
  #fonte[elaboração própria com dados do IBGE.]],
  kind: table,
  caption: [Medidas de concentração populacional nos estados do Nordeste em 2022.],
) <tab:concentracao>

#figure(
  image("../notebook_output/v4/figura_comparacao_nordeste.png", width: 100%),
  caption: [(a) População dos municípios do Nordeste em 2022, em escala logarítmica. (b) População de cada município relativa à maior cidade do estado, por posição no ranking, em escala log-log; o Ceará aparece em destaque e a linha tracejada é a Lei de Zipf estrita. (c) Expoente $q$ dos 20 maiores municípios com o intervalo de 95% do erro usual da regressão e do erro de Gabaix e Ibragimov. Fonte: elaboração própria com dados do IBGE.],
) <fig:nordeste>

A @tab:expoentes mostra que a conclusão sobre a Lei de Zipf depende do método. Com todos os municípios, o $q$ da regressão varia de 0,83 (Bahia) a 1,10 (Sergipe), e o erro usual rejeita $q = 1$ em oito dos nove estados; com o erro de Gabaix e Ibragimov, a rejeição (a 5%) fica só na Bahia. Entre os 20 maiores, o erro usual rejeita a lei a 5% no Maranhão ($p$ = 0,001) e quase a rejeita na Paraíba e no Rio Grande do Norte ($p$ = 0,061 e 0,089), enquanto o erro corrigido não a rejeita em nenhum estado ($p >= 0,55$). A @fig:nordeste(c) mostra a diferença: com só 20 pontos, o intervalo correto de $q$ tem cerca de ±0,6, e os intervalos estreitos do erro usual são enganosos.

#figure(
  [#table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 2.1fr, 1fr, 1fr),
    align: (left, right, right, right, right, right, right, right, right),
    topo,
    table.header(
      [], table.cell(colspan: 5, align: center)[*Mínimos quadrados*], table.cell(colspan: 3, align: center)[*Máxima verossimilhança*],
      table.hline(start: 1, end: 6, stroke: 0.4pt), table.hline(start: 6, end: 9, stroke: 0.4pt),
      [*Estado*], [*$q$ todos*], [*$p$ GI*], [*$q$ 20 maiores*], [*$p$ usual*], [*$p$ GI*], [*$alpha$ ± erro (cauda)*], [*$p$ de $alpha = 2$*], [*$p$ de aderência*],
    ),
    meio,
    [Maranhão], [0,85], [0,057], [0,84], [0,001], [0,549], [2,48 ± 0,13 (121)], [< 0,001], [0,690],
    [Piauí], [0,87], [0,107], [0,91], [0,282], [0,743], [2,24 ± 0,09 (189)], [0,008], [0,885],
    [*Ceará*], [*0,90*], [*0,295*], [*0,99*], [*0,887*], [*0,970*], [*2,18 ± 0,10 (129)*], [*0,089*], [*0,033*],
    [Rio Grande do Norte], [1,02], [0,862], [1,08], [0,089], [0,824], [2,24 ± 0,24 (27)], [0,319], [0,900],
    [Paraíba], [0,96], [0,664], [1,10], [0,061], [0,769], [2,49 ± 0,18 (68)], [0,007], [0,435],
    [Pernambuco], [0,97], [0,754], [0,99], [0,772], [0,971], [2,21 ± 0,14 (78)], [0,120], [0,836],
    [Alagoas], [0,93], [0,565], [0,95], [0,564], [0,873], [2,50 ± 0,20 (54)], [0,014], [0,180],
    [Sergipe], [1,10], [0,594], [1,00], [0,963], [0,995], [2,33 ± 0,23 (34)], [0,148], [0,926],
    [Bahia], [0,83], [0,003], [0,93], [0,207], [0,802], [2,44 ± 0,13 (123)], [< 0,001], [0,728],
    topo,
  )
  #fonte[elaboração própria com dados do IBGE. Os $p$ da regressão se referem ao teste $q = 1$ com o erro padrão usual ou com o de Gabaix e Ibragimov (GI). Entre parênteses, o número de municípios na cauda acima de $x_min$.]],
  kind: table,
  caption: [Expoentes de Zipf por mínimos quadrados e por máxima verossimilhança nos estados do Nordeste.],
) <tab:expoentes>

Pela máxima verossimilhança, a lei de potência é plausível ($p$ de aderência ≥ 0,1) em oito dos nove estados; o Ceará é a única exceção (@fig:mv). Em todos os estados, $hat(alpha)$ fica acima de 2, de 2,18 (Ceará) a 2,50 (Alagoas): a cauda cai mais rápido do que pela Lei de Zipf, ou seja, as cidades grandes são mais raras em relação às médias do que a lei estrita prevê. O valor $alpha = 2$ é rejeitado no Maranhão, no Piauí, na Paraíba, em Alagoas e na Bahia, e não é rejeitado no Ceará, no Rio Grande do Norte, em Pernambuco e em Sergipe. O Ceará tem, portanto, o expoente mais próximo de Zipf da região e, ao mesmo tempo, a única distribuição que não é bem descrita por uma lei de potência. Nos estados menores, os testes têm pouco poder: a cauda tem 27 municípios no Rio Grande do Norte e 34 em Sergipe.

#figure(
  image("../notebook_output/v4/figura_maxima_verossimilhanca.png", width: 92%),
  caption: [(a)–(i) Distribuição cumulativa complementar $P(X >= x)$ das populações municipais em 2022. Os pontos cinza ficam abaixo de $x_min$; a linha cheia é a lei de potência estimada por máxima verossimilhança e a tracejada é a Lei de Zipf ($alpha = 2$) com o mesmo ponto de partida. (j) Expoente $alpha$ com intervalo de 95% pelos dois métodos; para os mínimos quadrados, $alpha = 1 + 1 slash q$ com o intervalo da regressão. Fonte: elaboração própria com dados do IBGE.],
) <fig:mv>

A @tab:extremos aplica à região os testes do maior município e das cidades médias. Nenhuma capital é anômala pela lei ajustada: $P(text("maior") >= text("observado"))$ fica entre 0,10 (Maceió) e 0,42 (Recife), e a razão entre os dois primeiros municípios também não destoa em nenhum estado ($P(R >= r)$ entre 0,10 e 0,36). A diferença do Ceará está nas cidades médias: é o estado com a menor proporção entre municípios observados e previstos acima de 100 mil habitantes (0,57) e o único em que a falta é quase significativa ($p$ = 0,051; nos demais, $p >= 0,31$). Piauí e Alagoas têm proporções parecidas, mas com 2 municípios observados e 3 previstos, uma diferença que não se distingue do acaso.

#figure(
  [#table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1.3fr, 1fr),
    align: (left, right, right, right, right, right, right, right),
    topo,
    table.header(
      [*Estado*], [*Maior município (mil hab.)*], [*Mediana esperada do maior (mil hab.)*], [*$P$(maior ≥ obs.)*], [*Razão 1ª/2ª*], [*$P(R >=$ obs.)*], [*≥ 100 mil prev. / obs.*], [*$p$ de falta*],
    ),
    meio,
    [Maranhão], [1.038], [538], [0,231], [3,80], [0,139], [8,3 / 10], [0,793],
    [Piauí], [866], [362], [0,209], [5,34], [0,125], [3,4 / 2], [0,337],
    [*Ceará*], [*2.429*], [*1.294*], [*0,281*], [*6,83*], [*0,104*], [*14,0 / 8*], [*0,051*],
    [Rio Grande do Norte], [751], [419], [0,284], [2,84], [0,275], [4,0 / 4], [0,623],
    [Paraíba], [834], [283], [0,129], [1,99], [0,360], [3,2 / 4], [0,778],
    [Pernambuco], [1.489], [1.210], [0,416], [2,31], [0,362], [14,2 / 12], [0,316],
    [Alagoas], [958], [275], [0,101], [4,08], [0,121], [3,1 / 2], [0,384],
    [Sergipe], [603], [296], [0,234], [3,13], [0,219], [2,9 / 4], [0,840],
    [Bahia], [2.418], [899], [0,153], [3,92], [0,140], [16,4 / 18], [0,722],
    topo,
  )
  #fonte[elaboração própria com dados do IBGE. As probabilidades são calculadas pela lei de potência ajustada a cada estado (@eq:maior). O $p$ de falta é a probabilidade binomial de observar no máximo o número real de municípios com mais de 100 mil habitantes.]],
  kind: table,
  caption: [O maior município e as cidades médias em relação à lei de potência ajustada.],
) <tab:extremos>

== Interpretação

Os resultados respondem à pergunta inicial em duas partes. No conjunto, a hierarquia cearense tem a inclinação da Lei de Zipf: os dois métodos dão $q$ entre 0,85 e 0,99, com intervalos que incluem 1 quando a incerteza é calculada corretamente, e o Ceará tem o expoente mais próximo de Zipf do Nordeste. A forma da distribuição, porém, é atípica na região, e o motivo não é o tamanho de Fortaleza, compatível com o modelo, mas a falta de cidades entre 100 mil e 400 mil habitantes logo abaixo dela. Se o crescimento fosse proporcional ao tamanho, como no mecanismo de Simon (1955) e Gabaix (1999), seria de esperar uma cauda contínua, sem esse degrau.

Pernambuco é o melhor contraponto. Tem quase o mesmo número de municípios (185) e de habitantes (9,06 milhões) que o Ceará, mas 12 municípios acima de 100 mil, perto dos 14,2 previstos. Oito deles, porém, estão na Região Metropolitana do Recife (Recife, Jaboatão dos Guararapes, Olinda, Paulista, Cabo de Santo Agostinho, Camaragibe, Igarassu e São Lourenço da Mata), enquanto no Ceará só Caucaia, Maracanaú e Maranguape, vizinhos da capital, passam desse limite. Parte da diferença pode vir, portanto, da forma como cada aglomeração metropolitana é dividida em municípios, e não só de uma diferença real na rede de cidades médias. Este trabalho não separa as duas explicações. Para o planejamento, o resultado sugere olhar para os polos regionais (Juazeiro do Norte, Crato, Sobral e Iguatu) e para a periferia metropolitana, mais do que para a capital.

= Limitações

A unidade de análise é o município, que inclui áreas rurais e não coincide com a mancha urbana; como mostra a comparação com Pernambuco, a divisão municipal das regiões metropolitanas afeta diretamente a contagem de cidades médias, e os arranjos populacionais do IBGE seriam uma unidade mais adequada. O estudo usa só o Censo de 2022, o que não permite testar diretamente o crescimento proporcional. A escolha de $x_min$ pelo critério de Kolmogorov-Smirnov é objetiva, mas outras escolhas mudam $alpha$; nos estados com caudas curtas, os testes têm pouco poder. Os testes do maior município e das cidades médias usam o expoente estimado com os mesmos dados e são, por isso, aproximados. A comparação vale para o Nordeste e não deve ser generalizada para o país. Por fim, a distribuição log-normal também é compatível com crescimento proporcional (EECKHOUT, 2004) e não foi testada. Trabalhos futuros podem comparar os censos de 2000, 2010 e 2022, usar arranjos populacionais e aplicar o teste da razão de verossimilhança entre lei de potência e log-normal proposto por Clauset, Shalizi e Newman (2009).

= Conclusão

A hierarquia populacional do Ceará é compatível com a inclinação da Lei de Zipf, mas não com a sua forma. Pela regressão, $q$ = 0,90 para os 184 municípios e 0,99 para os 20 maiores; pela máxima verossimilhança, $alpha$ = 2,18 ± 0,10 na cauda acima de 15 mil habitantes, o valor mais próximo de 2 entre os nove estados do Nordeste. O Ceará é, porém, o único estado da região em que o teste de aderência rejeita a lei de potência ($p$ = 0,03). Fortaleza não é grande demais para a lei ajustada ($p$ = 0,28); o que destoa é a falta de cidades médias, com 8 municípios acima de 100 mil habitantes onde o modelo prevê 14, a menor proporção da região. A principal lição de método é a de Newman (2005): o $R^2$ alto de uma reta em escala log-log não prova a lei, o erro padrão da regressão subestima a incerteza, e um ponto acima da reta não basta para chamar uma cidade de anômala sem considerar a variabilidade do maior valor.

#v(0.5em)
#heading(numbering: none)[Referências]

#set par(first-line-indent: 0em, hanging-indent: 1.2em, justify: false)
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
