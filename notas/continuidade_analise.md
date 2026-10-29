# Continuidade da análise (branch `test`)

Notas para retomar o trabalho em outra máquina. Escritas em 29/10/2026, ao fim da sessão em que a comparação foi ampliada para oito estados.

## Onde estamos

- **`main`**: artigo com quatro estados (CE, BA, SP, PR) e a análise de máxima verossimilhança de Newman (2005). PDF: `pdfs/entrega/trabalho_zipf_ceara_davipassos_v2.pdf` (5 páginas).
- **`test`**: comparação ampliada para oito estados (+ RJ, MG, SC, RS). PDF: `pdfs/entrega/trabalho_zipf_ceara_davipassos_v3.pdf` (6 páginas).
- O merge de `test` em `main` ainda **não** foi decidido.
- Limite do manual: 3 páginas na entrega final. Por enquanto, o professor aceita até 10 para acompanhar o andamento.

### Como reproduzir

```bash
uv sync
uv run --with nbconvert --with nbclient jupyter nbconvert --to notebook --execute --inplace \
    --ExecutePreprocessor.timeout=1200 Lei_de_Zipf_Ceara_reproducao.ipynb   # cerca de 1 minuto
uvx --from typst python -c "import typst; typst.compile('artigo/artigo.typ', output='pdfs/entrega/trabalho_zipf_ceara_davipassos_v3.pdf', root='.')"
```

O artigo usa as figuras de `notebook_output/`, que fica fora do git; por isso o notebook precisa ser executado antes de compilar.

## Conclusões que se sustentam

| Conclusão | Força da evidência |
|---|---|
| A inclinação da hierarquia cearense é compatível com Zipf (q entre 0,85 e 0,99; intervalos incluem 1) | Forte, pelos dois métodos |
| Uma única lei de potência não descreve a cauda cearense (bootstrap, p = 0,033) | Moderada, perto do limite de 0,1 |
| A causa é a falta de cidades entre 100 mil e 400 mil (8 observadas, 14 previstas; binomial P(X ≤ 8) ≈ 0,05) | Moderada |
| O tamanho de Fortaleza, sozinho, **não** é anômalo (P(maior ≥ 2,43 mi) = 0,28 pela lei ajustada) | Forte, e contradiz o texto atual |
| O teste de mínimos quadrados gera rejeições falsas: o erro usual rejeita Zipf entre os 20 maiores em MG, PR, SC e RS (p < 0,001); o erro de Gabaix-Ibragimov não rejeita em nenhum (p entre 0,28 e 0,97) | Forte |
| O q de mínimos quadrados com todos os municípios não serve para comparar estados (de 0,83 a 1,42, conforme os municípios pequenos) | Forte |

A primazia medida pela razão 1ª/2ª (6,83) é real, mas vem de o segundo município (Caucaia) ser pequeno, não de Fortaleza ser grande demais.

### Correção pendente no artigo (prioridade máxima)

O artigo (v2 e v3) diz que "Fortaleza é grande demais" e que a rede combina "uma capital grande demais com poucas cidades médias". Pela distribuição do maior valor numa lei de potência (Newman, 2005, seção III.B), isso não se sustenta:

- mediana esperada do maior município com α = 2,18, x_min = 15.157 e n = 129: cerca de 1,29 milhão;
- probabilidade de o maior ter 2,43 milhões ou mais: 1 − (1 − (2.428.708/15.157)^(−1,176))^129 ≈ 0,28.

O valor de "945 mil" (tamanho em que se espera exatamente uma cidade acima) **não** é o máximo típico e não deve ser usado para dizer que Fortaleza é anômala. É preciso reescrever o texto como "falta de cidades médias abaixo da capital".

Mesma conta para os outros estados (P(maior ≥ observado)): BA 0,15; SP 0,82; RJ 0,26; MG 0,65; PR 0,58; SC 0,93; RS 0,98. Nenhuma capital é anômala pela lei ajustada. Essa conta ainda **não** está no notebook.

