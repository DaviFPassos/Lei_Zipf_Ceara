// Artigo da disciplina Ciência de Dados Aplicada à Ciência das Cidades, versão 6 (3 páginas).
// Condensa o artigo_v5_v3.typ para o limite do manual: sem o mapa e a regressão da antiga Figura 1 e sem a tabela dos estados do Nordeste (resumida em texto). Todos os números vêm do notebook Lei_de_Zipf_Ceara_v5.ipynb.
// Para compilar, a partir da raiz do projeto (depois de executar o notebook):
//   uvx --from typst python -c "import typst; typst.compile('artigo/artigo_v6.typ', output='pdfs/entrega/trabalho_zipf_ceara_davipassos_v6.pdf', root='.')"

#set document(title: "A distribuição populacional dos municípios cearenses segue a Lei de Zipf?", author: "Davi Passos")
#set page(paper: "a4", margin: (x: 1.8cm, y: 1.5cm), numbering: "1")
#set text(font: "Libertinus Serif", size: 10pt, lang: "pt", region: "br")
#set par(justify: true, leading: 0.55em, spacing: 0.7em, first-line-indent: (amount: 1.2em, all: true))
#set heading(numbering: "1.")
#show heading: set text(size: 10.5pt)
#show heading: set block(above: 1em, below: 0.6em)
#show figure.where(kind: table): set figure.caption(position: top)
#show figure.caption: set text(size: 9pt)
#show figure: set block(above: 0.9em, below: 0.9em)
#set figure(placement: auto)
#set table(stroke: none, inset: (x: 4pt, y: 2.5pt))
#show table: set text(size: 9pt, hyphenate: false)
#show table: set par(justify: false)
#set math.equation(numbering: "(1)")

// Linhas horizontais no estilo booktabs.
#let topo = table.hline(stroke: 0.8pt)
#let meio = table.hline(stroke: 0.4pt)
#let fonte(corpo) = align(left, block(text(size: 8.5pt)[#set par(first-line-indent: 0em); Fonte: #corpo]))

#align(center)[
  #text(size: 14pt, weight: "bold")[A distribuição populacional dos municípios cearenses segue a Lei de Zipf?]
  #v(0.3em)
  Davi Passos \
  #text(size: 9pt)[Universidade de Fortaleza | Mestrado em Ciência da Computação | Ciência de Dados Aplicada à Ciência das Cidades]
]

#v(0.4em)
#block(inset: (x: 1em))[
  #set par(first-line-indent: 0em)
  #set text(size: 9.5pt)
  *Resumo.* Este trabalho investiga se a população dos 184 municípios do Ceará segue a Lei de Zipf, com dados do Censo Demográfico 2022 e na sequência proposta por Newman (2005): medir, estimar, testar e interpretar. A regressão rank-size resulta em $q$ = 0,90 e a máxima verossimilhança, em $alpha$ = 2,18 ± 0,10, compatíveis com a Lei de Zipf ($q = 1$, $alpha = 2$). Mesmo assim, o teste de aderência rejeita a lei de potência ($p$ = 0,03), algo que só ocorre no Ceará entre os nove estados do Nordeste. O resultado que não depende do modelo é a falta de cidades médias: há 8 municípios com mais de 100 mil habitantes, onde os modelos preveem 13 ou 14, e 1,29 milhão de cearenses vivem a mais de 100 km de um município com 100 mil habitantes. Fortaleza é compatível com a lei de potência ($p$ = 0,28).

  *Palavras-chave:* Lei de Zipf; lei de potência; log-normal; hierarquia urbana; Ceará.
]

= Qual é o problema?

O tamanho das cidades não tem um valor típico, como a altura das pessoas: num mesmo estado convivem uma metrópole e municípios com poucos milhares de habitantes. Newman (2005) mostra que a fração de cidades com população $x$ segue aproximadamente uma lei de potência, $p(x) = C x^(-alpha)$, regularidade notada por Auerbach em 1913 (apud NEWMAN, 2005) e popularizada por Zipf (1949) na forma de ranking: ordenadas da maior para a menor, as cidades seguem $P_r prop r^(-q)$, com $q approx 1$. Pela forma estrita, a segunda cidade teria metade da população da primeira, a terceira um terço, e assim por diante. As duas formulações são equivalentes, porque o gráfico de posição contra tamanho é a distribuição cumulativa com os eixos trocados (NEWMAN, 2005, Apêndice A):

