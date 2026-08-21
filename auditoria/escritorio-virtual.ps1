# Escritorio Virtual do Ecossistema
# Gera auditoria/escritorio-virtual.html a partir dos arquivos REAIS do projeto.
# Nao inventa estado: cada sinal exibido tem uma origem citada no rodape do HTML.
#
# Uso:
#   .\escritorio-virtual.ps1              gera e abre no navegador
#   .\escritorio-virtual.ps1 -Loop 60     regenera a cada 60s (pagina se auto-recarrega)
#   .\escritorio-virtual.ps1 -NoOpen      so gera o arquivo
#   .\escritorio-virtual.ps1 -SelfTest    valida o medidor contra caso de resposta conhecida

param(
  [int]$Loop = 0,
  [switch]$NoOpen,
  [switch]$SelfTest
)

$ErrorActionPreference = 'Stop'
$RAIZ = 'C:\Users\usuario\Desktop\Projeto-professor-William'
$AUD  = Join-Path $RAIZ 'auditoria'
$AGENTES_DIR = 'C:\Users\usuario\.claude\agents'
$SAIDA = Join-Path $AUD 'escritorio-virtual.html'

function Read-Safe([string]$p) {
  if (Test-Path -LiteralPath $p) { return (Get-Content -LiteralPath $p -Raw -Encoding UTF8) }
  return ''
}

function Esc([string]$s) {
  if ($null -eq $s) { return '' }
  return $s.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;').Replace('"','&quot;')
}

# ---------------------------------------------------------------- agentes
# Descoberta ao vivo do diretorio: agente novo aparece sozinho, sem lista fixa.
function Get-Agentes {
  if (-not (Test-Path -LiteralPath $AGENTES_DIR)) { return @() }
  return @(Get-ChildItem -LiteralPath $AGENTES_DIR -Filter '*.md' -File |
    ForEach-Object { $_.BaseName } | Sort-Object)
}

# ---------------------------------------------------------------- salas
# As "salas" do escritorio saem do organograma.md (fonte de verdade declarada),
# nao de uma lista hardcoded aqui. Casa nivel exato de cabecalho (Armadilha 5).
function Get-Salas([string[]]$agentes) {
  $mapa = @{}
  $conteudo = Read-Safe (Join-Path $AUD 'organograma.md')
  $sala = 'Sem sala definida'
  foreach ($linha in ($conteudo -split "`r?`n")) {
    if ($linha -match '^###\s+(.+?)\s*$') {
      $sala = $Matches[1]
    } elseif ($linha -match '^##\s+(.+?)\s*$') {
      $t = $Matches[1]
      if ($t -notmatch 'Inconsistencia|Inconsist|Fora do ecossistema') { $sala = $t }
    }
    foreach ($m in ([regex]::Matches($linha, '`([a-z0-9\-]+)`'))) {
      $nome = $m.Groups[1].Value
      if (($agentes -contains $nome) -and (-not $mapa.ContainsKey($nome))) { $mapa[$nome] = $sala }
    }
  }
  foreach ($a in $agentes) { if (-not $mapa.ContainsKey($a)) { $mapa[$a] = 'Sem sala definida' } }
  return $mapa
}

# ---------------------------------------------------------------- problemas
# problemas.md NAO tem uma tabela canonica. Aprendido lendo as linhas cruas em
# 2026-08-21, e cada armadilha aqui ja custou uma leitura errada:
#   (a) tabelas de problema aparecem DEPOIS do cabecalho "## Resolvidos"
#       (linha 560; os itens #97-#109 vivem entre as linhas 618-691) - quem usa
#       "## Resolvidos" como limite perde os 13 itens mais novos, inclusive os
#       GUT 100. E o bug real que o painel VS Code (parseProblemas) tem hoje;
#   (b) uma tabela quebra em linha em branco + prosa e CONTINUA depois com
#       linhas orfas sem cabecalho novo (ex.: #64 na linha 311) - quem para na
#       linha em branco perde o resto;
#   (c) o mesmo # reaparece em tabelas de reunioes diferentes - a ultima
#       ocorrencia vence;
#   (d) linhas editadas depois nem sempre tem a largura do cabecalho (7 ou 8
#       celulas) - o formato se decide LINHA A LINHA, nunca pelo cabecalho.
# Por isso nao existe "achar a tabela": varre o arquivo inteiro e aceita
# qualquer linha com >=7 celulas cuja 1a celula seja numero. As duas tabelas
# que NAO sao problema ("03/08 tabela de ontem" e "Recorrente") tem 6 celulas
# exatas e caem fora sozinhas - verificado nas linhas cruas, nao presumido.
$SENTINELA_PIPE = [string][char]0xFFFD

