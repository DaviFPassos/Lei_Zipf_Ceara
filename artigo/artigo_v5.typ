// Artigo da disciplina Ciência de Dados Aplicada à Ciência das Cidades, versão 5 (3 páginas, sequência de Newman, 2005).
// Todos os números vêm do notebook Lei_de_Zipf_Ceara_v5.ipynb.
// Para compilar, a partir da raiz do projeto (depois de executar o notebook):
//   uvx --from typst python -c "import typst; typst.compile('artigo/artigo_v5.typ', output='pdfs/entrega/trabalho_zipf_ceara_davipassos_v5.pdf', root='.')"

#set document(title: "A distribuição populacional dos municípios cearenses segue a Lei de Zipf?", author: "Davi Passos")
#set page(paper: "a4", margin: (x: 1.9cm, y: 1.8cm), numbering: "1")
#set text(font: "Libertinus Serif", size: 10.5pt, lang: "pt", region: "br")
#set par(justify: true, leading: 0.55em, spacing: 0.75em, first-line-indent: (amount: 1.2em, all: true))
#set heading(numbering: "1.")
#show heading: set text(size: 11pt)
#show heading: set block(above: 1.0em, below: 0.6em)
#show figure.where(kind: table): set figure.caption(position: top)
#show figure.caption: set text(size: 9pt)
#show figure: set block(above: 0.9em, below: 0.9em)
#set figure(placement: auto)
#set table(stroke: none, inset: (x: 5pt, y: 2.5pt))
#show table: set text(size: 9pt, hyphenate: false)
#show table: set par(justify: false)
#set math.equation(numbering: "(1)")

#let topo = table.hline(stroke: 0.8pt)
#let meio = table.hline(stroke: 0.4pt)

#align(center)[
  #text(size: 14pt, weight: "bold")[A distribuição populacional dos municípios cearenses segue a Lei de Zipf?]
  #v(0.2em)
  Davi Passos \
  #text(size: 9pt)[Universidade de Fortaleza | Mestrado em Ciência da Computação | Ciência de Dados Aplicada à Ciência das Cidades]
]

= Qual é o problema?

O tamanho das cidades não tem um valor típico: num mesmo estado convivem uma metrópole com milhões de habitantes e municípios com poucos milhares. Desde Auerbach (1913, apud NEWMAN, 2005) e Zipf (1949), observa-se que, ordenadas da maior para a menor, as cidades seguem aproximadamente $P_r prop r^(-q)$, com $q approx 1$: a segunda cidade teria metade da população da primeira, a terceira um terço, e assim por diante. Newman (2005) mostra que essa Lei de Zipf é uma lei de potência, $p(x) prop x^(-alpha)$, vista de outro ângulo: o gráfico de posição contra tamanho é a distribuição cumulativa $P(X >= x)$ com os eixos trocados, e $q = 1 slash (alpha - 1)$, de modo que $q = 1$ equivale a $alpha = 2$. A explicação mais aceita é o crescimento proporcional: se as cidades crescem a taxas que não dependem do tamanho, a distribuição tende a uma lei de potência com $alpha$ próximo de 2 (SIMON, 1955; GABAIX, 1999). Desvios indicam que o crescimento não foi proporcional e ajudam a identificar onde a rede urbana é desequilibrada, o que importa para planejar serviços que dependem de uma população mínima, como hospitais de alta complexidade e universidades.

*Este trabalho pergunta se a população dos 184 municípios do Ceará, rede dominada por Fortaleza, segue a Lei de Zipf.* A pergunta tem uma armadilha de método. O procedimento mais comum, ajustar uma reta por mínimos quadrados ao gráfico log-log de posição e tamanho, produz estimativas enviesadas e incertezas pequenas demais (NEWMAN, 2005; CLAUSET; SHALIZI; NEWMAN, 2009), e um $R^2$ alto não prova que os dados sigam uma lei de potência. Por isso, a análise segue a sequência proposta por Newman: medir, estimar, testar e interpretar.

= O que foi feito?

Foram usados os dados de população residente do Censo Demográfico 2022 (IBGE, SIDRA, tabela 4709) para os 184 municípios do Ceará e, para comparação, para os 1.794 municípios dos nove estados do Nordeste. Todo o processamento foi feito em Python, num notebook que baixa os dados e reproduz os números e a figura deste texto.

*Medir.* A distribuição foi representada pela função cumulativa complementar $P(X >= x)$ em escala log-log, que Newman recomenda no lugar do histograma por não depender da escolha de intervalos.

