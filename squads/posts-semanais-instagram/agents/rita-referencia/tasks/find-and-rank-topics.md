---
task: "Find and Rank Topics"
order: 1
input: |
  - research_focus: Tema e janela de tempo definidos pelo usuário no checkpoint "foco-da-semana"
  - research_brief_data: Achados-chave já compilados em pipeline/data/research-brief.md (opcional, usar como base)
output: |
  - topic: Tema pesquisado da semana
  - fact: 1 fato/dado concreto com fonte
  - myth: 1 mito comum + correção com fonte
  - parent_question: 1 dúvida frequente de pais relacionada ao tema
---

# Find and Rank Topics

Pesquisa o foco definido no checkpoint da semana e retorna um brief estruturado e curto — o dado bruto que Carlos Carrossel e Vitor Vídeo vão transformar em copy. Nunca decide gancho, formato ou tom; só entrega fato, mito e dúvida com fonte.

## Process

1. **Ler o foco da semana** (tema + janela de tempo) no arquivo `squads/posts-semanais-instagram/output/research-focus.md`, produzido pelo checkpoint anterior.
2. **Rodar 2-3 buscas focadas no tema** (ex: "sinais de dificuldade de leitura crianças", "mitos alfabetização método fônico"), priorizando fontes já mapeadas em `pipeline/data/research-brief.md` (Instituto NeuroSaber, AlphaFono, Gazeta do Povo, Raízes da Infância) e o material próprio da Formação ESSI quando o tema tocar fundamentos técnicos do método.
3. **Extrair os três elementos obrigatórios**: 1 fato/dado concreto, 1 mito comum + a correção, 1 dúvida frequente de pais — cada um com a fonte identificada.
4. **Verificar se algum termo clínico escapou** (distúrbio, transtorno, diagnóstico) e substituir por linguagem de acompanhamento antes de finalizar.
5. **Compilar em um brief curto** (máx. 300 palavras) no formato de saída abaixo e salvar em `squads/posts-semanais-instagram/output/research-brief.md`.

## Output Format

```yaml
tema: "..."
fato:
  afirmacao: "..."
  fonte: "..."
mito_comum:
  crenca: "..."
  correcao: "..."
  fonte: "..."
duvida_frequente_de_pais: "..."
```

## Output Example

> Use as quality reference, not as rigid template.

```
TEMA: Sinais de alerta na leitura

FATO: Se a criança não percebe rimas ou sons de letras no início da alfabetização, é um sinal precoce que merece acompanhamento (fonte: Instituto NeuroSaber).

MITO COMUM: "Vai melhorar com o tempo, é só imaturidade."
CORREÇÃO: Quanto mais cedo a dificuldade é identificada, melhor o resultado — esperar pode agravar o quadro (fonte: AlphaFono).

DÚVIDA FREQUENTE DE PAIS: "Meu filho de 6 anos ainda não lê, isso é normal?" — depende do estágio, mas recusa sistemática de leitura ou ansiedade em avaliações são sinais de atenção que merecem acompanhamento.
```

Um segundo exemplo, para o tema "mito comum sobre método fônico":

```
TEMA: Mito comum sobre método fônico

FATO: A decodificação fluente libera a memória de curto prazo da criança para focar no significado do texto (fonte: material próprio, Formação ESSI).

MITO COMUM: "Método fônico é decoreba, atrapalha a compreensão."
CORREÇÃO: Sem decodificar bem, toda a energia cognitiva vai para "descobrir a palavra" — sobra pouco para compreender (fonte: Raízes da Infância).

DÚVIDA FREQUENTE DE PAIS: "Meu filho lê as palavras mas não entende o texto, isso é falha do método?" — geralmente é sinal de que a decodificação ainda não é automática o suficiente.
```

## Quality Criteria

- [ ] Brief tem no máximo 300 palavras
- [ ] Toda afirmação (fato e mito) tem fonte explicitamente citada
- [ ] Os três elementos (fato, mito, dúvida) estão presentes e claramente rotulados
- [ ] Nenhum termo clínico de diagnóstico aparece no texto final

## Veto Conditions

Reject and redo if ANY are true:
1. Qualquer fato ou mito aparece sem fonte identificável.
2. O brief ultrapassa 300 palavras ou omite um dos três elementos obrigatórios (fato, mito, dúvida).
