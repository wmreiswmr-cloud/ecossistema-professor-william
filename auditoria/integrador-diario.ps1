# Disparado diariamente pelo workflow n8n "integradorN8n00001".
# Corrigido 20/08 (item #93 de problemas.md) -- a Tarefa Agendada do Windows
# "CerebroIntegradorDiario" nao existe mais, confirmado com Get-ScheduledTask.
# Roda o Claude Code headless com escopo restrito ao cerebro-integrador, pra
# fazer o Health Check operacional diario e RESOLVER de fato os itens sob seu
# mandato (nao mais so recomendar). Mandato elevado em 2026-08-20 (ordem
# direta do dono, `decisoes.md` 20/08: "deixe o ceo-integrador resolver as
# acoes e voce vai validando" -- substitui a restricao de 14/08 que so
# permitia recomendacao). Fronteira que NAO mudou: sem categoria N0/N1, sem
# editar workflow n8n direto (mandato exclusivo do cerebro-automacao, regra
# de 15/08), sem falar com o dono (isso e do Diretor). O Diretor valida o
# que for resolvido em vez de exigir execucao propria; cerebro-reitor
# confirma com evidencia real quando o nivel de gestao subir (problemas.md
# #63) -- ate la, toda resolucao real fica registrada com prova, marcada
# como feita por cerebro-integrador, nao so recomendada.
Set-Location "c:\Users\usuario\Desktop\Projeto-professor-William"

$prompt = @'
Use a skill cerebro-integrador pra fazer o Health Check operacional diario do ecossistema. Isto e uma execucao automatica, nao supervisionada -- decida e execute o QUE ESTA DENTRO DO SEU MANDATO, nunca pare pra perguntar "como quer seguir".

MANDATO DESTA EXECUCAO (elevado 2026-08-20, `decisoes.md`): voce RESOLVE de fato os itens do quadro sob seu mandato -- muda Status, fecha item com prova real, atribui dono quando um item estiver `FALTA: sem responsavel` e a escolha for obvia/sem conflito (mesmo criterio do precedente 15/08 para #61/#64/#65/#67: quem executa, nao quem so supervisiona). Fronteira dura, continua nao-negociavel: NUNCA decide categoria N0/N1 (dinheiro, producao, marca, dado de usuario) sozinho -- so recomenda essas; NUNCA edita workflow n8n direto (mandato exclusivo do `cerebro-automacao`, regra de 15/08); NUNCA fala com o dono (so o Diretor fala com ele); NUNCA reduz/aumenta o prazo de SLA de um item sozinho (isso e do Diretor/`ceo-orquestrador`, com justificativa em `decisoes.md`). Toda vez que resolver um item de verdade, deixe explicito no campo Prova que foi voce quem resolveu, nao so recomendou -- e o dado que o Reitor usa pra avaliar se seu nivel de gestao subiu (`problemas.md` #63).

O que fazer, na ordem:

1. Ler `auditoria/problemas.md` inteiro (ja vem com GUT/SLA calculado pelo cerebro-secretario, que roda antes de voce). Ler tambem `auditoria/decisoes.md` (decisoes pendentes) e checar `auditoria/alertas-automaticos.md` (ultimas entradas, pra saber se algum workflow de n8n falhou).

2. Fazer o Health Check: quantos itens abertos, quantos com prazo de SLA vencido, quantos marcados "FALTA" (sem dono/prazo real), quantos 🔴/🟠, se algum workflow do n8n aparece com erro no Mission Control, se alguma decisao em `decisoes.md` tem "revisar em" vencido sem resultado preenchido.

3. Calcular uma "Saude Operacional" REAL, nunca ilustrativa (regra do proprio ecossistema: numero sem medicao nao se publica) -- formula simples e reproduzivel: media entre (a) % de itens abertos SEM prazo de SLA vencido, (b) % de itens abertos SEM "FALTA" (dono/prazo completos), (c) % de workflows n8n ativos sem erro recente no Mission Control. Mostre o calculo, nao so o numero final.

4. Para os 2-3 problemas de maior GUT que ainda nao tem plano de acao claro, montar um WORK ORDER completo (ID, Problema, Objetivo, Prioridade, GUT, Responsavel sugerido, Revisor sugerido, Prazo, SLA, Dependencias, Ferramentas, Criterios de aceite, Resultado esperado) -- como RECOMENDACAO, deixando claro no proprio texto que precisa de aprovacao do Diretor antes de qualquer agente ser acionado.

5. Identificar se algo hoje se qualifica como "atrito real" pra voce mesmo praticar (Mes 1 do seu curriculo) -- ex: um bloqueio real entre 2 celulas, uma tarefa travada esperando 2 pessoas. Se achar um candidato real, registre-o explicitamente como candidato a virar seu 1o caso pratico -- mas NAO o resolva sozinho ainda, so aponte.

6. Escrever um "Daily Executive Brief" no formato abaixo, em `auditoria/brief-integrador-diario.md` (SOBRESCREVA o brief do dia anterior -- e resumo vivo, nao historico; o historico completo continua em problemas.md/decisoes.md, que voce nao sobrescreve):

```
# Brief Executivo do CEO-Integrador -- [DATA]

Saude operacional: [X/100] -- calculo: [mostrar as 3 partes]
Itens abertos: [N] | Vencidos: [N] | FALTA dono/prazo: [N]
GUT: 🔴 [N] · 🟠 [N] · 🟡 [N] · 🔵 [N] · 🟢 [N]
Workflows n8n: [N/N ativos, erro recente: sim/nao]
Escalonamento necessario ao Diretor: [sim/nao -- se sim, por que]

## Work Orders propostos (aguardando aprovacao do Diretor)
[lista, formato completo do item 4]

## Candidato a 1o atrito real (curriculo Mes 1)
[se achou, descreva; se nao achou hoje, diga isso explicitamente]

## Situacao
[1 frase: operacao sob controle / atencao necessaria em X]
```

7. Itens dentro do mandato (bug/config/doc local, `FALTA: sem responsavel` sem conflito, status obsoleto por fato ja consumado) voce EDITA de verdade em `problemas.md` -- Status/Dono, com Prova real e a marca de que foi voce quem resolveu. Itens fora do mandato (N0/N1, editar workflow n8n, redesignar SLA) continuam so como recomendacao no brief, sem tocar no arquivo. NUNCA edite `decisoes.md` -- registrar decisao continua sendo o Diretor.

Se nao achar nenhum problema real relevante hoje, escreva isso mesmo -- silencio nao e opcao, mas inventar problema pra preencher o brief tambem nao.
'@

$env:CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS = "0"
# ponytail: $null | evita o wait/warning "no stdin data received in 3s" (Task
# Scheduler nao anexa stdin nenhum) -- achado real em #71, 19/08.
# Lock global (#116, A3 22/08): impede que este "claude -p" rode ao mesmo tempo
# que qualquer outro do ecossistema e estoure a RAM da maquina.
. "c:\Users\usuario\Desktop\Projeto-professor-William\automacao-n8n\claude-p-lock.ps1"
Lock-ClaudeP
try {
  $null | claude -p $prompt --dangerously-skip-permissions --output-format text 2>&1 | Out-File -FilePath "c:\Users\usuario\Desktop\Projeto-professor-William\auditoria\integrador-diario-ultima-execucao.log" -Encoding utf8
} finally {
  Unlock-ClaudeP
}