*Estimar.* Como referência, foi feita a regressão tradicional de $log P_r$ sobre $log r$, com o erro padrão corrigido de Gabaix e Ibragimov (2011), $q sqrt(2 slash n)$. O método principal é o estimador de máxima verossimilhança de Newman (2005, Eq. 5), $hat(alpha) = 1 + n [sum_i ln(x_i slash x_min)]^(-1)$, com erro $(hat(alpha) - 1) slash sqrt(n)$, aplicado só à cauda $x >= x_min$, já que a lei de potência raramente vale para os municípios pequenos. O limite $x_min$ foi escolhido pelo critério de Kolmogorov-Smirnov (CLAUSET; SHALIZI; NEWMAN, 2009).

*Testar.* A aderência foi avaliada por bootstrap paramétrico com 1.000 amostras: $p < 0,1$ indica que a lei de potência não é plausível. A alternativa log-normal, também compatível com crescimento proporcional (EECKHOUT, 2004), foi comparada pela razão de verossimilhança $cal(R)$, com o $p$ de Vuong ($cal(R) > 0$ favorece a lei de potência).

*Interpretar.* Para saber se Fortaleza destoa, usou-se a distribuição do maior de $n$ valores numa lei de potência (NEWMAN, 2005, seção III.B), $P(text("maior") >= x) = 1 - [1 - (x slash x_min)^(-(alpha - 1))]^n$. O número de municípios acima de 100 mil habitantes foi comparado ao previsto pela lei ajustada com um teste binomial.

= Quais são os resultados e as conclusões?

Em 2022, Fortaleza tinha 2.428.708 habitantes, 27,6% da população do estado e 6,83 vezes a de Caucaia, o segundo município. A regressão tradicional dá $q$ = 0,90 ($R^2$ = 0,94) para os 184 municípios e $q$ = 0,99 para os 20 maiores. Pelo erro usual, o primeiro valor rejeita a Lei de Zipf ($p < 0,001$); com o erro corrigido, não ($p$ = 0,29). A @tab:resultados resume a análise pelo método de Newman e a @fig:principal(a) mostra a distribuição cumulativa.

#figure(
  image("../notebook_output/v5/figura_artigo_v5.png", width: 100%),
  caption: [(a) Distribuição cumulativa complementar das populações municipais do Ceará em 2022, com a lei de potência de máxima verossimilhança, a Lei de Zipf ($alpha = 2$) e a log-normal truncada, todas ajustadas à cauda acima de $x_min$ (linha pontilhada vertical). A faixa cinza marca 100 mil a 400 mil habitantes. (b) Expoente $alpha$ nos nove estados do Nordeste por máxima verossimilhança (com intervalo de 95%) e pela regressão com todos os municípios ($alpha = 1 + 1 slash q$). Fonte: elaboração própria com dados do IBGE.],
) <fig:principal>

#figure(
  table(
    columns: (auto, auto, 1fr),
    align: (left, right, left),
    topo,
    table.header([*Etapa*], [*Resultado*], [*Leitura*]),
    meio,
    [Início da cauda ($x_min$)], [15.157 hab.], [129 municípios (70%) na cauda],
    [Expoente $alpha$ (máxima verossimilhança)], [2,18 ± 0,10], [$q$ = 0,85; $alpha = 2$ não é rejeitado ($p$ = 0,089)],
    [Aderência da lei de potência], [$p$ = 0,033], [lei de potência rejeitada],
    [Lei de potência × log-normal], [$cal(R)$ = −0,89; $p$ = 0,58], [o teste não distingue os dois modelos],
    [Aderência da log-normal truncada], [$p$ = 0,32], [log-normal plausível],
    [$P$(maior ≥ Fortaleza)], [0,28 (log-normal: 0,05)], [depende do modelo],
    [Municípios ≥ 100 mil (previstos / observados)], [14,0 (log-normal: 13,1) / 8], [faltam cidades médias nos dois modelos ($p$ = 0,051 e 0,083)],
    topo,
  ),
  caption: [Análise da cauda da distribuição cearense pela sequência de Newman (2005).],
) <tab:resultados>

*A inclinação é a de Zipf.* A máxima verossimilhança escolhe $x_min$ = 15.157 habitantes e estima $alpha$ = 2,18 ± 0,10, compatível com $alpha = 2$. Os dois métodos concordam: $q$ fica entre 0,85 e 0,99, e os intervalos incluem 1 quando a incerteza é calculada corretamente.

*A forma não é a de uma lei de potência.* O bootstrap rejeita a lei de potência ($p$ = 0,033). Na @fig:principal(a), os pontos acompanham a reta até cerca de 60 mil habitantes, ficam abaixo dela entre 70 mil e 400 mil e voltam a ela em Fortaleza. A log-normal truncada, que se curva para baixo, acompanha melhor esse trecho e é plausível ($p$ = 0,32), mas a razão de verossimilhança não distingue os dois modelos ($cal(R)$ = −0,89; $p$ = 0,58). Nos outros oito estados do Nordeste, o ajuste da log-normal converge para a própria lei de potência, o que indica que lá não há curvatura a explicar.

