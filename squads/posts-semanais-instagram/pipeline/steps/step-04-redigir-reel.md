---
execution: inline
agent: vitor-video
format: instagram-reels
inputFile: squads/posts-semanais-instagram/output/carrossel.md
outputFile: squads/posts-semanais-instagram/output/reel.md
---

# Step 4: Redigir Reel

## Context Loading

Load these files before executing:
- `squads/posts-semanais-instagram/output/carrossel.md` — carrossel completo já aprovado no passo anterior, com gancho e ângulo definidos
- `squads/posts-semanais-instagram/agents/vitor-video/tasks/create-instagram-reel.md` — processo e formato exato de saída desta etapa
- `_opensquad/core/best-practices/instagram-reels.md` — regras de estrutura, duração e legendas embutidas (injetado automaticamente via `format: instagram-reels`)

## Instructions

### Process

1. Ler o gancho e o ângulo já aprovados no carrossel e identificar como adaptar a mesma tensão para os 2 primeiros segundos do vídeo falado.
2. Escrever o roteiro completo seguindo Hook (0-2s) → Setup (2-5s) → Entrega (5-25s) → CTA (últimos 3-5s), especificando visual, fala e texto na tela em cada bloco.
3. Especificar legendas embutidas em todos os blocos (85% assiste sem som) e definir a direção de áudio (som em alta ou áudio original) com justificativa.
4. Escrever a legenda curta do post (gancho nos primeiros 125 caracteres, CTA coerente com o carrossel) e salvar tudo em `reel.md`.

## Output Format

```
=== ROTEIRO DO REEL ===

HOOK (0-2s):
[Visual]: "..."
[Fala]: "..."
[Texto na tela]: "..."

SETUP (2-5s):
[Visual]: "..."
[Fala]: "..."

ENTREGA (5-25s):
[Visual]: "..."
[Fala]: "..."
[Texto na tela]: "..."

CTA (últimos 3-5s):
[Visual]: "..."
[Fala]: "..."
[Texto na tela]: "..."

=== LEGENDA ===
[gancho + contexto curto + CTA]

=== HASHTAGS ===
#tag1 #tag2 #tag3 #tag4

=== NOTA DE ÁUDIO ===
[direção de áudio + justificativa]
```

## Output Example

```
=== ROTEIRO DO REEL ===

HOOK (0-2s):
[Visual]: Professor de frente pra câmera, olhando direto
[Fala]: "Ele só precisa praticar mais" — quantas vezes você já ouviu isso?
[Texto na tela]: "SÓ PRECISA PRATICAR MAIS"?

SETUP (2-5s):
[Visual]: Corte para close
[Fala]: Isso é um dos mitos mais perigosos sobre dificuldade de leitura.

ENTREGA (5-25s):
[Visual]: Cortes a cada 3-4s, alternando plano
[Fala]: Esperar pode agravar o problema. Quanto antes a gente identifica o que está travando a leitura, melhor o resultado. Não é sobre "praticar mais" — é sobre praticar do jeito certo, com o método certo, no ritmo da criança.
[Texto na tela]: "QUANTO ANTES, MELHOR"

CTA (últimos 3-5s):
[Visual]: Volta pro plano inicial
[Fala]: Se você reconheceu isso no seu filho, manda mensagem — vamos conversar.
[Texto na tela]: "Manda mensagem 💬"

=== LEGENDA ===
"Ele só precisa praticar mais." Um dos mitos mais perigosos sobre dificuldade de leitura.

Reconheceu isso no seu filho? Comenta ou manda mensagem.

=== HASHTAGS ===
#dificuldadedeleitura #metodofonico #alfabetizacao #dislexiainfantil

=== NOTA DE ÁUDIO ===
Áudio original falado — tom pessoal e direto funciona melhor que som em alta para conteúdo educativo/autoridade.
```

## Veto Conditions

Reject and redo if ANY of these are true:
1. O roteiro introduz um ângulo ou tema diferente do já aprovado no carrossel.
2. Falta especificação de legendas embutidas em algum bloco, ou o roteiro ultrapassa 30 segundos.

## Quality Criteria

- [ ] Duração entre 15-30 segundos
- [ ] Hook nos 2 primeiros segundos
- [ ] Legendas embutidas especificadas
- [ ] CTA específico coerente com o carrossel
