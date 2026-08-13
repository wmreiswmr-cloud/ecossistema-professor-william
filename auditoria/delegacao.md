# Sistema de Delegação — formalizado

Criado em 2026-08-09 — item BL-011 do `evolution-backlog.md`. O padrão abaixo já era seguido de fato (ver histórico de hoje: campanha do ProfGestor, correção de copy, auditoria do tráfego) — este arquivo é a primeira vez que vira processo citável, fora de um documento de auditoria pontual.

## Matriz de decisão — pra quem vai cada tarefa

| Perfil da tarefa | Delegação | Exemplo real já aplicado |
|---|---|---|
| Baixo risco + baixa complexidade + especialidade única | 1 especialista, sem revisor | Rodar as trilhas de conhecimento diárias (`cerebro-analista-mercado` sozinho) |
| Alta complexidade, uma área técnica | Especialista + Diretor revisa a entrega com prova real | Copywriter reescrevendo a copy da campanha; Diretor confere contra a Landing real antes de aceitar |
| Toca marca/identidade (categoria N0) | Especialista prepara, **Diretor decide** | Cor do eyebrow, escolha de fonte DM Sans — nunca decidido pelo especialista sozinho |
| Toca dinheiro (categoria N0) | Especialista prepara o caso, **dono decide** | Ativar a campanha — só rodou depois do comando explícito "pode ativar" |
| Auditoria/crítica de outro trabalho | Especialista independente, nunca toca no que audita | `cerebro-trafego` auditando a campanha que o Diretor montou |
| Achado contradiz outro achado | Diretor vai à fonte primária antes de arbitrar quem está certo | Premissa não verificada do Qualidade (item #39, 08/08) — resolvido lendo o arquivo real, não escolhendo um lado |
| Estrutura do time/processo (categoria N1) | Diretor decide, não-delegável a nenhum especialista | Este próprio backlog, o Caminho de Construção de Design |

## Como decidir — os 7 critérios, na ordem que realmente importa

1. **Risco de marca ou dinheiro?** → sobe direto pro dono ou Diretor, ignora os critérios abaixo.
2. **Complexidade** — cabe num especialista, ou precisa de mais de uma competência em cadeia? (ver processo de delegação em cadeia, Seção 7 do "Architecture of Intelligent Management")
3. **Especialização necessária** — existe um agente cuja skill cobre isso de verdade, ou seria forçar um agente genérico?
4. **Dependência** — a tarefa espera outra terminar primeiro? Se sim, não despacha ainda.
5. **Prazo** — urgente o bastante pra rodar em paralelo com outra coisa, ou pode esperar a fila normal?
6. **Necessidade de revisão** — o resultado é objetivamente verificável (código, número) ou precisa de julgamento humano/par (design, copy, estratégia)?
7. **Necessidade de aprovação** — mesmo um resultado tecnicamente correto pode precisar de aprovação por impacto (visual, externo, financeiro).

## O que isto formaliza que já era verdade

Nenhuma regra nova aqui — é a mesma disciplina usada o dia inteiro em 08-09/08 (auditoria do tráfego, correção de copy, ativação da campanha), agora escrita uma vez em vez de reconstruída a cada decisão parecida.
