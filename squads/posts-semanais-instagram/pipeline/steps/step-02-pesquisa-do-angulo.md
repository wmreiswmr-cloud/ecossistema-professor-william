---
execution: subagent
agent: rita-referencia
inputFile: squads/posts-semanais-instagram/output/research-focus.md
outputFile: squads/posts-semanais-instagram/output/research-brief.md
model_tier: fast
---

# Step 2: Pesquisa do Ângulo

## Context Loading

Load these files before executing:
- `squads/posts-semanais-instagram/output/research-focus.md` — o tema/ângulo da semana definido pelo usuário no checkpoint anterior
- `squads/posts-semanais-instagram/pipeline/data/research-brief.md` — achados-chave já compilados (fontes, mitos, sinais de alerta) para usar como base
- `squads/posts-semanais-instagram/agents/rita-referencia/tasks/find-and-rank-topics.md` — a tarefa que define o processo e formato exato de saída

## Instructions

### Process

1. Ler o foco da semana em `research-focus.md` e identificar o ângulo específico a pesquisar (sinal de alerta, mito ou dúvida de pais).
2. Rodar 2-3 buscas focadas no tema, priorizando as fontes já mapeadas (Instituto NeuroSaber, AlphaFono, Gazeta do Povo, Raízes da Infância) e o material próprio da Formação ESSI quando o tema tocar fundamentos técnicos do método fônico.
3. Extrair os três elementos obrigatórios — 1 fato/dado concreto, 1 mito comum + correção, 1 dúvida frequente de pais — cada um com fonte citada.
4. Compilar o brief em no máximo 300 palavras, seguindo o formato de `find-and-rank-topics.md`, e salvar em `research-brief.md` (output desta etapa).

## Output Format

```
TEMA: [tema pesquisado]

FATO: [afirmação concreta] (fonte: [nome da fonte])

MITO COMUM: "[crença comum]"
CORREÇÃO: [correção com base em evidência] (fonte: [nome da fonte])

DÚVIDA FREQUENTE DE PAIS: "[pergunta típica]" — [resposta breve e não-alarmista]
```

## Output Example

```
TEMA: Sinais de alerta na leitura

FATO: Se a criança não percebe rimas ou sons de letras no início da alfabetização, é um sinal precoce que merece acompanhamento (fonte: Instituto NeuroSaber).

MITO COMUM: "Vai melhorar com o tempo, é só imaturidade."
CORREÇÃO: Quanto mais cedo a dificuldade é identificada e trabalhada, melhor o resultado — esperar pode agravar o quadro (fonte: AlphaFono).

DÚVIDA FREQUENTE DE PAIS: "Meu filho de 6 anos ainda não lê, isso é normal?" — depende do estágio de desenvolvimento, mas recusa sistemática de leitura ou ansiedade em avaliações são sinais de atenção que merecem acompanhamento, não pânico.
```

Este brief tem 3 elementos claros, cada afirmação tem fonte nomeada, e o tom é informativo sem ser alarmista — exatamente o padrão que Carlos Carrossel e Vitor Vídeo esperam receber para construir o gancho da semana.

Um segundo exemplo, para um foco de semana diferente ("mito comum sobre método fônico"), segue a mesma estrutura:

```
TEMA: Mito comum sobre método fônico

FATO: A decodificação fluente libera a memória de curto prazo da criança para focar no significado do texto lido (fonte: material próprio, Formação ESSI — pré-alfabetização).

MITO COMUM: "Método fônico é decoreba, atrapalha a compreensão do texto."
CORREÇÃO: Sem decodificar bem, toda a energia cognitiva da criança vai para "descobrir a palavra" — sobra pouco para compreender o que foi lido. A fluência na decodificação é o que abre espaço para a compreensão, não o contrário (fonte: Raízes da Infância).

DÚVIDA FREQUENTE DE PAIS: "Meu filho lê bem as palavras mas não entende o que leu, isso é falha do método?" — geralmente é sinal de que a decodificação ainda não está automática o suficiente; a compreensão chega depois que ler palavras deixa de exigir esforço consciente.
```

Nos dois exemplos, cada afirmação carrega sua fonte entre parênteses, o vocabulário evita termos clínicos de diagnóstico, e o brief inteiro fica dentro do limite de 300 palavras.

## Veto Conditions

Reject and redo if ANY of these are true:
1. Alguma afirmação (fato ou mito) aparece sem fonte identificável.
2. O brief ultrapassa 300 palavras ou não contém os três elementos obrigatórios (fato, mito, dúvida).

## Quality Criteria

- [ ] Brief tem no máximo 300 palavras
- [ ] Toda afirmação tem fonte citada explicitamente
- [ ] Contém exatamente 1 fato + 1 mito + 1 dúvida de pai
- [ ] Nenhum termo clínico de diagnóstico aparece no texto
