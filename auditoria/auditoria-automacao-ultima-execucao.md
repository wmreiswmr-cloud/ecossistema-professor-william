# Auditoria de Automação do Ecossistema — última execução

**Quando:** 2026-08-20, ~17:12-17:20 `America/Sao_Paulo` (20:12-20:20 UTC). Execução chamada direto pelo dono via skill (`cerebro-automacao`), não supervisionada, seguindo `processo-empresa.md` FASE 3.1 / regra de 15/08 de auditoria 2x/semana.

**Nota de contexto, não achado:** enquanto esta auditoria rodava, o workflow n8n dedicado a esta mesma cadência (`3WMLT1x0T8C35DW9`) também tinha uma execução real em andamento (`129`, `mode:trigger`, iniciada 20:12:22 UTC — minutos depois de o próprio workflow ter sido republicado às 20:06:19 UTC pelo fix do item #95). Mesmo padrão já registrado na rodada de 15/08 (as duas rodando em paralelo). Ver item #100 (novo, nesta rodada) sobre o padrão de disparo fora de hora logo após republish.

## O que foi checado

- **20 workflows** no total via `search_workflows` (16 ativos, 4 inativos — 2 já conhecidos de rodadas anteriores + **2 novos desde 15/08**: `jUyF9rEyg9tBgITL`/`MIJwgq6GsCGhHyb8`, templates padrão do n8n, nunca ativados, registrados como item #101).
- Para cada um dos **16 workflows ativos**, `search_executions` com `startedAfter=2026-08-13T00:00:00Z` (7 dias) — nunca só `active:true`.
- `get_workflow_details` (código real do trigger e do node de execução) para os workflows com padrão suspeito de disparo, para separar "gatilho nunca configurado certo" de "gatilho configurado certo mas servidor fora do ar".
- `get_execution` com `includeData:true` para a execução real de `economiaToken000001` de hoje — achado central desta rodada.
- Releitura de `auditoria/problemas.md` (seções 15-20/08) e `auditoria/decisoes.md` para a Parte (b).

## Parte (a) — Correção: 3 achados NOVOS reais (itens #97, #98, #99 de `problemas.md`)

| Achado | Severidade | Resumo |
|---|---|---|
| **#97** | 🔵 Médio (GUT 27) | `economiaToken000001` roda com `status:success` todo dia, mas a medição real de token falha 100% das vezes desde a reescrita do #85 (19/08) — o node do n8n ainda passa o arquivo `.jsonl` mais pesado como argumento, e o script foi reescrito para exigir um diretório. Confirmado com `get_execution(includeData:true)` da execução real de hoje: erro `ENOTDIR` capturado e mascarado (por design, jidoka) como sucesso do workflow. `higiene-sessao-status.json` confirma `ultimaMedicaoOk:false` há dias. |
| **#98** | 🟠 Muito alto (GUT 64) | **6 dos 16 workflows ativos** (`trilhasIncompletas001`, `riscoParado0001`, `encodingQuebrado001`, `alertaPrazoVencido01`, `handoffSessao000001`, `decisaoRevisaoVencida1`) ainda usam o gatilho relativo frágil `hoursInterval:24`, mesma classe de defeito já corrigida nos 5 workflows-irmãos. Consequência real confirmada: 5 desses 6 dispararam **exatamente 1 vez em 7 dias** (15/08) e ficaram **5 dias inteiros mudos** (16-20/08) — nenhum alerta de prazo vencido, risco parado, encoding quebrado, trilha incompleta ou handoff rodou de verdade nesse período, mesmo com `active:true`. |
| **#99** | 🟢 Baixo (GUT 12) | Varredura real do item #81 (proposto 15/08, nunca varrido) finalmente feita, lendo o código ao vivo dos 6 workflows suspeitos. Resultado: **3 confirmados com o bug** (`alertaPrazoVencido01`, `riscoParado0001`, `guardiaoDecisao0001` — timestamp `getUTCHours()` sem fuso), **2 sem o bug** (`trilhasIncompletas001`, `encodingQuebrado001` — usam hora local, não UTC), **1 não checado** (`handoffSessao000001`, delega a um script externo). |

**Achados secundários, registrados com honestidade sobre o nível de certeza:**
- **#100** (🟢 Baixo, hipótese não confirmada): dois workflows republicados hoje minutos um do outro (`3WMLT1x0T8C35DW9`, `economiaToken000001`) e os dois dispararam uma execução `trigger` minutos depois, fora do horário configurado — padrão observado 2x no mesmo dia, precisa de teste controlado antes de virar diagnóstico definitivo.
- **#101** (🟢 Baixo, housekeeping): 2 workflows-template inativos do próprio n8n apareceram desde 15/08, mesma classe de lixo do #82.

## Parte (b) — Oportunidade: 0 achados novos

Reli `problemas.md`/`decisoes.md` procurando trabalho manual repetido com caminho de automação de custo zero ainda não construído. A frota de 16 workflows ativos já cobre a quase totalidade do trabalho de governança que era manual. O que resta manual (#14 popular FAQ, #20 migrar WhatsApp Business) depende de decisão/OTP do próprio dono — não é trabalho mecânico automatizável. **Honesto: nenhuma oportunidade nova e específica esta rodada** — todos os achados reais foram de correção.

## #81 / #82 — situação ao final desta rodada

- **#81**: deixou de ser proposta nunca varrida — agora tem varredura real (item #99): 3/6 workflows confirmados com o bug, 2/6 confirmados sem o bug, 1/6 não checado (script externo, fora do escopo desta rodada).
- **#82** (`diagnosticoYoutube01`, lixo de debug inativo): sem mudança — ainda existe, ainda inativo, ainda `FALTA: sem responsável`. Arquivar está fora do mandato desta auditoria (só audita/recomenda, regra explícita da tarefa desta rodada).

## Resumo numérico

- Workflows ativos auditados: **16**
- Execuções reais inspecionadas (`search_executions`, 7 dias): **~110** (soma de todas as consultas por workflow)
- Execuções com `get_execution`/dado completo lido: **1** (a que expôs o #97)
- Workflows com `get_workflow_details` (código real do trigger) lido: **11**
- Achados de correção **novos**: **5** (#97, #98, #99, #100, #101 — #98 é o mais grave, GUT 64)
- Oportunidades de automação **novas**: **0**
- Itens de `problemas.md` **adicionados** nesta rodada: **5** (#97-#101)
