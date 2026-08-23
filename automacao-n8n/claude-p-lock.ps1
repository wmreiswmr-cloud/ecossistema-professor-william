# Lock global entre TODAS as chamadas "claude -p" do ecossistema (n8n + Task Scheduler).
#
# Por que existe: A3 do #116 (auditoria/problemas.md, 22/08) mediu que uma unica
# invocacao de "claude -p" custa ~800MB-1GB de RAM real nesta maquina, que roda
# cronicamente com ~2-3GB livres (18,9% medido). 2 invocacoes concorrentes ja bastam
# para estourar a memoria e crashar o node do n8n (NodeCrashedError) - 3 ocorrencias
# reais desde 15/08 (#75, depois #116 em 20/08 e 21/08), com concorrencia confirmada
# via search_executions nas duas ultimas. Poka-yoke: torna a concorrencia IMPOSSIVEL,
# nao apenas rara - um lock de arquivo com fila (retry) antes de qualquer "claude -p".
#
# Uso: dot-source este arquivo e envolva a chamada "claude -p" em try/finally:
#   . "c:\...\automacao-n8n\claude-p-lock.ps1"
#   Lock-ClaudeP
#   try { ...claude -p... } finally { Unlock-ClaudeP }

$script:ClaudePLockFile = "c:\Users\usuario\Desktop\Projeto-professor-William\automacao-n8n\claude-p.lock"
$script:ClaudePLockHandle = $null

function Lock-ClaudeP {
  param([int]$TimeoutSeg = 600)
  $inicio = Get-Date
  while ($true) {
    try {
      $script:ClaudePLockHandle = [System.IO.File]::Open($script:ClaudePLockFile, 'OpenOrCreate', 'ReadWrite', 'None')
      return
    } catch {
      if (((Get-Date) - $inicio).TotalSeconds -gt $TimeoutSeg) {
        throw "Lock-ClaudeP: esperei $TimeoutSeg s por outra chamada claude -p liberar o lock (automacao-n8n/claude-p.lock) e ela nao liberou. Abortando em vez de arriscar crash por falta de memoria."
      }
      Start-Sleep -Seconds 5
    }
  }
}

function Unlock-ClaudeP {
  if ($script:ClaudePLockHandle) {
    $script:ClaudePLockHandle.Close()
    $script:ClaudePLockHandle = $null
  }
}
