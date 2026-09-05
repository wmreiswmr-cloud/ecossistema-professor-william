# A3 — Por que "decisões com revisão vencida" nunca fecha de verdade

**Autor:** Queila Qualidade (`cerebro-qualidade`) · **Data:** 2026-09-03 · **Gatilho:** Política de Escalonamento (regra do dono, 2026-08-04) — item-mãe #52 bateu pela 4ª rodada seguida (26/08, 28/08, 31/08, 03/09) sem fechar de verdade.

## 1. Contexto

`decisoes.md` é o instrumento da Escada de Autonomia — toda decisão relevante registra um "resultado esperado" e uma data de `revisar em`, para separar decisão boa de sorte. Sem revisão feita na data, o instrumento inteiro perde função: fica um arquivo que só cresce, nunca fecha o ciclo que o justifica.

## 2. Condição atual medida (não estimada)

Dois instrumentos independentes medem a mesma coisa e divergem:

| Instrumento | Contagem hoje (03/09) | O que conta |
|---|---|---|
| `auditoria/2026-09-03.md` (script de auditoria diária) | **8** | não confirmado qual filtro aplica |
| Alerta n8n `decisaoRevisaoVencida1` (2026-09-02 14:00) | **27**, linha por linha | varre `decisoes.md` inteiro contra a data em `revisar em` |

O histórico do item-mãe **#52**: aberto 13/08 (7 vencidas) → redatado 26/08 (Diretor assume acompanhamento, 2ª ocorrência) → reconciliação parcial 28/08 (5 reconciliadas para 01/09) → 31/08 sobe para **8** → hoje, alerta n8n mostra **27**. A tendência é de piora, não de melhora — cada rodada de "redatar a data" reduz o número visível por alguns dias e depois ele volta maior, porque decisões novas com `revisar em` continuam sendo criadas no mesmo ritmo em que as antigas vencem.

## 3. Meta

Reduzir "decisões com revisão vencida" para um número que caia rodada após rodada, não que oscile — e eliminar a divergência entre os dois instrumentos (deveriam contar a mesma coisa).

## 4. Causa raiz — 5 Porquês

1. **Por que há 27 decisões vencidas?** Porque a data de `revisar em` passou sem ninguém abrir a linha e escrever o resultado real.
2. **Por que ninguém abre a linha na data?** Porque não existe gatilho que force alguém a olhar naquele dia especificamente — o alerta n8n avisa, mas avisar não é o mesmo que ter um dono que executa a revisão.
3. **Por que o aviso não vira execução?** Porque o dono da revisão, na maioria das linhas, é "Diretor" ou "`ceo-orquestrador`" — cargos genéricos sobrecarregados por outras 20+ ações do quadro — e a revisão de uma decisão antiga compete por atenção com item novo de GUT mais alto, e perde.
4. **Por que perde?** Porque revisar uma decisão de 3 semanas atrás não tem GUT — não está no `problemas.md`, está só em `decisoes.md`, fora do mecanismo de priorização que já existe (Gravidade × Urgência × Tendência).
5. **Por que "decisões vencidas" nunca ganhou GUT próprio?** **Causa raiz:** o processo tratou `decisoes.md` e `problemas.md` como dois sistemas paralelos — um para decisão, um para problema — mas nunca definiu que "decisão vencida sem revisão" é, ela mesma, um problema com dono e prazo dentro do quadro único. O item #52 tenta ser essa ponte, mas é 1 linha genérica cobrindo 27 casos, sem musculatura para forçar cada revisão individual.

## 5. Causa comum × causa especial (Shewhart)

**Causa comum**, não especial: não há 1 decisão específica com problema — são 27+ linhas de naturezas totalmente diferentes (Headroom, watchdog, modelo de reunião, n8n vs. Windows...) falhando pelo mesmo motivo estrutural. Tratar caso a caso (redatar 1 data por vez) é *tampering* — mexe no sistema sem mudar a causa, e por isso o número sempre volta.

## 6. Contramedida proposta (poka-yoke, Diretor decide se aprova)

1. **Todo item de `decisoes.md` cuja `revisar em` vencer entra automaticamente como item do quadro (`problemas.md`) com GUT próprio**, calculado pela idade do vencimento (T sobe com o tempo, como já acontece com prazo de `problemas.md`). Isso dá à revisão de decisão a mesma pressão de prioridade que qualquer outro problema — hoje ela não compete, porque não existe nesse sistema.
2. **Reconciliar os dois instrumentos antes de mexer no processo** — não adianta corrigir o fluxo se o número que mede sucesso está errado (8 vs. 27, item #131 aberto hoje). Fazer isso primeiro, com teste de resposta conhecida (FASE 4.1).
3. **Dono padrão "Diretor"/"ceo-orquestrador" só para decisão N0/N1 nova** — decisões operacionais reversíveis (N2) passam a ter revisor nomeado no momento da decisão, não herdado por categoria. Reduz a fila que se acumula em cima de 2 pessoas.

## 7. Verificação proposta

Depois de aplicada a contramedida 1: contar decisões vencidas na próxima auditoria e nas 2 seguintes — a meta é queda sustentada (não platô, não oscilação), e os dois instrumentos (script + n8n) batendo no mesmo número.

## 8. O que este A3 NÃO decide

Não decide se a contramedida 1 é aprovada — isso é do Diretor com o dono (mudança de processo, item não-delegável). Este A3 entrega diagnóstico e proposta, não implementa.
