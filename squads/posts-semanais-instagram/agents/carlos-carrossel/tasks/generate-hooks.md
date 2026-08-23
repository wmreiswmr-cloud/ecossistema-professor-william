---
task: "Generate Hooks"
order: 1
input: |
  - research_brief: Fato + mito + dúvida da semana, produzido por Rita Referência
  - company_context: Tom de marca e público-alvo (company.md)
output: |
  - hooks: Lista de 3 ganchos (Hook A, B, C), cada um com gatilho psicológico e formato estrutural diferentes
  - rationale: 1 frase de justificativa por gancho
---

# Generate Hooks

Gera 3 ganchos com gatilhos psicológicos e formatos estruturais diferentes a partir do brief de pesquisa, cada um com uma frase justificando por que funciona para pais preocupados com a leitura do filho. Esta tarefa sempre roda antes de `create-instagram-feed.md` — o corpo do carrossel nunca é escrito sem um gancho escolhido.

## Process

1. **Ler o brief de Rita Referência** (fato + mito + dúvida da semana) e identificar qual dos três elementos tem mais força de identificação para o pai/mãe leitor.
2. **Diagnosticar o nível de consciência do público** (Problem Aware — sabe do problema, não sabe do caminho) e o driver psicológico dominante para esta semana (medo de perda, alívio, controle) antes de redigir qualquer gancho.
3. **Redigir 3 ganchos**, cada um usando um driver psicológico E um formato estrutural diferentes (ex: pergunta que desafia senso comum, confissão pessoal, dado/estatística), seguindo `_opensquad/core/best-practices/copywriting.md`.
4. **Escrever a justificativa de cada gancho** em uma frase, citando o driver psicológico usado e por que ele funciona para esta audiência específica.
5. **Apresentar os 3 ganchos ao usuário e aguardar a escolha** — nunca prosseguir para o corpo do carrossel sem confirmação explícita.

## Output Format

```yaml
hooks:
  - id: "A"
    text: "..."
    driver: "..."
    format: "..."
    rationale: "..."
  - id: "B"
    text: "..."
    driver: "..."
    format: "..."
    rationale: "..."
  - id: "C"
    text: "..."
    driver: "..."
    format: "..."
    rationale: "..."
```

## Output Example

> Use as quality reference, not as rigid template.

```
Hook A (Pergunta que desafia senso comum):
"Ele só precisa praticar mais." Mas será que é isso mesmo?
Rationale: Cita a crença mais comum entre pais e a questiona diretamente — cria tensão cognitiva que só se resolve lendo o post inteiro.

Hook B (Confissão pessoal + identificação):
Também demorei pra perceber que "só praticar mais" não ia resolver a leitura do meu aluno mais difícil.
Rationale: Gera identificação emocional imediata com quem também já tentou "só mais prática" sem resultado.

Hook C (Dado/estatística):
1 em cada 5 crianças que "só precisam praticar mais" está, na verdade, sem a base da consciência fonológica.
Rationale: Usa especificidade numérica para gerar credibilidade e curiosidade sobre o que realmente está faltando.
```

## Quality Criteria

- [ ] 3 ganchos apresentados, cada um com driver psicológico e formato estrutural diferentes
- [ ] Cada gancho tem 1 frase de justificativa citando o driver e por que funciona para esta audiência
- [ ] Nenhum gancho usa termo clínico de diagnóstico ou promessa numérica sem prova
- [ ] Ganchos calibrados para o nível de consciência "Problem Aware"

## Veto Conditions

Reject and redo if ANY are true:
1. Os 3 ganchos usam o mesmo driver psicológico ou o mesmo formato estrutural (falta de diferenciação real).
2. Qualquer gancho promete resultado numérico específico ou usa linguagem de diagnóstico clínico.
