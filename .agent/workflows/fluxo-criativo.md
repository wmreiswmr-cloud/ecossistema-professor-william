---
description: Fluxo do Criativo — pipeline de 7 portões com handoff em arquivo entre os cerebro-*, no mesmo padrão do Opensquad (squad.yaml + Reads from/Writes to + checkpoints)
source: FASE 5.2 de ~/.claude/knowledge/processo-empresa.md (regra do dono, 2026-08-02) + [[project_criativos]]. Gaps fechados 22/08 (nota numérica, passo de pesquisa, pipeline.yaml) depois de comparar de verdade com `squads/posts-semanais-instagram` do Opensquad — ver `criativos/pipeline/pipeline.yaml`.
---

# Fluxo do Criativo — pipeline

Cada peça de anúncio/post/story passa pelos 7 passos abaixo, nesta ordem, sem pular nenhum.
O handoff entre agentes é **sempre por arquivo em disco** em `criativos/pipeline/output/<peça>/` —
nunca por resumo verbal de um agente pro outro. Isso é o que faz a prova ser real (ver `armadilhas-conhecidas.md`:
"instrumento não auditado não verifica nada" vale também pra handoff — arquivo lido é prova, alegação não é).

A definição machine-readable equivalente ao `pipeline.yaml` do Opensquad vive em
`criativos/pipeline/pipeline.yaml` — mesma tabela abaixo, formato `steps`/`type`/`agent`/`on_reject`.

## Pipeline

| # | Passo | Tipo | Quem executa | Lê de | Escreve em | Volta pro passo se reprovar |
|---|---|---|---|---|---|---|
| 1 | Briefing | checkpoint | Diretor + dono | — (conversa) | `01-briefing.md` (objetivo único, público, nível de consciência Schwartz) | — |
| 2 | Pesquisa do ângulo | agent | cerebro-social-media (referência real de post que já funcionou pro público, mesmo padrão do investigador Sherlock do Opensquad) | `01-briefing.md` | `02-pesquisa.md` (ângulo escolhido + referência real que sustenta a escolha, nunca ângulo inventado sem lastro) | — |
| 3 | Construção | agent | Célula Marca & Produto (cerebro-design-pro / cerebro-brand-director) | `01-briefing.md`, `02-pesquisa.md`, Brand Book do projeto | `03-peca.html` + `03-peca.png` (via `render.js`/Playwright) | — |
| 4 | Validação de marketing | agent | ceo-orquestrador-agencia + cerebro-copywriter | `03-peca.html`, `mestres-copy.md` | `04-validacao.md` (nota 1-10 por crivo — Schwartz, Collier/Halbert, Ogilvy, Hormozi, Carlton — com justificativa "porque..."; ver regra de corte abaixo) | 3 |
| 5 | Auditoria de contraste | agent | cerebro-accessibility | `03-peca.html` | `05-contraste.md` (contraste calculado por par de cor, nunca estimado) | 3 |
| 6 | Edição final | agent | cerebro-editor-in-chief | `03-peca.html`, `04-validacao.md` | `06-editorial.md` (Relatório Editorial — só língua, nunca toca estratégia/oferta/CTA/tom) | 4 (aponta ao Copywriter, não corrige) |
| 7 | Decisão | checkpoint | dono | `04-validacao.md`, `05-contraste.md`, `06-editorial.md` | `07-decisao.md` (aprovado/reprovado) | 4, editado **junto** com a célula de marketing, nunca refeito sozinho |

## Regra de corte do passo 4 — nota numérica, mesmo padrão da Beatriz do Opensquad

Cada um dos 5 crivos recebe **nota 1-10 com justificativa escrita** ("Nota: X/10 porque...", nunca número isolado).

- **Qualquer crivo abaixo de 4/10 reprova a peça sozinho** — inegociável, mesmo que a média geral esteja alta. É o mesmo gatilho de rejeição automática da Beatriz (`quality-criteria.md` do squad).
- **Aprovado** exige média ≥ 7 **e** nenhum crivo abaixo de 4.
- Abaixo da média 7 sem nenhum crivo eliminatório: **APROVADO COM RESSALVA** — a ressalva fica registrada em `04-validacao.md`, não trava a peça, mas pauta a próxima do calendário.
- Isto substitui o veredito só-qualitativo (✅/❌/⚠️) usado até 21/08 — mantém o mesmo raciocínio (crivo eliminatório definido, nunca julgamento no momento), só formaliza o número pra tornar o corte auditável sem reler o texto inteiro.

## Regra dura nova, 22/08 — todo portão cita trecho E número de linha

