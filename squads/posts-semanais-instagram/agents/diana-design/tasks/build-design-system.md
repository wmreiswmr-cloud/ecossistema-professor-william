---
task: "Build Design System"
order: 1
input: |
  - visual_identity: pipeline/data/visual-identity.md — sistema visual já aprovado (cores, tipografia, layout)
  - template_reference: pipeline/data/template-reference.html — referência estrutural de HTML aprovada
  - brand_tone: Tom da marca (company.md) — caloroso, profissional, acolhedor
output: |
  - design_system: Confirmação/documentação do sistema visual aplicado nesta execução (cores, tipografia, espaçamento, grid)
---

# Build Design System

Confirma e documenta o sistema visual que será aplicado ao carrossel da semana, sempre a partir de `pipeline/data/visual-identity.md` e `pipeline/data/template-reference.html` — nunca uma identidade nova. Esta tarefa não cria design do zero; ela ancora a execução da semana no sistema já aprovado.

## Process

1. **Ler `pipeline/data/visual-identity.md`** por completo: paleta de cores, tipografia, layout, regras de composição e regras de adaptação já definidas e aprovadas.
2. **Ler `pipeline/data/template-reference.html`** para confirmar a estrutura HTML/CSS de referência (grid, classes, composição) que será reaproveitada nos slides desta semana.
3. **Confirmar o tom da marca** (`_opensquad/_memory/company.md`: caloroso, profissional, acolhedor) contra o sistema visual — nenhuma cor ou fonte fora do que já está documentado.
4. **Documentar o sistema aplicado nesta execução** no formato de saída abaixo, citando os valores exatos já definidos em `visual-identity.md` (nunca "aproximadamente").

## Output Format

```yaml
plataforma: "Instagram Carrossel (1080x1440)"
cores:
  fundo: "..."
  texto: "..."
  accent_dourado: "..."
  accent_azul: "..."
tipografia:
  heading: "..."
  body: "..."
  caption: "..."
grid:
  padding: "..."
  gap_cards: "..."
fonte_base: "pipeline/data/visual-identity.md + pipeline/data/template-reference.html"
```

## Output Example

> Use as quality reference, not as rigid template.

```
DESIGN SYSTEM
Plataforma: Instagram Carrossel (1080x1440)
Cores: fundo #0D1830 → #1B2A4A → #0A1224 (degradê azul marinho) | texto #F5F3EE (branco-creme) | accent dourado #E0BE7A/#C9A24B | accent azul #5B8DEF
Tipografia: 'Poppins' 900 (Heading 52px) | 'Inter' 500 (Body 34px, Caption 24px)
Card label: 'Inter' 500 (28px) | Card value: 'Poppins' 800 (38px)
Grid: coluna única, flexbox vertical, padding 72px, gap 16px entre cards
Elementos: radius 16px, tag de categoria no topo, rodapé com avatar + nome, sem contador de slide
Contraste verificado: branco-creme sobre fundo marinho = 12.8:1 (WCAG AA aprovado)
Base: pipeline/data/visual-identity.md (paleta, tipografia, composição) + pipeline/data/template-reference.html (estrutura HTML de referência)
Rationale: Paleta quente e acolhedora, evitando o azul/branco corporativo genérico — alinhada ao tom "caloroso, profissional, acolhedor" do perfil da empresa. O dourado e o azul alternam por item para dar ritmo visual sem nunca competir no mesmo elemento.
```

## Quality Criteria

- [ ] Todos os valores de cor, tipografia e espaçamento vêm diretamente de `visual-identity.md`, sem invenção
- [ ] A estrutura de referência de `template-reference.html` é citada explicitamente como base
- [ ] Nenhum valor é descrito como "aproximado" — todos são exatos em px/hex

## Veto Conditions

Reject and redo if ANY are true:
1. O sistema documentado diverge dos valores definidos em `pipeline/data/visual-identity.md` sem justificativa.
2. `template-reference.html` não é citado como base estrutural da execução.
