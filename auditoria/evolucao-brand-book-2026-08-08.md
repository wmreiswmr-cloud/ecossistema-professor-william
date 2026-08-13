# Evolução do Brand Book — resposta ao feedback "o brand book está limitando meu design"

**Data:** 2026-08-08
**Autor:** `cerebro-brand-director`
**Status:** proposta para o dono decidir — categoria **N0 "Marca, voz e identidade"** (`processo-empresa.md`), nenhum código tocado.

---

## 0. O que eu li antes de propor qualquer coisa (Fase 0 do processo)

- `~/.claude/knowledge/processo-empresa.md` — regra do dono: pedido subjetivo exige referência concreta (veio, é o print do "Relay") e contraste é sempre calculado, nunca estimado (Armadilha 20 do catálogo).
- `site/design-system/william-reis/BRAND-BOOK.md` — Direção C "Navy + Papel", aprovada 2026-08-02: fundo claro deliberado contra "frieza tecnológica" pro público de pais preocupados.
- `auditoria/design-system-2026-08-08.md` — reconciliação de hoje, aprovada, mantendo navy/dourado e fundo claro nos dois projetos.
- `Profgestor github/profgestor/src/index.css` — **achado que muda a resposta:** o projeto **já tem um bloco `.dark` inteiro, calculado e em produção, e nunca usado em nenhuma tela.** Ver seção 2.
- `Profgestor github/profgestor/src/pages/Landing.tsx` — a hero atual é: blob de cor decorativo (sem conteúdo) atrás da foto + headline uma cor só + botão `rounded-md` (não pílula).
- `~/.claude/knowledge/referencias-padrao.md` + `~/.claude/knowledge/armadilhas-conhecidas.md` — nenhuma referência "Relay" catalogada (é print, não link, então não dá pra rodar `extrair-referencia.js` contra ela — sinalizado como limite abaixo).

---

## 1. Resposta à pergunta central: o Brand Book está limitando de verdade, ou é um contexto específico?

**As duas coisas são verdadeiras ao mesmo tempo, e dá pra separar sem contradição:**

1. **A queixa "estrutura monótona" é real e verificável no código, não é impressão.** A hero do ProfGestor hoje (`Landing.tsx` linha 162) tem um `div` decorativo atrás da foto que é **só cor, sem nenhum conteúdo** — exatamente a metade que falta do padrão "foto + card de UI" que a própria reconciliação de hoje já recomendou (ver `design-system-2026-08-08.md`, seção "Padrão estrutural"). O headline é uma escala só, uma cor só. Isso já era um problema identificado **antes** do print do Relay chegar — o print só deu nome e urgência a ele.
2. **A razão original do fundo claro (não assustar pai preocupado com "frieza de startup") continua válida e não foi refutada por nada no pedido de hoje.** O dono não trouxe dado novo de que o site pessoal está performando mal por parecer "quente demais" — trouxe uma referência de **SaaS**, pra um produto que **é** SaaS (ProfGestor), sendo visto por um público diferente (professor autônomo comparando ferramenta, não pai decidindo sobre o filho).

**Minha leitura honesta:** o pedido, levado ao pé da letra no site pessoal (fundo escuro lá também), reabriria o problema de 20/07 sem nenhum motivo novo — seria trocar uma decisão aprovada por moda, o que o processo proíbe explicitamente ("Brand Book × preferência do especialista → vence o Brand Book, o dono já aprovou aquilo"). Mas recusar o pedido inteiro também seria errado: a queixa de monotonia tem base real, e o ProfGestor **tem** um ativo pronto — o modo escuro — parado no repositório sem uso.

---

## 2. O achado que muda a proposta: modo escuro já existe, calculado, em produção — e nunca é ligado

`Profgestor github/profgestor/src/index.css`, bloco `.dark` (linhas 84-105), com comentário original do próprio código:

```css
.dark {
  --background: 219 40% 9%;   /* navy quase-preto */
  --foreground: 210 20% 92%;  /* quase branco */
  --primary: 218 55% 62%;     /* azul claro — "no escuro o navy vira fundo,
                                  entao a primaria clareia para manter contraste" */
  --accent: 37 60% 55%;       /* dourado clareado pro fundo escuro */
  --accent-foreground: 30 23% 10%; /* ink — mesma regra do modo claro */
  ...
}
```

Isso não é uma cor nova para inventar — é a mesma paleta navy/dourado da marca, **já reformulada por alguém para funcionar sobre fundo escuro**, e simplesmente nunca aplicada em nenhuma tela (`Landing.tsx` não usa a classe `.dark` em lugar nenhum). O pedido do dono tem, literalmente, ativo pronto esperando.

---

## 3. Contraste — calculado por luminância relativa (WCAG), não estimado

Convertendo os tokens HSL acima para RGB e aplicando a fórmula de luminância relativa (mesmo método usado no Brand Book original para "dourado sobre papel = 2,88"):

