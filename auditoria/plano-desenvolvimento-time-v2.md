# Plano de Desenvolvimento do Time v2 — rumo a melhor do mundo em cada função, melhor empresa do Brasil no que realizamos

**Feito pelo Reitor, a pedido do dono, 2026-08-06.** Esta é a versão aprofundada do rascunho do mesmo dia (`plano-desenvolvimento-time-2026-08-06.md`) — não uma reformatação. Kernel de Rumelt aplicado de novo, mais rigorosamente: diagnóstico investigado célula por célula (não presumido), benchmark externo real com fonte, e "Teto nunca é final" aplicado a um caso concreto, não citado como slogan.

## Nota de correção — o arquivo existe, só não no caminho que eu tinha checado

Antes de escrever este documento, o coordenador apontou que `plano-crescimento-profgestor.md` teria sido escrito hoje pelo `ceo-orquestrador-agencia` e pediu para eu reconferir antes de declarar ausência. Minha primeira checagem (duas vezes, por métodos independentes — `Glob`/`Grep` e `find` via Bash) cobriu só a raiz de `Projeto-professor-William`, e lá o arquivo de fato não existe. Uma terceira busca, mais ampla (`find` na `C:\Users\usuario` inteira), achou o arquivo real: **`C:\Users\usuario\.claude\knowledge\plano-crescimento-profgestor.md`** — na Base de Conhecimento global, não no projeto. Erro meu de escopo de busca, não do coordenador nem de quem escreveu o arquivo; registrado aqui em vez de escondido (FASE 5.1). Lido por completo agora — Fase 0 (30 dias, primeiro cliente pagante externo), Fase 1 (R$5-10K/mês), Marcos 2-4 (R$20-30K → R$50-100K → milhões), riscos e pendências do dono — e incorporado abaixo onde é diretamente relevante ao desenvolvimento do time, junto com `meta-5-anos-profgestor.md` e `meta-10k-mensal.md`, que continuam sendo o diagnóstico de mercado por trás dele.

---

## 1. Diagnóstico real, célula por célula

Não em impressão — em número medido onde existe escala auditada (Mercado & Receita, Gestão), e em investigação real de código/arquivo onde não existia nenhuma (Marca & Produto, Engenharia). A v1 declarou essas duas últimas "sem baseline" e parou aí. Esta versão investigou de verdade — e o achado central é que **as duas células têm o problema espelhado invertido** de Mercado & Receita, não o mesmo problema.

### 1.1 Mercado & Receita — pesquisa rica, execução pobre (já medido, recapitulado)

