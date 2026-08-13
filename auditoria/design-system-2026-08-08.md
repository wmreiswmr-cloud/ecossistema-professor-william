# Especificação de Design System — Portão 2

**Data:** 2026-08-08
**Autor:** `cerebro-brand-director`
**Status:** aguardando aprovação do dono — nenhum código foi tocado, nenhuma mensagem foi enviada ao Lovable.

## O que é este documento e o que não é

O dono já escolheu a referência de cada projeto (Portão 1, feito) e o DNA de cada uma já foi **medido**, não estimado, pela `ferramentas/extrair-referencia.js` — confirmado contra `~/.claude/knowledge/referencias-padrao.md`:

- ProfGestor → TutorCruncher, medido 2026-08-05: base pastel + índigo único `#362E83` · Inter+Halyard · base 8px
- Site pessoal → Linda Raynier, medido 2026-08-07: branco + dourado `#A8943E` + navy `#3643A8` · Baskervville+sofia-pro · base 4px · raio 3-4px

Este documento **não** é a escolha de direção A/B/C — essa etapa já passou. É a **reconciliação**: os dois projetos já têm Design System em produção, aprovado antes. Pela regra de precedência do processo (`processo-empresa.md`, "Brand Book × preferência do especialista → vence o Brand Book, o dono já aprovou aquilo"), **tokens já em produção só mudam com argumento real declarado — nunca por inércia de copiar a referência nova**. Onde não há argumento, o token de produção vence e a referência contribui só estrutura/padrão.

---

# PROJETO 1 — ProfGestor

## Achado antes de especificar (lido o código real, não assumido)

Fontes lidas: `Profgestor github/profgestor/src/index.css`, `tailwind.config.ts`, `src/pages/Landing.tsx` — **e corrigido depois contra produção real**, ver nota abaixo.

