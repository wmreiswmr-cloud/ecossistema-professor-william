# A3 — Itens do quadro perdem o rastro do próprio estado (2026-08-22)

**Queila Qualidade (`cerebro-qualidade`), despacho real, 2026-08-22.**
Não decido e não executo. Diagnóstico + contramedida proposta; Ricardo Diretor e William decidem juntos.
Portão lido antes de agir: `processo-empresa.md` + `armadilhas-conhecidas.md` (6, 7, 21, 22, 25, 30).

---

## 1. Contexto

Em 3 dias apareceram 5 ocorrências em que a informação de controle de um item (estado, prazo, contagem de escalonamento, identidade) ficou escrita num lugar que nenhum leitor do quadro consulta. O efeito é sempre o mesmo: **o quadro mente sobre si mesmo**, para cima (vencido falso) ou para baixo (vencido invisível). Isso ataca a rotina que o dono usa todo dia para saber onde a empresa está.

## 2. Condição atual — medida por mim, em linha crua

Tudo abaixo foi verificado por leitura da linha crua ou execução real, nunca por contagem nem por relato de terceiro (Armadilha 30).

| O que medi | Número | Como medi |
|---|---|---|
| Itens distintos no quadro | **116** IDs, maior = **#123**, em **131** linhas de item | `grep` de 1ª célula numérica, IDs deduplicados |
| Itens cuja **última linha viva** contradiz o estado real | **8 de 8** conferidos (#18, #19, #24, #33, #52, #78, #107, #110) | li a célula Status da última linha numérica de cada um: `⏳ Aberto` ×5, `READY` ×1, `BLOCKED` ×2 — todos fechados com prova em outro lugar |
| Fechamentos escritos fora da linha do item | **10 item-fechamentos** — 7 na tabela narrativa de 19/08 (1ª célula `#18 (duração da pesquisa…)`) + 3 numa célula só (`106/107/110`) | linhas cruas 538-544 e 768 |
| Contador automático de escalonamento | `contagem-vencimentos.json` = **`{}`**, 2 bytes | `cat` do arquivo |
| Decisão vencida sem sinal | **1**, 3 dias (`decisoes.md` L70, data real no texto do "resultado real") | linha crua |
| Colisões de numeração | **2** (#94 em 19/08; #118/#120 em 22/08) | notas do próprio quadro |
| **Achado novo desta análise** — o poka-yoke criado hoje já está quebrado | `node auditoria/valida-quadro.js` → **13 falsos positivos**, exit 1 | executei o script real agora |

**O achado novo, porque muda o diagnóstico.** `valida-quadro.js` (criado hoje contra o defeito do #112) isenta as tabelas históricas por **faixa de número de linha** (`de:110 ate:140`, `de:245 ate:255`). O arquivo cresceu desde então: a tabela de 03/08 mora hoje em 142-153 e a tabela "Recorrente" em 269-271. As duas saíram da faixa e o script agora acusa **13 defeitos inexistentes** (conferi: L271 tem 8 campos, é cabeçalho de outra tabela, não item malformado). O instrumento construído para pegar a classe **é ele próprio uma instância da classe** — controle preso a uma posição que se move. Alerta falso treina o time a ignorar o painel (Armadilha 7).

**Corolário medido:** as referências `L155/L161/L173/L179/L262/L438/L689/L712` que o Sandro Sentinela deixou no #121 hoje de manhã **já não apontam para os itens citados** — L173 é o #17, L179 é o #23. Número de linha apodrece em horas neste arquivo.

## 3. Meta

**Zero item cuja linha viva discorde do estado real, verificado por instrumento e não por leitura humana** — medido por um validador que roda dentro de uma rotina existente e falha alto. Prazo proposto: em operação até **29/08** (mesmo SLA do #121), reavaliado em **21/09**.

## 4. Análise de causa

### 4.1 Primeiro: o enquadramento está certo? (Armadilha 21)

**Parcialmente. Não é uma causa raiz só — são três, numa mesma família.** Forçar uma causa comum onde há três produziria uma contramedida que resolve um terço do problema e dá o assunto por fechado. Separo:

| Grupo | Ocorrências | Mecanismo real |
|---|---|---|
| **A — schema sem dono na escrita** | #121, #122, #112, **+ o defeito novo do `valida-quadro.js`** | dado de controle escrito num lugar que os leitores não leem |
| **B — estado sem armazenamento** | absorção #29→#67 | a contagem de escalonamento não existe em lugar nenhum: é re-derivada da prosa a cada execução |
| **C — alocação sem coordenação** | #94, #118/#120 | não há alocador de ID; quem abre item lê o maior e torce |

A é o grupo dominante (4 de 6 ocorrências) e é o que produziu os 8 vencidos falsos.

### 4.2 Causa comum × causa especial (Deming)

- **Grupo A é causa comum, sem dúvida.** 4 manifestações, 4 autores diferentes, em 3 dias, sem evento disparador compartilhado — é a variação normal de um processo de escrita livre. **Corolário duro: tratar caso a caso é *tampering* e piora o sistema.** Foi exatamente o que aconteceu hoje — o #112 foi corrigido no caso e a classe reapareceu duas vezes no mesmo dia (#121, #122), mais uma terceira dentro do próprio remédio.
- **Grupo B tem gatilho especial (uma fusão aconteceu) e exposição comum.** O contador não "zerou": ele está `{}` — nunca contou nada. A fusão só revelou que a régua de escalonamento (1ª/2ª/3ª vez) é memória de prosa, não estado.
- **Grupo C é causa comum de outro processo (alocação), com n=2.** Ocorrência medida ainda é baixa: Armadilha 22 proíbe instalar barreira cara antes de medir. Barreira barata, sim.

### 4.3 Cinco Porquês — grupo A

1. **Por que 8 itens fechados aparecem como vencidos?** Porque o fechamento foi gravado numa linha/célula que nenhum leitor consulta.
2. **Por que foi gravado ali?** Porque o fechamento foi escrito como narrativa do dia, e a linha viva do item ficou intocada.
3. **Por que isso é possível?** Porque escrever no quadro é editar markdown livre — nada distingue "linha de item" de "parágrafo sobre itens"; toda posição do arquivo é igualmente gravável.
4. **Por que é markdown livre?** Porque o quadro nasceu documento de reunião (para humano ler) e **depois** ganhou leitores de máquina — painel, Sentinela, alertas, GUT, Escritório Virtual. Os leitores ganharam schema; os escritores nunca ganharam.
5. **Por que os leitores têm schema e os escritores não?** **Porque não existe caminho de escrita.** Não há `abrir-item` / `fechar-item` que seja dono do formato. A única coisa que segura o formato é cada agente lembrar das 7 colunas na hora de digitar.

Paro aqui: a resposta é o sistema (ausência de caminho de escrita), não uma pessoa. Se a resposta fosse "fulano escreveu errado", eu teria parado no porquê 2.

### 4.4 Ishikawa com dado — cada espinha tem evidência, nenhuma é palpite

| Espinha | Evidência medida |
|---|---|
| **Método** | 10 item-fechamentos escritos fora da linha viva (L538-544, L768) |
| **Máquina** | leitores descartam em silêncio o que não casa: `>=7` células e "última ocorrência do # vence" — nenhum dos dois grita quando o dado não bate |
| **Medição** | `contagem-vencimentos.json` = `{}`; o #70 já registrava que o contador rastreava 3 de 10 vencidos |
| **Material** | `problemas.md` = **922 linhas**, arquivo único, misturando regra, ata, tabela e prosa no mesmo espaço de nomes |
| **Meio** | escritores concorrentes: #118/#120 entraram "enquanto eu trabalhava, em outra execução do mesmo dia" (nota crua do Sentinela) |

## 5. Contramedidas propostas

Critério da casa: paliativo depende de lembrar; definitivo torna o erro impossível ou faz o sistema parar sozinho. **"Escrever com mais cuidado" e "revisar antes de salvar" estão reprovados por definição** — e note que a regra proposta no #121 ("fechamento substitui a célula Status") é necessária mas **é paliativa sozinha**: sem barreira, ela é a 4ª regra escrita que depende de memória.

| # | Grupo | Contramedida | Tipo | Por que é definitiva |
|---|---|---|---|---|
| **CM-1** | A | **Estender `valida-quadro.js` de "conta células" para "reconcilia estado"**: para cada ID, achar a última linha numérica e sua célula Status; acusar todo ID que apareça como fechado/`DONE` em qualquer outro ponto do arquivo enquanto a linha viva não estiver fechada. Falha alto (exit 1), no estilo do `ranking-agentes.js` | **Jidoka** — o sistema para sozinho quando o defeito aparece | não impede escrever errado, mas torna **impossível o erro sobreviver ao dia**. É a barreira que faz a regra do #121 valer alguma coisa |
| **CM-2** | A | **Trocar as isenções por linha de `valida-quadro.js` por âncora de conteúdo** (o texto do cabeçalho da tabela, ou uma marca explícita na própria linha isenta) | **Poka-yoke** | mata a classe "controle preso a posição que se move" — a mesma que produziu os 13 falsos positivos de hoje e as âncoras podres do #121 |
| **CM-3** | A | **Mesmo validador varre `decisoes.md`**: qualquer data `AAAA-MM-DD` dentro da célula "resultado real" que seja **posterior** à data da coluna `revisar em` é defeito | **Poka-yoke** | uma regex sobre 190 linhas; fecha o #122 na classe, não no caso |
| **CM-4** | C | **O mesmo validador acusa ID duplicado** (já percorre todos os IDs — custo zero) | **Jidoka** | com n=2, detectar no mesmo dia basta; **não** proponho alocador agora (Armadilha 22). Se recorrer, o mecanismo já existe pronto: o lock exclusivo de `automacao-n8n/claude-p-lock.ps1`, provado com teste de concorrência real em 22/08 — reusar, nunca construir novo |
| **CM-5** | B | **Item absorvido não pode ser marcado `CANCELLED` sem nomear o sucessor**, e o validador exige que o sucessor exista. A contagem de vencimento passa a ser derivada por ID **seguindo a cadeia de absorção** | **Poka-yoke parcial — teto declarado** | resolve a perda de rastro na fusão. **Não** resolve o fundo: contagem derivada de prosa continua frágil. O conserto de fundo é a linha do item ganhar campo próprio de contagem — mudança de schema, **decisão do Diretor**, não minha |

**Onde CM-1 a CM-5 são ligadas ao motor — isto faz parte da contramedida, não é tarefa seguinte (Armadilha 25).** O validador precisa ser chamado no fim de uma rotina que comprovadamente roda hoje — candidata natural: `auditoria/quadro-diario.ps1` (rotina diária do Sérgio Secretário, que já é quem monta o quadro). Só se dá a contramedida por instalada depois de `grep` mostrar a chamada dentro do script **e** uma execução real acusando/limpando. Escolher o ponto de ligação é decisão do Diretor.

## 6. Verificação

1. **Auditar o instrumento antes de confiar nele (Armadilha 6 / MSA).** Teste de resposta conhecida: rodado contra o `problemas.md` de hoje, o validador tem de acusar **exatamente os 8 itens** que eu confirmei em linha crua (#18, #19, #24, #33, #52, #78, #107, #110) — nem mais, nem menos. Acusou 7 ou 9, o defeito é do medidor, não do quadro.
2. **Prova de CM-2:** rodar o validador antes e depois de inserir 30 linhas em qualquer ponto do arquivo. Os dois resultados têm de ser idênticos. Hoje não são.
3. **Prova de operação:** em **21/09**, reler a saída crua de uma execução real e a linha Status dos itens acusados. Meta: zero divergência acumulada em 30 dias.
4. Prova é sempre a **linha crua impressa**, nunca a contagem, nunca exit code 0.

## 7. O que eu NÃO cobri — limite declarado

- **Não construí nada.** Diagnóstico e proposta; a execução é do Diretor com o dono. Nenhum script foi criado ou alterado por mim.
- **Verifiquei 8 dos 116 itens** — os 8 apontados. Não sei quantos dos outros 108 estão com a linha viva divergente; **é exatamente isso que CM-1 mediria de uma vez**. Até lá, o número real de itens com rastro perdido é **desconhecido e provavelmente maior que 8**.
- Não li o código do painel VS Code nem do `escritorio-virtual.ps1`; usei o comportamento de parsing descrito no #111/#112 e o que o `valida-quadro.js` implementa.
- Não varri o histórico inteiro do arquivo atrás de outros fechamentos narrativos além dos dois blocos achados (L538-544, L768).
- Não avaliei a hipótese de fundo — **trocar o markdown por um formato com schema** (JSON/CSV gerando o markdown). É a única contramedida que mataria o grupo A pela raiz em vez de detectá-lo. Não a proponho porque é mudança estrutural com custo real e é decisão do Diretor e do dono, não minha. **Fica registrada como a alternativa não avaliada.**

## 8. Lacuna encontrada (FASE 5.1)

**Poka-yoke construído sem teste de resposta conhecida entra em operação produzindo sinal falso.** `valida-quadro.js` nasceu hoje já quebrado e ninguém notou até eu executá-lo. Não é falha de quem escreveu — é falha do processo: **não existe portão exigindo que todo medidor novo seja validado contra um caso de resposta conhecida antes de entrar em operação**, apesar de a Armadilha 6 dizer isso desde 03/08. Regra escrita, motor não ligado — o mesmo padrão da Armadilha 25, agora aplicado a instrumento de medição. Escalado ao Diretor.
