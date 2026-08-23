---
task: "Review Content"
order: 1
input: |
  - carousel: Carrossel completo (carrossel.md)
  - reel_script: Roteiro do Reel (reel.md)
  - rendered_slides: Artes renderizadas (output/artes/)
  - quality_criteria: pipeline/data/quality-criteria.md
output: |
  - verdict: APROVAR ou REJEITAR
  - scoring_table: Nota (1-10) por critério com justificativa
  - required_changes: Lista de correções específicas (se REJEITAR)
---

# Review Content

Nota cada critério (1-10), aponta pontos fortes e mudanças obrigatórias, e emite o veredito final APROVAR/REJEITAR sobre o carrossel, o roteiro do Reel e as artes visuais da semana — seguindo a metodologia de `_opensquad/core/best-practices/review.md`.

## Process

1. **Carregar os critérios de qualidade** de `pipeline/data/quality-criteria.md` antes de avaliar qualquer conteúdo.
2. **Ler o carrossel, o roteiro do Reel e ver as artes por completo**, sem pular nenhuma seção — nenhuma nota é dada antes da leitura completa.
3. **Notar cada critério individualmente (1-10) com justificativa por escrito**, citando o trecho ou slide exato que gerou a nota.
4. **Aplicar a regra de veredito**: APROVAR se a média geral >= 7/10 E nenhum critério individual abaixo de 4/10. REJEITAR em qualquer outro caso (gatilho automático, inegociável).
5. **Compilar o resultado** no formato de saída abaixo, com pelo menos um ponto forte citado mesmo em rejeição, e toda rejeição acompanhada de correção específica e acionável.

## Output Format

```yaml
veredito: "APROVAR | REJEITAR"
notas:
  - criterio: "..."
    nota: 0
    justificativa: "..."
overall: 0.0
pontos_fortes:
  - "..."
mudancas_obrigatorias:
  - "..."
```

## Output Example

> Use as quality reference, not as rigid template.

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
Ponto forte: O roteiro do Reel mantém o mesmo ângulo do carrossel sem introduzir tema novo, como exigido.

MUDANÇAS OBRIGATÓRIAS: nenhuma — conteúdo aprovado sem ressalvas bloqueantes.
```

## Quality Criteria

- [ ] Todos os critérios de `pipeline/data/quality-criteria.md` relevantes ao conteúdo da semana foram avaliados
- [ ] Toda nota tem justificativa por escrito, citando trecho ou slide específico
- [ ] O veredito bate matematicamente com as notas (nenhuma contradição)
- [ ] Pelo menos um ponto forte está presente, mesmo em rejeição

## Veto Conditions

Reject and redo if ANY are true:
1. O veredito foi emitido sem o conteúdo ter sido lido/visto por completo.
2. Alguma nota aparece sem justificativa por escrito, ou o veredito contradiz a tabela de notas.
