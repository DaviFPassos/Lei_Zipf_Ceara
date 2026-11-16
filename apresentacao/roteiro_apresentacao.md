# Roteiro de apresentação: A distribuição populacional dos municípios cearenses segue a Lei de Zipf?

**Duração prevista:** cerca de 10 minutos de fala, mais perguntas. Se o tempo for menor, pule os blocos marcados com ✂️.
**Como usar:** leia em voz alta, no seu ritmo. O texto em *itálico entre colchetes* é indicação de cena, não é para falar. Os números estão no artigo `trabalho_zipf_ceara_davipassos_v5_v3.pdf`.

---

## 0. Cola rápida (leia antes de começar)

Se você esquecer todo o resto, lembre destas cinco frases:

1. **Pergunta:** a população dos 184 municípios do Ceará segue a Lei de Zipf?
2. **Na inclinação, sim:** α = 2,18 ± 0,10, e Zipf seria α = 2.
3. **Na forma, não:** o teste rejeita a lei de potência (p = 0,03), e o Ceará é o único dos nove estados do Nordeste onde isso acontece.
4. **O resultado que não depende do modelo:** faltam cidades médias. São 8 municípios com mais de 100 mil habitantes, e os modelos preveem 13 ou 14.
5. **Impacto:** 1,29 milhão de cearenses vivem a mais de 100 km de um município com 100 mil habitantes.

**Palavras que você vai usar, em português simples:**

| Termo | Como explicar |
|---|---|
| Lei de Zipf | A 2ª cidade tem metade da população da 1ª, a 3ª tem um terço, e assim por diante. |
| Lei de potência | A forma matemática por trás disso: poucas cidades enormes e muitas pequenas. |
| α (alfa) | O "expoente" da lei de potência. Zipf estrito é α = 2. |
| q | A mesma ideia, medida pelo ranking. q = 1 é Zipf. A conversão é α = 1 + 1/q. |
| Máxima verossimilhança | Um jeito mais confiável de estimar α do que a regressão, usando só a cauda (as cidades maiores). |
| Bootstrap | Simular milhares de estados "ideais" e ver se o Ceará real parece com eles. |
| p-valor | Se for menor que 0,1, a lei de potência não é plausível. |
| Log-normal | Um modelo concorrente, de cauda mais leve. |
| Cidades médias | Municípios entre 70 mil e 130 mil habitantes. |

---

## 1. Abertura (≈ 1 min)

> Boa tarde a todos. Eu sou o Davi, e vou apresentar o meu trabalho de Ciência de Dados Aplicada à Ciência das Cidades.
>
> A pergunta que eu quis responder é simples de dizer: **a população dos municípios do Ceará segue a Lei de Zipf?**
>
> Em uma frase, a Lei de Zipf diz o seguinte: se a gente ordena as cidades da maior para a menor, a segunda cidade tem metade da população da primeira, a terceira tem um terço, a quarta um quarto, e assim por diante.
>
> Eu usei os dados do Censo de 2022, do IBGE, para os 184 municípios do Ceará, e comparei com os outros oito estados do Nordeste.

---

## 2. Qual é o problema? (≈ 1 min 30 s)

*[Figura 1, painel (a): o mapa do Ceará]*

> Por que isso importa? Porque cidades não têm um tamanho típico. Altura de pessoas tem uma média, mas no mesmo estado existe uma metrópole com milhões de habitantes e municípios com poucos milhares.
>
> Essa regularidade foi notada por Auerbach, em 1913, e popularizada por Zipf, em 1949. Ela aparece como uma **lei de potência**. Depois, autores como Simon e Gabaix mostraram uma explicação: se as cidades crescem a taxas que não dependem do tamanho, a distribuição tende a Zipf.
>
> Para o planejamento, isso importa porque serviços especializados, como hospitais de alta complexidade e universidades, dependem de uma população mínima para existir. Então a forma da hierarquia de cidades influencia onde a demanda se concentra e quanto a população precisa se deslocar.
>
> E atenção: Zipf **não** é uma distribuição ideal. Ele é um **padrão de comparação**, para a gente medir onde a rede urbana se afasta dele.
>
> Existe também uma armadilha de método. O jeito mais comum de testar Zipf é ajustar uma reta no gráfico log-log. Só que isso dá estimativas enviesadas e erros pequenos demais, e um R² alto não prova nada. Por isso eu segui a sequência proposta por Newman, em 2005: **medir, estimar, testar e interpretar**.

