# Caminho de Construção de Design — versão final

**Autor:** Diretor (cerebro-ecossistema), com revisão real de `cerebro-analista-mercado-agencia` (Fases 0-2) e `cerebro-brand-director` (Fases 3-5) — os dois apontaram lacunas reais, incorporadas abaixo, não só validaram.
**Status:** pronto para aprovação do dono.

## Por que este processo

Em 08/08, a mesma página (ProfGestor) recebeu 3 reclamações em sequência — cor do hero, tipografia de um badge, falta de cor geral. Cada uma foi corrigida na hora, sem checar as outras dimensões. A causa raiz não foi nenhum dos três achados — foi a ausência de um caminho fixo que obrigasse passar por todas as dimensões de uma vez, na ordem certa, com verificação cruzada, antes de declarar pronto.

A primeira versão deste documento (rascunho) foi revisada por quem realmente executa cada parte, e as revisões acharam problemas reais — inclusive um: a atribuição "Marketing escolheu a referência de hoje" não tinha entrega correspondente, e a decisão nunca foi registrada em `decisoes.md` (categoria N0, exigência já existente). Isso já virou item de quadro (#37) e é a primeira coisa que este processo corrige.

---

## As fases

### Fase 0 — Fundamento de negócio (donos reais, não um só)
Três dimensões, três donos, coordenados **antes** da Fase 1 começar:
- **Público e narrativa** (medo, desejo, o que a página precisa comunicar emocionalmente) — `cerebro-branding`, não Mercado & Receita. É o que a análise de hoje (TutorCruncher vs. as 7 referências recusadas pro site pessoal) realmente fez, mesmo sem estar registrado como tal.
- **Categoria e concorrência** (Porter, Blue Ocean, o que os concorrentes diretos fazem) — `cerebro-analista-mercado-agencia`.
- **Ticket médio e motion de venda** (self-serve × consultivo — foi a diferença real entre TutorCruncher/ProfGestor e Linda Raynier/site pessoal hoje, mesmo sem estar nomeada) — `cerebro-financeiro`.
- **Estágio funil/consciência** (Schwartz — já exigido pra criativo de tráfego em `processo-empresa.md`, agora também aqui) e **aquisição × retenção** (a página resolve trazer gente nova, ou reter quem já converteu?) entram como perguntas obrigatórias do briefing, não dimensão de dono novo.

**Mecanismo de handoff, obrigatório:** quem está na Fase 1 (Brand Scout) aciona `cerebro-branding` **antes** de levantar referências, com resposta em até 1 dia útil. Sem essa resposta registrada, a Fase 1 não começa — é o que faltou hoje.
**Saída:** perfil de público + critério de encaixe escrito, com os 3 donos assinando, registrado em local consultável.

### Fase 1 — Levantar referências (dono: cerebro-brand-scout)
Navegar a Biblioteca de Referências primeiro; só sair da lista fixa se genuinamente nada servir — documentado como exceção (como aconteceu hoje com o site pessoal).
**Se a referência chegar sem URL** (só print, como aconteceu hoje com o "Relay"): declarar esse limite explicitamente. Não dá pra medir DNA dela — pule a Fase 3-medição e reconcilie (Fase 4) usando só tokens **já existentes e aprovados**, nunca estimando a cor da referência de olho.
**Saída:** 2-3 candidatos reais com link (ou o limite declarado, se só houver print).

### Fase 2 — Escolher com critério de negócio (dono real: Marketing prepara, William decide)
Cada candidato é julgado contra o critério da Fase 0, **mais pelo menos 1 evidência de mercado**: benchmark de conversão do padrão estrutural escolhido, dado de concorrente ao vivo (`ads_library_search` na Meta Ads Library), ou confirmação direta do dono sobre o cliente real — nunca só narrativa de framework sem checagem.
**Obrigatório:** a escolha final entra em `decisoes.md` **antes** do resultado aparecer — é decisão N0 "Marca, voz e identidade", exige registro. Isso não aconteceu hoje; não pode faltar de novo.
**Saída:** referência aprovada, razão de negócio + evidência de mercado documentadas, decisão registrada.

### Fase 3 — Confirmar o estado real de produção (nova fase, antes de medir qualquer coisa nova)
Antes de decidir se vale medir a referência nova: checar o que **já existe**, no Brand Book documentado **e** no código/produção real (via `curl` ou `mcp Lovable read_file` num commit real — **nunca clone local**, é instrumento não confiável, já catalogado como armadilha). Hoje isso pegou dois casos reais: Bricolage Grotesque já estava implementado (quase reportado como lacuna por ler o clone desatualizado) e o modo escuro do ProfGestor já existia em código, calculado, nunca documentado nem usado — um terceiro estado que "aprovado" ou "não existe" não cobre.
**Se o token já está travado** (contraste calculado, motivo estratégico documentado): não vale medir a referência pra esse token — só vale medir se for pra **estrutura/composição**.
**Saída:** confirmação do que já existe de verdade (não do que o Brand Book *deveria* dizer), separando o que está documentado, o que está em código mas invisível pro processo, e o que genuinamente não existe.

### Fase 4 — Reconciliar (dono: cerebro-brand-director) — três trilhas, não uma decisão binária
1. **Token** (cor, fonte, espaçamento, raio) — regra de precedência: Brand Book aprovado vence referência nova, token só muda com argumento real declarado.
2. **Estrutura/composição** (ex. "foto + card de UI flutuando", "credencial primeiro") — pode ser absorvida livremente da referência **mesmo mantendo o token intacto**, porque não é a mesma coisa que cor/fonte.
3. **Nova exceção documentada** — quando a reconciliação revela que nem "manter" nem "mudar" resolve, e o caminho certo é criar uma variante nova, formal, com escopo declarado (foi o caso do modo escuro do ProfGestor hoje — Direção C, "duas identidades declaradas").

**Verificação cruzada obrigatória, antes da Fase 5 (não depois, na Fase 7):**
- Todo par de cor **novo** introduzido aqui é conferido por `cerebro-accessibility` — quem decide o token não é quem confere se ele passa.
- `cerebro-design-system-manager` confere consistência contra o Design System já registrado.
- `cerebro-component-library-manager` confere se o componente estrutural proposto (ex. o card de UI) já existe cadastrado em outro projeto, antes de propor um novo.
- Se o trabalho envolveu extrair **princípio estrutural** de uma referência (não só medir número) — reconhecer isso como o trabalho real de `cerebro-reverse-engineering`, não só da ferramenta de extração de DNA.

**Saída:** especificação de Design System com as três trilhas explícitas, mais as 3 conferências cruzadas registradas.

### Fase 5 — Rascunho visual (dono: cerebro-design-pro + cerebro-design-critic, com a skill ui-ux-pro-max obrigatória)
Mockup em artefato com conteúdo real, comparando antes/depois.

**cerebro-design-pro consulta obrigatoriamente a skill `ui-ux-pro-max`** (banco de 84 estilos, 192 paletas, 74 pares tipográficos, 98 diretrizes de UX, por tipo de produto) antes de desenhar — não é opcional pra trabalho de cor/tipografia/layout, já é regra do processo (`~/.claude/CLAUDE.md`). É a ferramenta que embasa a escolha de paleta/tipografia/padrão com benchmark real de mercado, em vez de gosto pessoal do agente. Roda ANTES do rascunho ser montado, não depois.

**cerebro-design-critic entra em paralelo, com outro papel** — não só na Fase 7. As dimensões do Checklist $10K que dá pra avaliar num mockup estático (ponto de vista, tipografia, cor, hierarquia, imagem, indício de motion) são checadas antes do portão.

**Quando pular o mockup** — critério de superfície/reversibilidade, não de tamanho de diff (a lição de hoje: as 3 reclamações eram mudanças minúsculas em CSS, e ainda assim caras, porque caíram na hero). Só pula se **todos** forem verdade:
1. Toca só valor de um token já aprovado e com contraste já calculado — não introduz cor nova.
2. Não muda composição/layout — não adiciona nem reordena elemento.
3. Reverte com um comando/uma mensagem ao Lovable.
4. **Não toca a zona de primeira impressão** — hero, headline principal, CTA primário da landing pública.
5. `cerebro-design-critic` ou `cerebro-design-system-manager` consegue verificar o resultado com screenshot real em menos de 5 minutos depois.

Falhar só o critério 4 já basta pra exigir o mockup — foi o ponto mais caro do dia.
**Saída:** artefato de comparação, já lido contra o Checklist $10K, pronto pra aprovação.

### 🚪 Portão de aprovação do dono
Nada da Fase 5 em diante vira código sem o dono ver o rascunho e aprovar.

### Fase 6 — Implementar com prova real (dono: quem executa)
`send_message` (nunca edição local direta em projeto Lovable — não sincroniza). Confirmar `latest_commit_sha` novo via `get_project` — nunca confiar no texto de resposta do agente do Lovable (já divergiu do campo real mais de uma vez hoje).

### Fase 7 — Auditoria de qualidade de ponta a ponta (dono: cerebro-design-critic)
As dimensões que só dá pra checar com o site real no ar — mobile em breakpoint real (não só mockup), performance (Lighthouse), HTML semântico, meta tags, acessibilidade em produção. Nota por critério com evidência real, nunca estimativa.

### Fase 8 — Fechar o loop (dono: Diretor)
Registrar no quadro tudo que ficou pendente, com dono e prazo. Padrão que se repete vira armadilha catalogada.

---

## Mapa de agentes (corrigido)

| Fase | Dono principal | Apoio / verificação cruzada |
|---|---|---|
| 0 — Fundamento de negócio | `cerebro-branding` (narrativa/público) + `cerebro-analista-mercado-agencia` (categoria) + `cerebro-financeiro` (ticket/motion de venda) | — |
| 1 — Levantar referências | `cerebro-brand-scout` | Biblioteca de Referências |
| 2 — Escolher com critério | Marketing (recomenda, com evidência de mercado) | **William decide**; `cerebro-growth-hacker` se precisar de benchmark de conversão |
| 3 — Confirmar produção real | quem executa | `curl`/`read_file` real — nunca clone local |
| 4 — Reconciliar | `cerebro-brand-director` | `cerebro-accessibility` (contraste), `cerebro-design-system-manager` (consistência), `cerebro-component-library-manager` (componente), `cerebro-reverse-engineering` (princípio estrutural) |
| 5 — Rascunho visual | `cerebro-design-pro` (consulta obrigatória à skill `ui-ux-pro-max`) + `cerebro-design-critic` (Checklist $10K desde o rascunho) | `cerebro-motion-designer` se aplicável |
| 6 — Implementar | quem executa | Lovable MCP / edição local (site pessoal) |
| 7 — Auditoria $10K completa | `cerebro-design-critic` | `cerebro-accessibility`, `cerebro-performance` |
| 8 — Fechar o loop | Diretor | `cerebro-secretario` (quadro) |

---

## O que este processo NÃO resolve sozinho

- Discordância do dono do que a Fase 4 recomendou — decisão sempre dele.
- Decisão de gasto (ex. upgrade de plano do Lovable) — categoria "Dinheiro saindo", sempre do dono.
- O critério de pular a Fase 5 (acima) já cobre o caso de ajuste pontual e urgente — não existe mais uma saída informal separada "pular tudo pra pedido pequeno".

---

## O que mudou do rascunho pra esta versão (transparência)

- Fase 0 deixou de ter um dono só — tinha um erro real de atribuição (Marketing "decidiu" algo que na prática foi feito pela célula de Marca sozinha, sem registro em `decisoes.md` — virou item #37 do quadro).
- Nova Fase 3 (confirmar produção real) — não existia; hoje pegou 2 erros reais que quase viraram decisão errada.
- Fase 4 deixou de ser binária — virou 3 trilhas (token / estrutura / exceção nova) mais 3 verificações cruzadas obrigatórias antes da Fase 5, não só depois na Fase 7.
- Fase 5 ganhou um critério real de quando pular o mockup, em vez de "sempre" ou "pequeno pode pular" sem definição.
- Mapa de agentes ganhou 6 nomes que faltavam: `cerebro-branding`, `cerebro-financeiro`, `cerebro-growth-hacker`, `cerebro-accessibility`, `cerebro-design-system-manager`, `cerebro-component-library-manager`, `cerebro-reverse-engineering`.
