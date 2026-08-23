---
execution: inline
agent: carlos-carrossel
format: instagram-feed
inputFile: squads/posts-semanais-instagram/output/research-brief.md
outputFile: squads/posts-semanais-instagram/output/carrossel.md
---

# Step 3: Redigir Carrossel

## Context Loading

Load these files before executing:
- `squads/posts-semanais-instagram/output/research-brief.md` — brief de pesquisa produzido por Rita Referência (fato + mito + dúvida)
- `squads/posts-semanais-instagram/pipeline/data/tone-of-voice.md` — os 6 tons possíveis; apresentar ao usuário e aguardar escolha antes de escrever
- `_opensquad/_memory/company.md` — tom de marca e público-alvo da mentoria
- `squads/posts-semanais-instagram/agents/carlos-carrossel/tasks/generate-hooks.md` e `create-instagram-feed.md` — processo e formato exato das duas fases desta etapa

## Instructions

### Process

1. Apresentar as opções de tom (`tone-of-voice.md`), recomendar um tom padrão (Caloroso e Acolhedor) com justificativa, e aguardar a escolha do usuário.
2. Gerar 3 ganchos (Hook A/B/C) com driver psicológico e formato estrutural diferentes, cada um com uma frase de rationale, e aguardar a escolha do usuário — nunca escrever o corpo antes dessa confirmação.
3. Com o gancho escolhido, definir o formato de carrossel (Problema → Solução ou Mito vs Realidade) e escrever os 8-10 slides (40-80 palavras cada) seguindo `instagram-feed.md`.
4. Escrever a legenda (gancho nos primeiros 125 caracteres, CTA único ao final) e selecionar 5-15 hashtags.
5. Rodar o Copy Stress Test (cortar 15-25% do texto, checar clichês banidos) antes de salvar em `carrossel.md`.

## Output Format

```
=== FORMATO ===
[Problema → Solução | Mito vs Realidade]

=== SLIDES ===
Slide 1 (Capa):
  Título: "..."
  Background: [claro/escuro/accent]

Slide 2 ([papel]):
  Headline: "..."
  Texto de apoio: "..."
  Background: [claro/escuro/accent]

... (até slide 8-10)

Slide N (CTA):
  Texto: "..."
  CTA: "..."

=== LEGENDA ===
[gancho + corpo + CTA]

=== HASHTAGS ===
#tag1 #tag2 #tag3 #tag4 #tag5
```

## Output Example

```
=== FORMATO ===
Mito vs Realidade

=== SLIDES ===
Slide 1 (Capa):
  Título: "Ele só precisa praticar mais." 4 mitos sobre dificuldade de leitura que atrasam a ajuda certa.
  Background: escuro, alto contraste

Slide 2 (Mito 1):
  Headline: Mito: "É só imaturidade, vai passar sozinho."
  Texto de apoio: Esperar pode agravar o quadro. Quanto mais cedo a dificuldade é identificada e trabalhada, melhores os resultados — não é sobre esperar a criança "amadurecer" sozinha.
  Background: claro

Slide 3 (Mito 2):
  Headline: Mito: "Método fônico é decoreba, não ensina a entender o texto."
  Texto de apoio: A decodificação fluente é o que libera a memória da criança para focar no significado. Sem decodificar bem, sobra pouca energia para compreender.
  Background: accent

(... continua até slide 8-9 ...)

Slide 9 (CTA):
  Texto: Reconheceu algum desses sinais no seu filho?
  CTA: Manda uma mensagem — vamos conversar sobre o caso dele.

=== LEGENDA ===
"Ele só precisa praticar mais." Se você já ouviu isso sobre a leitura do seu filho, esse post é pra você.

Existem pelo menos 4 mitos que atrasam a ajuda certa — e o mais perigoso é achar que dá pra esperar.

Reconheceu algum desses sinais? Manda mensagem, vamos conversar sobre o caso do seu filho.

=== HASHTAGS ===
#dificuldadedeleitura #metodofonico #alfabetizacao #paisdodialecio #dislexiainfantil
```

## Veto Conditions

Reject and redo if ANY of these are true:
1. O corpo do carrossel foi escrito antes do usuário escolher entre os 3 ganchos apresentados.
2. Algum slide fica fora da faixa de 40-80 palavras, ou a legenda não tem CTA único e específico.

## Quality Criteria

- [ ] 3 hooks apresentados e aprovados antes do corpo ser escrito
- [ ] Cada slide entre 40-80 palavras
- [ ] Legenda com CTA único e específico
- [ ] 5-15 hashtags
