# Ciclo de Vida de Skills

Criado em 2026-08-09 — item BL-008 do `evolution-backlog.md`. Até hoje: skills nascem a pedido do dono, e **nenhuma jamais foi desativada** — processo de desativação nunca existiu, mesmo com agentes que ainda não provaram valor real (ex: `cerebro-automacao`, nível 1 desde 04/08, zero workflow até 09/08).

## Estados

`PROPOSED` → `DESIGN` → `TEST` → `ACTIVE` → `MATURE` → `DEPRECATED` → `ARCHIVED`

| Estado | O que significa | Quem move pro próximo |
|---|---|---|
| `PROPOSED` | Pedido real do dono ou lacuna comprovada (não achismo) | Diretor confirma que não existe skill parecida já (regra: "primeiro pergunte se resolve com o que já existe") |
| `DESIGN` | Identidade, escopo e fronteira escritos | Diretor revisa contra `principios-decisao.md` |
| `TEST` | Primeira execução real, currículo inicial se aplicável | Reitor valida com evidência, nunca autodeclaração |
| `ACTIVE` | Em uso real, nível evoluindo com prova | — |
| `MATURE` | Nível 3+ (exige resultado real observável, não só framework) | Reitor |
| `DEPRECATED` | Sem uso real por período longo, ou substituída por outra skill | Diretor propõe, dono aprova (mesma régua de criar) |
| `ARCHIVED` | Removida do organograma ativo, arquivo mantido como histórico | Diretor executa após aprovação |

## Antes de criar uma skill nova — checklist obrigatório

1. Existe skill com responsabilidade parecida? (busca real em `~/.claude/commands/`/`~/.claude/agents/`, não achismo)
2. O problema se resolve com **processo, memória, automação, governança ou documentação** em vez de um agente novo? (regra direta do feedback executivo, 09/08)
3. Só se as duas perguntas acima derem "não" — propor skill nova.

## Quem pode criar / desativar

**Diretor propõe, dono aprova**, sempre, para criar ou desativar — nenhuma exceção registrada até hoje. Mesma regra da categoria "Estrutura do time, processo, organograma" na Escada de Autonomia (`decisoes.md`).

## Estado real hoje — nenhum agente formalmente classificado ainda

Este é o primeiro dia deste ciclo de vida existir. Próximo passo real (não feito agora, fica pro Reitor): passar os ~41 agentes reais pelos estados acima, começando pelos criados há mais tempo sem revisão (`cerebro-automacao`, `cerebro-integrador`, ambos 04/08, nível 1).