**Correção 2026-08-08:** a primeira versão deste documento afirmou que Bricolage Grotesque "não existe em nenhum arquivo do repositório" e listou como lacuna a implementar. **Estava errado.** A fonte lida era o clone local do projeto (`c:\Users\usuario\Desktop\Profgestor github\profgestor\`), que está desatualizado — edições feitas via Lovable mudam o repositório interno do Lovable direto e não sincronizam de volta pro clone local automaticamente. O Diretor já tinha aplicado Bricolage Grotesque nos headings via Lovable nesta mesma sessão (commit `e659a92b`), e isso foi confirmado aqui com instrumento real contra o ambiente que importa — produção, não o clone:

```
$ curl -s https://profgestor.com.br/assets/index-Dq1R2lQ_.css | grep -o "@import[^;]*Bricolage[^;]*;"
@import"https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:wght@600;...

$ curl -s https://profgestor.com.br/assets/index-Dq1R2lQ_.css | grep -o "\-\-font-heading:[^;]*"
--font-heading: "Bricolage Grotesque", sans-serif

$ curl -s https://profgestor.com.br/assets/index-Dq1R2lQ_.css | grep -oE "h1[^{]*\{[^}]*font-family:[^;}]*"
h1,h2,h3,h4,h5,h6{font-family:var(--font-heading)
```

Bricolage Grotesque **já está em produção**. Não é lacuna, não precisa de implementação — é token existente. Lição registrada: para este projeto, o clone local não é instrumento confiável pra afirmar o que está em produção; a fonte de verdade é o Lovable (`read_file` num commit real) ou o site ao vivo.

## Tokens

| Token | Valor | Fonte | Decisão |
|---|---|---|---|
| Cor primária (autoridade) | Navy `#16233b` / `hsl(219 46% 16%)` | **Produção** (`--primary`) | Mantém — ver Decisão de Cor abaixo |
| Cor de acento | Dourado `#b8842e` / `hsl(37 60% 45%)` | **Produção** (`--accent`) | Mantém — ver Decisão de Cor abaixo |
| Contraste dourado sobre navy | 4.77 — AA ✅ | **Produção**, já calculado no comentário do CSS | Reutilizado, não recalculado |
| Contraste ink sobre dourado | 5.23 — AA ✅ (padrão de botão dourado) | **Produção** | Reutilizado |
| Fundo | `hsl(40 28% 96%)` — quente, família do papel do site do William | **Produção** | Mantém |
| Tipografia — títulos | Bricolage Grotesque 600/700/800 | **Produção** — confirmado via `curl` contra `profgestor.com.br` (commit `e659a92b`), não pelo clone local | Mantém — já implementado, mesmo par do site pessoal |
| Tipografia — corpo/botões | Plus Jakarta Sans 400/500/600 | **Produção** | Mantém |
| Espaçamento base | 4px (padrão Tailwind, sem override em `tailwind.config.ts`) | **Produção** | Mantém — ver justificativa abaixo |
| Raio | `0.75rem` (12px), `--radius` | **Produção** | Mantém |
| Sombra | `--shadow-sm/md/lg/accent`, já calibradas em navy 6-18% opacidade | **Produção** | Mantém |
| Padrão estrutural — foto real + card de UI flutuando | Herdado do DNA TutorCruncher (base 8px, estrutura de hero) | **Referência** | Absorver a estrutura — ver seção própria |

## Decisão de cor — a tensão, declarada

**Pergunta:** o índigo `#362E83` do TutorCruncher substitui o par navy/dourado já em produção?

**Não. Mantém navy/dourado.** Razão, não inércia:

1. **O par já tem contraste calculado e aprovado** (dourado/navy 4.77, ink/dourado 5.23) — trocar por índigo reabre uma auditoria de acessibilidade inteira sem nenhum ganho declarado.
2. **A escolha de navy/dourado já é estratégica, não estética.** O comentário do próprio código de produção diz que a cor foi escolhida para criar família visual com o site pessoal do William. Isso importa porque o ProfGestor **vende confiança usando a credibilidade do próprio William** — a seção "Sobre o criador" da Landing (`Landing.tsx`, linha 198-216) é literalmente o depoimento dele como professor real usando o próprio produto. Duas propriedades com a mesma paleta reforçam "é a mesma pessoa, a mesma autoridade" — é o ativo de marca mais forte que o projeto tem, e trocar a cor jogaria fora essa ponte.
3. **O índigo do TutorCruncher não carrega nenhum princípio isolável.** Ele é uma cor de marca genérica de SaaS britânico — não existe dado ou padrão de categoria (produtividade/educação) que diga que índigo converte melhor que navy/dourado nesse nicho. Não há argumento real, só novidade.

**O que absorve de verdade:** a **estrutura** — foto real + card de UI flutuando — e a disciplina de espaçamento, quando fizer sentido (ver abaixo). Cor e tipografia de corpo não mudam.

### Sobre a base 8px do TutorCruncher

**Não adotar como override de token.** O ProfGestor já roda em produção sobre o grid padrão de 4px do Tailwind (nenhum override em `tailwind.config.ts`) — trocar a unidade-base agora significa reauditar espaçamento em toda tela já construída, por um ganho que é só estético. A disciplina "múltiplo de 8" pode ser seguida **dentro** do grid de 4px (escolhendo classes pares: `p-4`, `p-6`, `p-8`) sem mexer no token. Ganho sem custo — não precisa da decisão de trocar a base.

## Padrão estrutural — foto real + card de UI flutuando

O que a Marketing elogiou no TutorCruncher resolve dois medos do público (professor autônomo entregando agenda/cobrança a um software): "isso organiza minha vida" (mostrar produto) + "tem gente de verdade por trás" (mostrar humano). A Landing atual já tem a foto (`williamSobre`) na hero, mas **atrás dela só existe um bloco de cor decorativo** (`Landing.tsx`, linha 162: `gradient-primary rounded-[2rem] -z-10 rotate-2`), sem nenhum elemento de UI. É metade do padrão — falta a peça que mostra o produto.

**Onde aplicar:**

1. **Hero (prioridade alta).** Adicionar um card flutuando sobre/ao lado da foto, no mesmo espírito do bloco decorativo já existente (reaproveitar a rotação e a sombra que já estão lá, só adicionar conteúdo real de UI por cima). Conteúdo do card: um recorte real do produto — ex. um mini-card de "aula confirmada hoje" ou resumo financeiro do mês. **Regra dura do processo, vale aqui também:** nenhum número ou tela fictícia — se o card mostrar valor recebido ou aula confirmada, tem que ser uma captura real do produto ou um estado de exemplo claramente identificável como exemplo, nunca estatística inventada como se fosse real.
2. **"Sobre o criador" (opcional, prioridade baixa).** A seção já tem foto (`williamBusto`) + depoimento em texto — um selo pequeno tipo "usa o ProfGestor desde [ano]" reforça o mesmo padrão, mas não é essencial; a seção já cumpre o papel de humanização sozinha.

## O que NÃO muda

- Copy da Landing inteira: headline, subheadline, os 4 diferenciais, o depoimento do William, nomes/preços dos planos (R$29,90 e R$97,00) — nada disso é reescrito
- Fotos já aprovadas: `williamSobre`, `williamBusto`
- Paleta navy/dourado e a lógica de contraste já calculada
- Grid de espaçamento (4px Tailwind)

---

# PROJETO 2 — Site pessoal de William Reis

## Tokens

| Token | Valor | Fonte | Decisão |
|---|---|---|---|
| Fundo | `#f6efe0` papel / `#ece0c8` papel escuro | **Produção** (`globals.css`, Brand Book) | Mantém |
| Autoridade | Navy `#16233b` / `#263a5c` claro | **Produção** | Mantém |
| Acento | Dourado `#b8842e` / `#d9ab5c` claro | **Produção** | Mantém |
| Texto | Ink `#201a14` / ink-soft `#574d3f` | **Produção** | Mantém |
| Apoio | Vinho `#7a2e2e` · Sálvia `#5f7355` | **Produção** | Mantém |
| Contraste (todos os pares) | Calculado no Brand Book — ink/papel 15.04, navy/papel 13.71, dourado/navy 4.77, ink/dourado 5.23; dourado sobre papel **proibido** (2.88, reprova) | **Produção**, Brand Book | Reutilizado, nenhum par novo a calcular |
| Tipografia — títulos | Bricolage Grotesque 700/800 | **Produção** (`--font-bricolage`, `globals.css` linha 32) | Mantém |
| Tipografia — corpo | Plus Jakarta Sans 400/500/600 | **Produção** (`--font-jakarta`) | Mantém |
| Espaçamento base | 4px, múltiplo de 8 por disciplina de uso | **Produção/Brand Book** | Mantém |
| Raio | Não fixado em token único hoje — varia `rounded-xl`/`rounded-2xl` conforme componente | **Produção** | Mantém — a referência (raio 3-4px, mais reto) não se aplica: o Brand Book já define raio maior como parte do "acolhedor sem ser infantil" |
| Padrão estrutural — credencial → prova → foto | Herdado da Linda Raynier | **Referência**, aprovado explicitamente pelo dono | Aplicar — ver seção própria |

A paleta dourado+navy medida na Linda Raynier (`#A8943E` + `#3643A8`) é da mesma família do Brand Book real do William — isso confirma que a direção já escolhida funciona nesse tipo de negócio (consultoria/mentoria pessoa física), não é motivo para trocar o token. Nenhuma mudança de cor neste projeto.

## Padrão estrutural — "credencial primeiro", aplicado à estrutura de seções atual

**O que está no ar hoje (`site/src/app/page.tsx`) não segue esse padrão ainda.** A hero atual (linhas 14-132) já mostra a foto grande de William lado a lado com o headline, na primeira dobra — é o padrão "foto + texto juntos", não "credencial primeiro, foto depois em seção própria" que o dono aprovou como referência. Esta é uma mudança estrutural real, não cosmética, e por isso está aqui para aprovação antes de qualquer código.

**Mapeamento proposto — mesma copy, mesmas fotos, nova ordem:**

| Ordem hoje | Seção | Ordem proposta | O que muda |
|---|---|---|---|
| 1 | Hero: foto grande + headline juntos | 1 | Hero perde a foto grande — mantém headline, subheadline, selos de credencial ("Método Fônico · Neuropsicopedagogia · Atendimento individual") e CTA. Vira só texto + autoridade, como a Linda Raynier |
| 2 | Card de destaque sobre a hero | 2 | Mantém, sem mudança |
| 3 | Diferenciais (prova de valor) | 3 | Mantém — já é "prova" no lugar certo |
| — | *(não existe hoje)* | **4 — nova** | **Reconhecimento externo**: selos/credenciais formais (registro profissional, formação em Método Fônico, o que for verificável), no lugar de depoimento longo — ver dependência abaixo |
| 5 | Sobre resumo (badge + bio, sem foto) | 5 | **Ganha a foto grande** aqui — é a seção própria de "foto depois", como a referência aprovada. Copy do `sobreTexto` não muda, só ganha imagem |
| 6 | Método | 6 | Mantém |
| 7 | Depoimentos (condicional, vazio hoje) | 7 | Mantém como está — some pela regra já existente ("nenhuma estatística ou depoimento sem origem real") até haver depoimento de verdade |
| 8 | CTA final | 8 | Mantém |

**Dependência aberta, não é decisão de design — é conteúdo real que falta:** a seção 4 (reconhecimento externo) só pode ser construída com credenciais **verificáveis** de William (registro profissional, certificação do método, instituição de formação). Não é permitido inventar selo ou placeholder — mesma regra que já proíbe depoimento fabricado. Se esse material não existir hoje, a seção 4 fica marcada como pendente na spec e a ordem segue sem ela até o dono trazer o que existe de verdade.

## O que NÃO muda

- Toda a copy: headline, subheadline, `sobreTexto`, `diferenciais`, `metodoResumo` — texto idêntico, só a posição da seção muda
- A foto `william-perfil-busto.jpg` — já aprovada, só muda de seção
- A lógica condicional dos depoimentos (só aparece com depoimento real)
- Paleta, tipografia, motion DNA — nada disso muda

---

# Contrato de passagem

1. **O que entreguei:** especificação de reconciliação de Design System para ProfGestor e site pessoal, tokens declarados com fonte (produção vs. referência) e decisão explícita sobre a tensão de cor do ProfGestor
2. **Como verifiquei:** primeiro li o CSS e o Tailwind config do clone local dos dois projetos — o que produziu um erro real, corrigido depois com instrumento melhor: `curl` direto contra o CSS servido em `profgestor.com.br`, linha crua, não contagem, confirmando que Bricolage Grotesque já está em produção (o clone local estava desatualizado, edição feita via Lovable não sincroniza de volta pra ele). Contraste de cor citado nos dois projetos é o já calculado em produção/Brand Book, nenhum par novo foi estimado
3. **O que não cobri:** nenhum código foi escrito, nenhum componente foi desenhado, nenhuma mensagem foi enviada ao Lovable — é spec para aprovação, conforme pedido
4. **O que o próximo precisa saber:** ProfGestor mantém navy/dourado, grid 4px e Bricolage nos títulos (já em produção) e ganha só um card de UI real na hero; site pessoal reordena seções (hero perde a foto grande, "Sobre" ganha) e tem uma seção nova pendente de conteúdo real (reconhecimento externo)
5. **Lacuna encontrada:** (a) processo — o clone local do ProfGestor não é instrumento confiável pra afirmar o que está em produção (edição via Lovable não sincroniza de volta); reportar ao Diretor como armadilha a catalogar, não repetir a checagem sem confirmar contra Lovable/produção primeiro; (b) a seção "reconhecimento externo" do site pessoal depende de credencial verificável que ainda não está listada em nenhuma memória do projeto — precisa ser levantada com o dono antes de especificar o conteúdo dessa seção
