---
task: "Create Instagram Feed"
order: 2
input: |
  - chosen_hook: Gancho escolhido pelo usuário (Hook A, B ou C de generate-hooks.md)
  - research_brief: Fato + mito + dúvida da semana, produzido por Rita Referência
output: |
  - carousel: Slides completos (8-10), legenda e hashtags no formato instagram-feed.md
---

# Create Instagram Feed

Escreve o carrossel completo do Instagram Feed a partir do gancho já escolhido pelo usuário, no formato Problema → Solução ou Mito vs Realidade — a escolha do formato segue diretamente do gancho, nunca é decidida de forma independente.

## Process

1. **Confirmar o gancho escolhido** e definir o formato de carrossel mais adequado a ele: Problema → Solução para dor + oferta, Mito vs Realidade para desconstruir uma crença comum.
2. **Escrever os slides (8-10)** seguindo a hierarquia de duas camadas de `_opensquad/core/best-practices/instagram-feed.md`: headline grande (afirmação principal) + texto de apoio (dado, contexto, elaboração), 40-80 palavras por slide, alternando background claro/escuro/accent.
3. **Escrever a legenda**: gancho nos primeiros 125 caracteres, corpo com quebras de linha curtas, fechando com CTA único e específico (mensagem no WhatsApp ou comentário).
4. **Selecionar 5-15 hashtags**, misturando nicho/específico e alcance médio, sem hashtag banida ou genérica demais.
5. **Rodar o Copy Stress Test** antes de entregar: cortar 15-25% do texto, checar clichês banidos, confirmar que resistiria a um leitor cético.

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

> Use as quality reference, not as rigid template.

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

## Quality Criteria

- [ ] Formato de carrossel coerente com o gancho escolhido (Problema → Solução ou Mito vs Realidade)
- [ ] 8-10 slides, cada um entre 40-80 palavras (headline + texto de apoio)
- [ ] Legenda com gancho nos primeiros 125 caracteres e CTA único ao final
- [ ] 5-15 hashtags relevantes, sem spam

## Veto Conditions

Reject and redo if ANY are true:
1. O carrossel foi escrito sem o gancho ter sido confirmado pelo usuário antes.
2. Algum slide fica fora da faixa de 40-80 palavras ou a legenda não tem CTA único e específico.