$ q = 1 / (alpha - 1) quad <==> quad alpha = 1 + 1/q, $ <eq:relacao>

e a Lei de Zipf estrita corresponde a $alpha = 2$. A explicação mais aceita é o crescimento proporcional (SIMON, 1955; GABAIX, 1999), mas a forma estrita é rejeitada em muitos países e o resultado depende da definição de cidade e do estimador (SOO, 2005).

*Este trabalho pergunta se a população dos 184 municípios do Ceará, rede dominada por Fortaleza, segue a Lei de Zipf, e se o padrão cearense é atípico no Nordeste.* A questão importa para o planejamento: serviços especializados, como hospitais de alta complexidade e universidades, dependem de uma população mínima, então a forma da hierarquia urbana influencia onde a demanda se concentra e quanto a população precisa se deslocar. Zipf não é uma distribuição ideal, mas um padrão de comparação para medir desvios. Há também uma armadilha de método: ajustar uma reta por mínimos quadrados ao gráfico log-log dá estimativas enviesadas e incertezas pequenas demais, e um $R^2$ alto não prova uma lei de potência (NEWMAN, 2005; CLAUSET; SHALIZI; NEWMAN, 2009). Por isso, a análise segue a sequência de Newman.

= O que foi feito?

Foram usados os dados de população residente do Censo 2022 (IBGE, SIDRA, tabela 4709) para os 184 municípios do Ceará e, para comparação, para os 1.794 municípios dos nove estados do Nordeste (54,7 milhões de habitantes), região de estados com povoamento e economia mais parecidos e que não depende de escolha do autor. O processamento foi feito em Python (pandas, NumPy, SciPy, Matplotlib), num notebook que reproduz os números e as figuras.

*Medir.* Para cada tamanho $x$, calcula-se a fração de municípios com pelo menos $x$ habitantes, $P(X >= x)$, e o resultado é desenhado em escala log-log, onde uma lei de potência vira uma reta. Esse gráfico não depende de intervalos, ao contrário do histograma.

*Estimar.* Como referência, ajustou-se a reta tradicional ao gráfico de posição contra tamanho (regressão de $log_10 P_r$ sobre $log_10 r$), com todos os municípios e com os 20 maiores, testando se $q = 1$ com o erro usual e com o erro $q sqrt(2 slash n)$ de Gabaix e Ibragimov (2011), que leva em conta que os pontos de um ranking não são independentes. O método principal é a máxima verossimilhança, que estima o expoente diretamente dos dados (NEWMAN, 2005, Eq. 5 e 6),

$ hat(alpha) = 1 + n [sum_(i=1)^n ln(x_i / x_min)]^(-1), quad quad sigma = (hat(alpha) - 1) / sqrt(n), $ <eq:mv>

usando só os $n$ municípios com pelo menos $x_min$ habitantes, a cauda, onde a lei de potência costuma valer. O $x_min$ é o ponto de corte que deixa a curva ajustada mais próxima da real (distância de Kolmogorov-Smirnov, com pelo menos 10 municípios na cauda; CLAUSET; SHALIZI; NEWMAN, 2009).

*Testar.* Para saber se a lei de potência é plausível, usou-se o bootstrap: simulam-se 1.000 estados que seguem exatamente a lei ajustada e vê-se se o Ceará real se parece com eles; $p < 0,1$ indica que não. A alternativa foi a log-normal, modelo com menos cidades gigantes e também compatível com crescimento proporcional (EECKHOUT, 2004), ajustada à mesma cauda e comparada com a lei de potência pela razão de log-verossimilhança $cal(R)$ e pelo teste de Vuong ($cal(R) > 0$ favorece a lei de potência). Nos estados em que a log-normal se confunde com uma lei de potência, esse teste não acrescenta informação.

