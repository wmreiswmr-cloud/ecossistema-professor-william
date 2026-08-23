# Roda as rotinas do dia que ainda nao entregaram - em fila, nunca em paralelo.
#
# Criado em 21/08, quando o notebook precisou ser desligado no meio da fila. Sem
# isto, recuperar um dia interrompido exigia lembrar quais rotinas faltavam e
# rodar cada uma na mao, torcendo para nao disparar duas ao mesmo tempo.
#
# Seguro de rodar quantas vezes quiser: cada rotina passa pelo rotina-guard.ps1,
# que pula o que ja entregou hoje. O custo de rodar a toa e zero; o custo de nao
# rodar e um dia sem quadro, sem integrador e sem varredura.
#
# Fila, nao paralelo: as quatro rotinas dividem a MESMA cota de assinatura. Rodar
# junto foi o que derrubou a tarde de 21/08 inteira.

$b     = "c:\Users\usuario\Desktop\Projeto-professor-William\auditoria"
$guard = "$b\rotina-guard.ps1"
$raiz  = "c:\Users\usuario\Desktop\Projeto-professor-William"
$hoje  = Get-Date -Format 'yyyy-MM-dd'

# A pesquisa tem guard proprio (prompt de 10 trilhas, alvo datado) - entra primeiro
# porque e a mais longa e a que alimenta todas as outras.
if (-not (Test-Path "$raiz\pesquisa-diaria\$hoje.md")) {
  Write-Host "[1/4] pesquisa diaria - digest de hoje ausente, rodando..."
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$raiz\pesquisa-diaria\run-daily-guard.ps1"
  Write-Host "      exit=$LASTEXITCODE"
} else {
  Write-Host "[1/4] pesquisa diaria - digest de hoje ja existe, pulando"
}

$rotinas = @(
  @{ n = 'quadro';     s = 'quadro-diario' },
  @{ n = 'integrador'; s = 'integrador-diario' },
  @{ n = 'varredura';  s = 'varredura-diaria' }
)

$i = 1
foreach ($r in $rotinas) {
  $i++
  Write-Host "[$i/4] $($r.n)..."
  & $guard -Script "$b\$($r.s).ps1" -Log "$b\$($r.s)-ultima-execucao.log" -Nome $r.n
  Write-Host "      exit=$LASTEXITCODE"
}

Write-Host ""
Write-Host "=== motivos registrados hoje ==="
Get-Content "$b\motivos-rotinas.csv" | Where-Object { $_ -like "$hoje*" }
Get-Content "$raiz\pesquisa-diaria\motivos.csv" | Where-Object { $_ -like "$hoje*" }
