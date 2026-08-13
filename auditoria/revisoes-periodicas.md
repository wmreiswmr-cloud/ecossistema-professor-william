# Revisões Periódicas do Diretor

Criado em 2026-08-09 — item BL-018 do `evolution-backlog.md`. Só a revisão diária era real até hoje (rodou todo dia desde 03/08, ver `auditoria/*-reuniao.md`). As demais são novas — primeira execução real fica marcada abaixo, não fingida.

| Cadência | O que analisar | Fonte real | Primeira execução |
|---|---|---|---|
| **Diária** | Quadro de problemas, prazos vencidos, gargalo do sistema, 3 perguntas de fechamento | `problemas.md`, `alertas-automaticos.md` (novo, via n8n) | ✅ Já rotina desde 03/08 |
| **Semanal** | Idade média dos itens abertos, quantos agentes subiram de nível na semana, taxa de reversão de decisão dos últimos 7 dias | `problemas.md`, `skill-maturity-register.md`, `decisoes.md` | ⏳ Ainda não executada — próxima segunda-feira real |
| **Mensal** | Progresso vs. meta de R$10K/mês, CAC/LTV real (quando existir dado), revisão do `organograma.md` | `meta-10k-mensal.md`, dados reais do Supabase/Meta Ads | ⏳ Ainda não executada |
| **Trimestral** | Revisão da Constituição (`principios-decisao.md`), teto de escala de cada agente, aposentar skill sem uso real (ver BL-008) | `principios-decisao.md`, `skill-maturity-register.md` | ⏳ Ainda não executada |
| **Anual** | A meta de 5 anos do ProfGestor segue no caminho? O mercado mudou? O que funcionou/falhou? | `meta-5-anos-profgestor.md` | ⏳ Ainda não executada — ecossistema tem 6 dias de operação intensa, cedo demais pra ciclo anual real |

## Regra de agendamento

A revisão semanal é a próxima a virar real — candidata natural pra um 3º workflow n8n (Schedule Trigger semanal, mesma lógica dos dois já ativos), quando houver dado suficiente acumulado (pelo menos 2-3 semanas de `decisoes.md`/`problemas.md` reais) pra a comparação semana-a-semana fazer sentido, não só repetir o resumo diário com outro nome.

**Honestidade:** marcar como "ainda não executada" aqui, em vez de fingir uma revisão semanal que nunca aconteceu, é a mesma disciplina de evidência que rege todo o resto deste backlog.