*Interpretar.* Uma capital acima da reta não é, por si só, anômala, porque em uma lei de potência o maior valor varia muito de uma amostra para outra. Por isso, calculou-se a chance de, se a lei ajustada fosse verdadeira, o maior município ser pelo menos tão grande quanto Fortaleza (NEWMAN, 2005, seção III.B), e o mesmo com a log-normal. Para as cidades médias, comparou-se quantos municípios acima de 100 mil habitantes cada modelo prevê com o observado e se essa diferença seria rara por acaso (distribuição binomial). Para medir o impacto, calculou-se a distância em linha reta até o município mais próximo com pelo menos 100 mil habitantes (em qualquer estado do Nordeste) e simulou-se quais cidades de 70 mil a 100 mil habitantes mais reduziriam a população a mais de 100 km se passassem desse limite.

= Quais são os resultados e as conclusões?

== Inclinação e forma

Em 2022, Fortaleza tinha 2.428.708 habitantes, 27,6% do estado e 6,83 vezes a população de Caucaia, a segunda (355.679). A regressão com os 184 municípios resulta em $q$ = 0,901 e $R^2$ = 0,940. Pelo erro usual, o intervalo de 95% (0,868 a 0,935) rejeita a Lei de Zipf ($p < 0,001$); com o erro de Gabaix e Ibragimov, vai de 0,72 a 1,09 e inclui 1 ($p$ = 0,29). Entre os 20 maiores, $q$ = 0,988. A máxima verossimilhança escolhe $x_min$ = 15.157 habitantes, com 129 municípios na cauda, e estima $alpha$ = 2,18 ± 0,10 ($q$ = 0,85 pela @eq:relacao); $alpha = 2$ não é rejeitado ($p$ = 0,089). Os dois métodos concordam: a inclinação é compatível com a de Zipf.

Isso não garante a forma. O bootstrap mostra que o Ceará real não se parece com uma lei de potência perfeita ($p$ = 0,033). Na @fig:principal(a), os pontos acompanham a reta até cerca de 70 mil habitantes, ficam abaixo dela daí até Caucaia, e Fortaleza fica cerca de três vezes acima. A log-normal, que se curva para baixo, acompanha melhor esse trecho e é plausível ($p$ = 0,32), mas a comparação direta não consegue dizer qual dos dois modelos é melhor ($cal(R)$ = −0,89; $p$ = 0,58), como mostra a @tab:ceara.

#figure(
  image("../notebook_output/v5/figura_artigo_v5.png", width: 94%),
  caption: [(a) Distribuição cumulativa complementar das populações municipais do Ceará em 2022, com a lei de potência de máxima verossimilhança, a Lei de Zipf ($alpha = 2$) e a log-normal truncada, ajustadas acima de $x_min$ (linha pontilhada). A faixa cinza (100 mil a 400 mil habitantes) marca onde os pontos ficam abaixo da lei de potência. (b) Expoente $alpha$ nos nove estados do Nordeste, por máxima verossimilhança (intervalo de 95%) e por regressão ($alpha = 1 + 1 slash q$). Fonte: elaboração própria com dados do IBGE.],
) <fig:principal>

#figure(
  [#table(
    columns: (1fr, auto, auto),
    align: (left, right, right),
    topo,
    table.header([*Teste na cauda cearense*], [*Lei de potência*], [*Log-normal truncada*]),
    meio,
    [$p$ de aderência (bootstrap)], [0,033], [0,318],
    [Qual modelo é melhor? ($cal(R)$ e $p$ de Vuong)], table.cell(colspan: 2, align: center)[−0,89 (0,584)],
    [Municípios ≥ 100 mil previstos (observados: 8)], [14,0], [13,1],
    [$p$ da falta de cidades médias], [0,051], [0,083],
    [Chance de o maior município ser ≥ Fortaleza], [0,281], [0,050],
    topo,
  )
  #fonte[elaboração própria com dados do IBGE.]],
  kind: table,
  caption: [Lei de potência e log-normal na cauda cearense ($x >=$ 15.157 habitantes, 129 municípios).],
) <tab:ceara>

== Fortaleza e as cidades médias