| Par | Cores (hex aprox.) | Contraste | AA texto normal (4.5:1) |
|---|---|---|---|
| Fundo escuro × texto branco | `#0E1420` × `#E6EBEF` | **15.35 : 1** | ✅ AAA |
| Fundo escuro × dourado (texto/destaque) | `#0E1420` × `#D19C47` | **7.51 : 1** | ✅ AAA |
| Fundo escuro × subtexto cinza-azulado | `#0E1420` × `#8F9BAE` | **6.56 : 1** | ✅ AA (quase AAA) |
| Dourado × ink (botão pílula) | `#D19C47` × `#1F1A14` | **7.04 : 1** | ✅ AAA |

**O achado mais importante da conta:** no Brand Book atual, dourado sobre papel **reprova** (2.88 — proibido como texto, é regra escrita no BRAND-BOOK.md). Só que isso é specific a fundo **claro**. Sobre fundo **escuro**, o mesmo dourado (numa versão clareada, a que já está em `.dark`) passa em AAA. Ou seja: a "palavra de destaque em dourado" que o Relay mostra em azul **é executável de verdade na paleta da marca — só funciona no modo escuro, nunca no papel claro.** Isso não é opinião, é o motivo matemático de por que o fundo claro nunca poderia entregar esse efeito específico com a paleta atual.

**Limite declarado:** não tenho a URL do Relay, só a descrição do dono — não rodei `extrair-referencia.js` contra ela. Todos os números acima vêm de tokens **já existentes e aprovados** (Brand Book + `.dark` de produção), não de medir o print. Isso significa que a proposta é conservadora por construção: não estou inventando cor pra imitar a referência, estou reaproveitando o que já foi calculado.

---

## 4. Três direções

### DIREÇÃO A — "Hero escuro só na aquisição do ProfGestor"

**Quando é a certa:** se o objetivo é resolver a frustração pontual do hero do ProfGestor, rápido, sem reabrir nenhuma outra decisão.

- **Escopo:** só a seção Hero (e opcionalmente o bloco final de CTA/preço) da landing pública do ProfGestor — `Landing.tsx`. Não toca no site pessoal. Não toca no dashboard autenticado (continua claro, como já está).
- **Paleta:** os quatro tokens da tabela acima — todos já existentes em `.dark`, nenhuma cor nova.
- **Tipografia:** mantém Bricolage Grotesque nos títulos / Plus Jakarta Sans no corpo — já em produção nos dois projetos, não muda.
- **Ícones:** Lucide, como já é regra (zero emoji).
- **Espaçamento:** grid 4px já em produção, sem override.
- **Forma:** botão vira pílula (`rounded-full`) só nesta seção — mudança estrutural pontual, coerente com o pedido do Relay ("Start Free", "Watch Proof" em pílula). Card/foto mantêm `rounded-[1.75rem]` atual.
- **Motion:** mantém o Motion DNA já existente (baixa intensidade, 300-400ms) — o "drama" vem da cor e do glow, não de animação nova.
- **Risco declarado, não resolvido aqui:** a transição entre a hero escura e a seção "Diferenciais" (clara, logo abaixo) precisa de um degradê ou faixa de transição — se cortar seco, lê como dois sites colados. Isso é decisão de execução do Product Designer, não de identidade, mas fica registrado para não ser esquecido.
- **Referências de princípio** (não cópia): Linear (fundo escuro, tipografia grande — já catalogado em `referencias-padrao.md`, DNA medido) para a disciplina de texto claro sobre escuro; TutorCruncher (já referência aprovada do ProfGestor) para o card de UI flutuando sobre a foto.

### DIREÇÃO B — "Só a estrutura, sem trocar o fundo"

**Quando é a certa:** se o que realmente incomodou não foi a cor, e sim a hero parecer "fraca" — headline pequena, foto sem propósito, botão sem impacto — e o dono prefere não abrir nenhuma discussão de paleta em nenhum dos dois projetos.

- **Escopo:** os dois projetos (site pessoal e ProfGestor), zero mudança de cor.
- **Paleta:** inalterada — papel `#f6efe0` (site pessoal) / `hsl(40 28% 96%)` (ProfGestor), navy `#16233b` como cor de destaque no lugar do dourado (contraste navy sobre papel = **13.71:1**, já calculado e aprovado no Brand Book — dourado sobre papel continua proibido, 2.88).
- **Tipografia:** mesma dos dois projetos, escala de título ampliada no desktop (de 60px de teto para ~72-80px), pra ganhar o impacto visual que "headline enorme" do Relay tem, sem trocar fonte nem cor.
- **Forma:** pílula nos CTAs nos dois projetos; foto ganha sombra mais profunda/vinheta sutil pra "flutuar" sobre o fundo, sem precisar de fundo escuro pra isso.
- **Motion:** inalterado.
- **Argumento:** resolve a queixa de "estrutura fraca" sem reabrir nenhuma decisão de cor em nenhum dos dois projetos — zero nova auditoria de acessibilidade, zero risco de reintroduzir frieza no site pessoal.
- **Contra-argumento honesto:** se o que o dono realmente sentiu foi a **atmosfera** do Relay (o glow, o contraste dramático, "parece tech de verdade") e não só a composição, essa direção entrega menos do que ele pediu — é a opção mais seguros, mas também a mais tímida frente ao pedido original.