---

## 3. O que foi feito? (≈ 2 min)

> Vou explicar cada etapa de forma direta.
>
> **Medir.** Eu representei a distribuição pela função cumulativa complementar em escala log-log. Ela mostra a fração de municípios com população maior ou igual a x. Newman recomenda isso no lugar do histograma, porque não depende da escolha de intervalos.
>
> **Estimar.** Primeiro, como referência, fiz a regressão tradicional. Testei se q = 1 com o erro usual e com o erro corrigido de Gabaix e Ibragimov. A correção é necessária porque os pontos de um ranking não são independentes.
>
> O método principal é a **máxima verossimilhança**, aplicada só à cauda, isto é, aos municípios acima de um tamanho mínimo, o x_min. Isso porque a lei de potência costuma valer só nas cidades grandes. Escolhi o x_min pelo critério de Clauset, Shalizi e Newman: o valor que deixa a distribuição ajustada mais próxima da real. No Ceará, deu **15.157 habitantes**, com **129 municípios na cauda**.
>
> **Testar.** Para saber se a lei de potência é plausível, fiz um **bootstrap** com 1.000 amostras simuladas. Se o p-valor for menor que 0,1, a lei de potência não é plausível. Também comparei com a **log-normal**, que é um modelo concorrente.
>
> **Interpretar.** Aqui eu calculei duas coisas: se Fortaleza é grande demais para a lei, e se faltam cidades médias, comparando o número de municípios previsto com o observado em vários limites de população.
>
> Por fim, para medir o impacto no território, calculei a distância em linha reta de cada município do Ceará até o município mais próximo com pelo menos 100 mil habitantes, em qualquer estado do Nordeste.

---

## 4. Resultados (≈ 4 min)

### 4.1 A inclinação bate com Zipf

*[Figura 1, painel (b): o gráfico rank-size]*

> Primeiro resultado. Fortaleza tem 2,4 milhões de habitantes, 27,6% do estado. É 6,83 vezes a população de Caucaia, que é a segunda.
>
> A regressão com os 184 municípios dá **q = 0,90**. A máxima verossimilhança dá **α = 2,18 com margem de 0,10**. Zipf estrito seria α = 2, e esse valor **não é rejeitado**, com p = 0,089.
>
> Ou seja: **os dois métodos concordam, a inclinação do Ceará é compatível com a de Zipf.**

### 4.2 Mas a forma não é

*[Figura 2, painel (a)]*

> Só que inclinação compatível não garante que a forma seja a mesma. O bootstrap **rejeita a lei de potência**, com **p = 0,03**.
>
> Neste gráfico dá para ver. Os pontos acompanham a reta até uns 70 mil habitantes, depois ficam **abaixo** dela, e Fortaleza fica cerca de três vezes **acima**.
>
> A log-normal, que se curva para baixo, acompanha melhor esse trecho e é plausível, com p = 0,32. Mas a comparação direta entre os dois modelos não consegue dizer qual é melhor, com p = 0,58. Então eu **não afirmo** que a log-normal é a resposta certa. Só que ela é plausível e a lei de potência não é.

### 4.3 Fortaleza: depende do modelo

> E Fortaleza? Pela lei de potência, o tamanho dela é perfeitamente plausível, com probabilidade de 0,28. Pela log-normal, essa probabilidade cai para 0,05, que é o limite.
>
> Como os dados não distinguem os dois modelos, eu **não posso dizer que Fortaleza é grande demais**, nem descartar essa hipótese.

