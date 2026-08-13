# Caminho de Construção de Design — rascunho para revisão

**Autor:** Diretor (cerebro-ecossistema) — categoria "Estrutura do time/processo", N1 não-delegável.
**Status:** rascunho, ainda não aprovado pelo dono. Enviado para revisão real da Marketing e do Brand Director antes de fechar.

## Por que este processo, agora

Hoje (08/08) a mesma página (ProfGestor) recebeu 3 reclamações de "muito simples"/"horrível" em sequência — cor do hero, tipografia de um badge, falta de cor geral. Cada uma foi corrigida pontualmente, sem checar se as outras dimensões (tipografia, cor, estrutura, performance, acessibilidade) também tinham o mesmo problema. A causa raiz não foi nenhum dos três achados — foi a ausência de um caminho fixo que obrigasse passar por todas as dimensões de uma vez, na ordem certa, antes de declarar pronto.

Este documento fecha esse buraco: define as fases, quem é dono de cada uma, o que sai de cada fase, e o portão de aprovação do dono entre elas.

---

## As fases

### Fase 0 — Fundamento de negócio (dono: Marketing/Mercado & Receita)
Antes de qualquer escolha visual: quem é o público real, que medo/desejo o design precisa resolver, o que a concorrência direta faz. Sem isso, a Fase 2 (escolha de referência) vira preferência estética sem critério.
**Saída:** perfil de público + critério de encaixe escrito (o que a página precisa comunicar emocionalmente).
**Já temos exemplo real disso:** a análise que escolheu TutorCruncher pro ProfGestor e recusou as 7 referências pro site pessoal (nenhuma servia — todas eram SaaS, e o site pessoal vende confiança pessoal, não produto).

### Fase 1 — Levantar referências (dono: cerebro-brand-scout)
Nunca pesquisar do zero. Navegar a Biblioteca de Referências (artefato + `~/.claude/knowledge/referencias-padrao.md`) primeiro; só sair da lista fixa se genuinamente nada servir (como aconteceu com o site pessoal hoje — aí o Brand Scout pesquisa fora, documentado como exceção, não como hábito).
**Saída:** 2-3 candidatos reais, com link — nunca screenshot sem URL (perdemos a chance de medir DNA da referência "Relay" hoje por isso).

### Fase 2 — Escolher com critério de negócio, não de gosto (dono: Marketing + dono do produto)
Cada candidato da Fase 1 é julgado contra o critério da Fase 0. **Quem decide a escolha final é sempre o William** (Portão 1) — Marketing prepara a recomendação com razão escrita, nunca decide sozinho.
**Saída:** referência aprovada, com a razão de negócio documentada (não "gostei", e sim "resolve X do público Y").

### Fase 3 — Medir de verdade (dono: quem estiver executando, ferramenta obrigatória)
Rodar `ferramentas/extrair-referencia.js <url>` na referência aprovada. Nunca estimar cor/tipografia/espaçamento de olho — hoje isso já rendeu 3 medições reais (TutorCruncher, Linda Raynier, e as 3 alternativas de consultoria) com DNA real, e evitou pelo menos um erro (perceber que o dourado do TutorCruncher colidiria com a paleta já aprovada, ANTES de implementar).
**Saída:** DNA medido (paleta com opacidade, escala de espaçamento, tipografia, raios), registrado em `referencias-padrao.md`.

### Fase 4 — Reconciliar com o que já existe (dono: cerebro-brand-director)
Aqui mora a regra mais importante do dia: **Brand Book já aprovado vence preferência de referência nova — token em produção só muda com argumento real declarado, nunca por inércia de copiar a referência.** O Brand Director decide, para cada token (cor, fonte, espaçamento, raio): manter ou mudar, com razão escrita nos dois casos.
**Saída:** especificação de Design System (o modelo já usado hoje em `design-system-2026-08-08.md`) — tokens com fonte declarada (produção vs. referência) e decisão de cor justificada.

**Regra de ouro desta fase, aprendida hoje:** nunca ler clone local de projeto Lovable pra afirmar o que está em produção — é instrumento não confiável (armadilha catalogada). Fonte de verdade é sempre `mcp Lovable read_file` num commit real, ou `curl`/screenshot direto da produção.

### Fase 5 — Rascunho visual (dono: cerebro-design-pro + cerebro-design-critic, com cerebro-motion-designer se motion for relevante)
Nunca implementar direto a partir da especificação de tokens sozinha. Monta um rascunho visual (mockup em artefato, comparação antes/depois) usando conteúdo real (copy aprovada, foto real) — isso é o que permitiu o dono aprovar visualmente a reestruturação do hero do site pessoal e a cor do eyebrow do ProfGestor hoje, sem surpresa depois de publicado.

