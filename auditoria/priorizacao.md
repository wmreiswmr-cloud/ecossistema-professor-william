# Sistema Formal de Priorização (RICE)

Criado em 2026-08-09 — item BL-006 do `evolution-backlog.md`. Fecha a pergunta do feedback executivo: *"o Diretor deverá conseguir explicar por que esta tarefa vem antes daquela, com base em critérios objetivos."*

## A fórmula

**RICE = (Reach × Impact × Confidence) / Effort**

| Fator | Escala usada | O que mede |
|---|---|---|
| Reach | 1-10 | Quantas partes do ecossistema/com que frequência isto é usado |
| Impact | 0.25 mínimo · 0.5 baixo · 1 médio · 2 alto · 3 maciço | Tamanho do efeito quando usado |
| Confidence | 0-100% | Quão seguro estou da estimativa (achismo puro nunca passa de 50%) |
| Effort | 1 (poucas horas) a 5+ (vários dias) | Custo real de fazer, não custo desejado |

**P0-P3 continua existindo** — mede criticidade/urgência (isto bloqueia algo? é risco real?). **RICE mede throughput** — dado tempo limitado, o que rende mais por unidade de esforço agora. Os dois são lentes diferentes, não concorrentes: um item pode ser P0 (crítico) e ter RICE baixo (caro de fazer agora) — significa que é importante mas não é o próximo passo executável, não que deixou de ser crítico.

## Aplicado de verdade ao backlog atual (itens ainda não `DONE`)

| ID | Item | R | I | C | E | RICE | Por quê |
|---|---|---|---|---|---|---|---|
| BL-006 | Este próprio sistema de priorização | 10 | 1 | 90% | 1 | **9.00** | Usado em toda decisão futura, barato, alta confiança |
| BL-011 | Delegação formal (matriz documentada, fora do doc de auditoria) | 7 | 1 | 85% | 1 | **5.95** | Padrão já real e usado hoje, só falta formalizar — barato |
| BL-017 | n8n — workflow de prazo vencido | 8 | 2 | 70% | 5 | **2.24** | Alto impacto real (já causou 1 problema descoberto tarde), mas caro — instalação em curso |
| BL-012 | Matriz de autonomia por agente | 6 | 1 | 70% | 3 | **1.40** | Útil, mas a Escada por categoria já cobre boa parte do risco real |
| BL-018 | Revisões periódicas formais (semanal/mensal/trimestral) | 5 | 0.5 | 70% | 2 | **0.88** | Baixo impacto imediato — só a diária tem uso real comprovado hoje |
| BL-008 | Ciclo de vida formal de Skill | 4 | 1 | 60% | 3 | **0.80** | Nenhuma skill foi desativada ainda — risco teórico, não vivido |
| BL-016 | Métricas de performance (qualidade/retrabalho/ROI) | 5 | 1 | 50% | 4 | **0.63** | Caro de fazer direito, confiança baixa em qual métrica realmente importa ainda |
| BL-009 | Avaliar criação de Chief of Staff | 3 | 0.5 | 50% | 2 | **0.38** | Baixo reach hoje — `cerebro-integrador` já cobre parte disso |
| BL-020 | Automatizar WhatsApp (Cloud API) | 7 | 2 | 50% | 4 | **1.75** | Alto impacto potencial (contato direto de cliente), mas bloqueado numa ação do dono antes de começar — confidence baixa por isso |
| BL-019 | Automatizar suporte do site (FAQ) | 6 | 1 | 60% | 3 | **1.20** | Precisa do conteúdo (item #14) existir antes de automatizar algo vazio |

**Ordem de execução recomendada, a partir de agora:** BL-006 (feito, é este arquivo) → BL-011 → continuar BL-017 (já em andamento, alto impacto justifica o custo) → BL-012 → BL-018 → BL-008 → BL-016 → BL-009.

## Regra de recálculo

Todo item novo do backlog entra aqui com os 4 fatores estimados **antes** de começar — nunca depois, pra não racionalizar a ordem que "pareceu certa". Reavaliar Confidence sempre que uma estimativa se provar errada (registra em `lessons-learned.md` se o erro for grande).