## Avaliação dos oito estados

- **Enriqueceu as evidências:** o Rio de Janeiro é o melhor contraponto (primazia parecida, razão 6,93, mas número de cidades acima de 100 mil próximo do previsto: 28 contra 31). MG, SC e RS reforçam a lição de método (rejeições falsas passaram de 1 para 4 estados).
- **Pesou no artigo:** duas tabelas de 8 linhas e três figuras são demais para 3 páginas e tiram o foco do Ceará.
- **O conjunto é arbitrário**, e as frases com "único" dependem dele. Um protótipo com as 26 UFs (bootstrap com 200 repetições, fora do notebook) mostrou:
  - o Ceará é o 9º em participação da maior cidade (o Norte é mais concentrado: RR 65%, AP 60%, AM 52%, AC 44%) e o 5º na razão 1ª/2ª;
  - Roraima também combina α compatível com 2 (p = 0,35) e lei de potência rejeitada (p = 0,07), embora tenha só 15 municípios.
  - Portanto, "o Ceará é o único" vale entre os 8, não no país.

## Próximos passos sugeridos

1. **Corrigir a narrativa sobre Fortaleza** (ver acima) e incluir no notebook o cálculo de P(maior ≥ observado) para cada estado.
2. **Testar a alternativa log-normal** (Newman, seção II.B; teste da razão de verossimilhança de Clauset, Shalizi e Newman, 2009). Responde diretamente se a forma da distribuição cearense é outra. Hoje aparece só como trabalho futuro.
3. **Reorganizar o artigo na sequência do Newman:** medir (distribuição cumulativa), estimar (máxima verossimilhança com x_min), testar (aderência e log-normal), interpretar (mecanismo de Yule/Gibrat). A regressão passa a ser "o método tradicional, comparado". A Figura 1(b) poderia mostrar a distribuição cumulativa do Ceará no lugar da reta.
4. **Interpretar α < 2 em SP e RS** (Newman, seção III: abaixo de 2 a média diverge e o total é dominado pelas maiores cidades). Opcional.
5. **Decidir o conjunto de comparação** (decisão do Davi, ainda em aberto):
   - os 9 estados do Nordeste (pares naturais; pergunta: "o Ceará é atípico na sua região?"); ou
   - as 26 UFs (DF excluído, porque tem um município), com um único gráfico de resumo no artigo.
6. **Reduzir para 3 páginas** na versão final: uma figura e uma tabela compactas, com os outros estados resumidos em frases.

## Outras pendências

- **Frase sobre planejamento** na introdução: "a concentração da população **define** a demanda..." é forte demais e não tem citação. Sugestão de reescrita:
  > A questão importa para o planejamento porque serviços especializados, como hospitais de alta complexidade e universidades, dependem de uma população mínima para existir. Assim, a forma da hierarquia urbana influencia onde a demanda se concentra e quanto a população precisa se deslocar entre municípios. A Lei de Zipf não indica uma distribuição ideal, mas oferece um padrão de comparação que permite medir o tamanho desses desvios.

  Referências possíveis (conferir antes de citar): Bettencourt et al. (2007), "Growth, innovation, scaling, and the pace of life in cities", *PNAS*; Jefferson (1939), "The law of the primate city", *Geographical Review*.
- **Erro de arredondamento na `main`:** o p de São Paulo (20 maiores, erro de Gabaix-Ibragimov) é 0,659, não 0,661, no artigo v2 e no README. Já está corrigido na `test`; se não houver merge, corrigir na `main` separadamente.
- **Referências acrescentadas** que convém conferir (DOIs): Clauset et al. (2009), Gabaix e Ibragimov (2011), Simon (1955), Eeckhout (2004); Auerbach (1913) citado como "apud Newman".
- **Figuras:** com oito estados, cores diferentes não se distinguem numa mesma área de gráfico; por isso o Ceará aparece em destaque e os demais em cinza com rótulo. Manter esse padrão se o número de estados crescer.
