# Project State Engine

Criado em 2026-08-09 — item BL-003 do `evolution-backlog.md`. Fonte oficial do estado de cada projeto real (ver `source-of-truth.md`). Reconstruído a partir do histórico real em `problemas.md`/`decisoes.md`, não inventado.

**Estados possíveis:** `IDEA` → `DISCOVERY` → `STRATEGY` → `PLANNING` → `EXECUTION` → `REVIEW` → `QA` → `APPROVAL` → `LAUNCH` → `MEASUREMENT` → `LEARNING` → `ARCHIVED`. Um projeto pode ciclar entre `EXECUTION`/`REVIEW`/`MEASUREMENT` continuamente — não é uma linha reta única.

---

## PROJ-001 — ProfGestor (Landing + SaaS)

| Campo | Valor |
|---|---|
| Objetivo | Converter visitante em teste grátis; crescer MRR rumo à meta de R$10K/mês |
| Responsável (produto) | `cerebro-brand-director` |
| Responsável (aquisição) | `cerebro-trafego` |
| Diretor | Diretor (Innovator Director) |
| Prioridade | P0 |
| **Status/Fase** | **EXECUTION + MEASUREMENT** (produto em produção contínua; campanha de aquisição ativa sendo medida) |
| Prazo | Campanha atual: 15/08 (fim da janela). Meta de 5 anos: sem data de marco intermediário fixado |
| KPIs | CPL, leads reais gerados, taxa trial→pago, MRR real (via Supabase) |
| Riscos ativos | `riscos.md` #1 (clone local), #6 (Design System duplicado) — #2 e #4 já mitigados |
| Dependências | Lovable (código+deploy), Meta Ads (aquisição), Supabase (dados reais) |
| Orçamento | R$100 (teste de aquisição em curso) |
| Agentes envolvidos | brand-director, design-pro, design-critic, motion-designer, performance, trafego, copywriter, gerador-criativos, product-architect |
| **Próximo checkpoint** | **12/08 — critério de matar da campanha (CPL &gt; R$15-20), ver `problemas.md` #46** |
| Última atualização | 2026-08-09 |

## PROJ-002 — Site Pessoal (William Reis)

| Campo | Valor |
|---|---|
| Objetivo | Transmitir confiança pra pai preocupado com filho que troca letras/lê devagar; gerar contato de mentoria/aula particular |
| Responsável | `cerebro-brand-director` |
| Diretor | Diretor (Innovator Director) |
| Prioridade | P1 |
| **Status/Fase** | **REVIEW** (hero credencial-primeiro reestruturada e testada localmente com Playwright — screenshot real confirmado — aguardando decisão do dono pra avançar a `APPROVAL`/`LAUNCH`) |
| Prazo | Sem data forçada — decisão do dono |
| KPIs | Nenhum definido ainda (sem campanha paga aqui) |
| Riscos ativos | Nenhum catalogado formalmente em `riscos.md` ainda |
| Dependências | GitHub, Vercel |
| Orçamento | N/A (orgânico) |
| Agentes envolvidos | brand-director, design-pro |
| **Próximo checkpoint** | Decisão do dono: publicar a hero nova ou pedir ajuste — ver `problemas.md` #30 |
| Última atualização | 2026-08-07 (última mudança real de estado) |

---

## O que este arquivo NÃO cobre ainda

A Trilha P (construção de site/app profissional, `construcao-site-app.md`) é iniciativa de capacitação do time, não um projeto voltado a cliente — fica fora do Project State Engine de propósito, mesma lógica que separa conhecimento de entrega.

**Atualização:** todo checkpoint atingido, mudança de fase ou risco novo entra aqui no mesmo dia — nunca reconstruído depois via histórico (essa reconstrução manual é exatamente o problema que este arquivo substitui).
