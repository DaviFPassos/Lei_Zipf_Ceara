# Fator geográfico: rejeição do Ceará e distância na região central

Script: `analise/analise_geografica_ceara.py` (reproduz os números do artigo e acrescenta os testes abaixo). Saídas em `notebook_output/geografia/` (tabelas CSV e `figura_geografia_ceara.png`). Dados: os mesmos de `data/`, sem nada novo.

## Pergunta 1: há um fator geográfico na rejeição da lei de potência?

**Não há gradiente espacial no interior.** O tamanho dos municípios não cai com a distância a Fortaleza (Spearman fora da RMF: ρ = −0,04, p = 0,59) e municípios grandes e pequenos não se agrupam no mapa (Moran I fora da RMF: −0,02, p = 0,76).

**O que há é um efeito da região metropolitana.**
- Os 12 municípios a até 50 km de Fortaleza ocupam 2,6% da área e têm 41% da população.
- Dos 14 municípios de 70 mil a 85 mil habitantes, 6 estão a menos de 50 km de um município com 100 mil (Pacatuba, Aquiraz, Horizonte, Eusébio, Pacajus e Barbalha, vizinha de Juazeiro do Norte).
- Unir a região metropolitana de Fortaleza em um só município muda o teste: p de aderência 0,033 (sem unir), 0,127 (raio de 30 km), 0,055 (50 km), 0,353 (70 km). A rejeição não resiste a uma delimitação de 30 km.
- Com a mesma união, Pernambuco passa de 12 municípios acima de 100 mil observados contra 14,2 previstos (razão 0,84) para 4 contra 7,4 (0,54, raio de 50 km), perto do Ceará (0,52). A normalidade de Pernambuco vem em parte da divisão do Recife em vários municípios.
- A Paraíba mostra que o teste é sensível: aceita a lei sem união (p = 0,44) e passa a rejeitá-la com 50 km (p = 0,001).

**Leitura:** "único estado em que a lei é rejeitada" é frágil. O que resiste é a falta de cidades médias (razão observado/previsto em torno de 0,5 a 0,6 em todas as delimitações), mas com p entre 0,07 e 0,14 quando a metrópole é unida, porque o teste perde poder com menos unidades.

## Pergunta 2: a distância na região central tem causa geográfica?

**Correção de número.** Há 14 municípios (441.566 habitantes, 5,0%) a mais de 150 km de um município com 100 mil, e o máximo é 207 km. Os 47 municípios e 1,29 milhão (14,7%) são a mais de 100 km.

**O que a geografia mostra:**
- A zona a mais de 100 km de um polo tem 42,2% da área e 14,7% da população: 20,6 hab/km², contra 47,3 nas demais e 946 na RMF. Os municípios têm em média 1.338 km², o dobro dos demais (657 km²).
- Dos 8 municípios com 100 mil ou mais, 4 estão a até 40 km de Fortaleza. Tirar Caucaia, Maracanaú e Maranguape quase não muda a cobertura (16,0% contra 14,7%): os 8 polos agem como 4 (Fortaleza, Sobral, Itapipoca e Cariri, com 16,7%).
- Sortear 8 polos ao acaso, com probabilidade proporcional à população, dá em média 14,4% (90%: 5,9 a 25,6): o observado (14,7%) é típico. Sortear 14 (o número previsto pela lei) daria 5,7%, e o observado ficaria acima de 96% dos sorteios. Ou seja, a distância vem de haver poucos polos, não de eles estarem em lugar incomum.
- A geografia não impõe o problema: 8 polos bem escolhidos cobririam todo o estado (0% a mais de 100 km).

## Limites

- Distâncias entre centroides de polígonos, não entre sedes urbanas. Em municípios grandes (Tauá, 4.009 km²; Quixeramobim, 3.326 km²) o erro pode ser de dezenas de quilômetros.
- A união por raio a partir da capital é aproximada e não é a delimitação oficial. Os arranjos populacionais do IBGE seriam o teste certo.
- Chuva, relevo e rios foram medidos depois, na seção "Seca, sertão, serras e rios". A proporção urbana e rural continua sem medida (não está nos dados baixados).
- O bootstrap usa 1.000 repetições (erro de cerca de 0,01 no p), então p = 0,055 e 0,127 diferem de fato, mas p = 0,05 e 0,07 não.

# Seca, sertão, serras e rios (São Francisco)

Scripts: `analise/coletar_dados_geograficos.py` (baixa os dados para `data/geografia/`) e `analise/analise_fatores_ambientais_ceara.py`. Saídas em `notebook_output/geografia/`. Fontes: chuva média de 2001 a 2023 (NASA POWER, grade de cerca de 55 km), altitude (SRTM 30 m), rios (OpenStreetMap), litoral (Natural Earth) e a lista oficial de 1.477 municípios do semiárido (IBGE/SUDENE, 2022).

