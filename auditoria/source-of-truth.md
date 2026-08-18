# Source of Truth Registry

Criado em 2026-08-09 — item BL-001 do `evolution-backlog.md`. Regra fixa: quando dois lugares divergem sobre o mesmo tipo de informação, **o arquivo/local listado aqui vence, sempre, sem exceção.** Todo outro lugar é cópia, cache, resumo ou interpretação — nunca fonte.

**Como usar:** antes de afirmar qualquer coisa sobre o estado real de um projeto/decisão/processo, confira aqui onde a fonte oficial vive e vá até ela — nunca confie em memória de conversa anterior ou em resumo de terceiro.

**Regra do dono, 2026-08-12, resposta a "como administramos tanta informação":** artefato nunca é fonte, é retrato de um momento — só o Diretor consegue atualizar, manualmente. O **painel VS Code é a única superfície que lê o arquivo real toda vez que abre** — por isso a coluna nova abaixo diz exatamente onde CADA categoria aparece pra você olhar sem precisar decorar caminho de arquivo.

| Categoria | Fonte oficial (o que manda) | Onde você olha | Nunca confiar em |
|---|---|---|---|
| Estratégia | `~/.claude/knowledge/meta-5-anos-profgestor.md`, `meta-10k-mensal.md`, `plano-crescimento-profgestor.md` | Nenhuma seção no painel ainda — pergunte ao Diretor | Resumo verbal de reunião antiga |
| Arquitetura / Código — ProfGestor | Lovable cloud, via `get_project.latest_commit_sha` (MCP) | Nenhuma (técnico, Diretor consulta direto) | O clone local em `c:\Users\usuario\Desktop\Profgestor github\profgestor` — Armadilha 33, catalogada |
| Arquitetura / Código — Site pessoal | Branch `main` no GitHub, deploy Vercel | Nenhuma (técnico) | Qualquer branch local não sincronizada |
| Design System | `site/design-system/william-reis/BRAND-BOOK.md` (site) + `src/index.css` real do ProfGestor (tokens) | Nenhuma (técnico) | Descrição de memória do que "deveria estar" no CSS |
| Conhecimento | `~/.claude/knowledge/*.md` (34+ arquivos temáticos) | Nenhuma (técnico) | Achado de pesquisa ainda não promovido de `pesquisa-diaria/` |
| Processos | `~/.claude/knowledge/processo-empresa.md` (geral), `processo-site-portoes.md` e `processo-design-final.md` (site/app) | Nenhuma (técnico) | Versão de processo lembrada de uma conversa antiga |
| Decisões | `auditoria/decisoes.md` | **Painel — só a contagem de pendentes hoje**, detalhe completo ainda é só arquivo | Decisão só falada em conversa, nunca registrada (causa raiz do achado de 08/08 sobre o foco da campanha) |
| Projetos (estado) | `auditoria/projetos.md` (Project State Engine, BL-003) | Nenhuma seção no painel ainda | Reconstrução manual via leitura de histórico |
| Tarefas / Quadro de problemas | `auditoria/problemas.md` | **Painel — Quadro de Problemas** (corrigido 12/08: agrega TODAS as tabelas de reunião, antes só lia a última) | Lembrança de "acho que já resolvi isso" |
| Riscos | `auditoria/riscos.md` | **Painel — só a contagem de abertos hoje**, detalhe completo ainda é só arquivo | Risco identificado e resolvido de cabeça, nunca registrado |
| Backlog de evolução | `auditoria/evolution-backlog.md` | **Painel — tabela Evolution Backlog** | Status verbal ("já fiz isso") sem linha atualizada no arquivo |
| Skills / Agentes (organograma) | Arquivos individuais em `~/.claude/commands/`/`~/.claude/agents/` (43 reais, contados 12/08) | **Painel — seção Organograma** (construindo agora) + Artifact "Organograma" (retrato, republicado sob demanda) | Contagem antiga ("41/41") sem recontar os arquivos reais |
| Nível de maturidade dos agentes | `~/.claude/knowledge/skill-maturity-register.md` | **Painel — Níveis do time** (ao vivo, lê `snapshot-*.json`) | Nível autodeclarado por qualquer agente |
| Princípios / Constituição | `~/.claude/knowledge/principios-decisao.md` | Nenhuma (técnico) | Qualquer regra "de memória" que pareça razoável |
| Clientes (ProfGestor) | Banco Supabase real, via Lovable (`query_database`) | Nenhuma (técnico) | Qualquer número estimado sem consulta ao banco |
| Campanha de tráfego | Meta Ads real, via MCP (`ads_get_ad_entities`/`ads_get_creatives`) — nunca o texto do chat de um agente | Nenhuma seção no painel ainda | `auditoria/plano-campanha-r100.md` é o PLANO original, não o estado atual da campanha |
| Automação / n8n (workflows rodando) | `automacao-n8n/*.json` (definição) + o processo real do servidor (`curl localhost:5679/healthz`) | **Painel — em construção 12/08** (vai mostrar rodando/parado ao vivo, não só o resultado que ele escreveu) | Assumir que está rodando só porque rodou hoje mais cedo — já morreu em silêncio 2x hoje (BL-037) |
| Economia de token / Higiene de sessão | `auditoria/uso-tokens-real.json` + `higiene-sessao-status.json` | **Painel — Economia de Token** (ao vivo) | Achismo de "a sessão está cara" sem o número medido |
| Opportunity Pipeline | `auditoria/opportunity-pipeline.md` (BL do `cerebro-empreendedor`, formado 12/08) | Nenhuma seção no painel ainda — pipeline ainda vazio de propósito | Oportunidade "de cabeça", sem passar pelo Opportunity Score |
| Procedimentos (passo a passo obrigatório) | `auditoria/procedimentos.md` (criado 15/08) | Nenhuma seção no painel ainda | Descrição de memória de "como isso deveria funcionar" |

## O que ainda não tem fonte única declarada — honestidade, não lacuna escondida

| Categoria | Situação real |
|---|---|
| Missão | Nenhum arquivo dedicado existe ainda |
| Métricas de produto (série histórica) | Não existe repositório central — cada auditoria mede do zero |
| Financeiro (P&L, CAC/LTV real) | Não existe relatório central |
| Memória pessoal do Claude × memória de projeto | Duas fontes sem ponte formal — ver `memoria-organizacional.md` |

**Revisão:** sempre que uma nova categoria de informação relevante aparecer, ela entra aqui no mesmo dia — nunca depois de já ter causado divergência real (mesma lição do achado #37/#39 de 08/08).