### 4.4 O resultado que não depende do modelo: faltam cidades médias

*[Figura 2, faixa cinza do painel (a); Tabela 1]*

> O resultado mais sólido está **abaixo** da capital. A lei de potência prevê **14** municípios com mais de 100 mil habitantes, e a log-normal prevê **13**. O Ceará tem **8**. É uma evidência moderada, com p entre 0,05 e 0,08.
>
> E a falta tem um começo definido. Acima de 70 mil habitantes, o número de municípios é o previsto. Mas há **14 municípios entre 70 mil e 85 mil**, e **só 2 entre 85 mil e 130 mil**, que são Iguatu e Maranguape. A hierarquia se interrompe por volta de 85 mil habitantes.
>
> Resumindo: o tamanho da lacuna depende do modelo, mas **a existência dela não**.

### 4.5 Comparação com o Nordeste ✂️

*[Figura 2, painel (b); Tabela 2]*

> Repeti tudo nos nove estados do Nordeste. Em todos, α fica acima de 2, ou seja, as cidades grandes são mais raras do que a lei estrita prevê.
>
> O Ceará é o **mais próximo de Zipf**, com 2,18. Mas é o **único** em que a lei de potência é rejeitada. Em todos os outros ela é plausível. Nenhuma outra capital é anômala. E a falta de cidades médias só se aproxima de significativa no Ceará.
>
> Também vale um recado de método: com o erro usual da regressão, rejeita-se q = 1 em 8 dos 9 estados. Com o erro corrigido, só na Bahia. **O método muda a conclusão.**

### 4.6 O que isso significa no território

*[Figura 3]*

> Para dar um significado prático, eu calculei distâncias. Cerca de **1,29 milhão de cearenses**, 14,7% da população, vivem a **mais de 100 km** de um município com 100 mil habitantes. Eles estão concentrados no centro e no oeste do estado.
>
> Isso é quase o dobro de Pernambuco, que tem população parecida, com 7,4%.
>
> Mas, se o limite fosse 80 mil habitantes em vez de 100 mil, esse número cai para 4,5%. Ou seja: **o interior cearense tem cidades bem distribuídas, só que um degrau abaixo do porte médio.**
>
> Fiz uma simulação. Se **Quixeramobim, Crateús, Iguatu e Quixadá** passassem de 100 mil habitantes, esse número cairia de 1,29 milhão para cerca de 160 mil. Isso não é uma previsão, o limite de 100 mil é arbitrário. É um jeito de apontar quais cidades ocupam posição estratégica na rede. A Iguatu, por exemplo, tem 98.064 habitantes. Com mais 1.936, ela sozinha reduziria esse número em 330 mil pessoas.

---

## 5. Limitações (≈ 45 s)

> É importante ser honesto sobre o que o trabalho **não** mostra.
>
> - A unidade é o **município**, que inclui áreas rurais e não coincide com a mancha urbana. Em Pernambuco, 8 dos 12 municípios grandes estão na Região Metropolitana do Recife, contra 4 no Ceará. Então parte da diferença pode vir de como cada metrópole é dividida em municípios, e não só de uma diferença real. Não separei as duas explicações.
> - Usei **só o Censo de 2022**, então não consigo testar diretamente o crescimento proporcional.
> - As **distâncias são em linha reta**, e população não é o mesmo que oferta de serviços.
> - Os testes do maior município e das cidades médias usam parâmetros estimados com os mesmos dados, então são aproximados.
> - A comparação vale para o Nordeste, não para o país.

---

## 6. Conclusão (≈ 45 s)