Fortaleza é grande demais? Uma lei de potência já admite uma cidade muito maior que as outras, então a pergunta é se 2,43 milhões de habitantes seria um valor raro. Pela lei de potência ajustada, não: em cerca de 28% dos estados simulados o maior município é pelo menos tão grande quanto Fortaleza. Pela log-normal, que admite menos gigantes, isso ocorre em apenas 5%. Como os dados não permitem escolher entre os modelos, não se pode afirmar que Fortaleza é grande demais, nem descartar essa hipótese.

O resultado que não depende do modelo está abaixo da capital. A lei de potência prevê 14 municípios com mais de 100 mil habitantes e a log-normal, 13; o Ceará tem 8, e ter tão poucos por acaso teria chance de 5% a 8% ($p$ = 0,051 e 0,083, evidência moderada). A falta tem início definido: até 70 mil habitantes o número de municípios é o previsto, e há 14 municípios de 70 mil a 85 mil, mas só 2 entre 85 mil e 130 mil (Iguatu e Maranguape). O interior tem muitas cidades pequenas e poucas passam desse degrau. O tamanho da lacuna depende do modelo, mas sua existência não.

== Comparação com o Nordeste

Nos nove estados, o expoente $hat(alpha)$ vai de 2,18 (Ceará, o mais próximo de Zipf) a 2,50 (Alagoas), sempre acima de 2 (@fig:principal(b)): na região, as cidades grandes são mais raras, em relação às médias, do que a lei estrita prevê. O Ceará tem a maior razão entre os dois primeiros municípios (6,83, contra 5,34 no Piauí), mas se destaca em três pontos. Primeiro, a lei de potência é plausível em todos os outros estados ($p$ entre 0,18 e 0,93). Segundo, nenhuma outra capital é anômala (a chance de ser tão grande por acaso vai de 0,10 a 0,42). Terceiro, só no Ceará a falta de cidades médias se aproxima de ser significativa ($p$ = 0,051; nos demais, $p >= 0,31$): ele tem apenas 57% dos municípios acima de 100 mil que a lei prevê, a menor proporção da região. O método também muda a conclusão: com todos os municípios, o erro usual rejeita $q = 1$ em oito dos nove estados, e o erro de Gabaix e Ibragimov, só na Bahia.

== O que a lacuna significa no território

Cerca de 1,29 milhão de cearenses (14,7%), em 47 municípios, vivem a mais de 100 km de um município com 100 mil habitantes, concentrados no centro e no oeste (@fig:distancia(a)). A proporção é quase o dobro da de Pernambuco (7,4%), estado de população parecida. O número depende do limite: se ele fosse 80 mil habitantes, cairia para 4,5% no Ceará e 1,7% em Pernambuco, o que indica que o interior cearense tem cidades bem distribuídas, mas um degrau abaixo do porte médio. A simulação da @fig:distancia(b) mostra quais são elas: se Quixeramobim, Crateús, Iguatu e Quixadá, que juntas estão a 59 mil habitantes do limite, o ultrapassassem, a população a mais de 100 km cairia para cerca de 160 mil. A conta não é uma previsão, e o limite de 100 mil é arbitrário: Iguatu, com 98.064 habitantes, reduziria sozinha esse número em 330 mil com mais 1.936. Os dados não medem acesso a serviços, mas indicam onde investigar primeiro: nessas cidades, mais do que na capital.

#figure(
  image("../notebook_output/v5/figura_distancia_ceara.png", width: 52%),
  caption: [(a) Distância em linha reta do centro de cada município do Ceará ao município mais próximo com pelo menos 100 mil habitantes, em qualquer estado do Nordeste. (b) Simulação da população a mais de 100 km se as cidades indicadas passassem de 100 mil habitantes, uma de cada vez. Fonte: elaboração própria com dados do IBGE.],
) <fig:distancia>

== Interpretação e limitações

Pernambuco, que tem quase o mesmo número de municípios (185) e de habitantes (9,06 milhões), tem 12 acima de 100 mil, perto dos 14,2 previstos. Oito deles, porém, estão na Região Metropolitana do Recife, contra quatro do Ceará na de Fortaleza. Parte da diferença pode vir, portanto, de como as aglomerações são divididas em municípios, e não de uma diferença real nas cidades médias; este trabalho não separa as duas explicações.