function Get-Problemas {
  $linhas = (Read-Safe (Join-Path $AUD 'problemas.md')) -split "`r?`n"
  $porId = [ordered]@{}
  foreach ($row in $linhas) {
    if (-not $row.TrimStart().StartsWith('|')) { continue }
    # Pipe escapado de markdown (\|) continua sendo o byte '|': dividir cru
    # estoura a contagem de celulas e desloca TODAS as colunas da linha (visto
    # de verdade em 2026-08-21 no item #111, que virou 12 celulas). Neutraliza
    # antes de dividir e devolve depois.
    $partes = ($row -replace '\\\|', $SENTINELA_PIPE).Split('|')
    if ($partes.Count -lt 9) { continue }
    $c = @($partes[1..($partes.Count - 2)] | ForEach-Object { $_.Trim().Replace($SENTINELA_PIPE, '|') })
    if ($c.Count -lt 7) { continue }
    $id = ($c[0] -replace '[~\s\*]', '')
    if ($id -notmatch '^\d+$') { continue }
    $idade = ''
    $prova = $c[6]
    $status = $c[5]
    if ($c.Count -ge 8) { $idade = $c[6]; $prova = $c[7] }
    $porId[$id] = [pscustomobject]@{
      Id = $id; Titulo = $c[1]; Origem = $c[2]; Dono = $c[3]
      Prazo = $c[4]; Status = $status; Idade = $idade; Prova = $prova
    }
  }
  # Status e a fonte de verdade de "resolvido", nao o texto riscado do titulo:
  # ha itens com ~~trecho~~ riscado dentro de descricao que segue aberta.
  #
  # E o marcador tem que estar ANCORADO no inicio da celula, nunca solto no
  # meio da prosa. Caso real conferido na linha crua (#104, 2026-08-21): o
  # status e "`READY` - ... nao fechado como `DONE` porque a reconciliacao
  # formal ainda nao foi feita". Um regex frouxo /DONE/ le a palavra dentro da
  # frase que diz o CONTRARIO e fecha um item aberto - erro silencioso, o item
  # some do quadro sem ninguem notar.
  return @($porId.Values | Where-Object { $_.Status -notmatch '^[\*\s`~]*(✅|DONE|CANCELLED)' })
}

# Prazo vem em formatos mistos ("**22/08**", "23/08 (verificacao); ... 03/09",
# "2026-09-04"). Pega a PRIMEIRA data do texto e copia o grupo na linha
# seguinte ao -match (Armadilha 3). Sem data legivel devolve $null - nunca
# assume vencido.
function Get-PrazoData([string]$txt) {
  if ($txt -match '(\d{4})-(\d{2})-(\d{2})') {
    $g = $Matches
    try { return [datetime]::new([int]$g[1], [int]$g[2], [int]$g[3]) } catch { return $null }
  }
  if ($txt -match '(\d{1,2})/(\d{1,2})') {
    $g = $Matches
    try { return [datetime]::new((Get-Date).Year, [int]$g[2], [int]$g[1]) } catch { return $null }
  }
  return $null
}

function Get-Gut([string]$titulo) {
  if ($titulo -match 'GUT:[^\]]*?=(\d+)') { $g = $Matches; return [int]$g[1] }
  return 0
}

# ---------------------------------------------------------------- niveis
function Get-Snapshot {
  $arqs = @(Get-ChildItem -LiteralPath $AUD -Filter 'snapshot-*.json' -File | Sort-Object Name)
  if ($arqs.Count -eq 0) { return $null }
  try { return (Get-Content -LiteralPath $arqs[-1].FullName -Raw -Encoding UTF8 | ConvertFrom-Json) }
  catch { return $null }
}

