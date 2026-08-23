---
task: "Create Instagram Reel"
order: 1
input: |
  - carousel: Carrossel completo aprovado, com gancho e ângulo definidos (carrossel.md)
output: |
  - reel_script: Roteiro completo (15-30s) com hook, setup, entrega e CTA
  - caption: Legenda curta do Reel
  - audio_note: Direção de áudio (som em alta ou áudio original)
---

# Create Instagram Reel

Roteiro completo de Reel (15-30s) a partir do mesmo ângulo já aprovado no carrossel, com hook nos 2 primeiros segundos, legendas embutidas e CTA final — a adaptação para o formato falado, não uma repetição literal do texto do carrossel.

## Process

1. **Ler o gancho e o ângulo já aprovados no carrossel de Carlos Carrossel** e identificar como a mesma tensão pode abrir os 2 primeiros segundos do vídeo (texto na tela + fala).
2. **Escrever o roteiro completo** seguindo a estrutura Hook (0-2s) → Setup (2-5s) → Entrega (5-25s) → CTA (últimos 3-5s), conforme `_opensquad/core/best-practices/instagram-reels.md`.
3. **Especificar legendas embutidas** em cada bloco do roteiro — texto na tela que reforça a fala, pensado para quem assiste sem som.
4. **Escrever a legenda do post** (curta, gancho nos primeiros 125 caracteres, CTA coerente com o carrossel) e definir a direção de áudio (som em alta ou áudio original falado) com justificativa curta.

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

> Use as quality reference, not as rigid template.

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

## Quality Criteria

- [ ] Duração entre 15-30 segundos, cronometrada por bloco
- [ ] Hook especificado nos 2 primeiros segundos com visual, fala e texto na tela
- [ ] Legendas embutidas especificadas em todos os blocos do roteiro
- [ ] CTA específico e coerente com o CTA do carrossel

## Veto Conditions

Reject and redo if ANY are true:
1. O roteiro introduz um ângulo ou tema diferente do já aprovado no carrossel.
2. Falta a especificação de legendas embutidas ou o roteiro ultrapassa 30 segundos.
