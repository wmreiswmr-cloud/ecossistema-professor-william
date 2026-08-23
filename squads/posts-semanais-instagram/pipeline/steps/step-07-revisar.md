---
execution: subagent
agent: beatriz-bussola
inputFile: squads/posts-semanais-instagram/output/
outputFile: squads/posts-semanais-instagram/output/review.md
on_reject: 3
model_tier: fast
---

# Step 7: Revisar

## Context Loading

Load these files before executing:
- `squads/posts-semanais-instagram/output/carrossel.md` — carrossel completo produzido por Carlos Carrossel
- `squads/posts-semanais-instagram/output/reel.md` — roteiro do Reel produzido por Vitor Vídeo
- `squads/posts-semanais-instagram/output/artes/` — artes renderizadas por Diana Design
- `squads/posts-semanais-instagram/pipeline/data/quality-criteria.md` — critérios consolidados de todas as etapas
- `squads/posts-semanais-instagram/agents/beatriz-bussola/tasks/review-content.md` — processo e formato exato de saída desta etapa

## Instructions

### Process

1. Carregar `quality-criteria.md` antes de avaliar qualquer conteúdo.
2. Ler o carrossel, o roteiro do Reel e ver as artes por completo, sem pular nenhuma seção.
3. Notar cada critério individualmente (1-10) com justificativa por escrito, citando o trecho ou slide exato.
4. Aplicar a regra de veredito: APROVAR se média >= 7 e nenhum critério abaixo de 4; REJEITAR em qualquer outro caso.
5. Se REJEITAR, listar correções específicas e acionáveis — o pipeline volta ao step 3 (`redigir-carrossel`) com esse feedback.

## Output Format

```
==============================
 VEREDITO: [APROVAR | REJEITAR]
==============================
| Critério | Nota | Resumo |
|----------|------|--------|
| ...      | X/10 | ...    |
OVERALL: X.X/10 — [APROVAR/REJEITAR]

PONTOS FORTES:
Ponto forte: ...

MUDANÇAS OBRIGATÓRIAS (se REJEITAR):
Required change: ...
```

## Output Example

```
==============================
 VEREDITO: APROVAR
==============================
| Critério                  | Nota | Resumo |
|---------------------------|------|--------|
| Gancho (scroll-stop)      | 8/10 | Pergunta desafia senso comum, forte |
| CTA único e específico    | 9/10 | "Manda mensagem" claro e direto |
| Alinhamento com a marca   | 8/10 | Tom acolhedor mantido |
| Critérios visuais (Diana) | 9/10 | Contraste e legibilidade ok |
OVERALL: 8.5/10 — APROVAR

PONTOS FORTES:
Ponto forte: O slide 1 do carrossel usa alto contraste e uma frase de impacto que cumpre o critério de scroll-stop.
Ponto forte: O roteiro do Reel mantém o mesmo ângulo do carrossel, sem introduzir tema novo.

MUDANÇAS OBRIGATÓRIAS: nenhuma — conteúdo aprovado sem ressalvas bloqueantes.
```

## Veto Conditions

Reject and redo if ANY of these are true:
1. O veredito foi emitido sem o conteúdo ter sido lido/visto por completo.
2. Alguma nota aparece sem justificativa por escrito, ou o veredito contradiz a tabela de notas.

## Quality Criteria

- [ ] Todos os critérios relevantes de `quality-criteria.md` foram avaliados
- [ ] Toda nota tem justificativa por escrito
- [ ] Veredito bate com as notas
- [ ] Pelo menos um ponto forte citado, mesmo em rejeição