11 especialistas, média **1,82/5** (auditoria 06/08, escala 0-10 de `mestres-marketing-agencia.md`). Quase todos travados em nível 2 por desenho, não por preguiça: nível 3+ exige campanha real rodando, regra do próprio dono (29/07), e até a manhã de hoje não existia pixel nem conta de anúncio ativa (resolvido hoje — ver `problemas.md` #9). O gargalo real deste time é **teste**, não conhecimento — está documentado e não muda nesta versão.

### 1.2 Gestão (Diretor) — 4 de 14 mestres, escala sem teto artificial (já medido, recapitulado)

Nível 4/5 sob a escala antiga, reclassificado como "4 de 14 mestres, Formação" sob a escala estendida (`gestao.md`, 08-06): níveis 1-5 exigem o currículo completo (14 mestres), níveis 6-10 exigem decisão de gestão real com resultado medido. Próximo mestre: Brooks (#4, *Mythical Man-Month*), caso real já disponível (39 skills, impulso de criar mais agentes).

### 1.3 Marca & Produto — o achado central: execução real, trilha de pesquisa pobre

**Isto é o oposto do problema de Mercado & Receita**, não a mesma lacuna com nome diferente. Investigação real, não presumida:

- **Evidência de execução em produção, verificada:** o Brand Book (`site/design-system/william-reis/BRAND-BOOK.md`, Direção C "Navy + Papel", aprovada pelo dono em 02/08) está **vivo em produção**. Confirmado por leitura direta do `globals.css` pelo `cerebro-integrador` em 05/08: os hex exatos do Brand Book (`#16233b` navy, `#b8842e` dourado, `#f6efe0` papel) estão em uso em toda página do site (Home/Sobre/Método/Contato), não é aspiração de documento. O site em si é real — 15 arquivos `.tsx` num Next.js 16 funcional, com `Reveal.tsx` e `Parallax.tsx` implementando literalmente o Motion DNA declarado no Brand Book (entrada por scroll, 300-400ms).
- **Mas quase nenhuma trilha de pesquisa registrada nos moldes da regra de ouro do Reitor** (framework nomeado + fonte + aplicação). Checando os 8 agentes da célula + o líder:
  - `cerebro-brand-scout` é a **exceção real e forte**: 5 execuções da Trilha I em `brand-inspiracao.md`, cada uma com DNA **medido por ferramenta** (`extrair-referencia.js`) em vez de descrito — Linear, Stripe, Notion, Basecamp, TutorCruncher/Teachworks, shadcn dashboard, Vercel, iProfe, Duolingo. Isto é evidência de confiança **mais alta** que citação de blog: é medição direta, não opinião de terceiro.
  - `cerebro-branding` tem 2 frameworks reais registrados com fonte (Byron Sharp, *How Brands Grow*; Ries & Trout, *Positioning*) — mas estão fisicamente em `mestres-marketing-agencia.md`, sob a célula **Mercado & Receita**, enquanto o organograma (`processo-empresa.md`) lista `branding` como membro de **Marca & Produto**. **Isto é uma inconsistência estrutural real, não uma opinião minha** — o mesmo agente aparece com endereço diferente em dois documentos oficiais. Não é meu papel resolver (estrutura de célula é categoria N1 não-delegável do Diretor, `decisoes.md`) — escalo como achado.
  - `cerebro-brand-director`, `cerebro-design-pro`, `cerebro-motion-designer`: têm **execução real e testada** (o Brand Book aplicado e o site no ar), mas **zero registro formal de framework+fonte** da forma que a regra de ouro exige. Isso expõe um paradoxo real do próprio sistema de avaliação: um agente pode entregar trabalho real, aprovado pelo dono, em produção, sem nunca ter "subido de nível" porque não citou de onde veio a técnica. A regra de ouro pune quem entrega sem documentar tanto quanto premia quem documenta sem entregar — os dois lados são inflação, mas hoje só o segundo está sendo medido.
  - `cerebro-ux-research`: nenhuma evidência de pesquisa formal de usuário conduzida em nenhum artefato consultado. Esta é lacuna genuína, diferente das anteriores — não há nem execução nem citação.
  - `cerebro-design-system-manager` / `cerebro-component-library-manager`: `component-library.md` tem 25 linhas, sem crescimento na auditoria de hoje (comparado a `design-patterns.md` +22, `brand-inspiracao.md` +39 no mesmo dia). A função de guardião do design system não tem evidência de ter sido exercida — o que importa porque é justamente o papel que deveria ter impedido o defeito abaixo.
  - `cerebro-reverse-engineering`: o trabalho que ele nominalmente faz (extrair princípio de referência externa) está, na prática, sendo feito pelo `brand-scout` via `extrair-referencia.js` — sobreposição a esclarecer com o Diretor, mesma categoria da inconsistência do `branding`.
- **Defeito real documentado, precedente de risco:** `processo-empresa.md` (ORGANOGRAMA) e `qualidade-lean.md` citam o mesmo caso — *"a paleta navy foi aplicada dessaturando os estados, e nenhum auditor barrou antes de o dono ver"*. Investiguei se isso é do ciclo atual do Brand Book ou de um ciclo anterior (antes das 4 rodadas de redesign rejeitadas de 20/07) — **a evidência disponível não permite datar com certeza**, e digo isso em vez de supor. O que é fato verificado: é citado como precedente real de risco, e a linha de auditoria que deveria pegar esse tipo de erro **ainda não está afiada** (próximo ponto).
- **A linha de auditoria — risco estrutural compartilhado com a Engenharia, não exclusivo de uma célula.** `design-critic`, `accessibility` e `qa-automation` respondem ao Diretor por fora das duas células justamente para poder barrá-las. Hoje só `design-critic` tem 1 registro real (Heurísticas de Nielsen, `qualidade-lean.md`, 05/08, aplicado retroativamente ao próprio caso da dessaturação). `accessibility` e `qa-automation` seguem em **zero registros** — texto do próprio arquivo confirma: *"faltam cerebro-accessibility e cerebro-qa-automation"*. Isto significa que o portão que existe no papel para impedir o próximo defeito de cor/contraste ainda não está pronto pra pegar nada.

### 1.4 Engenharia — o achado central: execução real pequena, zero instrumentação de qualidade

Investigação direta do código, não estimativa:

- **`site/package.json` lido linha por linha**: Next.js 16.2.10, React 19.2.4, Tailwind 4 — stack real, moderna, em produção. **Zero framework de teste como dependência** (nenhum Jest, Vitest, Playwright, Cypress no `package.json`). Busca por `.github/workflows` na raiz do projeto e dentro de `site/`: **não existe**, confirmado por `Glob` (ausência real, não estimativa truncada). Ou seja: existe entrega, não existe rede de segurança nenhuma atrás dela.
- **`cerebro-performance`**: nenhum número de Core Web Vitals/Lighthouse foi encontrado em nenhum arquivo da base de conhecimento consultada. A própria regra da FASE 2 do processo (*"número real, nunca estimativa"*) ainda não foi cumprida uma vez sequer por este especialista.
- **ProfGestor não é código que a célula controla diretamente.** É construído e mantido via Lovable (AI app builder hospedado) — as edições passam pelo agente do Lovable via chat, não por commit direto do nosso time. Isto não é hipótese: é o que o próprio incidente real documentado em `problemas.md` (Resolvidos) prova — um push direto pro GitHub não atualizou o deploy do Lovable, e só funcionou quando a instrução foi mandada ao agente do Lovable via `send_message`. Isso é um limite estrutural real da autoridade da célula Engenharia sobre esse produto específico, relevante para o que "melhor do mundo em engenharia" pode significar aqui (seção 3).
- **Bugs reais em produção, todos corrigidos reativamente, nenhum pego por teste ou monitoramento prévio:** e-mail de confirmação de contrato quebrado no ProfGestor (*"Falha no email"*, achado ao vivo, ainda sem correção confirmada); `.env` removido do versionamento derrubou produção inteira até reversão manual (FASE 3, `processo-empresa.md`); pixel do Meta não instalava por push direto ao GitHub (resolvido 06/08). Três incidentes reais, zero deles detectado antes de acontecer.
- **Este bug de e-mail já tem dono e critério definidos** — `plano-crescimento-profgestor.md` (Fase 0, tabela de entregas por célula) atribui a `cerebro-product-architect` corrigi-lo **na causa raiz** (verificar configuração real do provedor de envio — domínio, API key, DKIM/SPF — não só reenviar) como pré-condição para o primeiro cliente pagante externo. Não é uma tarefa nova deste documento — é reforço de que a Engenharia já tem prazo real (Fase 0, 30 dias) amarrado a esse defeito, não um item solto no quadro de problemas.
- **`cerebro-automacao` (n8n):** criado em 04/08, célula Engenharia, **nenhum workflow real rodado ainda** (`decisoes.md`, revisão pendente). Nível 1 honesto — agente recém-nascido, não um caso de estagnação.
- **`cerebro-dominios`:** bloqueado por decisão de orçamento do dono (domínio `williammarilioreis.com.br` não registrado, `problemas.md` #11) — não é falta de capacidade da célula, é pendência explicitamente marcada como dele.
- **Backend Architect, Database Optimizer, Software Architect, DevOps Automator, SRE** (camada de escala da célula): **nenhuma evidência de terem sido acionados uma vez sequer** em qualquer arquivo consultado. Isto não é "nível 0 de maturidade" — é "ainda não existe trabalho no projeto que justifique escala suficiente para acioná-los". Distinção honesta: não confundir "nunca usado por não precisar ainda" com "nunca usado por estar raso".

### 1.5 Duas lacunas estruturais a escalar ao Diretor, não a resolver aqui

1. **`cerebro-branding` tem endereço duplo** — listado em Marca & Produto no organograma, registrado e nivelado em Mercado & Receita em `mestres-marketing-agencia.md`. Estrutura de célula é categoria N1 não-delegável do Diretor (`decisoes.md`) — o Reitor expõe, não decide.
2. **A linha de auditoria (accessibility, qa-automation) está sem uso real há mais tempo do que as duas células que ela deveria auditar.** Isso é um risco maior que qualquer nível baixo de especialista isolado, porque um portão vazio deixa passar defeito pras duas células ao mesmo tempo.

---

## 2. Benchmark externo real, com fonte, aplicado ao nosso contexto

Pesquisado agora (WebSearch/WebFetch), não de memória. Protocolo das 5 perguntas (`processo-empresa.md`, FASE 5.5) resumido em cada um — princípio, decisão real, erro evitado, adaptação ao nosso ecossistema, regra permanente.

### 2.1 Artsy Engineering Career Ladder (open source, GitHub)

**Princípio:** progressão por **escopo de impacto crescente** — de "self" (IC2) a "equipe" (IC4-5) a "múltiplas equipes" (IC6) a "organização inteira" (IC7-8) — avaliada em **4 dimensões**: Knowledge Leadership, Impact, Influence, Discretion. Cita explicitamente: *"increased mastery is a necessary condition but isn't sufficient to expand impact"* — domínio técnico sozinho não promove, influência organizacional importa igualmente.

**Decisão real por trás:** um framework de nível público, versionado no GitHub, para que qualquer engenheiro veja exatamente o que falta — nada avaliado por impressão.

**Erro que evita:** medir "maturidade" só por acúmulo de conhecimento técnico, ignorando se aquele conhecimento afeta algo além do próprio trabalho.

**Adaptação ao nosso ecossistema:** a rubrica 0-10 que já usamos (`mestres-marketing-agencia.md`) mede **profundidade de conhecimento e teste real**, mas não mede **escopo**. Um `cerebro-brand-director` que aplica o Brand Book só no site do William está num escopo diferente de um que o aplicasse consistentemente em múltiplos projetos (site + ProfGestor + futuros). Vou incorporar escopo como critério explícito na extensão da rubrica (seção 4).

**Regra permanente:** ao avaliar "melhor do mundo" numa função de Engenharia ou Marca & Produto, perguntar não só "quão fundo" mas "quão largo" — quantos projetos/decisões reais aquele padrão já sustentou, não um só.

Fonte: [github.com/artsy/README — careers/ladder.md](https://github.com/artsy/README/blob/main/careers/ladder.md).

### 2.2 GitLab Engineering Career Framework (handbook público)

**Princípio:** competência documentada por nível, **publicamente auditável** — qualquer pessoa, dentro ou fora da empresa, pode ler exatamente o que separa Intermediate de Senior de Staff.

**Decisão real por trás:** transparência radical como valor de empresa remota — GitLab decidiu que esconder o critério de promoção cria política, não mérito.

**Erro que evita:** critério de nível que só existe na cabeça de quem avalia, mudando sem aviso.

**Adaptação ao nosso ecossistema:** já é exatamente como operamos — `mestres-marketing-agencia.md`, `gestao.md` e (a partir deste documento) a rubrica de Marca & Produto/Engenharia vivem em arquivo aberto, auditável pela própria auditoria diária. O benchmark confirma que isso não é excesso de burocracia nosso, é padrão de empresa de referência remota.

**Regra permanente:** nenhuma escala de maturidade deste ecossistema pode voltar a existir só em memória de conversa — sempre em arquivo, sempre auditável por script.

Fonte: [handbook.gitlab.com/handbook/engineering/careers](https://handbook.gitlab.com/handbook/engineering/careers/).

### 2.3 T-shaped skills — origem McKinsey (anos 1980) e popularização IDEO/Tim Brown (2010)

**Princípio:** a barra vertical do "T" é profundidade numa especialidade; a barra horizontal é capacidade de colaborar e aplicar conhecimento fora da própria especialidade. Origem documentada em consultoria (McKinsey, anos 1980, formalizado por David Guest em 1991); popularizado como modelo de time criativo por Tim Brown, CEO da IDEO, em 2010 — ele descreve equipes de design montadas deliberadamente com "T-shaped stars": profundidade real + empatia genuína pela especialidade do colega ao lado.

**Decisão real por trás:** a IDEO avalia candidato por **largura e profundidade juntas** — especialista raso em tudo, ou profundo sem conseguir colaborar, os dois são rejeitados.

**Erro que evita:** montar time de silos profundos que não conversam, ou de generalistas que não entregam nada de padrão mundial em nenhuma frente.

**Adaptação ao nosso ecossistema:** é literalmente o desenho do nosso organograma — célula com líder + especialistas profundos, arbitrando entre si sem subir tudo ao Diretor. Nunca nomeamos esse princípio explicitamente; vale nomear, porque explica *por que* a estrutura de célula é a certa, não só *que* ela existe.

**Regra permanente:** ao formar um agente novo (matrícula, FASE 5.3), a trilha dele precisa cobrir tanto a profundidade da função quanto pelo menos 1 ponto de colaboração nomeado com a célula vizinha — hoje as 6 matrículas cobrem profundidade, nenhuma cobre a barra horizontal do T explicitamente.

Fontes: [chiefexecutive.net — IDEO CEO Tim Brown: T-Shaped Stars](https://chiefexecutive.net/ideo-ceo-tim-brown-t-shaped-stars-the-backbone-of-ideoaes-collaborative-culture__trashed/); [en.wikipedia.org/wiki/T-shaped_skills](https://en.wikipedia.org/wiki/T-shaped_skills).

### 2.4 T-shaped Marketer — Rand Fishkin (2013) e Brian Balfour (HubSpot)

**Princípio:** Rand Fishkin (fundador da Moz) formalizou visualmente o "T-shaped web marketer" em 2013 — base ampla e rasa em vários canais, profundidade real em 1-2. Brian Balfour (então VP de Growth da HubSpot) transformou isso num caminho de aprendizado concreto: **Base Layer** (fundamentos) → **Marketing Foundation Layer** → **Channel Expertise** (profundidade real, com dado de canal específico).

**Decisão real por trás:** Balfour recomenda ir largo o suficiente pra colaborar, e só então ir fundo, incrementalmente, em poucos canais — não tentar ser profundo em tudo ao mesmo tempo.

**Erro que evita:** achar que "aprender mais marketing" em abstrato sobe alguém de nível — sem escolher e testar canal específico, a profundidade nunca vira competência real.

**Adaptação ao nosso ecossistema — convergência real, não framework novo a adotar:** a escala 0-10 de `mestres-marketing-agencia.md` **já é** essa progressão, sem ter sido desenhada citando Fishkin/Balfour: nível 1-2 é Base Layer + Foundation Layer (framework geral, pesquisa ampla); nível 3+ é Channel Expertise provada com campanha real specific (não abstrata). Isto não é uma recomendação de mudar nada — é a confirmação externa de que a escala que já auditamos está desenhada do jeito certo. Vale registrar essa convergência para não reinventar a escala por vaidade de "ter benchmark novo".

Fontes: [sparktoro.com/blog/the-t-shaped-web-marketer](https://sparktoro.com/blog/the-t-shaped-web-marketer/); [smartinsights.com — Are you a T-Shaped Marketer?](https://www.smartinsights.com/managing-digital-marketing/personal-career-development/csimon-swan-t-shaped-marketer/).

### 2.5 Pentagram — modelo de seleção de sócios (Eye on Design / AIGA)

**Princípio:** Pentagram tem 24 sócios, todos donos iguais e designers praticantes (não hierarquia executiva sobre designer júnior). Um novo sócio é avaliado como **"pessoa inteira"** — não para preencher lacuna de disciplina — ao longo de **2 a 3 anos** de observação real de trabalho, com decisão final por **consenso unânime**: *"one vote against and it's over, truly. We've seen it happen"* (Abbott Miller, sócio).

**Decisão real por trás:** recusar o modelo hierárquico convencional (CEO decide, designer executa) em favor de julgamento coletivo de pares, todos com padrão equivalente de excelência.

**Erro que evita:** promover por tempo de casa ou por preencher vaga, em vez de por qualidade de julgamento provada ao longo do tempo.

**Adaptação ao nosso ecossistema:** nosso equivalente estrutural de "consenso unânime de sócios" é a **linha de auditoria** (`design-critic` + `accessibility` + `qa-automation`) — os três precisam concordar, com critério nomeado, antes de uma entrega de Marca & Produto ou Engenharia ser considerada de padrão mundial. Isso é exatamente o que a seção 1.5 já expôs como incompleto: com 2 dos 3 auditores ainda sem registro real, não existe "consenso" possível hoje — só a opinião de quem construiu, autoaprovando o próprio trabalho.

**Regra permanente:** nenhuma entrega de Marca & Produto ou Engenharia é "padrão mundial" só porque o dono aprovou visualmente — precisa também ter passado pelos 3 auditores, cada um com critério nomeado, não estimado.

Fonte: [eyeondesign.aiga.org — "Epically Long": How Pentagram Chooses Its New Partners](https://eyeondesign.aiga.org/epically-long-how-pentagram-chooses-its-new-partners/).

### 2.6 McKinsey — modelo de aprendizado no fluxo do trabalho (apprenticeship distribuído)

**Princípio:** McKinsey desenvolve consultores por **mentoria estruturada** — cada pessoa tem um "development group leader" (revisão semestral formal) e mentores por tarefa ("task-based mentors") no dia a dia, não só treinamento formal isolado. O modelo é "up or out": quem não avança para o próximo nível num prazo razoável recebe ajuda para sair.

**Decisão real por trás:** aprendizado acontece **no trabalho real**, com revisão periódica formal — não em curso isolado sem aplicação.

**Erro que evita:** deixar desenvolvimento de pessoa sênior sem nenhuma cadência de revisão, avaliando só quando alguém lembra de perguntar.

**Adaptação ao nosso ecossistema, com uma exclusão deliberada:** o Reitor já faz, informalmente, o papel do "development group leader" do Diretor — mas hoje isso acontece **quando o dono pergunta** ("e o diretor?", 06/08), não numa cadência fixa. Vou propor formalizar isso (seção 5). **Não adoto "up or out"** — não se aplica: o Diretor não é peça substituível de um pool de talento, é o único agente naquele papel; a analogia certa é "sempre in, sempre subindo", não "suba ou saia".

**Regra permanente:** a avaliação do Diretor pelo Reitor passa a ter cadência fixa declarada, não só reativa a pergunta do dono (concreto na seção 5).

Fonte: [mckinsey.com/careers — Mentorship at McKinsey](https://www.mckinsey.com/careers/meet-our-people/careers-blog/mentorship).

---

## 3. O que "melhor do mundo" significa, operacionalizado por tipo de função

Não é aspiração solta — cada tipo de função tem critério diferente porque o que conta como excelência é diferente. Amarrado ao benchmark da seção 2.

### 3.1 Design (Marca & Produto)

Não é "acumular framework registrado". É: **(a)** toda decisão visual defensável por um heurístico nomeado (Nielsen, já usado 1x por `design-critic`), nunca por "gosto"; **(b)** zero retrabalho depois da aprovação do dono — o defeito de dessaturação (1.3) é exatamente o tipo de coisa que não pode se repetir; **(c)** trilha de pesquisa citada com framework+fonte, não só executada em silêncio (o paradoxo nomeado em 1.3 — hoje entregamos sem documentar a origem da técnica); **(d)** escopo crescente (Artsy, 2.1) — o mesmo padrão sustentando mais de 1 projeto real, não só o site do William.

### 3.2 Engenharia

Não é "código bonito". É: **(a)** escopo crescente por impacto (Artsy) — de "1 componente" a "1 projeto" a "múltiplos projetos usando o mesmo padrão", medido pelo que já está em `design-system.md`/`component-library.md` sendo reaproveitado, não reescrito; **(b)** número real medido, nunca estimado — Core Web Vitals de verdade via Lighthouse, taxa de incidente de produção contada, não "parece rápido"; **(c)** teste automatizado existindo e rodando — hoje zero, esse é o critério mais urgente e mais barato de destravar (seção 5); **(d)** honestidade sobre limite de arquitetura — quando o produto (ProfGestor) não é código nosso e sim de uma plataforma terceira (Lovable), "melhor do mundo em engenharia" inclui saber operar bem *dentro* desse limite (via chat estruturado ao agente do Lovable, não via git direto — lição já aprendida do incidente do pixel), não fingir controle que não existe.

### 3.3 Marketing / Tráfego (Mercado & Receita)

Já operacionalizado corretamente pela escala existente — a convergência com o T-shaped Marketer (2.4) confirma isso, não muda nada. Nível 1-2 é Base+Foundation (framework geral); nível 3+ é Channel Expertise real (campanha rodando, dado de canal específico). Nenhuma mudança de critério aqui — só a confirmação externa de que o desenho já era o certo.

### 3.4 Gestão (Diretor)

Já operacionalizado por `gestao.md`: nível 1-5 é Formação (14 mestres, currículo completo como piso, não os 5 primeiros); nível 6-10 é Aplicação Real (decisão de gestão de verdade, com resultado medido). O modelo McKinsey (2.6) reforça o "porquê": aprendizado que não acontece no fluxo real do trabalho, revisado com cadência, não conta.

---

## 4. Rubrica estendida — Marca & Produto e Engenharia (extensão, não escala nova)

**Regra seguida à risca:** não criar escala concorrente com as duas já auditadas (`mestres-marketing-agencia.md`, `gestao.md`) — reprovado antes numa proposta anterior por essa exata razão (`decisoes.md`, 06/08). O que segue é a **mesma rubrica 0-10** de `mestres-marketing-agencia.md`, com "campanha real" substituído pelo equivalente real de cada célula: **entrega em produção, aprovada pelo dono, sem retrabalho**.

| Nível | O que significa (Mercado & Receita, referência) | Equivalente em Marca & Produto / Engenharia |
|---|---|---|
| 0 | Template genérico | Agente sem framework registrado nem entrega real |
| 1 | 1 framework real com fonte | 1 técnica/padrão registrado com fonte, aplicado a um caso nosso |
| 2 | Múltiplos frameworks / trilha ativa | Trilha de pesquisa ativa (measured, como `brand-inspiracao.md`) OU múltiplos padrões registrados |
| 3 | Testado em projeto real, resultado observável | **Entrega real em produção, aprovada pelo dono, passada pela linha de auditoria (2.5)** |
| 4 | Pronto pra competir nacionalmente | Processo próprio replicável + múltiplos padrões + testado + os 3 auditores validam com critério nomeado |
| 5 | Referência internacional | Nível 4 + escopo em múltiplos projetos (Artsy, 2.1), não só 1 |
| 6-9 | Múltiplas entregas reais comparáveis | Mesmo padrão sustentando 3+ decisões reais, com histórico próprio de acerto/erro |
| 10 | Autoridade citada externamente | Padrão nosso citado ou copiado por referência externa ao ecossistema |

### Níveis reais de hoje, aplicando a rubrica com a evidência da seção 1 — não estimativa

**Marca & Produto:**

| Especialista | Nível hoje | Evidência | Trava no próximo degrau |
|---|---|---|---|
| `cerebro-brand-director` | **3** | Brand Book aprovado, tokens vivos em produção (verificado por leitura direta) | Nível 4 exige os 3 auditores validando com critério nomeado — hoje só `design-critic` tem 1 registro |
| `cerebro-brand-scout` | **2** | 5 execuções medidas por ferramenta em `brand-inspiracao.md`, nunca descritas | Nível 3 exige uma decisão real de projeto ter usado a medição pra decidir algo que foi a produção (ex: paleta do ProfGestor) — ainda não aconteceu |
| `cerebro-branding` | **2** (já registrado em `mestres-marketing-agencia.md`) | Byron Sharp + Ries & Trout, com fonte e aplicação | Bloqueado por lacuna estrutural (1.5) até o Diretor resolver o endereço de célula |
| `cerebro-design-pro` | **0** formal / execução real sem registro | Site inteiro em produção, mas zero framework citado com fonte | Registrar 1 framework nomeado (ex: os princípios de hierarquia visual usados no layout real) — é trabalho de 1 execução da trilha, não de meses |
| `cerebro-motion-designer` | **0** formal / execução real sem registro | `Reveal.tsx`/`Parallax.tsx` implementam o Motion DNA do Brand Book | Mesmo caminho do design-pro |
| `cerebro-ux-research` | **0** | Nenhuma pesquisa formal encontrada | Lacuna genuína — nem execução nem citação |
| `cerebro-design-system-manager` | **0-1** | `component-library.md` quase vazio, função de guardião não demonstrada | Auditar 1 tela real contra o Design System e registrar o que achou |
| `cerebro-component-library-manager` | **0** | Idem acima | Catalogar os componentes reais já existentes no site (`Header`, `Footer`, `Badge`, `WhatsAppButton`) — eles já existem, só não estão catalogados |

**Engenharia:**

| Especialista | Nível hoje | Evidência | Trava no próximo degrau |
|---|---|---|---|
| `cerebro-product-architect` | **3** | Site em produção, mas com 1 incidente real de produção já registrado (`.env`) | Nível 4 exige zero incidente por período definido — ainda não decorreu tempo suficiente desde a correção |
| `cerebro-performance` | **0** | Nenhum número real de Core Web Vitals já gerado | 1 execução de Lighthouse real no site do William — mais barato de destravar do que parece, zero dependência externa |
| `cerebro-automacao` | **1** | Criado 04/08, zero workflow real ainda | 1º workflow real rodado (n8n), com execução mostrada, não configuração salva |
| `cerebro-dominios` | Bloqueado | Domínio pendente de orçamento do dono | Não é gargalo da célula — decisão pendente já marcada em `problemas.md` #11 |
| `cerebro-saas` | Não aplicável a código próprio | ProfGestor é operado via Lovable, não código local nosso | Redefinir o que "excelência" significa aqui — não é escrever mais código, é operar bem dentro do limite da plataforma (3.2) |
| Backend Architect / DB Optimizer / Software Architect / DevOps / SRE | Nunca acionados | Nenhuma evidência de uso | Não é estagnação — é ainda não ter escala que justifique. Não forçar uso artificial só para gerar nível |

---

## 5. "Teto nunca é final" — aplicado a um caso real, não um slogan

**Achado que a investigação revelou: já aconteceu uma vez, antes mesmo de a regra existir.** `mestres-copy.md` (Trilha E) cobriu os 13 mestres curados da copy inteiros num único dia, 2026-07-28, e a própria trilha reconheceu sozinha, sem ninguém instruir: *"os 13 nomes principais estão cobertos — a trilha entra em modo aprofundamento"*. Isso é exatamente o padrão que a regra "Teto nunca é final" viria a formalizar 9 dias depois (06/08) — só que instintivo, sem o passo formal de acionar `cerebro-analista-mercado` por benchmark externo antes de definir o próximo degrau.

**Verificação de que não ficou só na frase:** a auditoria de hoje (06/08) mostra `mestres-copy.md` com **+11 linhas** no dia — a trilha de aprofundamento está viva, não parada como "modo aprofundamento" anunciado e nunca executado (o mesmo modo de falha já catalogado com a Trilha F). Isso é prova real, não presumida.

**Aplicando a regra retroativamente, com rigor:**

1. **Função real do `cerebro-copywriter`:** escrever copy que converte um público específico, não genérico — nível de consciência (Schwartz), mercado faminto (Halbert), equação de valor (Hormozi) já cobertos entre os 13.
2. **Benchmark do próximo degrau:** o "modo aprofundamento" já em curso deveria buscar, com prioridade, o que falta explicitamente nomeado no próprio arquivo — a nota já registrada em Schwartz cita "Market Sophistication" (5 estágios de ceticismo do mercado) como "candidato a revisita quando a Trilha E entrar em modo aprofundamento". Isso não foi feito ainda, segundo a leitura de hoje.
3. **Próximo degrau concreto, não "continue estudando":** a Trilha E deve fechar **Market Sophistication** (Schwartz) como próximo item nomeado do aprofundamento — não é framework novo caçado ao acaso, é uma lacuna que o próprio arquivo já apontou e nunca fechou.
4. **Isto vira parte permanente do currículo** — registrado aqui e a ser refletido em `mestres-copy.md` pela Trilha E na próxima execução, não como relatório avulso.

---

## 6. Como isso sustenta a meta de 5 anos e "melhor empresa do Brasil"

Mesma ambição de `meta-5-anos-profgestor.md`, agora amarrada às 4 células de verdade — e ao caminho real e faseado que `plano-crescimento-profgestor.md` já desenhou (Fase 0 → Fase 1 → Marcos 2-4), não só a Mercado & Receita como a v1 fazia:

- **Mercado & Receita** decide o que vender e pra quem — já amarrado (v1), e a Fase 0 do plano de crescimento já cita `cerebro-copywriter` e `cerebro-trafego` com entrega concreta nos primeiros 30 dias (copy validada pelos 5 crivos da FASE 5.2; teste de aquisição orgânica pela rede pessoal do William, tráfego pago fora de escopo até a landing converter organicamente).
- **Marca & Produto**, pelo achado desta versão, precisa deixar de ser "execução sem documentação" — porque "melhor empresa do Brasil" exige que a identidade e a interface sejam **replicáveis e citáveis**, não só bonitas uma vez. Isso já é literalmente o próximo passo real: a Fase 0 do plano de crescimento coloca `cerebro-brand-director` como **primeira entrega, pré-requisito de tudo o mais** (Brand Book com 3 direções pro ProfGestor, hoje inexistente — o produto ainda usa o nome genérico "Professor Pro" sem identidade própria). Sem a trilha de pesquisa citada que a seção 1.3 aponta como lacuna, essa nova identidade corre o risco de repetir o mesmo padrão do site do William: bem executada, mal documentada.
- **Engenharia**, pelo achado desta versão, precisa resolver a dependência total do ProfGestor de uma plataforma terceira (Lovable) antes que "faturando milhões" seja um objetivo tecnicamente sustentável — e o próprio plano de crescimento já nomeia o risco 4 (*"o bug de e-mail é só o bug conhecido — pode haver outros não descobertos"*) como o tipo de coisa que queima a rede pessoal do William, que não se recompra com verba de anúncio. Não é decisão a tomar agora (é categoria de investimento, N0, dono+Diretor), mas é o tipo de limite que precisa estar nomeado num plano que fala de 5 anos, não escondido.
- **Gestão** sustenta as três de cima com julgamento cada vez mais formado — já amarrado (v1 e `gestao.md`).

**Os marcos do plano de crescimento já operacionalizam "melhor empresa do Brasil" em número, não em slogan** — vale citar aqui porque amarra diretamente ao desenvolvimento do time: Marco 4 (*"faturando milhões"*) exige explicitamente, entre suas condições de verdade, que **"cada célula da agência opere com processo próprio testado em campanha real, não só framework de pesquisa — nível 4+ na escada de maturidade"**. Ou seja: o próprio plano de crescimento do produto já depende do resultado deste plano de desenvolvimento do time — os dois documentos não são paralelos, um é pré-condição do outro.

---

## 7. Cronograma real — responsável e prazo, sem prometer decisão do dono

| Quem | Ação concreta | Prazo |
|---|---|---|
| Reitor | Registrar 1 framework nomeado de `design-pro` e `motion-designer` (destravar o paradoxo execução-sem-citação da seção 4) | 13/08 |
| Reitor | Escalar ao Diretor a inconsistência de célula do `cerebro-branding` (endereço duplo, seção 1.5) | Imediato, próxima interação com o Diretor |
| Reitor | Escalar ao Diretor o risco da linha de auditoria vazia (`accessibility`/`qa-automation` com zero registros, seção 1.3/2.5) | Imediato — é risco maior que qualquer nível baixo isolado |
| Reitor | Fechar Market Sophistication (Schwartz) como próximo item nomeado do aprofundamento da Trilha E (seção 5) | Próxima execução da Trilha E |
| Reitor | Formalizar cadência fixa de reavaliação do Diretor (benchmark McKinsey, seção 2.6) — proposta: a cada 15 dias, alinhado ao ciclo já existente do Artifact "Organograma" | 20/08 |
| `cerebro-performance` | 1ª execução real de Lighthouse no site do William, número registrado (não estimado) | 13/08 — é o item mais barato de destravar de toda a Engenharia |
| Diretor | Decidir o endereço de célula do `cerebro-branding` (Marca & Produto ou Mercado & Receita, não os dois) | A definir com o Diretor |
| Diretor | Priorizar `cerebro-accessibility`/`cerebro-qa-automation` no rodízio da linha de auditoria (já é regra da Trilha K — "próximo da fila", `qualidade-lean.md`) — cobrar que aconteça, não redefinir a fila | Próximas 2 execuções da Trilha K |
| Dono | Decisão de investimento se/quando migrar o ProfGestor pra fora do Lovable — **não decidido aqui, categoria N0 (Produção), só nomeado como limite real** | Sem prazo — pendência dele, marcada, não escondida |
| Dono + Diretor | As 5 pendências já registradas em `plano-crescimento-profgestor.md` (direção visual do Brand Book do ProfGestor, preço final, modelo de cobrança, quando investir em tráfego pago, contratação do Marco 3) — **não repetidas aqui**, só referenciadas para não haver dois lugares cobrando a mesma decisão | Conforme já marcado naquele arquivo |

---

## 8. Revisão

**06/09/2026**, mesma data de v1 e do plano de crescimento do ProfGestor — junto da pergunta original ("o time subiu de verdade, com prova?"), agora também: a rubrica estendida de Marca & Produto e Engenharia registrou pelo menos 1 subida real de nível cada, ou os números desta seção 4 são os mesmos de hoje?