> Voltando à pergunta: **o Ceará segue a Lei de Zipf?**
>
> **Na inclinação, sim.** α = 2,18, compatível com 2.
> **Na forma, não.** O Ceará é o único estado do Nordeste em que a lei de potência é rejeitada.
>
> O desvio tem lugar definido: a hierarquia se interrompe por volta de 85 mil habitantes. O interior tem cidades, mas poucas chegaram ao porte seguinte, e isso tem expressão no território.
>
> E o método foi decisivo. Sozinha, a regressão tradicional, com R² de 0,94, não indicaria nenhum problema de forma. Seguindo a sequência de Newman, a pergunta deixa de ser "a lei vale?" e passa a ser uma mais útil para o planejamento: **onde a rede urbana se afasta dela?**
>
> Muito obrigado. Fico à disposição para perguntas.

---

## 7. Perguntas prováveis e respostas

**O Ceará segue Zipf ou não segue?**
Depende do que se mede. Na inclinação, sim. Na forma, não: a lei de potência é rejeitada (p = 0,03). E essa rejeição vem de um trecho específico, as cidades médias.

**Fortaleza é grande demais?**
Não dá para afirmar. Pela lei de potência, o tamanho dela é plausível (p = 0,28). Pela log-normal, fica no limite (p = 0,05). Os dados não distinguem os dois modelos.

**Por que não usar só a regressão?**
Porque ela dá estimativas enviesadas e erros subestimados. Um R² alto não prova lei de potência. Neste trabalho, com R² = 0,94, a regressão sozinha não mostraria nenhum problema de forma.

**O que é o x_min e por que só a cauda?**
É o tamanho mínimo a partir do qual a lei de potência é ajustada. A lei costuma valer só nas cidades maiores. No Ceará, x_min = 15.157 habitantes, com 129 municípios na cauda.

**Por que a log-normal não é a resposta?**
O teste de comparação deu p = 0,58, ou seja, os dados não distinguem os dois modelos. A log-normal é plausível, mas não está provado que é melhor.

**Por que 100 mil habitantes? Esse limite não é arbitrário?**
É arbitrário, e eu disse isso no trabalho. Por isso mostrei a sensibilidade: com 150 mil, o Ceará tem 15,9% e Pernambuco 13,2%; com 80 mil, 4,5% e 1,7%. O Ceará fica sempre acima de Pernambuco.

**Isso significa que faltam hospitais ou universidades nessas cidades?**
Não. Os dados do trabalho não medem acesso a serviços. Eles só indicam **onde investigar primeiro**: Quixeramobim, Crateús, Iguatu e Quixadá.

**A diferença para Pernambuco é real ou é um efeito da divisão em municípios?**
Pode ser parte dos dois. Pernambuco tem 8 municípios grandes na região metropolitana do Recife, e o Ceará tem 4 na de Fortaleza. O trabalho não separa as duas explicações. Uma unidade melhor seria os arranjos populacionais do IBGE.

**Por que o Nordeste?**
Porque os estados têm história de povoamento e economia mais parecidas, e porque o conjunto não depende de escolha do autor.

**O que fazer depois?**
Usar arranjos populacionais, testar o crescimento proporcional com os censos de 2010 e 2022 e cruzar a rede urbana com dados de hospitais, universidades e deslocamentos.

**Se eu não souber responder:**
> "Essa é uma boa pergunta, e eu não testei isso neste trabalho. Posso verificar e retornar depois."

---

## 8. Dicas para não passar vergonha

- **Não leia as equações.** Se perguntarem, diga: "α é o expoente da lei de potência; Zipf estrito é α = 2".
- **Se travar em um número,** volte à cola rápida do início: 184 municípios, α = 2,18, p = 0,03, 8 observados contra 13 ou 14 previstos, 1,29 milhão a mais de 100 km.
- **Não diga "provei".** Diga "o teste rejeita" ou "é compatível". O trabalho tem evidência moderada nas cidades médias (p = 0,05 e 0,08).
- **Fale devagar nos números.** Respire entre as seções.
- **Se o tempo apertar,** corte o bloco 4.5 (Nordeste) e reduza o 4.6 à primeira metade (1,29 milhão e 4,5%).
