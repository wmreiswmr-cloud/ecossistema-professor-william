# Horários das rotinas automáticas — registro único

**Decisão do dono, 2026-08-21:** *"mantenha os horários das rotinas de automação rodando de 13:30 até 20:00 horas"*.

Este arquivo é a **fonte da verdade**. Antes de 21/08 os horários existiam só dentro do n8n — não havia como conferir, comparar ou perceber colisão sem abrir workflow por workflow. Quem mudar horário no n8n muda aqui na mesma tarefa.

## A janela

Todas as rotinas headless rodam entre **13:30 e 20:00** (America/Sao_Paulo). Nada fora disso.

## A grade

| Hora | Rotina | Workflow n8n | Retentativa | Script |
|---|---|---|---|---|
| 13:35 | Pesquisa diária (10 trilhas) | `trilhasDiariasN8n01` | **18:10** | `pesquisa-diaria/run-daily.ps1` |
| 14:30 | Quadro de Ações (GUT) | `quadroGutN8n0001` | **18:50** | `auditoria/quadro-diario.ps1` |
| 15:30 | Integrador — Health Check | `integradorN8n00001` | **19:30** | `auditoria/integrador-diario.ps1` |
| 16:30 | Varredura — Correção Automática | `n4LCdeH8Usn1ZS6v` | — | `auditoria/varredura-diaria.ps1` |
| — | Auditoria do ecossistema | encadeada, sem gatilho próprio | — | `auditoria/auditoria-diaria.ps1` |
| 13:40 seg/qui | Auditoria de Automação (2x/semana) | `3WMLT1x0T8C35DW9` | — | `auditoria/auditoria-automacao-2x-semana.ps1` |

## As três regras que sustentam a grade

1. **Espaçamento mínimo de 40 min.** Nenhuma rotina passa de ~20 min medidos (pior caso real: 18,3 min da pesquisa, `duracoes.csv`). Duas rotinas ao mesmo tempo disputam a **mesma cota de assinatura** — foi exatamente o que derrubou a tarde de 21/08.
2. **A retentativa fica depois do reset de cota das 18:00**, e só dispara se a primeira não entregou. Quem decide isso é o guard, não o horário.
3. **Rotina crítica tem retentativa; rotina secundária não.** Cada retentativa custa cota do mesmo pool — a varredura fica sem, de propósito.

## Por que estes horários, e não os antigos

Em 21/08 as três rotinas caíram em sequência com a **mesma** mensagem: `You've hit your session limit - resets 6pm`. Pesquisa 13:35, quadro 16:21, integrador 16:45 — todas empilhadas dentro do horário de trabalho do dono, disputando a cota com as sessões interativas dele. Não eram três problemas; era um.

E ninguém tinha percebido antes porque o padrão `$null | claude -p ... | Out-File` faz o PowerShell sair com **código 0 mesmo quando o claude morre dentro do pipe** — o n8n marcou `success` em dias sem entrega (execuções 104 de 18/08 e 123 de 20/08, lidas no histórico). Três semanas de luz verde sobre trabalho não feito.

## Os guards

Toda rotina passa por um wrapper que faz três coisas que os scripts não faziam:

| Guard | Cobre | Onde |
|---|---|---|
| `pesquisa-diaria/run-daily-guard.ps1` | pesquisa | motivo em `pesquisa-diaria/motivos.csv` |
| `auditoria/rotina-guard.ps1` | quadro, integrador, varredura | motivo em `auditoria/motivos-rotinas.csv` |

1. **Instância única** — duas execuções não brigam pelo mesmo log (a perdedora morria em segundos e gravava `False`, indistinguível de falta de cota)
2. **Pula se já entregou hoje** — a retentativa não repete trabalho nem queima cota
3. **Exit code real** — acabou o verde falso

## Conflito aberto, não resolvido

O item **#90** mediu a janela real de uptime do notebook como **13:00–16:00**, e a nota do workflow da varredura ainda diz isso. A janela nova (13:30–20:00) veio do dono em 21/08 e prevalece — mas **se a máquina desligar antes das 18h, as três retentativas nunca disparam** e a cobertura existe só no papel. Conferir na primeira semana: se as linhas de 18:10/18:50/19:30 não aparecerem em `motivos.csv`/`motivos-rotinas.csv`, puxar as retentativas para dentro de 13:30–16:00 e abrir mão do reset de cota.

## Mudança pendente, ainda NÃO aplicada (22/08)

As retentativas de **18:10/18:50/19:30 são cedo demais**. Medido em 21/08: 18:17 (pesquisa) e 18:30 (quadro) foram recusadas por cota mesmo depois do `resets 6pm`; o único sucesso da noite foi **21:09**. Proposta em aberto (`problemas.md` #113, Work Order para `cerebro-automacao`): mover para **19:30/19:45/19:55** — continua dentro da janela 13:30-20:00, com ~1h45 depois do reset. **Enquanto o workflow não for alterado, a grade acima continua sendo o que roda de verdade** — os horários novos não valem por estarem escritos aqui.

## Pendência de documentação

`~/.claude/commands/cerebro-sentinela.md`, item 1 do checklist, ainda manda conferir as tarefas do Windows `CerebroAnalistaMercado` e `CerebroAuditoriaDiaria` — **migradas para n8n em 14/08**. O Sentinela está checando um motor que não roda mais. Corrigir para apontar a este arquivo e ao histórico de execuções do n8n.
