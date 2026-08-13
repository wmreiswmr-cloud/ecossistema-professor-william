# Opportunity Pipeline

Banco permanente de oportunidades de negócio novo. Dono: `cerebro-empreendedor` (Entrepreneur Director, criado 2026-08-12). Alimentado pela Trilha Q (`~/.claude/knowledge/portfolio-empreendimentos.md`) e pela pesquisa própria do agente, dirigida a preencher lacuna real do pipeline — nunca brainstorm solto.

**Regra de existência deste arquivo:** estrutura primeiro, conteúdo depois. Ele nasce vazio de propósito — cada linha só entra quando tem dor com evidência, não como espaço reservado para ideia. Arquivo com linha fictícia "para não ficar vazio" é pior que arquivo vazio: parece progresso e não é.

**Fluxo:** `cerebro-empreendedor` preenche e pontua → Opportunity Report vai para `ceo-orquestrador` (triagem: descarta / pede mais validação / aprova para investigação) → só o que passou no filtro **e** exige decisão de dinheiro/portfólio/prioridade sobe ao Diretor (`cerebro-ecossistema`). Detalhe completo do fluxo e da fronteira com Trilha D/analista-mercado em `~/.claude/commands/cerebro-empreendedor.md`.

---

## Opportunity Score — fórmula fixa, ponderada

| Critério | Peso | O que mede |
|---|---|---|
| Demanda | 25% | Evidência de gente procurando/pagando por isso hoje |
| Dor | 20% | Frequência e intensidade da dor |
| Margem | 15% | Custo operacional recorrente vs. ticket |
| Escala | 15% | Cresce sem crescer o tempo do fundador na mesma proporção |
| Competição | 10% | Espaço livre real vs. mercado saturado |
| Velocidade de MVP | 10% | Quão rápido e barato dá para testar a promessa |
| Sinergia | 5% | Aproveita algo que o ecossistema já tem |

Cada critério pontuado 0-10. **Score = soma ponderada (0-10).** Score sem os 7 critérios individuais ao lado não conta como avaliação — é opinião com nota.

## Status possíveis

`RADAR` (visto, sem dor confirmada) → `DESCOBERTA` (problema/público/dor com evidência) → `VALIDANDO` (experimento barato rodando) → `REPORT_ENVIADO` (Opportunity Report entregue ao `ceo-orquestrador`) → `APROVADO` / `MAIS_VALIDACAO` / `DESCARTADO` (decisão do `ceo-orquestrador`, com motivo) → `ESCALADO_DIRETOR` (dinheiro/portfólio/prioridade).

Nenhuma linha fica sem status final e motivo — mesma regra do `auditoria/problemas.md`: sem dono, data e status não é gestão, é anotação.

---

## Pipeline

| ID | Problema | Mercado | Público | Tamanho | Tendência | Concorrência | Potencial | Risco | Custo MVP | Score | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| — | *(vazio — primeira execução do `cerebro-empreendedor` ainda não rodou)* | | | | | | | | | | |

---

## Log resumido (1 linha por execução, mais recente no topo)

- 2026-08-12: Estrutura criada pelo Reitor junto com o agente `cerebro-empreendedor`. Zero oportunidades registradas — é o primeiro trabalho real do agente, não uma lacuna escondida.
