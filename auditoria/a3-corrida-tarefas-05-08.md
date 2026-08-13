## A3 — Corrida entre CerebroAnalistaMercado e CerebroAuditoriaDiaria (2026-08-05)

**Contexto**
Terceira vez que a coordenação entre a tarefa de trilhas e a de auditoria falha (origem: Armadilha 27, 03/08; recorreu hoje). O Diretor já tinha declarado isso "corrigido" — voltou, então a correção anterior não atacou a causa raiz, só o sintoma mais comum dela.

**Condição atual — medida, não estimada**
`Get-ScheduledTaskInfo` de hoje: `CerebroAnalistaMercado.LastRunTime = 05/08/2026 13:33:33` e `CerebroAuditoriaDiaria.LastRunTime = 05/08/2026 13:33:33` — **os dois disparos no mesmo segundo**, não em horários próximos. `auditoria/2026-08-05.md` confirma o efeito: *"Pesquisa passou de 60 min sem terminar"* — a auditoria esperou o máximo permitido (`$esperou -ge 60` em `auditoria-diaria.ps1`, linha 66) e mesmo assim não alcançou o fim real da trilha.

**Classificação — causa comum ou especial (Shewhart/Deming), antes de qualquer outra análise**
**Causa comum.** Não foi um evento raro: é consequência estrutural e repetível de como o sistema está desenhado, dado o padrão real de uso (a máquina fica desligada com frequência nas janelas de 08:15 e 09:30). Tratar cada ocorrência como eventual e reiniciar manualmente — o que fiz hoje — é *tampering*: resolve o dia, não resolve o sistema. Já aconteceu 2x com o mesmo padrão exato.

**Meta**
Zero corrida entre os dois processos, mesmo quando a máquina fica desligada durante as duas janelas — sem depender de ninguém reiniciar nada manualmente.

**Análise de causa — 5 Porquês**
1. Por que os dois dispararam no mesmo segundo hoje? → `StartWhenAvailable` do Windows recuperou os dois gatilhos perdidos assim que a máquina ligou.
2. Por que os dois foram recuperados juntos? → A máquina esteve desligada durante as duas janelas (08:15 e 09:30) — os dois gatilhos "perderam o horário" ao mesmo tempo.
3. Por que isso causa corrida se a auditoria já espera a trilha terminar? → Porque existem **dois caminhos de execução para a auditoria**: (a) encadeada dentro de `run-daily.ps1`, que depende da trilha realmente terminar antes de chamar `auditoria-diaria.ps1`; e (b) um **gatilho independente às 09:30**, criado como rede de segurança — esse caminho (b) não sabe se a trilha *sequer começou de verdade* quando ele mesmo dispara via catch-up simultâneo.
4. Por que a rede de segurança não detecta isso com segurança? → O `while` que espera (linha 65) só checa `State -eq 'Running'` — se os dois processos nascem no mesmo instante, existe uma janela de corrida real entre "a trilha ainda não marcou Running" e "a auditoria já checou o estado".
5. Por que a rede de segurança continua sendo um segundo gatilho de horário fixo, em vez de puramente reativa? → Foi desenhada em 03/08 pra cobrir "a trilha nunca rodou" — mas o desenho não cobriu o caso "os dois gatilhos perdem o horário **juntos**", que é exatamente o padrão real deste ecossistema (máquina desligada de manhã é a norma, não exceção).

**Causa raiz**: o sistema tem **dois relógios independentes** controlando uma dependência sequencial (trilha → auditoria). `StartWhenAvailable` garante que cada gatilho perdido roda assim que possível — mas não garante ordem entre dois gatilhos perdidos ao mesmo tempo. Quando os dois perdem o horário juntos (padrão comum aqui), os dois "assim que possível" colidem.

**Contramedidas — com poka-yoke, não "ter mais cuidado"**
1. **Eliminar o segundo relógio.** Desativar o gatilho fixo das 09:30 da `CerebroAuditoriaDiaria`. A rede de segurança deixa de ser "outro horário fixo" e vira uma tarefa nova, única, agendada bem mais tarde (proposta: 22:00) — cuja única lógica é: *"o arquivo `auditoria/<hoje>.md` existe? Se não, roda `auditoria-diaria.ps1` agora."* Isso é poka-yoke real: torna a colisão **estruturalmente impossível**, não só menos provável — não sobra um segundo gatilho pra colidir com o primeiro.
2. Manter a corrente dentro de `run-daily.ps1` exatamente como está — ela já funciona no caso normal (não desligado).

**Verificação**
Amanhã (06/08) e nos dias seguintes: se a máquina ficar desligada de novo nas janelas da manhã, confirmar via `Get-ScheduledTaskInfo` que `CerebroAuditoriaDiaria` **não** tem mais gatilho fixo às 09:30 — só dispara via corrente do `run-daily.ps1` ou via a nova tarefa das 22:00, nunca os dois no mesmo segundo. Reavaliar em **2026-08-19** (15 dias) se o padrão de corrida realmente parou de aparecer no `problemas.md`.

**O que eu NÃO cobri**
Não analisei o erro de conexão de API em si (`Connection closed mid-response`) — isso é falha externa da rede/API, fora do meu escopo de causa raiz interna. Também não decidi o horário exato da nova tarefa de rede de segurança (22:00 é proposta, não decisão) — isso e a autorização pra mexer na Tarefa Agendada do Windows ficam para o Diretor e o dono decidirem juntos.
