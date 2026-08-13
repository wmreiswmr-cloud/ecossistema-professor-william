# Alertas automáticos — n8n

Gerado pelo workflow "Alerta de Prazo Vencido". Lido pelo Diretor no início de toda sessão, junto com o resto de auditoria/.

## 2026-08-09 13:07 — n8n (automático, Alerta de Prazo Vencido)

1 item(ns) vencido(s):

- #37 (1d vencido, dono Diretor, prazo **08/08**, status ⏳ Aberto — lacuna de registro identificada, correção não feita ainda): Escolha de referência visual de hoje (TutorCruncher/Linda Raynier) nunca foi registrada em

## 2026-08-09 13:11 — n8n (automático, Decisão com Revisão Vencida)

Nenhuma decisão com revisão vencida e resultado ainda pendente.

## 2026-08-09 11:29 — n8n (automático, Trilhas Incompletas)

Digest de hoje (2026-08-09) ainda não existe em pesquisa-diaria/ — nenhuma trilha rodou ainda.

## 2026-08-09 11:29 — n8n (automático, Trilhas Incompletas)

Digest de hoje (2026-08-09) ainda não existe em pesquisa-diaria/ — nenhuma trilha rodou ainda.

## 2026-08-09 14:34 — n8n (automático, Risco Parado)

Nenhum risco aberto há 5+ dias sem mitigação completa.

## 2026-08-09 14:40 — n8n + Claude (sob demanda, julgamento real, sem custo novo)

(erro chamando o claude: spawnSync C:\Users\usuario\AppData\Roaming\npm\claude.cmd EINVAL)

## 2026-08-09 14:41 — n8n + Claude (sob demanda, julgamento real, sem custo novo)

(erro chamando o claude: Cannot assign to read only property 'name' of object 'Error: Passing args to a child process with shell option true can lead to security vulnerabilities, as the arguments are not escaped, only concatenated.')

## 2026-08-09 14:43 — n8n + Claude (sob demanda, julgamento real, sem custo novo)

William, o alerta automático diz que o item #37 está vencido desde 08/08, mas o quadro de problemas.md já mostra esse mesmo item como resolvido (`DONE`) em 09/08 — o alerta está desatualizado ou dessincronizado do quadro real. O julgamento automático via Claude (n8n) falhou duas vezes seguidas com erros diferentes, e o segundo aponta um problema de segurança real: passar argumentos para um child process com `shell: true` sem escapar, o que é vetor de injeção de comando. Isso precisa de atenção do Diretor porque nenhum dos dois alertas mais recentes (14:40 e 14:41) chegou a produzir julgamento algum — a automação está rodando "com erro" silencioso, exatamente o tipo de coisa que a regra do dono de 04/08 proíbe esconder.

## 2026-08-09 11:54 — n8n (automático, Encoding Quebrado — Armadilha 31)

Nenhum dos arquivos do dia existe ainda pra checar.

## 2026-08-09 14:55 — n8n (automático, Guardião de Decisão Nova)

1ª execução — linha de base gravada (28 decisões existentes hoje). Próximas execuções comparam a partir daqui.

## 2026-08-09 15:23 — n8n (automático, Economia de Token)

Medido: 21005 linhas do transcript real, 17 dias com uso registrado. Output do dia mais recente: 693.337 tokens (reduziu 134.140 vs. o dia anterior).

## 2026-08-09 15:38 — n8n (automático, Economia de Token)

Medido: 21127 linhas do transcript real, 17 dias com uso registrado NA MESMA SESSÃO/CONVERSA (nunca reiniciada). Output do dia mais recente: 738.146 tokens (reduziu 89.331 vs. o dia anterior). 

HIGIENE DE SESSÃO: esta conversa já soma 17 dias sem nunca reiniciar — é a causa raiz real do cache_read alto (todo o histórico é reprocessado a cada turno, mesmo em cache). Recomendação real: começar uma conversa nova pro próximo assunto grande, não continuar empilhando nesta.

## 2026-08-10 12:00 — n8n (automático, Guardião de Decisão Nova)

Nenhuma decisão nova em decisoes.md desde a última checagem (28 linhas antes, 28 agora).

## 2026-08-10 12:02 — n8n (automático, Economia de Token)

Medido: 21412 linhas do transcript real, 18 dias com uso registrado NA MESMA SESSÃO/CONVERSA (nunca reiniciada). Output do dia mais recente: 70.275 tokens (reduziu 705.536 vs. o dia anterior). 

HIGIENE DE SESSÃO: esta conversa já soma 18 dias sem nunca reiniciar — é a causa raiz real do cache_read alto (todo o histórico é reprocessado a cada turno, mesmo em cache). Recomendação real: começar uma conversa nova pro próximo assunto grande, não continuar empilhando nesta.

## 2026-08-10 12:09 — n8n (automático, Economia de Token)

Medido: 21462 linhas do transcript real, 18 dias com uso registrado NA MESMA SESSÃO/CONVERSA (nunca reiniciada). Output do dia mais recente: 90.824 tokens (reduziu 684.987 vs. o dia anterior). 

HIGIENE DE SESSÃO: esta conversa já soma 18 dias sem nunca reiniciar — é a causa raiz real do cache_read alto (todo o histórico é reprocessado a cada turno, mesmo em cache). Recomendação real: começar uma conversa nova pro próximo assunto grande, não continuar empilhando nesta.