**Aprovada pelo dono em 22/08**, proposta por Eduardo Editorial (`cerebro-editor-in-chief`) no primeiro despacho real dele, e estendida pelo dono a **todos os portões** (não só o dele).

**Causa real, não teórica:** o relatório editorial narrado da peça "Sinal de Alerta" avaliava — e propunha corrigir — o trecho `"textos que a idade dele já deveria ler fluente"`. **Essa string não existe no arquivo.** O HTML real diz `em textos que já deveria conseguir ler com fluência pra idade dele`. Ou seja: o portão foi dado como cumprido revisando um texto que nunca esteve lá, e nada no pipeline pegou isso. Não era falta de cuidado — era ausência de âncora verificável.

**A regra:** todo achado dos portões 4 (validação), 5 (contraste) e 6 (editorial) **cita o trecho exato E o número da linha do arquivo-fonte** que ele avaliou. Achado sem âncora localizável não fecha o portão.

- Vale para nota, para reprovação e para elogio — "Nota: 8/10 porque X" precisa do X localizável.
- É **poka-yoke, não disciplina**: com a linha citada, revisar texto inexistente vira impossível de esconder — qualquer um abre o arquivo na linha e confere em segundos.
- Quem revisa não precisa recontar o arquivo inteiro para auditar o portão anterior: vai direto na linha.

## Regra dura nova, 22/08 — despacho real obrigatório, narração não conta

**Achado real, com prova em log:** a peça "Sinal de Alerta" (22/08, `criativos/pipeline/output/sinal-de-alerta/`) foi auditada contra o `.jsonl` bruto da sessão que a produziu. **Zero despachos de subagente.** Os 6 passos foram escritos por um único thread narrando os papéis — `cerebro-accessibility` e `cerebro-editor-in-chief` nunca rodaram como agente real em nenhuma das 102 sessões do projeto. Ver a correção anexada a `06-decisao.md` daquela peça.

A partir de agora, **todo passo `type: agent` deste pipeline só conta como cumprido se foi executado por um despacho real** — `Task`/`Agent` com `subagent_type` igual ao especialista da tabela, contexto próprio, não o thread principal escrevendo o arquivo e assinando o nome de outro.

- **Como provar:** antes de marcar um passo como feito, checar que existiu uma chamada de ferramenta `Task`/`Agent` com aquele `subagent_type` nesta sessão — não vale "escrevi o arquivo no estilo dele".
- **Se o ambiente não permitir despacho real de subagente** (ex: harness sem suporte, mesmo caso do Opensquad em Antigravity — `.agent/rules/opensquad.md` já declara essa limitação explicitamente), o passo tem que ser marcado no arquivo de saída como `EXECUTADO PELO THREAD PRINCIPAL, NÃO DESPACHADO` — nunca silenciado. É a mesma disciplina da Armadilha 16 (ferramenta conectada ≠ utilizável): capacidade que não existe não se finge.
- Isso vale pros 4 passos `agent` (2, 3, 4/5/6) — os 2 checkpoints (1 e 7) continuam sendo o dono/Diretor, nunca precisaram de despacho.

## Regras duras (herdadas do processo, não deste arquivo)

- Nenhuma peça pula os 6 portões nem o passo 7.
- Prova social e número só existem se forem reais e verificáveis — sem placeholder.
- Prazo é obrigatório sempre que existir dado real; escassez só se for verdadeira.
- Peça reprovada não é refeita do zero: volta pro passo indicado na tabela e é editada preservando o que já passou nos crivos.
- Passo 6 nunca corrige estratégia/oferta/CTA/tom — só aponta ao Copywriter.
- Passo 2 nunca inventa ângulo sem referência real — mesma regra de "não descrever de memória" que já vale pra Trilha I (`armadilhas-conhecidas.md`, Armadilha 35).

## Como rodar

1. Criar a pasta `criativos/pipeline/output/<nome-da-peça>/`.
2. Executar os passos em ordem, sempre lendo o arquivo do passo anterior (nunca memória de conversa) e escrevendo o arquivo do passo atual antes de acionar o próximo agente.
3. Cada passo `agent` é despachado de verdade (`Task`/`Agent`, `subagent_type` correto) — nunca narrado pelo thread principal. Sem exceção silenciosa (ver regra acima).
4. Nos checkpoints (1 e 7), parar e esperar o dono — nunca prosseguir sozinho.
5. Peça de produção sem custo: HTML/CSS com os tokens do Brand Book, renderizado em PNG pelo Playwright — modelo em `criativos/criativos.html` + `criativos/render.js`.
