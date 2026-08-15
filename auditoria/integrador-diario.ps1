# Disparado diariamente pela Tarefa Agendada do Windows "CerebroIntegradorDiario".
# Roda o Claude Code headless com escopo restrito ao cerebro-integrador, pra
# fazer o Health Check operacional diario e propor Work Orders -- SEM executar
# delegacao/fechamento/escalonamento sozinho. Pedido do dono, 2026-08-14, com
# escopo reduzido por decisao consciente dele mesmo (ver problemas.md #63 e
# auditoria/decisoes.md, 13/08 -- CEO-Integrador como COO pleno foi rejeitado
# por zero pratica real; esta e a versao "Mes 1" do curriculo de recuperacao
# que o Reitor escreveu no mesmo dia: 1 atrito real resolvido do inicio ao
# fim, antes de qualquer autoridade nova).
Set-Location "c:\Users\usuario\Desktop\Projeto-professor-William"

$prompt = @'
Use a skill cerebro-integrador pra fazer o Health Check operacional diario do ecossistema. Isto e uma execucao automatica, nao supervisionada -- decida e execute o QUE ESTA DENTRO DO SEU MANDATO (analisar, classificar, recomendar), nunca pare pra perguntar "como quer seguir".

LIMITE DURO, NAO NEGOCIAVEL NESTA EXECUCAO: voce SO recomenda. Nunca delega de verdade, nunca fecha item, nunca muda Dono/Prazo/Status de ninguem, nunca escala pro dono (so o Diretor fala com o dono), nunca cria Work Order que se autoexecuta. Motivo: sua autonomia real hoje e nivel 1/5 na Matriz de Autonomia (`auditoria/matriz-autonomia.md`) -- 11 frameworks registrados, zero pratica real ainda (achado do Reitor, `problemas.md` #63). Esta execucao diaria E o "Mes 1" do seu proprio curriculo de recuperacao: escolher 1 atrito real e acompanha-lo ate resolver, sem pedir framework novo. Tratar isto como autoridade plena de COO seria repetir o erro ja identificado e corrigido em 13/08 (`decisoes.md`) -- CEO-Integrador como COO pleno foi avaliado e REJEITADO por falta de prova de capacidade.

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

7. NUNCA toque em `problemas.md` nem em `decisoes.md` -- so leia. Sua saida e so o brief novo.

Se nao achar nenhum problema real relevante hoje, escreva isso mesmo -- silencio nao e opcao, mas inventar problema pra preencher o brief tambem nao.
'@

$env:CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS = "0"
claude -p $prompt --dangerously-skip-permissions --output-format text 2>&1 | Out-File -FilePath "c:\Users\usuario\Desktop\Projeto-professor-William\auditoria\integrador-diario-ultima-execucao.log" -Encoding utf8
