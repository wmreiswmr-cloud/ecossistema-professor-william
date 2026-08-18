# Procedimentos — registro dos passo-a-passo obrigatórios

Criado em 2026-08-15, a pedido do dono: "vamos criar vários procedimentos que precisam ser cumpridos." Diferença para os outros arquivos de `auditoria/`:

| Arquivo | O que registra |
|---|---|
| `decisoes.md` | Uma decisão tomada, uma vez, com motivo e prazo de revisão |
| `problemas.md` | Um problema, sua causa e sua correção |
| `procedimentos.md` (este) | Um passo-a-passo que se repete — **como algo deve ser feito toda vez**, não o que foi decidido uma vez |

**Regra:** todo procedimento aqui tem que citar a fonte real (arquivo/script/workflow que efetivamente executa cada passo) — nunca descrever de memória o que "deveria" acontecer. Se o procedimento mudar (o script for editado, o workflow republicado), este arquivo é atualizado no mesmo dia — ele é retrato do que roda de verdade, não aspiração.

Listado em `auditoria/source-of-truth.md` como fonte oficial da categoria "Procedimentos".

---

## Procedimento 1 — Reunião Diária

**Objetivo:** todo dia, sem o dono precisar cobrar, o time de gestão inteiro se manifesta sobre o estado real do ecossistema, e a rodada só termina com uma decisão e uma lição registradas.

**Gatilho:** workflow n8n `Auditoria Diária do Ecossistema` — automático às 22:00 (`America/Sao_Paulo`), ou disparo manual ("Rodar agora (teste)") a qualquer momento.

**Fonte de execução:** `auditoria/prompt-reuniao.txt` (o prompt real usado) via `auditoria/auditoria-diaria.ps1` → `claude -p` (ver Procedimento 2 para o mecanismo técnico da automação).

### Passo a passo

1. **Sentinela** — roda o checklist de 4 itens (tarefa agendada rodou? digest+auditoria existem? prazo do quadro venceu? decisão vencida?). Todo prazo vencido é contado: 1ª vez → nova data +2 dias úteis, mesmo dono; 2ª vez → Diretor assume/redistribui; 3ª vez → vira caso para o Qualidade.
2. **Qualidade** — só escreve conteúdo novo se algo chegou na 3ª ocorrência ou surgiu erro novo relevante. Formato A3 completo: causa raiz nomeada com ferramenta, contramedida com poka-yoke, verificação real — nunca "vamos ter mais cuidado".
3. **CEO-orquestrador** — não repete o que o painel VS Code já mostra ao vivo; escreve só a interpretação de por que um item específico está parado (decisão do dono vs. inércia do time).
4. **Reitor** — confirma nível novo de agente só quando há evidência nova registrada num arquivo de conhecimento; nunca aceita nível autodeclarado.
5. **Secretário** — atualiza `problemas.md` de verdade (edita o arquivo, não só descreve): todo item com Data/Responsável/Status completos, achado novo vira linha nova, resolvido migra para "Resolvidos" com prova real.
6. **Triagem por nível** (Seção 5B) — cada atrito é classificado: Nível 1 o especialista resolve sozinho · Nível 2 `cerebro-integrador` cobra/desbloqueia (nunca muda Dono/Prazo/Status) · Nível 3 integrador + especialista ou Qualidade · Nível 4 sobe para o Diretor. Só fato, nunca "acho que" — sem evidência, escreve "sem evidência apresentada".
7. **Diretor** — nomeia primeiro o gargalo do dia (Goldratt: qual célula trava o resultado do time inteiro, não um problema pontual qualquer). Para cada problema sem solução no quadro, propõe as 4 partes fixas: causa raiz (ferramenta nomeada) — quem resolve — com quê — como verifico (nunca código de saída ou leitura de código como prova). Fecha com 3 perguntas obrigatórias: qual a lição aprendida hoje; o que evita o problema se repetir amanhã (ação concreta com dono, nunca esperança); o que o Diretor já consegue aplicar na operação com o que aprendeu hoje.
8. **Devolutiva Executiva** (Seção 7, regra de ouro — **a reunião só termina aqui**) — relatório fixo e curto, o que o Diretor lê primeiro: status geral por faixa GUT, progresso desde a última devolutiva, problemas identificados, atenção do Diretor (score 61+), decisões tomadas, ações delegadas, riscos, bloqueios, indicadores (uso de token, saúde do n8n), pontos que exigem decisão do Diretor, e as **8 perguntas obrigatórias** (1 linha cada, mesmo que "nenhuma"):
   1. O que o Diretor precisa saber?
   2. O que precisa decidir?
   3. O que está andando sem ele?
   4. O que está atrasado?
   5. Qual o maior risco?
   6. Quem é responsável por cada item aberto?
   7. O que mudou desde a última devolutiva?
   8. **Existe algum problema sendo escondido pela equipe?**

**Onde ver o resultado:** `auditoria/AAAA-MM-DD-reuniao.md` — a Devolutiva Executiva vem no topo, o histórico das seções 1-6 embaixo.

**Quem não pode ficar em silêncio:** nenhum papel (Sentinela/Qualidade/CEO-orquestrador/Reitor/Secretário/Diretor) pode deixar sua seção vazia — se não há nada novo, escreve explicitamente "nada novo hoje, motivo: X". Silêncio sem essa linha é falha do Secretário, não economia de espaço.

**Histórico:** modelo adaptado em 2026-08-15 a partir de uma proposta do dono (Meeting Controller de 3 camadas) — a única mudança feita foi manter `cerebro-secretario` como condutor, nunca `cerebro-integrador` (conflito com o mandato fundador dele, "nunca substitui o Secretário", e com o escopo recomendar-only decidido em 14/08). Ver `decisoes.md`, 2026-08-15.