# ---------------------------------------------------------------- ultimo sinal
# O unico sinal honesto de "este agente trabalhou" que existe em arquivo:
# a data do registro escrito em que o nome dele aparece. Nao e "processo
# rodando" e o HTML diz isso com todas as letras no rodape.
function Get-UltimoSinal([string[]]$agentes) {
  $mapa = @{}
  $fontes = @()
  $fontes += @(Get-ChildItem -LiteralPath $AUD -Filter '*.md' -File |
    Where-Object { $_.Name -match '^(\d{4})-(\d{2})-(\d{2})' })
  $pd = Join-Path $RAIZ 'pesquisa-diaria'
  if (Test-Path -LiteralPath $pd) {
    $fontes += @(Get-ChildItem -LiteralPath $pd -Filter '*.md' -File |
      Where-Object { $_.Name -match '^(\d{4})-(\d{2})-(\d{2})' })
  }
  foreach ($f in ($fontes | Sort-Object Name)) {
    if ($f.Name -notmatch '^(\d{4}-\d{2}-\d{2})') { continue }
    $g = $Matches
    $data = $g[1]
    $texto = Read-Safe $f.FullName
    if ([string]::IsNullOrWhiteSpace($texto)) { continue }
    foreach ($a in $agentes) {
      if ($texto.Contains($a)) {
        if ((-not $mapa.ContainsKey($a)) -or ($mapa[$a] -lt $data)) { $mapa[$a] = $data }
      }
    }
  }
  return $mapa
}

# ---------------------------------------------------------------- rotinas
# Armadilha 28: todo monitor de artefato final tem que olhar tambem o sinal de
# trabalho parcial. Aqui: tamanho + primeira linha do log, nao so "existe".
function Get-Rotinas {
  $defs = @(
    @{ Nome = 'Pesquisa diaria (trilhas)'; Log = (Join-Path $RAIZ 'pesquisa-diaria\ultima-execucao.log') },
    @{ Nome = 'Auditoria da automacao';    Log = (Join-Path $AUD 'auditoria-automacao-ultima-execucao.log') },
    @{ Nome = 'Varredura diaria';          Log = (Join-Path $AUD 'varredura-diaria-ultima-execucao.log') },
    @{ Nome = 'Quadro diario (GUT)';       Log = (Join-Path $AUD 'quadro-diario-ultima-execucao.log') },
    @{ Nome = 'Integrador diario';         Log = (Join-Path $AUD 'integrador-diario-ultima-execucao.log') },
    @{ Nome = 'Reuniao do Diretor';        Log = (Join-Path $RAIZ 'reuniao-diretor\ultima-execucao.log') }
  )
  $saida = @()
  foreach ($d in $defs) {
    $quando = ''; $bytes = -1; $trecho = 'log nunca criado'
    if (Test-Path -LiteralPath $d.Log) {
      $fi = Get-Item -LiteralPath $d.Log
      $quando = $fi.LastWriteTime.ToString('dd/MM HH:mm')
      $bytes = $fi.Length
      if ($bytes -eq 0) {
        $trecho = 'arquivo vazio (0 bytes) - escreveu o log mas nao gravou conteudo'
      } else {
        $primeira = @(Get-Content -LiteralPath $d.Log -TotalCount 3 -Encoding UTF8) -join ' '
        $trecho = $primeira.Trim()
        if ($trecho.Length -gt 150) { $trecho = $trecho.Substring(0, 150) + '...' }
      }
    }
    $saida += [pscustomobject]@{ Nome = $d.Nome; Quando = $quando; Bytes = $bytes; Trecho = $trecho }
  }
  return $saida
}

function Get-Tarefas {
  $alvo = 'N8N-Servidor-Persistente|ReuniaoDiretorTime|BackupGitEcossistema|WatchdogJanelasClaude|Cerebro'
  $saida = @()
  try {
    foreach ($t in (Get-ScheduledTask | Where-Object { $_.TaskName -match $alvo })) {
      $info = Get-ScheduledTaskInfo $t
      $ultima = ''
      if ($info.LastRunTime) { $ultima = $info.LastRunTime.ToString('dd/MM HH:mm') }
      $saida += [pscustomobject]@{
        Nome = $t.TaskName; Estado = [string]$t.State
        Ultima = $ultima; Resultado = $info.LastTaskResult
      }
    }
  } catch { }
  return @($saida | Sort-Object Nome)
}