*Faltam cidades médias; o tamanho de Fortaleza depende do modelo.* Um ponto acima da reta não basta para chamar a capital de anômala, porque o maior valor de uma distribuição de cauda pesada varia muito. Pela lei de potência ajustada, a mediana esperada do maior município é 1,29 milhão, e a probabilidade de ele ter 2,43 milhões ou mais é 0,28; a razão de 6,83 entre os dois primeiros também não é significativa ($p$ = 0,10). Pela log-normal, cuja cauda é mais leve, essa probabilidade cai para 0,05. Como os dados não distinguem os dois modelos, não é possível afirmar que Fortaleza é grande demais. O resultado que não depende do modelo está abaixo da capital: a lei de potência prevê 14 e a log-normal 13 municípios com mais de 100 mil habitantes, e o Ceará tem 8 ($p$ = 0,051 e 0,083).

*No Nordeste, o caso cearense é único.* Repetida para os nove estados (@fig:principal(b)), a análise dá $alpha$ entre 2,18 (Ceará, o mais próximo de Zipf) e 2,50 (Alagoas), sempre acima de 2: na região, as cidades grandes são mais raras em relação às médias do que a lei estrita prevê. A lei de potência é plausível em todos os estados, menos no Ceará, e nenhuma capital é anômala pela lei ajustada ($P$ entre 0,10 e 0,42). A regressão, em contraste, dá $q$ de 0,83 a 1,10 com todos os municípios e, pelo erro usual, rejeita $q = 1$ em oito dos nove estados, rejeições que quase desaparecem com o erro corrigido.

*Conclusão.* A hierarquia cearense tem a inclinação da Lei de Zipf, mas não a sua forma: faltam cidades entre 100 mil e 400 mil habitantes abaixo da capital, resultado que aparece tanto na lei de potência quanto na log-normal. Já o tamanho de Fortaleza só é anômalo se a distribuição for log-normal. Se o crescimento fosse proporcional, como no mecanismo de Simon (1955) e Gabaix (1999), seria de esperar uma cauda sem esse degrau. Para o planejamento, isso aponta para os polos regionais (Juazeiro do Norte, Crato, Sobral e Iguatu), mais do que para a capital. A lição de método é a de Newman (2005): o $R^2$ de uma reta log-log não prova a lei, o erro da regressão subestima a incerteza, e a primazia deve ser julgada pela variabilidade do maior valor, que depende do modelo.

*Limitações.* O município não coincide com a mancha urbana: em Pernambuco, estado de tamanho parecido, 8 dos 12 municípios com mais de 100 mil habitantes estão na Região Metropolitana do Recife, enquanto a aglomeração de Fortaleza se divide em menos municípios grandes, o que pode explicar parte da falta de cidades médias. Os arranjos populacionais do IBGE seriam uma unidade mais adequada. Só o Censo de 2022 foi usado, o que impede testar diretamente o crescimento proporcional, e os testes do maior valor usam o expoente estimado com os mesmos dados.

#v(0.3em)
#heading(numbering: none)[Referências]

#set par(first-line-indent: 0em, hanging-indent: 1.2em, justify: false, spacing: 0.5em)
#set text(size: 8.5pt)

CLAUSET, A.; SHALIZI, C. R.; NEWMAN, M. E. J. Power-law distributions in empirical data. *SIAM Review*, v. 51, n. 4, p. 661-703, 2009.

EECKHOUT, J. Gibrat's law for (all) cities. *American Economic Review*, v. 94, n. 5, p. 1429-1451, 2004.

GABAIX, X. Zipf's law for cities: an explanation. *The Quarterly Journal of Economics*, v. 114, n. 3, p. 739-767, 1999.

GABAIX, X.; IBRAGIMOV, R. Rank − 1/2: a simple way to improve the OLS estimation of tail exponents. *Journal of Business & Economic Statistics*, v. 29, n. 1, p. 24-39, 2011.

IBGE. *Censo Demográfico 2022: população residente*. SIDRA, tabela 4709, 2023. Disponível em: https://sidra.ibge.gov.br/tabela/4709. Acesso em: 3 nov. 2026.

NEWMAN, M. E. J. Power laws, Pareto distributions and Zipf's law. *Contemporary Physics*, v. 46, n. 5, p. 323-351, 2005.

SIMON, H. A. On a class of skew distribution functions. *Biometrika*, v. 42, n. 3/4, p. 425-440, 1955.

ZIPF, G. K. *Human behavior and the principle of least effort*. Cambridge: Addison-Wesley, 1949.
