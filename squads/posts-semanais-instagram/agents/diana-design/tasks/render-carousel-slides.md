---
task: "Render Carousel Slides"
order: 2
input: |
  - carousel_text: Texto aprovado dos slides (carrossel.md)
  - design_system: Sistema visual confirmado em build-design-system.md
output: |
  - rendered_slides: Imagens renderizadas de cada slide, em squads/posts-semanais-instagram/output/artes/
---

# Render Carousel Slides

Gera e renderiza cada slide do carrossel em HTML self-contained, sempre partindo de `pipeline/data/template-reference.html` como estrutura e `pipeline/data/visual-identity.md` como sistema de cores/tipografia — verifica o slide 1 antes de gerar o lote completo.

## Process

1. **Escrever o HTML do slide 1** aplicando o texto aprovado do carrossel sobre a estrutura de `pipeline/data/template-reference.html`, usando exatamente as cores e tipografia de `pipeline/data/visual-identity.md`.
2. **Renderizar e verificar o slide 1**: fonte legível (body >= 34px), contraste mínimo 4.5:1, sem clipping de texto, sem contador de slide. Só prosseguir depois dessa verificação passar.
3. **Gerar os slides restantes (2 a N)** usando o mesmo sistema visual confirmado no slide 1 — nenhuma variação de paleta ou tipografia entre slides.
4. **Salvar todas as imagens renderizadas** em `squads/posts-semanais-instagram/output/artes/`, nomeadas em ordem (slide-01.png, slide-02.png...).

## Output Format

```yaml
slides_renderizados:
  - arquivo: "output/artes/slide-01.png"
    verificado: true
  - arquivo: "output/artes/slide-02.png"
    verificado: true
  # ... até o total de slides do carrossel
```

## Output Example

> Use as quality reference, not as rigid template.

```
SLIDE 1 — VERIFICAÇÃO
Arquivo: output/artes/slide-01.png
Base: template-reference.html + visual-identity.md
Fonte body: 34px (Inter 500) — OK
Contraste texto/fundo: 12.8:1 (branco-creme #F5F3EE sobre #0D1830) — OK
Sem contador de slide — OK
Sem clipping — OK
Status: aprovado para lote

LOTE COMPLETO
slide-01.png ... slide-09.png — 9 slides gerados, mesmo sistema visual do slide 1 mantido em todos.
```

## Quality Criteria

- [ ] Slide 1 renderizado e verificado (contraste, fonte, clipping) antes do lote completo
- [ ] Todos os slides usam o mesmo sistema visual, sem variação de paleta ou tipografia
- [ ] Nenhum slide contém contador de slide ("1/9" etc.)
- [ ] HTML de cada slide é self-contained (CSS inline, sem dependência externa além de Google Fonts)

## Veto Conditions

Reject and redo if ANY are true:
1. O lote foi gerado sem o slide 1 ter sido verificado visualmente primeiro.
2. Algum slide usa fonte body abaixo de 34px ou contraste abaixo de 4.5:1.
