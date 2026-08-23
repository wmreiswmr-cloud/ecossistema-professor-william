# Disparado 2x/semana pelo workflow n8n "Auditoria de Automacao -- Correcao e
# Oportunidade (n8n)". Regra do dono, 2026-08-15 (processo-empresa.md FASE 3.1):
# cerebro-automacao passa a auditar o ecossistema inteiro 2x/semana -- (a)
# CORRECAO: as automacoes ja ativas fazendo o que dizem, sem sucesso falso
# escondendo falha real; (b) OPORTUNIDADE: trabalho manual repetido no processo
# (qualquer celula, nao so engenharia) com caminho de automacao de custo zero
# ainda nao construido. So RECOMENDA -- nunca cria workflow novo sozinho, nunca
# decide arquitetura, so registra achado em problemas.md pro Diretor decidir.
Set-Location "c:\Users\usuario\Desktop\Projeto-professor-William"

$prompt = @'
Use a skill cerebro-automacao pra fazer a auditoria periodica de automacao do ecossistema (regra do dono, 2026-08-15, processo-empresa.md FASE 3.1). Execucao automatica, nao supervisionada -- decida e execute o que esta dentro do seu mandato, nunca pare pra perguntar "como quer seguir".

LIMITE DURO, NAO NEGOCIAVEL: voce so AUDITA e RECOMENDA. Nunca cria, edita ou publica workflow n8n novo nesta execucao. Nunca decide sozinho que uma automacao nova deve ser construida -- so propoe, com achado registrado em problemas.md, pro Diretor decidir.

PARTE (a) CORRECAO -- pra cada workflow n8n ATIVO (use search_workflows da MCP n8n-instancia):
1. Use search_executions (workflowId de cada um) pra ver as execucoes REAIS dos ultimos 7 dias -- nunca confie em "active:true" nem em "status" isolado sem olhar o padrao.
2. Sinais de falha real escondida atras de sucesso aparente, cace especificamente: (i) workflow ativo com gatilho de horario fixo mas ZERO execucoes modo "trigger" (gatilho nunca disparou de verdade, so testes manuais/cli); (ii) execucao "success" cujo resultado real (arquivo gravado, dado produzido) nao bate com o que o node deveria ter feito; (iii) execucao "crashed"/"error" repetida sem investigacao; (iv) mensagem de erro/limite de sessao gravada por cima de um arquivo que antes tinha conteudo valido.
3. Para cada achado real (nao suposicao), registre em auditoria/problemas.md, formato padrao da tabela (numero novo sequencial, GUT calculado G x U x T, Dono sugerido `cerebro-automacao` pendente aprovacao do Diretor, Prazo pelo SLA da faixa GUT, Status `READY`, Prova de como confirmar).

PARTE (b) OPORTUNIDADE -- releia auditoria/problemas.md, auditoria/rotinas-operacionais.md e auditoria/decisoes.md recentes procurando trabalho MANUAL REPETIDO (qualquer celula: marketing, financeiro, atendimento, nao so engenharia) que ainda depende de alguem lembrar de fazer na mao, e que teria caminho de automacao de CUSTO ZERO (n8n + o que ja esta instalado, sem assinatura nova) ainda nao construido. Para cada oportunidade real e especifica (nunca generica tipo "automatizar mais coisas"), registre em problemas.md no mesmo formato, deixando claro que e PROPOSTA -- Dono sugerido `cerebro-automacao`, mas o campo Status deve deixar explicito "aguardando aprovacao do Diretor para construir".

Se nao achar nenhum problema real de correcao nem nenhuma oportunidade real e especifica nesta rodada, escreva isso mesmo explicitamente no arquivo de saida -- silencio nao e opcao, mas inventar achado pra preencher tambem nao.

Escreva um resumo desta auditoria (o que foi checado, quantos workflows, quantos achados de cada parte, ou "nenhum achado nesta rodada") em auditoria/auditoria-automacao-ultima-execucao.md, SOBRESCREVENDO o resumo da rodada anterior -- e um resumo vivo, o historico completo de achados fica em problemas.md (que voce so ACRESCENTA, nunca reescreve linha de outro dono).
'@

# Mesma guarda do item #77 (problemas.md): erro de sessao/rate limit do claude -p
# nao pode virar sucesso silencioso nem sobrescrever nada com lixo. Aqui o risco
# e menor pq a saida vai pro log (nao sobrescreve arquivo de dado nenhum), mas o
# padrao de "erro real nunca sai como exit 0" se mantem (BL-030).
$env:CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS = "0"
$tmpLog = "c:\Users\usuario\Desktop\Projeto-professor-William\auditoria\auditoria-automacao-ultima-execucao.tmp"
$logFinal = "c:\Users\usuario\Desktop\Projeto-professor-William\auditoria\auditoria-automacao-ultima-execucao.log"
# Lock global (#116, A3 22/08): impede que este "claude -p" rode ao mesmo tempo
# que qualquer outro do ecossistema e estoure a RAM da maquina.
. "c:\Users\usuario\Desktop\Projeto-professor-William\automacao-n8n\claude-p-lock.ps1"
Lock-ClaudeP
try {
  $prompt | claude -p --dangerously-skip-permissions --output-format text 2>&1 | Out-File -FilePath $tmpLog -Encoding utf8
} finally {
  Unlock-ClaudeP
}

$tamanho = (Get-Item $tmpLog).Length
$texto = Get-Content -Path $tmpLog -Raw -Encoding UTF8
$pareceErro = ($tamanho -lt 200) -or ($texto -match 'session limit|rate limit|quota exceeded|usage limit')
Move-Item $tmpLog $logFinal -Force

if ($pareceErro) {
  Write-Output "FALHOU a auditoria de automacao: saida parece erro de sessao/rate limit ($tamanho bytes)"
  exit 1
}
Write-Output "auditoria de automacao concluida: $logFinal"
