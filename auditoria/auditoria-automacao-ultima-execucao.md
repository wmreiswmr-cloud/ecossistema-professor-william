# Auditoria de Automação do Ecossistema — última execução

**Quando:** 2026-08-15, ~20:05 `America/Sao_Paulo` (23:05 UTC). Execução manual desta sessão (`cerebro-automacao`, chamado direto pelo dono via skill), não supervisionada, seguindo `processo-empresa.md` FASE 3.1 / regra de 15/08 de auditoria 2x/semana.

**Nota de contexto, não achado:** enquanto esta auditoria rodava, o workflow n8n dedicado a esta mesma cadência (`3WMLT1x0T8C35DW9`, "Auditoria de Automação — Correção e Oportunidade") também estava com sua **primeira execução real disparada em paralelo** (execução `77`, `manual`, iniciada 23:01:57 UTC, ainda `running` no momento em que esta auditoria começou). As duas rodam o mesmo tipo de checagem porque o dono pediu esta manualmente na mesma janela em que o workflow novo teve seu primeiro teste real. Confirmar depois, separadamente, se a execução 77 do workflow terminou com `status:success` e se o conteúdo bate com este arquivo — se convergirem, não é problema; se divergirem, é achado novo para a próxima rodada.

---

## O que foi checado

- **17 workflows** listados via `search_workflows` (16 ativos + 1 marcado `isArchived:false`/`active:false` já conhecido — `iaSobDemanda00001`, inativo por decisão consciente de 09/08; e `diagnosticoYoutube01`, inativo, lixo de debug já proposto para arquivar em #82).
- Para cada um dos **16 workflows ativos**, `search_executions` com `startedAfter` = últimos 7 dias (desde 2026-08-08) — nunca só a flag `active:true`.
- Para as execuções suspeitas (erro, crashed, ou ausência total de execução em modo `trigger` num workflow com gatilho de horário fixo), `get_execution` com `includeData:true` para ler o erro real, não só o status.
- Releitura de `auditoria/problemas.md` (integral, 522 linhas), `auditoria/decisoes.md` (57 de 100 linhas, a metade mais recente) e tentativa de leitura de `auditoria/rotinas-operacionais.md` — **este arquivo não existe** no projeto (`Glob` sem resultado); a Parte (b) desta rodada se apoiou em `problemas.md` + `decisoes.md`, que são as fontes reais existentes.

## Parte (a) — Correção: 0 achados NOVOS

Todo padrão que esta auditoria encontrou de forma independente — reconferido execução por execução, nunca por suposição — já tinha sido encontrado, investigado e (na maior parte) corrigido por uma passada anterior do próprio `cerebro-automacao`, ainda hoje (2026-08-15, noite), registrada em `problemas.md` como itens **#75, #76, #77, #78, #79, #80, #81, #82**:

| O que esta auditoria viu de novo | Já registrado como |
|---|---|
| `youtubeTrendScout01` — gatilho de horário fixo (12:45), zero execuções modo `trigger` nos 7 dias, só `cli`/`manual` | #75 (achado geral) + #80 (este workflow nomeado) — causa: timezone da instância (`America/New_York`) sem override, corrigido, publicado; falta só confirmar o próximo disparo real |
| `trilhasDiariasN8n01` — execução `crashed` (`trigger`, 15/08 17:20 UTC) com `NodeCrashedError`/possível OOM | #75 — causa dupla (timezone + falta de headroom de memória), ambas corrigidas; teste real pós-fix (execução 72) confirmado `success` |
| `auditoriaN8n000001` — 3 execuções `error` seguidas (ids 40/41/42, madrugada de 15/08) por erro de sintaxe PowerShell em `auditoria-diaria.ps1` linha 230 | Já corrigido no mesmo dia (execuções seguintes, 43 em diante, todas `success`) — mesmo problema de timezone/gatilho `trigger` nunca confirmado ainda catalogado em #80 |
| `decisaoRevisaoVencida1` — falso positivo (decisão já resolvida aparecendo como vencida) | #76 — causa raiz (substring `pendente` sem âncora batendo em "inde-**pendente**"), corrigida e verificada com execução real antes/depois |
| `missionControl00001` (errorWorkflow) capturando e registrando a falha real do crash acima | Confirma que o Mission Control funciona de verdade (não é config morta) — não é achado, é verificação positiva |

**Verificação adicional feita agora, sem achado novo:** `quadroGutN8n0001` (erros `cli` em 14/08, ids 34/35) e `integradorN8n00001` (erro `cli` em 14/08, id 38) — ambos com execução `error` isolada seguida de sucesso no mesmo dia ou no dia seguinte, sem repetição desde então. Não abrem item novo: não há padrão de recorrência nem evidência de que o defeito segue vivo hoje.

**Dois itens da rodada anterior seguem em aberto, sem dono definido — reforçados aqui, não duplicados:**
- **#81** — mesmo bug de timestamp (`getUTCHours()` sem timezone) provavelmente copiado em 6 outros workflows de alerta (`alertaPrazoVencido01`, `riscoParado0001`, `trilhasIncompletas001`, `encodingQuebrado001`, `guardiaoDecisao0001`, `handoffSessao000001`) — proposto, não varrido ainda, `FALTA: sem responsável`.
- **#82** — `diagnosticoYoutube01` é lixo de debug inativo, candidato a `archive_workflow` — proposto, não executado, `FALTA: sem responsável`.

Nenhum dos dois é achado novo desta rodada — só confirmando que continuam reais e ainda sem decisão do Diretor.

## Parte (b) — Oportunidade: 0 achados NOVOS

Reli `problemas.md` e `decisoes.md` (não existe `rotinas-operacionais.md` neste projeto) procurando trabalho manual repetido, de qualquer célula, com caminho de automação de custo zero ainda não construído.

**Resultado honesto: nenhuma oportunidade nova e específica encontrada nesta rodada.** O ecossistema já tem **17 workflows n8n ativos** cobrindo a quase totalidade do trabalho de governança que antes era manual: auditoria diária, trilhas de pesquisa diárias, quadro GUT, health check do Integrador, handoff de sessão, economia de token, alerta de prazo vencido, alerta de decisão vencida, alerta de encoding quebrado, alerta de risco parado, alerta de trilhas incompletas, guardião de decisão nova, heartbeat de dead-man's-switch, Mission Control (captura de erro central), pesquisa de tendências do YouTube, e esta própria auditoria de automação. Os itens manuais que restam em `problemas.md` (ex.: #14 popular FAQ, #20 migrar WhatsApp Business para API) são tarefas de **conteúdo/decisão humana** (exigem revisão ou verificação OTP do próprio dono), não trabalho mecânico repetido que caiba em automação — não viram proposta por não se qualificarem como "automatizável de custo zero", e sim como "decisão/execução do dono".

## Resumo numérico

- Workflows ativos auditados: **16**
- Execuções reais inspecionadas (`search_executions`, 7 dias): **~70**
- Execuções com `get_execution`/dado completo lido: **5**
- Achados de correção **novos**: **0** (todos os padrões achados já estavam registrados e majoritariamente corrigidos por #75–#80; #81/#82 seguem como proposta pendente, não nova)
- Oportunidades de automação **novas**: **0**
- Itens de `problemas.md` **adicionados** nesta rodada: **0** (nada novo a registrar sem duplicar #75–#82)
