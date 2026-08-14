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

## 2026-08-13 16:00 — n8n (automático, Guardião de Decisão Nova)

1 decisão(ões) nova(s) desde a última checagem — confirmar que quem produz conteúdo/copy/design já leu:

- [Estrutura/processo] 2026-08-13: Avaliação real da proposta `cerebro-claude-os` (Claude Operating System Architect) trazida pelo dono — nota 32

## 2026-08-13 16:18 — n8n (automático, Economia de Token)

Falha ao medir uso de token: Command failed: node "C:\Users\usuario\Desktop\Projeto-professor-William\automacao-n8n\parse-token-usage.js" "C:\Users\usuario\.claude\projects\c--Users-usuario-Desktop-Projeto-professor-William\2cb60044-88e6-41e0-9aa5-91326534d5e4.jsonl" "C:\Users\usuario\Desktop\Projeto-professor-William\auditoria\uso-tokens-real.json"
node:internal/modules/cjs/loader:1479
  throw err;
  ^

Error: Cannot find module 'C:\Users\usuario\Desktop\Projeto-professor-William\automacao-n8n\parse-token-usage.js'
    at Module._resolveFilename (node:internal/modules/cjs/loader:1476:15)
    at wrapResolveFilename (node:internal/modules/cjs/loader:1049:27)
    at defaultResolveImplForCJSLoading (node:internal/modules/cjs/loader:1073:10)
    at resolveForCJSWithHooks (node:internal/modules/cjs/loader:1094:12)
    at Module._load (node:internal/modules/cjs/loader:1262:25)
    at wrapModuleLoad (node:internal/modules/cjs/loader:255:19)
    at Module.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:154:5)
    at node:internal/main/run_main_module:33:47 {
  code: 'MODULE_NOT_FOUND',
  requireStack: []
}

Node.js v24.15.0


## 2026-08-13 16:20 — n8n (automático, Economia de Token)

Medido: 23724 linhas do transcript real, 21 dias com uso registrado NA MESMA SESSÃO/CONVERSA (nunca reiniciada). Output do dia mais recente: 284.511 tokens (reduziu 313.767 vs. o dia anterior). 

HIGIENE DE SESSÃO: esta conversa já soma 21 dias sem nunca reiniciar — é a causa raiz real do cache_read alto (todo o histórico é reprocessado a cada turno, mesmo em cache). Recomendação real: começar uma conversa nova pro próximo assunto grande, não continuar empilhando nesta.

## 2026-08-14 00:00 — n8n (automático, Guardião de Decisão Nova)

5 decisão(ões) nova(s) desde a última checagem — confirmar que quem produz conteúdo/copy/design já leu:

- [Estrutura/processo] 2026-08-13: Avaliação da proposta n8n do dono ("PROBLEMA→...→OTIMIZAÇÃO", 3 níveis verde/amarelo/vermelho, n8n como sistem
- [Estrutura/processo] 2026-08-13: Parecer sobre "Organização Executiva do Ecossistema" — proposta grande de reorganização (Fundador→Diretor→CEO-
- [Estrutura/processo] 2026-08-13: Avaliação real da proposta `cerebro-claude-os` (Claude Operating System Architect) trazida pelo dono — nota 32
- [Estrutura/processo] 2026-08-13: Sequenciamento dos 29 agentes (de 44) sem nível formal nem matrícula verificada (`problemas.md` #58, achado do
- [**Dinheiro saindo**] 2026-08-13: Critério de matar da campanha R$100 aplicado com dado real, com atraso reconhecido (prazo original 12/08, chec

## 2026-08-14 01:42 — n8n (automático, Alerta de Prazo Vencido)

3 item(ns) vencido(s):

- #29 (3d vencido, 1ª ocorrência consecutiva, dono `cerebro-reitor`, prazo **11/08**, status ⏳ Aberto — matrícula/baseline pendente): Nível baseline nunca declarado para `cerebro-brand-scout`/`cerebro-brand-director` em desi
- #40 (2d vencido, 1ª ocorrência consecutiva, dono `ceo-orquestrador`, prazo **12/08**, status `ASSIGNED` — dono definido, investigação ainda não iniciada): `cerebro-trafego` parado no nível 1 há 7 auditorias seguidas, sempre "= parado", nunca vir
- #52 (1d vencido, 1ª ocorrência consecutiva, dono `ceo-orquestrador`, prazo 13/08, status ⏳ Aberto — divergência não reconciliada): Divergência de instrumento em `decisoes.md`: leitura direta encontra 3 decisões com `revis