### DIREÇÃO C — "Duas identidades declaradas" (minha recomendação)

**Quando é a certa:** se o objetivo é resolver o pedido de hoje **e** parar de precisar decidir isso de novo cada vez que o assunto voltar.

Direção C = Direção A, **mais** uma seção nova formal no Brand Book (ou um adendo por projeto) que declara por escrito onde cada modo vive, pra virar regra e não exceção combinada de boca:

```
MODO PADRÃO — "Navy + Papel" (calor, autoridade em blocos, fundo claro)
  → site pessoal: TODA a experiência
  → ProfGestor: dashboard autenticado, toda tela pós-login

MODO ALTO CONTRASTE — "Navy Escuro + Dourado" (drama, glow, impacto)
  → ProfGestor: SOMENTE superfícies de aquisição/conversão pública
    (hero da landing, banner final de preço) — nunca dentro do app
  → site pessoal: NÃO SE APLICA — decisão já fundamentada (público teme frieza),
    sem dado novo que justifique revisar
```

- **Paleta e contraste:** idênticos à Direção A (tabela da seção 3) — mesmos quatro pares, mesmos números.
- **Por que é a recomendação:** o processo (`processo-empresa.md`) já defende que Brand Book é fonte de verdade única — uma exceção aplicada sem documentar é exatamente o tipo de decisão que "some" e vira contradição descoberta depois pelo dono (foi citado como o problema real que motivou a estrutura de células, ver organograma). Documentar o critério agora custa uma seção a mais e evita reabrir essa mesma pergunta ("por que a hero é escura e o resto não?") toda vez que alguém novo mexer no projeto.
- **Custo real declarado:** é mais trabalho de documentação que a Direção A sozinha — não é mais trabalho de código, o código é o mesmo.

---

## 5. Parecer honesto (não é menu neutro)

**Recomendo a Direção C.** A frustração do dono é legítima e tem uma causa concreta e verificável (hero do ProfGestor genuinamente subaproveitada, com ativo de modo escuro pronto e nunca ligado) — não é capricho a ser resistido. Mas o pedido, se generalizado sem critério pro site pessoal, reabriria um problema já resolvido com dado real (medo de frieza tecnológica no público de pais). A Direção C entrega o impacto pedido onde o público pede impacto (comprador de SaaS) e preserva o acolhimento onde o público pede acolhimento (pai decidindo sobre o filho) — com contraste calculado nos dois casos, não estimado, e sem inventar nenhuma cor nova: tudo já existe no repositório, só nunca foi ligado nem documentado.

**O que eu NÃO decido aqui, por ser N0:** qual das três o dono escolhe, e — se for A ou C — qual palavra do headline do ProfGestor vira o destaque em dourado. Isso é decisão de marca/voz, do dono.

---

## Contrato de passagem

1. **O que entreguei:** três direções de evolução do Brand Book em resposta ao pedido "o brand book está limitando", com recomendação declarada (C), sem desenhar nenhuma tela.
2. **Como verifiquei:** li o Brand Book atual, a reconciliação de hoje, o CSS e a Landing real do ProfGestor (não o clone desatualizado — este arquivo tinha o `.dark` correto e batido contra o que está em produção via o `curl` já feito hoje na reconciliação). Contraste calculado por luminância relativa (conversão HSL→RGB→luminância→ratio), a mesma fórmula que produziu os números já existentes no Brand Book — não estimativa visual.
3. **O que não cobri:** nenhum código foi escrito; não tenho a URL real do "Relay" (só a descrição do dono), então não rodei o extrator de DNA contra ela — todos os tokens propostos vêm de ativos já existentes e aprovados, não de medir a referência nova.
4. **O que o próximo precisa saber:** se o dono aprovar A ou C, o Product Designer (`cerebro-design-pro`) não precisa inventar paleta — os quatro tokens do modo escuro já existem em `Profgestor github/profgestor/src/index.css` (`.dark`), só nunca foram aplicados em tela nenhuma. O risco de transição visual entre hero escura e seção clara abaixo fica declarado, não resolvido.
5. **Lacuna encontrada:** nenhuma referência tipo "Relay" está catalogada em `referencias-padrao.md` — se o dono tiver a URL real (não só o print), vale rodar `extrair-referencia.js` contra ela e adicionar à biblioteca para não depender de descrição por texto da próxima vez.
