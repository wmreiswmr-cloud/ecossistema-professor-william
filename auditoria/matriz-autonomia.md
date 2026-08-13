# Matriz de Autonomia por Agente

Criado em 2026-08-09 — item BL-012 do `evolution-backlog.md`. Complementa a Escada de Autonomia (`decisoes.md`, por **categoria de decisão**) com a pergunta que ela não responde sozinha: **este agente específico, hoje, pode agir sem pedir?**

## Os 4 níveis

| Nível | Pode fazer sozinho | Nunca pode sozinho |
|---|---|---|
| **Baixa** | Analisar, pesquisar, sugerir, propor rascunho | Publicar, executar, gastar |
| **Média** | Executar tarefa técnica de baixo risco, reversível | Decisão que toca marca/dinheiro/dado |
| **Alta** | Coordenar outros agentes, executar mudança já aprovada | Ação irreversível sem revisão independente |
| **Crítica** | Nada sem aprovação humana explícita | — |

Ações **sempre** críticas, para qualquer agente, sem exceção: gastar dinheiro real, publicar algo que sai pra fora (anúncio, e-mail, post), apagar dado, mudar marca/identidade, alterar arquitetura crítica de produção.

## Aplicado aos agentes reais mais ativos hoje

| Agente | Nível hoje | Por quê |
|---|---|---|
| `cerebro-trafego` | Alta pra auditoria/análise · Crítica pra ativar/pausar campanha | Hoje auditou e recomendou arquivar um anúncio sozinho, mas nunca ativou/pausou nada — instrução explícita seguida |
| `cerebro-copywriter` | Média | Reescreve copy sozinho, mas publicação de anúncio real continua crítica (Diretor/dono) |
| `cerebro-gerador-criativos` | Média | Produz peça visual sozinho, nunca publica |
| `cerebro-design-pro` | Média | Constrói sobre direção já aprovada; troca de fonte/marca foi decisão do dono, não dele |
| `cerebro-design-critic` | Alta pra auditoria | Audita e recomenda, nunca implementa a própria correção |
| `cerebro-brand-director` | Baixa pra decisão final | Propõe 3 direções, dono/Diretor escolhe — nunca decide identidade sozinho |
| `cerebro-analista-mercado` / `-agencia` | Alta | Pesquisa e registra conhecimento sozinho, rotina diária sem supervisão |
| `cerebro-financeiro` | Baixa pra decisão, Média pra análise | Prepara o caso de "Dinheiro saindo", nunca decide sozinho — CFO não-delegável é o Diretor |
| `cerebro-product-architect` / `cerebro-saas` | Alta pra execução técnica | Implementa mudança de código já decidida; produção crítica ainda passa por revisão |
| `cerebro-automacao` | Média | Constrói workflow, mas ativação em produção que toca dado real de cliente pede revisão |
| `cerebro-qualidade` | Alta pra diagnóstico | Nunca decide a contramedida sozinho — só Diretor+dono decidem juntos (regra do dono, 03/08) |
| `cerebro-secretario` | Alta pra montar o quadro | Nunca decide, nunca diagnostica causa raiz |
| `cerebro-sentinela` | Alta pra checagem mecânica | Nunca decide o que fazer com o atraso encontrado |
| `cerebro-integrador` | Alta pra resolver atrito operacional | Nunca decide estratégia, nunca fala com o dono |
| `cerebro-reitor` | Alta pra avaliar nível | Nunca aceita autoavaliação — sempre evidência real |
| Diretor (`cerebro-ecossistema`) | Alta em geral | Crítica em N0 continua sendo decisão conjunta com o dono, nunca só do Diretor |

## Regra prática pra qualquer agente não listado

Default: **Média**. Sobe pra Alta só com histórico real comprovado (mesma régua da Escada de Autonomia — decisões seguidas sem reversão). Nunca críticas por padrão — crítica exige aprovação humana sempre, sem exceção, independente de quão "confiável" o agente pareça.

**Atualização:** revisar junto com a Escada de Autonomia (`decisoes.md`) sempre que uma categoria subir/descer de nível.