*Limitações.* O município inclui áreas rurais e não coincide com a cidade; os arranjos populacionais do IBGE seriam uma unidade mais adequada. Há só um censo, o que impede testar o crescimento proporcional (os de 2010 e 2022 permitiriam). Outras escolhas de $x_min$ mudam $alpha$; nos estados de cauda curta (27 municípios no Rio Grande do Norte, 34 em Sergipe) os testes têm pouco poder; os testes do maior município e das cidades médias usam valores estimados dos mesmos dados e são aproximados; e as distâncias são em linha reta. A comparação vale para o Nordeste, não para o país.

== Conclusão

A população dos municípios cearenses segue a Lei de Zipf na inclinação ($alpha$ = 2,18 ± 0,10), mas não na forma: o Ceará é o único estado do Nordeste em que a lei de potência é rejeitada ($p$ = 0,03). O tamanho de Fortaleza, ao contrário, é compatível com a lei. Só o Ceará é rejeitado porque tem um degrau que os outros estados não têm: 14 municípios entre 70 mil e 85 mil habitantes, só 2 entre 85 mil e 130 mil, e 8 acima de 100 mil onde os modelos preveem 13 ou 14. O trabalho mostra onde está o desvio, mas não prova a causa, que pode estar na história do estado ou só na divisão dos municípios.

Esse degrau tem expressão no território: 1,29 milhão de cearenses vivem a mais de 100 km de um município com 100 mil habitantes, e Quixeramobim, Crateús, Iguatu e Quixadá ocupam as posições mais estratégicas. Sozinha, a regressão tradicional, com $R^2$ = 0,94, não indicaria nenhum problema de forma; seguir Newman (2005) troca a pergunta "a lei vale?" por outra, mais útil ao planejamento: onde a rede urbana se afasta dela.

#v(0.3em)
#heading(numbering: none)[Referências]

#set par(first-line-indent: 0em, hanging-indent: 1em, justify: false, spacing: 0.4em)
#set text(size: 8.5pt)

CLAUSET, A.; SHALIZI, C. R.; NEWMAN, M. E. J. Power-law distributions in empirical data. *SIAM Review*, v. 51, n. 4, p. 661-703, 2009. https://doi.org/10.1137/070710111.

EECKHOUT, J. Gibrat's law for (all) cities. *American Economic Review*, v. 94, n. 5, p. 1429-1451, 2004. https://doi.org/10.1257/0002828043052303.

GABAIX, X. Zipf's law for cities: an explanation. *The Quarterly Journal of Economics*, v. 114, n. 3, p. 739-767, 1999. https://doi.org/10.1162/003355399556133.

GABAIX, X.; IBRAGIMOV, R. Rank − 1/2: a simple way to improve the OLS estimation of tail exponents. *Journal of Business & Economic Statistics*, v. 29, n. 1, p. 24-39, 2011. https://doi.org/10.1198/jbes.2009.06157.

IBGE. *Censo Demográfico 2022: população residente, variação absoluta e taxa de crescimento geométrico*. SIDRA, tabela 4709, 2023. Disponível em: https://sidra.ibge.gov.br/tabela/4709. Acesso em: 3 nov. 2026.

NEWMAN, M. E. J. Power laws, Pareto distributions and Zipf's law. *Contemporary Physics*, v. 46, n. 5, p. 323-351, 2005. https://doi.org/10.1080/00107510500052444.

SIMON, H. A. On a class of skew distribution functions. *Biometrika*, v. 42, n. 3/4, p. 425-440, 1955. https://doi.org/10.2307/2333389.

SOO, K. T. Zipf's law for cities: a cross-country investigation. *Regional Science and Urban Economics*, v. 35, n. 3, p. 239-263, 2005. https://doi.org/10.1016/j.regsciurbeco.2004.04.004.

ZIPF, G. K. *Human behavior and the principle of least effort*. Cambridge: Addison-Wesley, 1949.
