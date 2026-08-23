---
execution: subagent
agent: diana-design
inputFile: squads/posts-semanais-instagram/output/carrossel.md
outputFile: squads/posts-semanais-instagram/output/artes/
model_tier: powerful
---

# Step 6: Gerar Artes

## Context Loading

Load these files before executing:
- `squads/posts-semanais-instagram/output/carrossel.md` — texto aprovado dos slides (só roda após o checkpoint "aprovar-conteudo", step 5)
- `squads/posts-semanais-instagram/pipeline/data/visual-identity.md` — sistema visual aprovado (cores, tipografia, layout) — base obrigatória
- `squads/posts-semanais-instagram/pipeline/data/template-reference.html` — referência estrutural de HTML aprovada — base obrigatória
- `_opensquad/_memory/company.md` — tom de marca (caloroso, profissional, acolhedor)
- `squads/posts-semanais-instagram/agents/diana-design/tasks/build-design-system.md` e `render-carousel-slides.md` — processo e formato exato das duas fases desta etapa

## Instructions

### Process

1. Confirmar o sistema visual desta execução a partir de `visual-identity.md` e `template-reference.html` — nunca criar uma identidade nova.
2. Escrever o HTML do slide 1 aplicando o texto do carrossel sobre o sistema confirmado, renderizar e verificar (fonte >= 34px, contraste >= 4.5:1, sem clipping, sem contador de slide).
3. Só após o slide 1 passar na verificação, gerar os slides restantes usando exatamente o mesmo sistema visual.
4. Salvar todas as imagens renderizadas em `squads/posts-semanais-instagram/output/artes/`, nomeadas em ordem (slide-01.png, slide-02.png...).

## Output Format

```
DESIGN SYSTEM (confirmado)
Plataforma: Instagram Carrossel (1080x1440)
Cores: [valores exatos de visual-identity.md]
Tipografia: [valores exatos de visual-identity.md]
Base: pipeline/data/visual-identity.md + pipeline/data/template-reference.html

SLIDE 1 — VERIFICAÇÃO
Arquivo: output/artes/slide-01.png
Fonte body: [px] — OK/FALHA
Contraste: [ratio] — OK/FALHA
Sem contador de slide: OK/FALHA
Status: [aprovado para lote / corrigir antes de continuar]

LOTE COMPLETO
[lista de arquivos gerados, N slides, mesmo sistema visual confirmado em todos]
```

## Output Example

```
DESIGN SYSTEM (confirmado)
Plataforma: Instagram Carrossel (1080x1440)
Cores: fundo #0D1830 → #1B2A4A → #0A1224 | texto #F5F3EE | accent dourado #E0BE7A/#C9A24B | accent azul #5B8DEF
Tipografia: 'Poppins' 900 (Heading 52px) | 'Inter' 500 (Body 34px, Caption 24px)
Base: pipeline/data/visual-identity.md + pipeline/data/template-reference.html
Rationale: paleta quente e acolhedora, evitando o azul/branco corporativo genérico — alinhada ao tom da marca.

SLIDE 1 — VERIFICAÇÃO
Arquivo: output/artes/slide-01.png
Fonte body: 34px (Inter 500) — OK
Contraste: 12.8:1 (branco-creme sobre fundo marinho) — OK
Sem contador de slide — OK
Sem clipping — OK
Status: aprovado para lote

LOTE COMPLETO
slide-01.png a slide-09.png — 9 slides gerados, mesmo sistema visual do slide 1 mantido em todos, nenhum contador de slide presente.
```

## Veto Conditions

Reject and redo if ANY of these are true:
1. O lote foi gerado sem o slide 1 ter sido renderizado e verificado visualmente primeiro.
2. Algum slide usa fonte body abaixo de 34px, contraste abaixo de 4.5:1, ou diverge do sistema visual de `visual-identity.md`.

## Quality Criteria

- [ ] Contraste mínimo 4.5:1 em todo texto
- [ ] Fonte body >= 34px em todos os slides
- [ ] Slide 1 verificado antes do lote completo
- [ ] Sem contador de slide em nenhuma imagem
