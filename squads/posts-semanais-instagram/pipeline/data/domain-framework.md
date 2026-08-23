# Domain Framework — Posts Semanais Instagram

Framework operacional do squad: como um post semanal (Feed + Reels) nasce, passa por aprovação humana em dois pontos e chega pronto para publicação.

## Visão geral do pipeline (8 passos)

1. **Foco da semana** (checkpoint) — o usuário define o tema/ângulo da semana (ex: sinais de alerta, mito comum, dúvida frequente de pais).
2. **Pesquisa do ângulo** (Rita Referência, subagent) — pesquisa o foco definido e entrega um brief curto: 1 fato + 1 mito + 1 dúvida de pai, cada um com fonte.
3. **Redigir carrossel** (Carlos Carrossel, inline) — gera 3 ganchos, aguarda escolha do usuário, escreve o carrossel completo (Feed).
4. **Redigir reel** (Vitor Vídeo, inline) — adapta o mesmo ângulo já aprovado no carrossel para roteiro de Reel (15-30s).
5. **Aprovar conteúdo** (checkpoint) — o usuário revisa carrossel + reel antes de qualquer arte ser gerada.
6. **Gerar artes** (Diana Design, subagent) — renderiza os slides do carrossel em HTML self-contained → imagem, seguindo o sistema visual aprovado (`pipeline/data/visual-identity.md`).
7. **Revisar** (Beatriz Bússola, subagent) — nota carrossel, roteiro e artes contra os critérios de qualidade; aprova ou rejeita (rejeição volta para o passo 3).
8. **Aprovação final** (checkpoint) — o usuário dá o sinal verde final antes de considerar o post pronto para publicação manual.

## Por que essa ordem

- **Pesquisa antes de escrever**: nenhum gancho ou fato entra no post sem fonte. Rita entrega o material bruto antes de qualquer copy ser escrita.
- **Gancho antes do corpo**: Carlos nunca escreve o carrossel completo sem antes apresentar 3 ganchos e esperar a escolha do usuário (regra de ouro do copywriting.md).
- **Reel reaproveita o ângulo do carrossel**: garante consistência de mensagem entre os dois formatos da semana, evitando retrabalho de pesquisa.
- **Checkpoint de conteúdo antes da arte**: gerar imagem é caro (tempo + créditos) — o texto precisa estar aprovado antes de qualquer renderização.
- **Revisão antes da aprovação final**: Beatriz aplica os critérios objetivos de `quality-criteria.md` antes do usuário gastar tempo revisando; reduz o número de rodadas de aprovação humana com problema óbvio.
- **Aprovação final como último portão**: mesmo depois da revisão automática, a decisão de publicar é sempre humana.

## Papéis por etapa

| Etapa | Agente | Execução | Produz |
|---|---|---|---|
| 2 | Rita Referência | subagent (fast) | Brief de pesquisa (research-brief.md) |
| 3 | Carlos Carrossel | inline | Carrossel completo (carrossel.md) |
| 4 | Vitor Vídeo | inline | Roteiro de Reel (reel.md) |
| 6 | Diana Design | subagent (powerful) | Artes renderizadas (artes/) |
| 7 | Beatriz Bússola | subagent (fast) | Revisão estruturada (review.md) |

## Regra de rejeição

Se Beatriz Bússola rejeita (passo 7), o pipeline volta ao passo 3 (redigir-carrossel) — o carrossel e o reel são reescritos considerando o feedback específico antes de nova tentativa de arte e revisão.
