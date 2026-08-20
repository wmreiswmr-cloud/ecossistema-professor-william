# Watchdog de janelas do Claude Code -- decisao do dono, 2026-08-19.
# So mantem 1 sessao INTERATIVA aberta por vez (a mais nova). Nunca toca em
# processo headless (-p, automacao/n8n) -- distingue pela ausencia de --resume=.
# Fecha a mais antiga so depois de GRACE_MIN minutos com 2+ abertas E so se ela
# estiver ociosa (sem escrita no proprio .jsonl ha IDLE_SEG segundos), pra nunca
# matar sessao no meio de um turno.

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'   # mesmo gotcha do item #87 -- nunca deixar progress virar CLIXML no stderr

$PROJETO_DIR  = 'C:\Users\usuario\Desktop\Projeto-professor-William'
$SESSOES_DIR  = 'C:\Users\usuario\.claude\projects\c--Users-usuario-Desktop-Projeto-professor-William'
$ESTADO       = Join-Path $PROJETO_DIR 'automacao-n8n\estado-watchdog-janelas.json'
$ALERTAS      = Join-Path $PROJETO_DIR 'auditoria\alertas-automaticos.md'
$GRACE_MIN    = 5
$IDLE_SEG     = 90

function Escrever-Alerta($texto) {
  $agora = Get-Date
  $bloco = "`n## $($agora.ToString('yyyy-MM-dd HH:mm')) (America/Sao_Paulo) - watchdog-janelas.ps1 (automatico)`n`n$texto`n"
  if (-not (Test-Path $ALERTAS)) {
    Set-Content -Path $ALERTAS -Value "# Alertas automaticos - n8n`n$bloco" -Encoding utf8
  } else {
    Add-Content -Path $ALERTAS -Value $bloco -Encoding utf8
  }
}

# 1. Lista processos claude.exe interativos: tem --resume=<uuid> e NUNCA tem -p (print mode)
$procs = Get-CimInstance Win32_Process | Where-Object {
  $_.Name -eq 'claude.exe' -and
  $_.CommandLine -match '--resume=[0-9a-f-]{36}' -and
  $_.CommandLine -notmatch '(^|\s)-p(\s|$)'
}

$interativas = foreach ($p in $procs) {
  if ($p.CommandLine -match '--resume=([0-9a-f-]{36})') {
    [PSCustomObject]@{
      ProcId    = $p.ProcessId
      SessionId = $Matches[1]
      Inicio    = $p.CreationDate   # Get-CimInstance ja devolve [DateTime], nao string DMTF (Get-WmiObject devolveria string)
    }
  }
}

$estadoAnterior = [PSCustomObject]@{ desde = $null }
if (Test-Path $ESTADO) {
  try { $estadoAnterior = Get-Content $ESTADO -Raw | ConvertFrom-Json } catch { }
}

if (-not $interativas -or $interativas.Count -le 1) {
  @{ desde = $null } | ConvertTo-Json | Set-Content $ESTADO -Encoding utf8
  exit 0
}

$agora = Get-Date

if (-not $estadoAnterior.desde) {
  @{ desde = $agora.ToString('o') } | ConvertTo-Json | Set-Content $ESTADO -Encoding utf8
  Escrever-Alerta "$($interativas.Count) sessoes interativas do Claude Code abertas ao mesmo tempo (PIDs: $($interativas.ProcId -join ', ')). Monitorando -- se continuar por $GRACE_MIN min, a mais antiga fecha sozinha (so se estiver ociosa)."
  exit 0
}

$desde = [DateTime]$estadoAnterior.desde
$minutosAberta = ($agora - $desde).TotalMinutes

if ($minutosAberta -lt $GRACE_MIN) {
  exit 0
}

$maisAntiga = $interativas | Sort-Object Inicio | Select-Object -First 1
$maisNova   = $interativas | Sort-Object Inicio -Descending | Select-Object -First 1

$arquivoSessao = Join-Path $SESSOES_DIR "$($maisAntiga.SessionId).jsonl"
$ociosa = $true
if (Test-Path $arquivoSessao) {
  $ultimaEscrita = (Get-Item $arquivoSessao).LastWriteTime
  $ociosa = ((Get-Date) - $ultimaEscrita).TotalSeconds -ge $IDLE_SEG
}

if (-not $ociosa) {
  Escrever-Alerta "$($interativas.Count) sessoes interativas ha $([math]::Round($minutosAberta,1)) min, mas a mais antiga (PID $($maisAntiga.ProcId), sessao $($maisAntiga.SessionId)) ainda esta ativa (escreveu ha menos de $IDLE_SEG s) -- nao fechei, esperando ficar ociosa."
  exit 0
}

try {
  Stop-Process -Id $maisAntiga.ProcId -Force -ErrorAction Stop
  Escrever-Alerta "Fechei sozinho a sessao interativa mais antiga (PID $($maisAntiga.ProcId), sessao $($maisAntiga.SessionId), aberta $([math]::Round($minutosAberta,1)) min, ociosa ha $IDLE_SEG+ s) -- mantive a mais nova (PID $($maisNova.ProcId), sessao $($maisNova.SessionId)). Nunca toquei em processo claude -p (automacao/n8n)."
  @{ desde = $null } | ConvertTo-Json | Set-Content $ESTADO -Encoding utf8
} catch {
  Escrever-Alerta "Tentei fechar a sessao mais antiga (PID $($maisAntiga.ProcId)) e falhou: $($_.Exception.Message)"
}
