# Proposta do Diretor — auditoria de 2026-08-03

> Innovator Director (`cerebro-ecossistema`). Baseado em: `processo-empresa.md`, `lacunas-conhecidas.md`, relatorio `2026-08-03.md` e relatorio anterior `2026-08-02.md`.
> Gravado como `-proposta.md` porque `2026-08-03-diretor.md` estava travado por outro processo (OneDrive/editor aberto).
>
> **Nao confiei no script.** Abri `gestao.md` e `operacional.md` para ver o que as trilhas G e H realmente produziram hoje (FASE 4/5). Isso mudou o diagnostico dos alertas 2 e 3.

## Achado que atravessa o relatorio

O relatorio se contradiz: a secao **Alertas** diz que as trilhas de `gestao.md`/`operacional.md` "nao entregaram", mas a **secao 3** mostra `gestao +6` e `operacional +7`, e o conteudo dentro dos arquivos e framework real, nomeado, com fonte e aplicado a erro nosso — nao log. O alerta esta errado sobre a propria causa: **falso negativo do motor de auditoria** (bug de limiar).

---

## Alerta 1 — 8 dos ultimos 14 dias sem pesquisa

- **CAUSA RAIZ:** cicatriz da epoca (07-21 a 08-01) em que a tarefa agendada estava mal-configurada (pedia so 4 trilhas, varios dias sem digest). Ja corrigido em 08-02 — prova: 08-02 e 08-03 produziram digest com as 9 trilhas. E indicador atrasado de apagao resolvido, que so sai da janela de 14 dias com o tempo.
- **QUEM RESOLVE:** causa ja corrigida; e monitoramento — **item nao-delegavel meu** (FASE 5, item 10). Celula Conhecimento & Operacao apenas mantem a execucao diaria.
- **COM QUE:** nenhuma acao nova. Nao mexer na tarefa que voltou a produzir 2 dias limpos.
- **COMO VERIFICO:** digests de 08-04, 08-05... existirem em disco com as 9 trilhas e o numero de cobertura subir (6->7->8...). Travar em 6 com um dia novo faltando = motor falhou em silencio apesar do codigo 0 -> vira acao. Prova e o arquivo aparecer, nao o exit code.

## Alerta 2 — gestao.md praticamente vazio (33 linhas)

- **CAUSA RAIZ:** falso "nao entregou". Trilha G rodou e adicionou *Normalization of Deviance* (Vaughan), com fonte (NASA + Wikibooks) e aplicado ao caso Trilha F. A causa do alerta e **bug de limiar do script**: chama de "nao entregou" qualquer arquivo <~40 linhas mesmo com delta +6 — mesma taxa dos arquivos saudaveis (`mestres-copy +10`, `meta-10k +8`). Arquivo criado vazio ha 2 dias; esta enchendo, nao parado.
- **QUEM RESOLVE:** (a) texto mentiroso do alerta = motor de auditoria -> **eu, Diretor** (o motor tem que dizer a verdade). (b) continuar engordando -> **Celula Conhecimento & Operacao** (`cerebro-knowledge-architect`), Trilha G.
- **COM QUE:** (a) corrigir o script para separar "trilha nao rodou" (delta=0) de "arquivo pequeno mas crescendo" (delta>0) — so o primeiro e "nao entregou". (b) Trilha G prioriza temas em 0: decisao sob incerteza, unit economics.
- **COMO VERIFICO:** linha e proxy, nao prova. Prova real = consumidor usar. Perguntar ao especialista de gestao *"por que 3 reunioes relataram 1,45 sem checar a fonte?"* e ele responder citando silencio organizacional/normalizacao do desvio de `gestao.md`. Respondeu com base -> entregou.

## Alerta 3 — operacional.md praticamente vazio (34 linhas)

- **CAUSA RAIZ:** falso, e o mais grave. Trilha H rodou (+7) e registrou *Teto de Capacidade + Lista de Espera*, que responde diretamente a **Lacuna #1** ("se a campanha trouxer 20 professores, quem atende?") — a pergunta em aberto mais cara do time. O script chamou de "nao entregou" o dia em que a trilha fechou a primeira camada da lacuna. Mesmo bug de limiar do Alerta 2.
- **QUEM RESOLVE:** (a) motor de auditoria -> **eu, Diretor**. (b) engordar -> **Celula Conhecimento & Operacao**, Trilha H, temas em 0 (onboarding, retencao, cobranca, continuidade).
- **COM QUE:** mesmo fix de script do Alerta 2; Trilha H continua a rotacao.
- **COMO VERIFICO:** efeito real = a resposta destrava decisao de negocio. A campanha paga pausada so reativa depois do minimo operacional (FAQ/onboarding automatico + lista de espera, `operacional.md:47`). Prova = usar o arquivo para dar o go/no-go da campanha em reuniao — a resposta ja esta escrita. **Recomendo rebaixar Lacuna #1 de vermelho para "primeira camada coberta".**

---

## Regra das 3 auditorias seguidas

So existem 2 relatorios em disco (08-02, 08-03). Os tres alertas aparecem nos dois -> **2a seguida, nao a 3a.** Falta 1 para o gatilho; nao registro como lacuna ainda (seria inventar dado).

**Risco de governanca:** se o bug de limiar nao for corrigido antes de 08-04, os Alertas 2 e 3 repetem mecanicamente amanha, batem a 3a e viram lacuna em `lacunas-conhecidas.md` por um problema que nao existe. Fix do script e prioridade **antes** da proxima auditoria.