# Checagem AO VIVO, nunca arquivo de status: um status gravado mentiria "ok"
# depois do processo cair.
function Test-N8n {
  foreach ($porta in 5678, 5679) {
    try {
      $r = Invoke-WebRequest -Uri ("http://localhost:{0}/healthz" -f $porta) -TimeoutSec 3 -UseBasicParsing
      if ($r.StatusCode -eq 200) { return ("no ar (porta {0})" -f $porta) }
    } catch { }
  }
  return 'FORA DO AR (5678 e 5679 sem resposta)'
}

# ---------------------------------------------------------------- html
function New-Html {
  $hoje = Get-Date
  $hojeStr = $hoje.ToString('yyyy-MM-dd')
  $agentes = Get-Agentes
  $salas = Get-Salas $agentes
  $problemas = Get-Problemas
  $snap = Get-Snapshot
  $sinal = Get-UltimoSinal $agentes
  $rotinas = Get-Rotinas
  $tarefas = Get-Tarefas
  $n8n = Test-N8n

  $niveis = @{}
  if ($snap -and $snap.niveis) {
    foreach ($p in $snap.niveis.PSObject.Properties) { $niveis[$p.Name] = $p.Value }
  }

  $vencidos = @($problemas | Where-Object {
    $d = Get-PrazoData $_.Prazo
    ($null -ne $d) -and ($d -lt $hoje.Date)
  })

  # ---- mesas por agente
  $mesas = @{}
  foreach ($a in $agentes) {
    $meus = @($problemas | Where-Object { $_.Dono -like ("*{0}*" -f $a) })
    $ultimo = ''
    if ($sinal.ContainsKey($a)) { $ultimo = $sinal[$a] }
    $dias = -1
    if ($ultimo) { $dias = [int]((New-TimeSpan -Start ([datetime]$ultimo) -End $hoje.Date).TotalDays) }
    $classe = 'mudo'; $rotulo = 'sem registro escrito'
    if ($dias -eq 0)                      { $classe = 'hoje';   $rotulo = 'aparece no registro de hoje' }
    elseif (($dias -ge 1) -and ($dias -le 3)) { $classe = 'ativo';  $rotulo = ("ultimo registro ha {0}d" -f $dias) }
    elseif ($dias -gt 3)                  { $classe = 'quieto'; $rotulo = ("ultimo registro ha {0}d" -f $dias) }
    $nivel = ''
    if ($niveis.ContainsKey($a)) { $nivel = [string]$niveis[$a] }
    $mesas[$a] = [pscustomobject]@{
      Nome = $a; Classe = $classe; Rotulo = $rotulo; Ultimo = $ultimo
      Nivel = $nivel; Itens = $meus
    }
  }

  $sb = New-Object System.Text.StringBuilder
  function Add([string]$t) { [void]$sb.AppendLine($t) }

  $refresh = ''
  if ($Loop -gt 0) { $refresh = ('<meta http-equiv="refresh" content="{0}">' -f $Loop) }

  Add '<!doctype html><html lang="pt-BR"><head><meta charset="utf-8">'
  Add '<meta name="viewport" content="width=device-width,initial-scale=1">'
  Add '<title>Escritorio Virtual do Ecossistema</title>'
  Add $refresh
  Add @'
<style>
*{box-sizing:border-box}
body{margin:0;background:#0d1117;color:#e6edf3;font:14px/1.5 "Segoe UI",system-ui,sans-serif}
header{padding:20px 24px;border-bottom:1px solid #21262d;background:#010409;position:sticky;top:0;z-index:5}
h1{margin:0 0 4px;font-size:19px;letter-spacing:-.2px}
.sub{color:#7d8590;font-size:12px}
.kpis{display:flex;gap:10px;flex-wrap:wrap;margin-top:14px}
.kpi{background:#0d1117;border:1px solid #21262d;border-radius:8px;padding:8px 14px;min-width:110px}
.kpi b{display:block;font-size:20px;font-weight:600}
.kpi span{color:#7d8590;font-size:11px;text-transform:uppercase;letter-spacing:.4px}
.kpi.bad b{color:#f85149} .kpi.warn b{color:#d29922} .kpi.good b{color:#3fb950}
main{padding:24px;max-width:1500px;margin:0 auto}
h2{font-size:13px;text-transform:uppercase;letter-spacing:.8px;color:#7d8590;margin:32px 0 12px;font-weight:600}
h2:first-child{margin-top:0}
.salas{display:grid;grid-template-columns:repeat(auto-fill,minmax(330px,1fr));gap:14px}
.sala{background:#0d1117;border:1px solid #21262d;border-radius:10px;padding:14px}
.sala h3{margin:0 0 10px;font-size:13px;font-weight:600;display:flex;justify-content:space-between;gap:8px}
.sala h3 em{font-style:normal;color:#7d8590;font-weight:400;font-size:11px}
.mesa{display:flex;align-items:center;gap:8px;padding:6px 0;border-top:1px solid #161b22}
.mesa:first-of-type{border-top:0}
.dot{width:8px;height:8px;border-radius:50%;flex:0 0 8px}
.hoje .dot{background:#3fb950;box-shadow:0 0 0 3px rgba(63,185,80,.15)}
.ativo .dot{background:#58a6ff} .quieto .dot{background:#d29922} .mudo .dot{background:#30363d}
.nome{flex:1;font-family:ui-monospace,Consolas,monospace;font-size:12px}
.mudo .nome{color:#6e7681}
.tag{font-size:10px;padding:1px 6px;border-radius:20px;border:1px solid #30363d;color:#8b949e;white-space:nowrap}
.tag.n{border-color:#1f6feb;color:#79c0ff}
.tag.p{border-color:#8b3a1f;color:#ffa657}
table{width:100%;border-collapse:collapse;font-size:12.5px}
th{text-align:left;color:#7d8590;font-weight:600;font-size:11px;text-transform:uppercase;padding:6px 10px;border-bottom:1px solid #21262d}
td{padding:8px 10px;border-bottom:1px solid #161b22;vertical-align:top}
tr:last-child td{border-bottom:0}
code{font-family:ui-monospace,Consolas,monospace;font-size:11.5px;color:#79c0ff}
.pill{font-size:11px;padding:2px 8px;border-radius:20px;display:inline-block}
.pill.ok{background:rgba(63,185,80,.12);color:#3fb950}
.pill.err{background:rgba(248,81,73,.12);color:#f85149}
.pill.warn{background:rgba(210,153,34,.12);color:#d29922}
.g100{color:#f85149;font-weight:600}.g60{color:#ffa657}.g30{color:#d29922}
footer{padding:20px 24px 40px;color:#6e7681;font-size:11.5px;max-width:1500px;margin:0 auto;line-height:1.7}
footer b{color:#8b949e}
.card{background:#0d1117;border:1px solid #21262d;border-radius:10px;padding:4px 6px}
</style></head><body>
'@

  # ---- header
  Add '<header>'
  Add '<h1>Escritorio Virtual do Ecossistema</h1>'
  Add ('<div class="sub">Gerado em {0} &middot; leitura direta dos arquivos do projeto, nada estimado</div>' -f (Esc $hoje.ToString('dd/MM/yyyy HH:mm:ss')))
  Add '<div class="kpis">'
  Add ('<div class="kpi"><span>Agentes</span><b>{0}</b></div>' -f $agentes.Count)
  $trabHoje = @($mesas.Values | Where-Object { $_.Classe -eq 'hoje' }).Count
  Add ('<div class="kpi good"><span>No registro de hoje</span><b>{0}</b></div>' -f $trabHoje)
  Add ('<div class="kpi warn"><span>Problemas abertos</span><b>{0}</b></div>' -f $problemas.Count)
  $clsV = 'kpi good'; if ($vencidos.Count -gt 0) { $clsV = 'kpi bad' }
  Add ('<div class="{0}"><span>Prazo vencido</span><b>{1}</b></div>' -f $clsV, $vencidos.Count)
  if ($snap) {
    Add ('<div class="kpi"><span>Nivel medio</span><b>{0}</b></div>' -f (Esc ([string]$snap.mediaNivel)))
  }
  $clsN = 'kpi bad'; if ($n8n -like 'no ar*') { $clsN = 'kpi good' }
  Add ('<div class="{0}"><span>n8n (ao vivo)</span><b style="font-size:13px">{1}</b></div>' -f $clsN, (Esc $n8n))
  Add '</div></header><main>'

  # ---- salas
  Add '<h2>Salas do escritorio</h2><div class="salas">'
  $ordem = @($salas.Values | Sort-Object -Unique)
  foreach ($sala in $ordem) {
    $doSala = @($agentes | Where-Object { $salas[$_] -eq $sala })
    if ($doSala.Count -eq 0) { continue }
    $ativosSala = @($doSala | Where-Object { $mesas[$_].Classe -eq 'hoje' }).Count
    Add '<div class="sala">'
    Add ('<h3><span>{0}</span><em>{1} de {2} no registro de hoje</em></h3>' -f (Esc $sala), $ativosSala, $doSala.Count)
    foreach ($a in $doSala) {
      $m = $mesas[$a]
      Add ('<div class="mesa {0}" title="{1}">' -f $m.Classe, (Esc $m.Rotulo))
      Add '<i class="dot"></i>'
      Add ('<span class="nome">{0}</span>' -f (Esc $a))
      if ($m.Nivel) { Add ('<span class="tag n">niv {0}</span>' -f (Esc $m.Nivel)) }
      if ($m.Itens.Count -gt 0) { Add ('<span class="tag p">{0} aberto(s)</span>' -f $m.Itens.Count) }
      Add ('<span class="tag">{0}</span>' -f (Esc $m.Rotulo))
      Add '</div>'
    }
    Add '</div>'
  }
  Add '</div>'

  # ---- rotinas
  Add '<h2>Rotinas - ultima execucao real (artefato + sinal de trabalho parcial)</h2>'
  Add '<div class="card"><table><tr><th>Rotina</th><th>Ultimo log</th><th>Bytes</th><th>Primeiras linhas do log (cru)</th></tr>'
  foreach ($r in $rotinas) {
    $pill = '<span class="pill ok">com conteudo</span>'
    if ($r.Bytes -lt 0) { $pill = '<span class="pill err">nunca criado</span>' }
    elseif ($r.Bytes -eq 0) { $pill = '<span class="pill err">vazio</span>' }
    elseif ($r.Trecho -match 'session limit|disabled|error|Error|Warning') { $pill = '<span class="pill warn">com erro no texto</span>' }
    $b = ''
    if ($r.Bytes -ge 0) { $b = [string]$r.Bytes }
    Add ('<tr><td><b>{0}</b></td><td><code>{1}</code></td><td>{2} {3}</td><td>{4}</td></tr>' -f `
      (Esc $r.Nome), (Esc $r.Quando), (Esc $b), $pill, (Esc $r.Trecho))
  }
  Add '</table></div>'

  # ---- tarefas
  Add '<h2>Tarefas agendadas do Windows (estado real do produtor)</h2>'
  Add '<div class="card"><table><tr><th>Tarefa</th><th>Estado</th><th>Ultima execucao</th><th>Resultado</th></tr>'
  foreach ($t in $tarefas) {
    $pill = '<span class="pill ok">0</span>'
    if ($t.Resultado -ne 0) { $pill = ('<span class="pill err">{0}</span>' -f $t.Resultado) }
    $ep = '<span class="pill ok">Ready</span>'
    if ($t.Estado -ne 'Ready') { $ep = ('<span class="pill warn">{0}</span>' -f (Esc $t.Estado)) }
    Add ('<tr><td><code>{0}</code></td><td>{1}</td><td>{2}</td><td>{3}</td></tr>' -f `
      (Esc $t.Nome), $ep, (Esc $t.Ultima), $pill)
  }
  Add '</table></div>'

  # ---- quadro
  Add ('<h2>Quadro aberto - {0} itens, ordenados por GUT</h2>' -f $problemas.Count)
  Add '<div class="card"><table><tr><th>#</th><th>GUT</th><th>Problema</th><th>Dono</th><th>Prazo</th><th>Status</th></tr>'
  $ord = @($problemas | Sort-Object -Property @{ Expression = { Get-Gut $_.Titulo } } -Descending)
  foreach ($p in $ord) {
    $gut = Get-Gut $p.Titulo
    $cls = ''
    if ($gut -ge 100) { $cls = 'g100' } elseif ($gut -ge 60) { $cls = 'g60' } elseif ($gut -ge 30) { $cls = 'g30' }
    $tit = ($p.Titulo -replace '\[GUT:[^\]]*\]', '' -replace '\*\*', '').Trim()
    if ($tit.Length -gt 190) { $tit = $tit.Substring(0, 190) + '...' }
    $d = Get-PrazoData $p.Prazo
    $prazoTxt = ($p.Prazo -replace '\*\*', '')
    if ($prazoTxt.Length -gt 40) { $prazoTxt = $prazoTxt.Substring(0, 40) + '...' }
    if (($null -ne $d) -and ($d -lt $hoje.Date)) { $prazoTxt = ('<span class="pill err">{0}</span>' -f (Esc $prazoTxt)) }
    else { $prazoTxt = (Esc $prazoTxt) }
    $st = ($p.Status -replace '\*\*', '')
    if ($st.Length -gt 60) { $st = $st.Substring(0, 60) + '...' }
    $dono = ($p.Dono -replace '\*\*', '')
    if ($dono.Length -gt 50) { $dono = $dono.Substring(0, 50) + '...' }
    Add ('<tr><td>{0}</td><td class="{1}">{2}</td><td>{3}</td><td><code>{4}</code></td><td>{5}</td><td>{6}</td></tr>' -f `
      (Esc $p.Id), $cls, $gut, (Esc $tit), (Esc $dono), $prazoTxt, (Esc $st))
  }
  Add '</table></div></main>'

  # ---- rodape: de onde vem cada sinal (sem isso o painel vira achismo bonito)
  Add '<footer>'
  Add '<b>De onde vem cada sinal, para nao virar achismo formatado:</b><br>'
  Add ('&bull; <b>Mesas e salas</b>: agentes descobertos ao vivo em <code>~/.claude/agents/*.md</code> ({0} arquivos); a sala vem de <code>auditoria/organograma.md</code>.<br>' -f $agentes.Count)
  Add '&bull; <b>Ponto verde "aparece no registro de hoje"</b> significa exatamente isto: o nome do agente aparece por escrito num arquivo datado de hoje em <code>auditoria/</code> ou <code>pesquisa-diaria/</code>. <b>Nao</b> quer dizer que ha um processo rodando agora - esse sinal nao existe em arquivo nenhum, e inventar um seria alerta falso.<br>'
  Add '&bull; <b>Rotinas</b>: data/tamanho/primeiras linhas cruas do proprio log. Log vazio aparece como vazio, nao como sucesso - artefato final e sinal de trabalho parcial sao coisas diferentes.<br>'
  Add '&bull; <b>Tarefas agendadas</b>: <code>Get-ScheduledTaskInfo</code> ao vivo (estado do produtor, nao o relogio).<br>'
  Add '&bull; <b>n8n</b>: GET real em <code>/healthz</code> no momento da geracao, nunca arquivo de status.<br>'
  Add '&bull; <b>Quadro</b>: <code>auditoria/problemas.md</code>, agregando todas as tabelas; aberto = Status sem ✅/DONE/CANCELLED.<br>'
  Add '&bull; <b>Nivel</b>: snapshot datado mais recente em <code>auditoria/snapshot-*.json</code>.<br>'
  if ($Loop -gt 0) { Add ('&bull; Auto-recarga a cada {0}s (modo -Loop).' -f $Loop) }
  else { Add '&bull; Retrato do instante acima. Para acompanhar ao vivo: <code>.\escritorio-virtual.ps1 -Loop 60</code>.' }
  Add '</footer></body></html>'

  return $sb.ToString()
}

# ---------------------------------------------------------------- self-test
# Armadilha 6: medidor novo e validado contra caso de resposta conhecida antes
# de entrar em operacao. Aqui o "conhecido" e contado por caminho independente
# do usado pelo painel.
function Invoke-SelfTest {
  $falhas = 0
  $agentes = Get-Agentes
  $esperado = @(Get-ChildItem -LiteralPath $AGENTES_DIR -Filter '*.md' -File).Count
  if ($agentes.Count -ne $esperado) { Write-Host "FALHA agentes: $($agentes.Count) != $esperado"; $falhas++ }
  else { Write-Host "ok  agentes = $($agentes.Count)" }

  $probs = Get-Problemas
  if ($probs.Count -lt 1) { Write-Host 'FALHA problemas: nenhum item aberto lido'; $falhas++ }
  else { Write-Host "ok  problemas abertos = $($probs.Count)" }
  $ids = @($probs | ForEach-Object { $_.Id })
  # Casos de resposta conhecida, conferidos a mao na linha crua de problemas.md
  # em 2026-08-21. Sao exatamente os que o parser anterior perdia em silencio:
  #   #107/#108/#109 estao DEPOIS do cabecalho "## Resolvidos" (linhas 689-691)
  #   #64 e linha orfa, depois de linha em branco + prosa (linha 311)
  # #104 tem a palavra DONE no meio de uma frase que diz que NAO esta fechado
  # #111 tem pipe escapado (\|) dentro da celula: divisao crua estoura a
  # contagem e desloca todas as colunas
  foreach ($esp in '107', '108', '109', '64', '104', '111') {
    if ($ids -notcontains $esp) { Write-Host "FALHA item conhecido #$esp nao foi lido"; $falhas++ }
    else { Write-Host "ok  item conhecido #$esp lido" }
  }
  # ler o item nao basta: com pipe escapado a linha e lida com as colunas
  # DESLOCADAS, o que e pior que nao ler (Dono/Prazo/Status trocados de lugar).
  $p111 = @($probs | Where-Object { $_.Id -eq '111' })
  if ($p111.Count -eq 1 -and $p111[0].Dono -match 'product-architect') { Write-Host 'ok  #111 com colunas alinhadas (Dono correto)' }
  else { Write-Host "FALHA #111 colunas deslocadas. Dono lido: '$($p111[0].Dono)'"; $falhas++ }
  $dupes = @($ids | Group-Object | Where-Object { $_.Count -gt 1 })
  if ($dupes.Count -gt 0) { Write-Host "FALHA ids duplicados: $($dupes.Name -join ',')"; $falhas++ }
  else { Write-Host 'ok  nenhum # duplicado' }
  $resolvidoVazado = @($probs | Where-Object { $_.Status -match '^[\*\s`~]*(✅|DONE|CANCELLED)' })
  if ($resolvidoVazado.Count -gt 0) { Write-Host "FALHA resolvido na lista de abertos: $($resolvidoVazado[0].Id)"; $falhas++ }
  else { Write-Host 'ok  nenhum resolvido vazou para abertos' }

  $d = Get-PrazoData '**22/08**'
  if ($d.Month -ne 8 -or $d.Day -ne 22) { Write-Host "FALHA prazo dd/mm: $d"; $falhas++ } else { Write-Host 'ok  prazo **22/08**' }
  $d2 = Get-PrazoData '2026-09-04 (SLA)'
  if ($d2.Month -ne 9 -or $d2.Day -ne 4) { Write-Host "FALHA prazo iso: $d2"; $falhas++ } else { Write-Host 'ok  prazo 2026-09-04' }
  if ($null -ne (Get-PrazoData 'sem data aqui')) { Write-Host 'FALHA prazo sem data devia ser null'; $falhas++ }
  else { Write-Host 'ok  texto sem data -> null (nao assume vencido)' }
  $g = Get-Gut '[GUT: G5xU5xT4=100 X] texto'
  if ($g -ne 100) { Write-Host "FALHA gut: $g"; $falhas++ } else { Write-Host 'ok  GUT=100' }

  $salas = Get-Salas $agentes
  if ($salas['cerebro-ecossistema'] -notmatch 'Diretor') { Write-Host "FALHA sala do Diretor: $($salas['cerebro-ecossistema'])"; $falhas++ }
  else { Write-Host "ok  sala de cerebro-ecossistema = $($salas['cerebro-ecossistema'])" }

  if ($falhas -eq 0) { Write-Host "`nSELF-TEST OK" } else { Write-Host "`nSELF-TEST FALHOU: $falhas" ; exit 1 }
}

if ($SelfTest) { Invoke-SelfTest; return }

do {
  $html = New-Html
  [System.IO.File]::WriteAllText($SAIDA, $html, (New-Object System.Text.UTF8Encoding $true))
  Write-Host ("[{0}] escritorio-virtual.html atualizado" -f (Get-Date -Format 'HH:mm:ss'))
  if ((-not $NoOpen) -and (-not $script:abriu)) { Start-Process $SAIDA; $script:abriu = $true }
  if ($Loop -gt 0) { Start-Sleep -Seconds $Loop }
} while ($Loop -gt 0)