## Resultados

**Sertão e seca.**
- 175 dos 184 municípios cearenses (95%) estão na lista oficial do semiárido. Os 9 de fora, entre eles Fortaleza, têm 3,06 milhões de habitantes.
- No Ceará fora da RMF, a chuva se associa ao tamanho do município mesmo controlando a área e a distância ao litoral: +100 mm de chuva anual = cerca de 27% mais população (p < 0,001). A área do município é o fator mais forte (maior área, mais população).
- Os 8 municípios com 100 mil ou mais ficam todos onde a chuva é de 900 mm ou mais. O maior município abaixo de 850 mm é Iguatu (98 mil), e abaixo de 750 mm é Quixeramobim (82 mil).
- A zona a mais de 100 km de um polo é mais seca (746 mm contra 893 mm), mais variável de um ano para outro (coeficiente de variação 0,31 contra 0,27) e mais longe do litoral (200 km contra 91 km), mas não é mais alta nem mais longe dos rios principais.
- **A seca não é um teto absoluto.** No Nordeste há 10 municípios com 100 mil ou mais onde chove até 850 mm (Campina Grande, Petrolina, Caruaru, Vitória da Conquista, Mossoró, Juazeiro BA, Arapiraca, Paulo Afonso, Itabaiana e Patos). O Ceará tem 0 de 83 municípios secos com 100 mil ou mais, contra 10 de 754 no resto da região, uma diferença que o acaso explica (Fisher p = 0,61; esperado cerca de 1).
- O Ceará seco tem mais cidades de 50 mil a 100 mil que o resto do Nordeste seco (14 de 83, 17%, contra 44 de 754, 6%; p < 0,001). A seca não impede cidades médias; o que falta é o degrau seguinte.
- Entre os estados semiáridos, a parcela da população semiárida que vive em cidades de 100 mil ou mais é parecida: Ceará 21,1%, Pernambuco 22,7%, Paraíba 21,2%, Bahia 22,1%. O Ceará não destoa nesse indicador.

**Serras.** Sem efeito mensurável. Entre os 30 municípios com altitude média de 500 m ou mais, 13% têm 50 mil ou mais habitantes (21% nos demais). A altitude não é significativa na regressão. As exceções são Crato, Tianguá e Barbalha.

**Rios principais do Ceará.** Evidência fraca: a distância do centroide ao rio não se associa ao tamanho. Os municípios banhados por rios principais são um pouco maiores só fora da RMF e controlando a área (p = 0,038; no estado todo, p = 0,88).

**Rio São Francisco.**
- O Ceará não toca no rio: o município mais próximo (Penaforte) fica a 90 km.
- No semiárido, 3 dos 41 municípios banhados pelo rio têm 100 mil ou mais (Petrolina, Juazeiro BA e Paulo Afonso), contra 22 de 1.213 nos demais (Fisher p = 0,045). As duas maiores cidades do sertão, Petrolina e Juazeiro, estão entre os municípios mais secos do Nordeste (424 e 446 mm). Isso sugere que a seca não impede cidade grande onde há rio perene, mas são só 3 casos.

## Limites

- A chuva da NASA POWER é uma grade de cerca de 55 km: subestima o litoral (Fortaleza aparece com 1.084 mm) e achata as serras. Serve para comparar municípios entre si, não como valor absoluto.
- A altitude média usa o centroide e quatro pontos a cerca de 9 km, que em municípios pequenos caem em vizinhos. Os rios vêm do OpenStreetMap, e os rios cearenses são intermitentes (contexto, não medido aqui).
- Altitude, distância ao litoral e chuva são correlacionadas (altitude e litoral, ρ = 0,78; chuva e litoral, ρ = −0,62), então os efeitos separados são incertos.
- Obras de transposição do São Francisco, irrigação, indústria e história econômica não foram medidas.
- São associações, não causas.

# Outros rios e açudes: o Cariri tem mais água que a região central?

