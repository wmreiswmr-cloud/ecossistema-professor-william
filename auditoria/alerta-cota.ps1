# Poka-yoke da parte B do item #126 -- autorizado pelo dono William em 2026-08-28.
#
# POR QUE EXISTE (a licao de 28/08, nao teoria):
# O item #127 foi aberto sobre a mensagem do errorWorkflow (missionControl00001) e
# passou 2 dias apontando para a variavel errada ("defeito de EncodedCommand").
# A mensagem do errorWorkflow diz QUE falhou, nunca POR QUE: ela carrega o stack do
# n8n, nao o stdout do script. A causa real -- cota de sessao do claude -p -- estava
# o tempo todo no stdout e no motivos.csv, dois lugares que ninguem le como quadro.
#
# Este script fecha o buraco: no MOMENTO em que o guard classifica o motivo, a linha
# CRUA vai para alertas-automaticos.md, que e onde o Mission Control tambem escreve.
# Assim quem for abrir item ja encontra a evidencia ao lado do resumo, e nao pode
# repetir o #127.
#
# Nao substitui o motivos.csv (que e serie historica) nem o Mission Control (que
# pega falha de qualquer no, nao so de rotina). E o terceiro registro, o unico que
# fica ao lado do resumo enganoso.
#
# ASCII puro de proposito: .ps1 sem BOM so e seguro se nao tiver acento nem emoji
# (Armadilha 2).

param(
  [Parameter(Mandatory=$true)][string]$Rotina,
  [Parameter(Mandatory=$true)][string]$Motivo,
  [string]$Log = "",
  [string]$Alertas = "c:\Users\usuario\Desktop\Projeto-professor-William\auditoria\alertas-automaticos.md"
)

# "ok" nao e falha. "pulou - ..." e o guard funcionando (idempotencia/instancia
# unica), nao problema -- alertar nisso treinaria o dono a ignorar o painel, que e
# exatamente a Armadilha 7 (alerta falso e pior que alerta nenhum).
if ($Motivo -eq "ok" -or $Motivo -like "pulou -*") { exit 0 }

# A linha crua: o pedaco do log que contem a assinatura do erro. E ISTO que faltava.
$linhaCrua = "(log nao encontrado: $Log)"
if ($Log -and (Test-Path $Log)) {
  $texto = Get-Content $Log -Raw
  if (-not $texto -or -not $texto.Trim()) {
    $linhaCrua = "(log vazio -- a rotina morreu sem escrever nada)"
  } else {
    $achadas = @(Get-Content $Log | Where-Object {
      $_ -match 'session limit|disabled Claude subscription|Background tasks still running|being used by another process|unknown option'
    })
    if ($achadas.Count -gt 0) {
      $linhaCrua = ($achadas | Select-Object -First 3) -join ' / '
    } else {
      # Sem assinatura conhecida: mostra o fim do log, que e onde o erro costuma cair.
      $ultimas = @(Get-Content $Log)
      $n = [Math]::Min(3, $ultimas.Count)
      $linhaCrua = ($ultimas | Select-Object -Last $n) -join ' / '
    }
  }
}

$carimbo = Get-Date -Format 'yyyy-MM-dd HH:mm'
$bloco = @"

## $carimbo -- guard da rotina "$Rotina" (automatico, poka-yoke do #126)

A rotina NAO entregou. Motivo classificado pelo guard: **$Motivo**

Linha crua do log (`$Log`) -- esta e a evidencia, o resto e resumo:

``````
$linhaCrua
``````

> Antes de abrir item no quadro sobre esta falha: use ESTA linha, nunca a mensagem
> do Mission Control. A mensagem do errorWorkflow carrega o stack do n8n e diz QUE
> falhou, nunca POR QUE -- foi assim que o #127 nasceu errado em 26/08 e so foi
> refutado em 28/08.
"@

Add-Content -Path $Alertas -Value $bloco -Encoding utf8
exit 0
