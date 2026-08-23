# Disparado diariamente pelo workflow n8n "quadroGutN8n0001".
# Corrigido 20/08 (item #93 de problemas.md) -- a Tarefa Agendada do Windows
# "CerebroQuadroDiario" nao existe mais, confirmado com Get-ScheduledTask.
# Roda o Claude Code headless com escopo restrito ao cerebro-secretario, pra
# revisar o quadro de acoes (problemas.md) e classificar cada item aberto
# pela matriz GUT. Pedido direto do dono, 2026-08-14: "estou achando o quadro
# muito parado... coloca um agente todos os dias para verificar".
Set-Location "c:\Users\usuario\Desktop\Projeto-professor-William"

$prompt = @'
Use a skill cerebro-secretario pra revisar o quadro de acoes de hoje (auditoria/problemas.md). Isto e uma execucao automatica diaria, nao supervisionada — decida e execute, nunca pare pra perguntar "como quer seguir".

O que fazer, na ordem:

1. Ler auditoria/problemas.md inteiro. Considerar "aberto" todo item cujo Status nao seja DONE/CANCELLED/APPROVED/resolvido (✅) — inclui READY, ASSIGNED, IN_PROGRESS, BLOCKED e o vocabulario antigo (Aberto/Bloqueado).

2. Pra cada item aberto, calcular ou recalcular a classificacao GUT (Gravidade x Urgencia x Tendencia, 1-5 cada, score 1-125 — regra completa no cabecalho do arquivo, secao "Classificacao GUT"). Se o item ja tem `[GUT: ...]` no texto, reavalie com honestidade — prazo mais perto de vencer costuma subir Urgencia mesmo sem o conteudo do item mudar; atualize o numero e adicione 1 frase curta dizendo o que mudou. NUNCA adicionar coluna nova na tabela — o parser do painel VS Code conta coluna fixa e quebra com coluna extra (ja aconteceu antes, item #38 do arquivo). Editar so o texto dentro da celula existente.

2b. **O score DETERMINA o SLA — voce nao escolhe prazo livremente.** Use a tabela fixa do cabecalho ("Faixa de prioridade e SLA"): 81-125 = 🔴 Critico, prazo 24-48h; 61-80 = 🟠 Muito alto, 3 dias; 41-60 = 🟡 Alto, 7 dias; 21-40 = 🔵 Medio, 15 dias; 1-20 = 🟢 Baixo, 30 dias. Escreva `[GUT: G{n}xU{n}xT{n}={score} · {emoji} {Prioridade}]` logo apos o titulo/inicio da celula "Problema". O prazo do SLA e pra INICIAR/mostrar plano, nao pra fechar o problema inteiro — nunca marque um item como "atrasado" so porque ele ainda esta em andamento dentro do proprio prazo do SLA.

2c. Pra item 🔴 ou 🟠, adicione tambem os 3 SLAs dentro do mesmo `[GUT: ...]`, no formato `SLA: resposta {X} / execucao {Y} / validacao {Z}` — Critico: resposta 0-4h, execucao ate 48h, validacao ate 72h; Muito alto: resposta ate 24h, execucao ate 3 dias, validacao ate 4 dias uteis. Item 🟡/🔵/🟢 usa so o prazo unico, sem detalhar os 3 SLAs.

3. Verificar completude: todo item aberto tem os 3 campos obrigatorios (Dono = pessoa/agente unico, nao "o time"; Prazo; Status explicito)? Se faltar algum, marcar isso claramente no proprio item ("FALTA: sem prazo definido" / "FALTA: sem responsavel definido") — **nunca decidir ou atribuir prazo/dono por conta propria**, isso nao e seu papel; item sem dono vira pauta do Diretor, nao atribuicao automatica.

4. Verificar prazo vencido sem prova: item com prazo no passado e sem "Resolvido"/prova real anexada entra automaticamente com Urgencia 5 no GUT (e prioridade recalculada pra cima conforme o novo score), independente do calculo original.

5. NUNCA apagar linha, nunca inventar problema que nao existe, nunca mudar Dono/Prazo/Status por conta propria (isso e diagnostico/decisao, fora do seu mandato — voce so monta e cobra completude). So editar o texto da celula Problema pra adicionar/atualizar o GUT e as notas de completude.

6. Ao final, escrever um bloco novo no topo do arquivo (logo apos a explicacao de GUT no cabecalho, antes da primeira secao datada), com o titulo "## Ranking GUT de hoje (AAAA-MM-DD, automatico)" contendo:
   - Os 5 itens abertos de maior score GUT, em ordem decrescente, com # e score
   - Contagem: quantos itens abertos no total, quantos sem GUT antes desta execucao, quantos com prazo vencido sem prova
   - Se esse bloco de ranking do dia anterior ja existir no arquivo, SUBSTITUA-O pelo de hoje (nao acumule ranking de dias antigos — isso e resumo vivo, nao historico. O historico completo continua nas secoes datadas abaixo, que nunca sao tocadas por este processo)

Nunca toque nas secoes "## Resolvidos" nem em qualquer secao com data anterior a hoje, exceto pra adicionar/atualizar o `[GUT: ...]` dentro da celula Problema de item que continua aberto.
'@

$env:CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS = "0"
# ponytail: $null | evita o wait/warning "no stdin data received em 3s" (Task
# Scheduler nao anexa stdin nenhum) -- mesma classe de achado do #71, 19/08.
# Lock global (#116, A3 22/08): impede que este "claude -p" rode ao mesmo tempo
# que qualquer outro do ecossistema e estoure a RAM da maquina.
. "c:\Users\usuario\Desktop\Projeto-professor-William\automacao-n8n\claude-p-lock.ps1"
Lock-ClaudeP
try {
  $null | claude -p $prompt --dangerously-skip-permissions --output-format text 2>&1 | Out-File -FilePath "c:\Users\usuario\Desktop\Projeto-professor-William\auditoria\quadro-diario-ultima-execucao.log" -Encoding utf8
} finally {
  Unlock-ClaudeP
}