Seção 7 de `analise/analise_fatores_ambientais_ceara.py` (rios e corpos d'água do OpenStreetMap). Cariri = 14 municípios a até 50 km de Juazeiro do Norte.

- **Hidrografia (fontes jornalísticas e técnicas, não medida aqui):** o Ceará é drenado por bacias próprias (Jaguaribe, com Salgado e Banabuiú; Metropolitana; Acaraú; Curu; Coreaú; Parnaíba na divisa oeste). O Cariri está na bacia do Salgado, cujas nascentes ficam na Chapada do Araripe. Nenhuma fonte encontrada trata rio cearense como afluente do São Francisco.
- **Rios:** densidade de rios mapeados igual no Cariri e na região central (4,10 e 4,08 km por 100 km²; p = 0,75). Os municípios banhados por rios principais são mais frequentes no centro/oeste (55% contra 29% no Cariri).
- **Açudes:** o centro/oeste tem mais (espelho d'água de 0,50% da área contra 0,14% no Cariri; p = 0,001). Atenção: o OpenStreetMap não traz Castanhão, Orós nem Banabuiú, então a área dos maiores açudes está subestimada.
- **Chuva:** o Cariri é mais úmido (863 mm contra 766 mm, cerca de 97 mm ou 13%). O p < 0,001 trata os municípios como independentes, mas os 14 do Cariri compartilham só 4 células da grade de chuva (e os 47 do centro, 23). Por célula, o p é 0,041. A associação entre chuva e tamanho no estado todo continua forte com erro agrupado por célula (+100 mm = +27% de população, p < 0,001, 49 células).
- **Regressão fora da RMF:** com área, chuva e litoral controlados, densidade de rios (p = 0,37) e área de açudes (p = 0,54) não se associam ao tamanho; chuva continua significativa (p < 0,001).
- **Leitura:** a diferença entre Cariri e centro não vem de rios nem de açudes mapeados; a chuva é o único fator hídrico com associação. Água subterrânea (aquífero do Araripe, nascentes), perenidade dos rios e história não foram medidas.

## Jaguaribe, Salgado e Banabuiú, rio por rio

Municípios cujo território contém trechos do rio (OpenStreetMap), em todo o Ceará:

| Rio | Municípios | Mediana da população | 50 mil+ | 100 mil+ |
|---|---|---|---|---|
| Jaguaribe (curso principal) | 23 | 19.675 (demais: 21.433) | 6 | 0 |
| Salgado | 9 | 36.822 (demais: 20.189) | 3 | 2 (Juazeiro do Norte e Crato) |
| Banabuiú | 11 | 40.187 (demais: 20.213) | 5 | 0 |

- No curso principal do Jaguaribe, coeficiente de regressão +0,007 (p = 0,90), com área, chuva e litoral controlados: nenhuma relação. Ele banha 11 dos 47 municípios da região central.
- No Salgado, +0,126 desvio-padrão (p = 0,11) e 100 mil+ em 2 de 9 municípios contra 6 de 175 nos demais (Fisher p = 0,051). Sinal fraco, de uma amostra minúscula, e Juazeiro e Crato formam uma só conurbação. Sem os dois, a mediana do Salgado é 30.802.
- No Banabuiú, +0,090 (p = 0,042), mas sem nenhuma cidade de 100 mil.
- Cuidado: o OpenStreetMap pode nomear trechos de cabeceira com outros nomes (Barbalha, por exemplo, não aparece como banhada pelo Salgado).

# Cariri x região central: economia, serviços, mercado e crescimento

Scripts: `analise/coletar_dados_socioeconomicos.py` e `analise/analise_cariri_centro.py`. Fontes: IBGE/SIDRA (população 2010 e 2022, PIB 2022 e valor adicionado por setor de 2021, Cadastro Central de Empresas 2022) e CNES (hospitais gerais e especializados). Não foi possível baixar dados de ensino superior (INEP). Saídas em `notebook_output/geografia/` (`cariri_centro_*.csv`, `zipf_2010_2022.csv` e `figura_cariri_centro.png`).

## Cariri (14 municípios) x região central (47), valores agregados

| | Cariri | Centro/oeste |
|---|---|---|
| População 2022 | 737 mil | 1,29 milhão |
| Crescimento 2010-2022 | +10,3% | −0,3% (27 dos 47 municípios perderam população) |
| PIB per capita (R$) | 15.047 | 13.232 |
| Serviços (% do valor adicionado) | 52,4 | 37,5 |
| Administração pública (%) | 29,7 | 36,5 |
| Agropecuária (%) | 8,3 | 16,7 |
| Empregos formais por 100 hab. | 16,5 | 11,5 |
| Salário médio mensal (R$) | 2.379 | 2.209 |
| Hospitais por 100 mil hab. | 4,7 | 4,3 |

## Município a município (Mann-Whitney)

A diferença não é regional, é de Juazeiro. As medianas dos municípios são parecidas em PIB per capita (11,1 mil e 12,5 mil), empregos por 100 hab. (10,3 e 9,9), parcela de serviços (29,6% e 30,5%) e administração pública (44% e 42%). Juazeiro do Norte tem 22 empregos por 100 hab. e 66,5% de serviços. O que difere de verdade é o mercado ao redor: mediana de 639 mil habitantes a até 50 km no Cariri contra 134 mil no centro (p < 0,001), e 1,40 milhão contra 0,73 milhão a até 100 km (p < 0,001). Juazeiro, Crato e Barbalha somam 492 mil habitantes.

O mercado ao redor, sozinho, não explica o corte de 100 mil: Iguatu (183 mil a até 50 km), Russas (255 mil) e Limoeiro do Norte (274 mil) têm mercado comparável ao de Sobral (204 mil) e continuam abaixo de 100 mil.

## Crescimento proporcional

- O crescimento de 2010 a 2022 depende do tamanho: Spearman +0,31 no Ceará (p < 0,001), positivo nos nove estados e significativo em seis. Os maiores crescem mais, o que contradiz o crescimento proporcional.
- Crescimento mediano por faixa de tamanho em 2010: menos de 10 mil, −0,9%; 10-20 mil, +0,6%; 20-50 mil, +1,7%; 50-70 mil, +8,7%; 70-100 mil, +4,7%; 100-200 mil, +7,8%; 200 mil ou mais, +11,7%.
- As cidades médias do interior cresceram devagar (Iguatu +3,0%, Quixadá +4,4%, Crateús +4,9%, Canindé +1,3%, Russas +3,6%). As de crescimento rápido na faixa de 70 mil a 100 mil são satélites de Fortaleza (Eusébio +61%, Horizonte +35%) ou do Cariri (Barbalha +35%).

## A lei de potência em 2010

O Ceará já era rejeitado em 2010 (p = 0,031, contra 0,033 em 2022) e tinha os mesmos 8 municípios com 100 mil ou mais. Nos outros oito estados a lei é plausível nos dois anos. O degrau é estrutural, não de 2022.

## Limites

Cadastro Central de Empresas só conta emprego formal, e no sertão o informal pesa. Hospitais são contados por estabelecimento, sem leitos nem complexidade. O PIB municipal inclui o gasto público. Os grupos (14 e 47 municípios) foram definidos por mim. São associações, não causas.

# Como o Cariri se formou: solo, água subterrânea e história

Script: `analise/coletar_solo_amostra.py` (SoilGrids/ISRIC, 5 a 15 cm de profundidade, amostra de 14 municípios do Cariri e 14 da região central, sorteados com semente 42; modelo estatístico de 250 m, não medida de campo).

**Solo (medido).** Medianas, Cariri contra centro/oeste: argila 26,9% contra 20,8%; areia 51,3% contra 57,2%; carbono orgânico 12,3 contra 9,3 g/kg; pH 5,9 contra 6,0; capacidade de troca de cátions 13,6 contra 16,1 cmolc/kg. O Cariri tem solo com mais argila e matéria orgânica (retém mais água), mas menor capacidade de reter nutrientes. O solo não é claramente mais fértil.

**Água subterrânea (fontes, não medida aqui).** A Bacia Sedimentar do Araripe tem aquíferos importantes (Grupo Missão Velha e Formação Mauriti). O topo da chapada recebe a recarga e, com as camadas inclinadas para o norte, a descarga vai para o Cariri e forma nascentes. O Cariri depende quase só de água subterrânea. Uma fonte cita 63% do Ceará sobre embasamento cristalino, de solos rasos (menos de 50 cm) e pouco armazenamento. Não encontrei fonte para o número de 75% que eu lembrava.

**História (fontes, não verificadas a fundo).** Padre Cícero chega a Juazeiro em 1872; o povoado vira refúgio para gente do sertão cearense e de estados vizinhos; as romarias moldam a organização urbana; e um modelo de pequena propriedade ("Padrão Juazeiro") aparece associado a ele. Não encontrei fontes sobre comércio, cana e rapadura.

**O que falta:** a geologia e a vazão de poços por município (CPRM/SGB), séries históricas de população antes de 2010 para ver quando o Cariri se separou do resto, e dados de ensino superior.

## Versão final do artigo

`artigo/artigo_final.typ` (copia de `artigo_v5_v3.typ`) gera `pdfs/entrega/trabalho_zipf_ceara_davipassos_final.pdf` (7 páginas, 1 a mais que antes por causa de um parágrafo novo na seção 3.6, ajustes nas limitações e na conclusão e três referências a mais). O PDF anterior ficou em `pdfs/testes/trabalho_zipf_ceara_davipassos_final_anterior.pdf`. Chuva e solo ficaram fora do texto (diferença pequena ou ambígua).
