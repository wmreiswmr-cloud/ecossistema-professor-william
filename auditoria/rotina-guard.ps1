# Guard generico das rotinas headless (quadro, integrador, varredura, auditoria).
#
# Por que existe: em 21/08 as tres rotinas do dia morreram com a MESMA mensagem -
# "You've hit your session limit - resets 6pm" - as 13:35 (pesquisa), 16:21 (quadro)
# e 16:45 (integrador). Nenhuma delas devolvia codigo de erro: o padrao
# "$null | claude -p ... | Out-File" faz o PowerShell sair com 0 mesmo quando o
# claude morre dentro do pipe. Resultado: o n8n marcou success em dias sem trabalho
# entregue (execucoes 104 e 123 do trilhasDiariasN8n01 sao a prova lida no historico).
#
# Este wrapper NAO altera nenhum dos scripts de rotina - eles continuam intactos.
# Ele so: (1) evita duas execucoes da mesma rotina brigando pelo mesmo log;
# (2) grava o motivo real da falha; (3) devolve exit code verdadeiro.
#
# Irmao de pesquisa-diaria/run-daily-guard.ps1, que ja esta em producao. Os dois
# duplicam ~15 linhas de proposito: unificar agora exigiria mexer no guard que esta
# rodando neste momento, e trocar peca em voo foi justamente o erro do #103.

param(
  [Parameter(Mandatory=$true)][string]$Script,   # .ps1 da rotina
  [Parameter(Mandatory=$true)][string]$Log,      # log que a rotina sobrescreve
  [string]$Alvo = "",                            # arquivo que prova a entrega (opcional)
  [string]$Nome = "",
  [switch]$DryRun
)

if (-not $Nome) { $Nome = [System.IO.Path]::GetFileNameWithoutExtension($Script) }

$motivos = "c:\Users\usuario\Desktop\Projeto-professor-William\auditoria\motivos-rotinas.csv"
if (-not (Test-Path $motivos)) {
  "data;hora;rotina;motivo" | Out-File -FilePath $motivos -Encoding utf8
}

function Anota($texto) {
  "$(Get-Date -Format 'yyyy-MM-dd');$(Get-Date -Format 'HH:mm');$Nome;$texto" |
    Out-File -FilePath $motivos -Encoding utf8 -Append
}

if (-not (Test-Path $Script)) {
  Anota "script nao encontrado: $Script"
  exit 1
}

# Idempotencia: se a rotina ja entregou o arquivo do dia, nao roda de novo.
if ($Alvo -and (Test-Path $Alvo)) {
  Anota "pulou - alvo do dia ja existe"
  exit 0
}

# Ja entregou hoje? Rotina sem arquivo datado (quadro, integrador) nao tem -Alvo
# para conferir, entao a prova de entrega e o proprio log: escrito hoje e sem
# assinatura de erro. Sem isto, a segunda janela da tarde repetiria trabalho ja
# feito e queimaria cota a toa - que e exatamente o recurso escasso aqui.
if ((Test-Path $Log) -and ((Get-Item $Log).LastWriteTime.Date -eq (Get-Date).Date)) {
  $jaFeito = Get-Content $Log -Raw
  if ($jaFeito -and $jaFeito.Trim() -and $jaFeito -notmatch 'session limit|disabled Claude subscription|Background tasks still running|being used by another process|unknown option') {
    Anota "pulou - ja entregou hoje (log de hoje, sem erro)"
    exit 0
  }
}

# Instancia unica: o log que as duas execucoes disputam e o proprio cadeado.
if (Test-Path $Log) {
  try {
    $lock = [System.IO.File]::Open($Log, 'Open', 'Write', 'None')
    $lock.Close()
  } catch {
    Anota "pulou - rotina ja em execucao (log bloqueado)"
    exit 0
  }
}

if (-not $DryRun) {
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Script
}

$motivo = "ok"
if ($Alvo -and -not (Test-Path $Alvo)) {
  $motivo = "rodou mas nao produziu o alvo"
}
if (Test-Path $Log) {
  $texto = Get-Content $Log -Raw
  if     ($texto -match 'session limit')                  { $motivo = "cota - session limit" }
  elseif ($texto -match 'disabled Claude subscription')   { $motivo = "cota - subscription access negado" }
  elseif ($texto -match 'Background tasks still running') { $motivo = "teto de background do claude.exe" }
  elseif ($texto -match 'being used by another process')  { $motivo = "colisao - log em uso por outra execucao" }
  elseif ($texto -match 'unknown option')                 { $motivo = "prompt quebrado na linha de comando (Armadilha 36)" }
  elseif (-not $texto -or -not $texto.Trim())              { $motivo = "log vazio - rotina morreu sem dizer por que" }
}

Anota $motivo
if ($motivo -ne "ok") { exit 1 }