**O Design Critic entra junto, não só depois de publicado.** As dimensões do Checklist $10K que dá pra avaliar num mockup estático — ponto de vista, tipografia, cor, hierarquia, imagem, indício de motion — são checadas nesta fase, antes do Portão de aprovação, não só na Fase 7. Isso é o ajuste direto da lição de hoje: 3 reclamações separadas (cor, tipografia, cor de novo) na mesma página aconteceram porque cada ajuste passou sozinho pelo Design Pro sem outro olhar checando as 8 dimensões de uma vez, mesmo em rascunho.
**Saída:** artefato de comparação antes/depois, com a leitura do Checklist $10K aplicada ao mockup, pronto pra aprovação.

### 🚪 Portão de aprovação do dono
Nada do que vier da Fase 5 em diante vira código sem o dono ver o rascunho e aprovar. Isso já é regra do processo (Portão 2), só está sendo formalizado aqui como parte deste caminho específico.

### Fase 6 — Implementar com prova real (dono: quem está executando)
Aplicar via `send_message` (nunca edição local direta em projeto Lovable — não sincroniza, já foi erro real hoje). Depois de cada mudança: confirmar `latest_commit_sha` novo via `get_project`, nunca confiar no texto de resposta do agente do Lovable (o `commit_sha` do texto e o campo real do `get_project` já divergiram hoje, mais de uma vez).
**Saída:** commit real confirmado, com screenshot ou `read_file` no commit exato provando a mudança.

### Fase 7 — Auditoria de qualidade de ponta a ponta (dono: cerebro-design-critic, usando o Checklist $10K)
Esta é a fase que faltava e que hoje só rodou por acaso, no fim, depois de 3 reclamações separadas. Ela cobre as 8 dimensões de uma vez — ponto de vista, tipografia, cor, hierarquia, imagem, motion, mobile, e "o caro que não se vê" (performance, acessibilidade, HTML semântico, meta tags) — em vez de descobrir uma de cada vez por reclamação.
**Saída:** nota por critério com evidência real (Lighthouse, `curl`, contraste calculado — nunca estimativa), lista do que foi corrigido direto e do que precisa de outro especialista (hoje, isso separou certo o que era "ajuste de execução" — cor, meta tag — do que era "fora do escopo de design" — bundle JS de 714KB, que é `cerebro-performance`, não Design Critic).

### Fase 8 — Fechar o loop (dono: Diretor)
Registrar no quadro (`problemas.md`) tudo que ficou pendente com dono e prazo — nunca deixar achado da Fase 7 se perder. Se algo revelar um padrão (ex. "clone local não confiável" apareceu 3 vezes hoje), vira armadilha catalogada, não só um item de quadro resolvido e esquecido.

---

## Quem participa de cada fase (mapa de agentes)

| Fase | Dono principal | Apoio |
|---|---|---|
| 0 — Fundamento de negócio | `cerebro-analista-mercado-agencia` / `ceo-orquestrador-agencia` | — |
| 1 — Levantar referências | `cerebro-brand-scout` | Biblioteca de Referências |
| 2 — Escolher com critério | Marketing (recomenda) | **William decide** |
| 3 — Medir DNA | quem executa | `ferramentas/extrair-referencia.js` |
| 4 — Reconciliar tokens | `cerebro-brand-director` | — |
| 5 — Rascunho visual | `cerebro-design-pro` + `cerebro-design-critic` (Checklist $10K desde o rascunho) | `cerebro-motion-designer` se aplicável |
| 6 — Implementar | quem executa | Lovable MCP / edição local (site pessoal) |
| 7 — Auditoria $10K | `cerebro-design-critic` | `cerebro-accessibility`, `cerebro-performance` se achado exigir |
| 8 — Fechar o loop | Diretor | `cerebro-secretario` (quadro) |

---

## O que este processo NÃO resolve sozinho

- Não decide o que fazer quando o dono discorda do que a Fase 4 recomendou (isso continua indo pro dono, sempre).
- Não substitui pedido urgente e pontual do dono (ex. "muda a cor da letra agora") — pra ajuste pequeno e isolado, pular direto pra Fase 5/6 é aceitável; o caminho completo é pra quando o objetivo é "design profissional de ponta a ponta", não pra micro-ajuste.
- Não cobre a decisão de gasto (ex. upgrade de plano do Lovable pra tirar o selo "Edit with Lovable") — isso é categoria "Dinheiro saindo", N0, sempre do dono.

---

## Pedido de revisão

Enviado para: `cerebro-analista-mercado-agencia` (Fase 0/2, critério de negócio) e `cerebro-brand-director` (Fase 4/5, se a ordem e a fronteira entre as fases fazem sentido do ponto de vista de quem realmente executa). Cada um deve apontar o que está faltando ou errado, não só validar.
