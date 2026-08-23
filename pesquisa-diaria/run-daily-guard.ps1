# Guarda de idempotencia + instancia unica + registro de motivo para a pesquisa
# diaria (item #103).
#
# Causa raiz medida (21/08): a assinatura e UMA so, compartilhada entre a sessao
# interativa do dono e o headless. O gatilho fixo do meio-dia cai no pico de uso do
# dono, o claude -p morre com "session limit" ou "disabled Claude subscription
# access", e o dia inteiro se perde - porque nao existe segunda tentativa nem
# registro do motivo. Sem o motivo gravado, o mesmo bloqueio voltou ao quadro tres
# vezes com numeros diferentes (#87, #103, #108) como se fosse achado novo.
#
# Segundo defeito, achado ao rodar isto de verdade as 18:19 do dia 21/08 (nao por
# leitura de codigo): DUAS execucoes de run-daily.ps1 no ar ao mesmo tempo. A
# segunda morre em segundos com IOException porque ultima-execucao.log ja esta
# aberto pela primeira. Isso produz exatamente a assinatura das falhas de 0.1 a
# 0.5 min em duracoes.csv (10/08, 11/08, 18/08, 20/08) - que ate agora foram todas
# atribuidas a cota. Nao da para saber quais eram cota e quais eram colisao, porque
# o log e sobrescrito por quem ganha a corrida; e por isso que motivos.csv passa a
# existir em vez de so o booleano digest_escrito.
#
# Este wrapper NAO altera run-daily.ps1 (61 linhas, prompt de 9,5 mil caracteres -
# reescrever aquele arquivo por causa de controle de execucao e risco sem ganho).

param([switch]$DryRun)

$raiz    = "c:\Users\usuario\Desktop\Projeto-professor-William\pesquisa-diaria"
$hoje    = Get-Date -Format 'yyyy-MM-dd'
$alvo    = Join-Path $raiz "$hoje.md"
$log     = Join-Path $raiz "ultima-execucao.log"
$motivos = Join-Path $raiz "motivos.csv"

function Anota($texto) {
  "$hoje;$(Get-Date -Format 'HH:mm');$texto" | Out-File -FilePath $motivos -Encoding utf8 -Append
}

if (-not (Test-Path $motivos)) {
  "data;hora;motivo" | Out-File -FilePath $motivos -Encoding utf8
}

# Idempotencia: com isto, a segunda janela de retentativa fora do pico nao gera
# pesquisa duplicada nem sobrescreve o digest ja escrito.
if (Test-Path $alvo) {
  Anota "pulou - digest do dia ja existe"
  exit 0
}

# Instancia unica: o proprio arquivo que as duas execucoes disputam e o cadeado.
# Se nao der para abri-lo com acesso exclusivo, ja ha uma pesquisa no ar - sair sem
# competir e melhor do que morrer em 0.3 min e gravar False como se fosse cota.
if (Test-Path $log) {
  try {
    $lock = [System.IO.File]::Open($log, 'Open', 'Write', 'None')
    $lock.Close()
  } catch {
    Anota "pulou - ja existe pesquisa em execucao (log bloqueado)"
    exit 0
  }
}

if (-not $DryRun) {
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $raiz "run-daily.ps1")
}

$motivo = "desconhecido - ver ultima-execucao.log"
if (Test-Path $alvo) {
  $motivo = "ok"
} elseif (Test-Path $log) {
  $texto = Get-Content $log -Raw
  if     ($texto -match 'session limit')                  { $motivo = "cota - session limit" }
  elseif ($texto -match 'disabled Claude subscription')   { $motivo = "cota - subscription access negado" }
  elseif ($texto -match 'Background tasks still running') { $motivo = "teto de background do claude.exe" }
  elseif ($texto -match 'being used by another process')  { $motivo = "colisao - log em uso por outra execucao" }
  elseif ($texto -match 'unknown option')                 { $motivo = "prompt quebrado na linha de comando (Armadilha 36)" }
}

Anota $motivo

# Exit code real: sem isto o n8n marca sucesso mesmo com o digest ausente, que foi
# como execucoes sem trabalho entregue apareceram verdes no historico.
if ($motivo -ne "ok") { exit 1 }
