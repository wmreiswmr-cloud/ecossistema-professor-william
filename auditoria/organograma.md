# Organograma do Ecossistema

Criado em 2026-08-09, item crítico da autoauditoria "Architecture of Intelligent Management". Até aqui o organograma existia só como Artifact publicado (link externo, sem versionamento) — isso quebrava a própria regra de fonte única declarada (qualquer link pode sumir ou ficar desatualizado sem ninguém notar). **Este arquivo passa a ser a fonte de verdade.** O Artifact continua existindo como versão visual pra consulta rápida, mas em caso de divergência, este arquivo vence.

**Cadência de atualização:** a cada 15 dias (item recorrente #22 em `problemas.md`), ou imediatamente quando um agente novo é criado.

## Camada 0 — Dono

William Reis. Decide tudo em categoria N0 (dinheiro saindo, marca/identidade, saída pra fora, dado apagado) — não-delegável, nem pelo Diretor.

## Camada 1 — Diretor

`cerebro-ecossistema` (Innovator Director) — CEO + CTO + Diretor de Produto + Diretor de Inovação + Diretor de Qualidade. Reporta só ao dono. Não escreve código nem telas; distribui, controla qualidade/custo/risco com métrica, decide categorias N0-não-delegável e N1.

## Camada 2 — Gestão (reportam direto ao Diretor, fora das 4 células)

| Agente | Função | Fronteira principal |
|---|---|---|
| `cerebro-secretario` | Conduz a reunião diária, monta o quadro único | Nunca decide, nunca diagnostica causa raiz |
| `cerebro-sentinela` | Confere se rotina mecânica rodou (tarefa agendada, prazo) | Nunca decide o que fazer com o atraso |
| `cerebro-integrador` | Cobra execução entre reuniões, resolve atrito cruzado entre células | Nunca decide estratégia, nunca fala com o dono |
| `cerebro-qualidade` | Causa raiz de problema recorrente/caro/sistêmico (A3, 5 Porquês) | Nunca decide, nunca culpa pessoa |
| `cerebro-reitor` | Governa trilhas de pesquisa e formação de todo agente novo | Nunca aceita nível autodeclarado |

## Camada 3 — Linha de auditoria (transversal, fora das células)

Nunca reportam a quem auditam — sempre direto ao Diretor.

| Agente | Audita |
|---|---|
| `cerebro-design-critic` | Visual/UX/UI/Performance/SEO/Acessibilidade antes de qualquer aprovação |
| `cerebro-accessibility` | Contraste, semântica HTML, ARIA, navegação por teclado (WCAG) |
| `cerebro-qa-automation` | Teste real com Playwright antes de entrega final |
| `cerebro-knowledge-architect` | Integridade da Base de Conhecimento — duplicata, obsolescência |

## Camada 4 — As 4 células

### Marca & Produto
Líder: `cerebro-brand-director` (nunca desenha tela — entrega direções, dono escolhe)

| Agente | Escopo |
|---|---|
| `cerebro-brand-scout` | Pesquisa referência visual diária, entrega pro Brand Director decidir |
| `cerebro-design-pro` | Constrói interface sobre direção já aprovada |
| `cerebro-design-system-manager` | Guardião das regras de design já definidas — nunca cria tela |
| `cerebro-component-library-manager` | Cataloga componentes reutilizáveis |
| `cerebro-motion-designer` | Animação com propósito |
| `cerebro-ux-research` | Jornada do usuário, fricção, antes da interface existir |
| `cerebro-product-architect` | Implementação técnica ampla (também ponte com Engenharia) |

### Engenharia
Líder: `cerebro-product-architect`

| Agente | Escopo |
|---|---|
| `cerebro-saas` | SaaS completo — auth, banco, arquitetura de produção |
| `cerebro-dominios` | Domínio, DNS, SSL, hospedagem, deploy |
| `cerebro-automacao` | Workflows n8n — nunca decide arquitetura de produto, nunca mexe no código-fonte do app |
| `cerebro-analiseusuario` | Conversão de usuário, campanhas de reengajamento via Supabase |
| `cerebro-performance` | Core Web Vitals, imagens, fontes, JS, caching |

### Mercado & Receita (Agência)
Líder: `ceo-orquestrador-agencia`

| Agente | Escopo |
|---|---|
| `cerebro-analista-mercado-agencia` | Benchmarking, SWOT, persona |
| `cerebro-trafego` | Meta/Google Ads, teste de criativo, CAC/ROAS |
| `cerebro-copywriter` | Copy de landing page, estrutura validada |
| `cerebro-editor-in-chief` | Última revisão de língua antes de publicar — nunca toca estratégia |
| `cerebro-seo` | SEO técnico e conteúdo orgânico |
| `cerebro-social-media` | Estratégia de conteúdo, calendário editorial |
| `cerebro-funil` | Mapeamento de funil, automação de nutrição |
| `cerebro-vendas` | Qualificação de lead, script de fechamento |
| `cerebro-financeiro` | CAC/LTV, margem, prepara o caso de "Dinheiro saindo" pro Diretor |
| `cerebro-growth-hacker` | Experimentação, teste A/B, priorização de alto impacto |
| `cerebro-gerador-criativos` | Imagem + copy + roteiro de anúncio — nunca inventa vídeo pronto que não existe |

### Conhecimento & Universidade
Líder: `cerebro-reitor` (também Camada 2 — dupla função reconhecida, não é erro)

| Agente | Escopo |
|---|---|
| `cerebro-analista-mercado` | Trend scout — 15 trilhas diárias de pesquisa |
| `cerebro-analisador` | Diagnóstico visual a partir de screenshot |
| `cerebro-analista-pro` | Análise de ideia de app, benchmark, arquitetura |
| `cerebro-reverse-engineering` | Extrai princípio de referência externa sem copiar |
| `cerebro-memoria-solucao` | Guardião da memória técnica entre projetos |
| `cerebro-branding` | Identidade de marca, naming, posicionamento |

## ⚠️ Inconsistência real, não resolvida — declarada, não escondida

`cerebro-branding` aparece referenciado em **duas células diferentes** entre este organograma e `mestres-marketing-agencia.md` (achado real do `cerebro-reitor`, registrado em `plano-desenvolvimento-time-v2.md`, 06/08). Listado aqui em Conhecimento & Universidade por proximidade com posicionamento/naming, mas a fonte de marketing o trata como agência. **Não decidi sozinho qual está certo** — fica pendente de resolução formal, mesmo achado já estava no quadro antes desta auditoria.

## Fora do ecossistema — registrado pra não confundir

O registro de "Available agent types" do Claude Code inclui ~50 subagentes genéricos bundled (ex: especialistas de Xiaohongshu, Baidu, vendas B2B) que **nunca foram acionados** neste projeto — não fazem parte do time real do dono, vieram no pacote da ferramenta. Não estão listados acima de propósito.
