# Anti-Patterns — Posts Semanais Instagram

Erros comuns do domínio (educação/mentoria de leitura) e do processo de produção de conteúdo, compilados para toda a equipe consultar antes de entregar.

## Pesquisa (Rita Referência)

- **Inventar dado ou estatística sem fonte**: prejudica a credibilidade da conta e pode ser cobrado publicamente por um seguidor. Toda afirmação precisa de fonte rastreável.
- **Pesquisa exaustiva de 10+ fontes**: o objetivo é um ângulo acionável para um post semanal, não uma revisão bibliográfica. 2-3 fontes por tema bastam.
- **Misturar fato com opinião pessoal sem marcar a diferença**: o brief deve deixar claro o que é dado verificável e o que é interpretação.

## Copy (Carlos Carrossel e Vitor Vídeo)

- **Escrever o corpo antes do gancho ser escolhido**: viola a regra de ouro do copywriting.md — sempre apresentar 3 ganchos e aguardar a escolha do usuário.
- **Usar termo clínico como diagnóstico definitivo** (ex: "seu filho tem dislexia"): o squad não substitui avaliação profissional formal — usar "sinal de alerta" e "acompanhamento" em vez disso.
- **Prometer resultado numérico específico sem prova real** (ex: "seu filho lê fluente em 30 dias"): gera expectativa que o método educacional não pode sustentar de forma responsável.
- **Misturar dois CTAs no mesmo post**: reduz a taxa de conversão e confunde o próximo passo do leitor. Um post, um CTA.
- **Abrir com cliché** ("Você sabia que...", "No mundo de hoje..."): mata o scroll-stop antes de começar.
- **Deixar o Reel com introdução lenta ou logo**: perde o viewer no primeiro segundo — hook precisa estar nos 2 primeiros segundos.
- **Entregar roteiro de Reel sem legendas embutidas especificadas**: 85% assiste sem som, roteiro incompleto sem essa direção.

## Visual (Diana Design)

- **Usar fonte abaixo de 34px no corpo**: viola o mínimo da plataforma para Instagram Carrossel (1080x1440) e prejudica legibilidade.
- **Pular a verificação visual do slide 1**: gera retrabalho em todo o lote se houver erro de contraste, clipping ou fonte.
- **Usar dependência externa no HTML além de Google Fonts**: quebra a renderização self-contained exigida pelo pipeline.
- **Incluir contador de slide na imagem**: Instagram já mostra navegação nativa — contador é ruído visual redundante.
- **Usar paleta corporativa genérica (azul/branco frio)**: contraria o tom "caloroso, profissional, acolhedor" da marca e o sistema visual já aprovado em `visual-identity.md`.

## Revisão (Beatriz Bússola)

- **Aprovar sem ler o conteúdo por completo**: um erro que passa despercebido na revisão vai parar no feed público.
- **Dar nota sem justificativa por escrito**: nota sem explicação não ensina nada e não pode ser contestada de forma construtiva.
- **Inflar nota para evitar confronto**: aprovar conteúdo abaixo do padrão mina a confiança no processo de revisão inteiro.
- **Rejeitar sem correção específica**: toda rejeição deve dizer exatamente o que mudar e onde, nunca "melhorar o tom" sem exemplo.

## Processo geral

- **Gerar arte antes do conteúdo estar aprovado**: renderização é cara em tempo/créditos — o checkpoint de aprovação de conteúdo (passo 5) existe justamente para evitar retrabalho visual.
- **Pular o checkpoint de aprovação final**: mesmo com revisão automática aprovada, a decisão de publicar é sempre humana — nunca considerar o post "pronto" sem o passo 8.
