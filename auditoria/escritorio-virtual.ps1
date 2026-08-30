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

# ---------------------------------------------------------------- elenco
# Nome de pessoa por agente - escolha do dono em 2026-08-21 ("nome humano +
# cargo"). O nome e APELIDO DE EXIBICAO, nada mais: nao existe em arquivo
# nenhum do ecossistema, nao e identidade, e o slug tecnico continua impresso
# embaixo pra qualquer rastreio (arquivo do agente, coluna Dono do quadro).
# Agente novo que nao esteja aqui NAO fica sem nome: cai no fallback abaixo.
$PESSOAS = @{
  'ceo-orquestrador'                 = 'Rafael|CEO de Produto'
  'ceo-orquestrador-agencia'         = 'Bianca|CEO da Agencia'
  'cerebro-accessibility'            = 'Aline|Acessibilidade'
  'cerebro-analisador'               = 'Otavio|Diagnostico Visual'
  'cerebro-analiseusuario'           = 'Priscila|Analise de Usuario'
  'cerebro-analista-mercado'         = 'Tiago|Trend Scout'
  'cerebro-analista-mercado-agencia' = 'Denise|Pesquisa de Mercado'
  'cerebro-analista-pro'             = 'Murilo|Analise de Produto'
  'cerebro-automacao'                = 'Vinicius|Automacao n8n'
  'cerebro-brand-director'           = 'Helena|Diretora de Marca'
  'cerebro-brand-scout'              = 'Livia|Referencia Visual'
  'cerebro-branding'                 = 'Sergio|Identidade de Marca'
  'cerebro-claude-os'                = 'Ivan|Registro de Capacidades'
  'cerebro-component-library-manager'= 'Paula|Biblioteca de Componentes'
  'cerebro-copywriter'               = 'Camila|Copywriter'
  'cerebro-design-critic'            = 'Roberto|Critico de Design'
  'cerebro-design-pro'               = 'Fernanda|Design de Interface'
  'cerebro-design-system-manager'    = 'Gustavo|Design System'
  'cerebro-dominios'                 = 'Anderson|Dominios e Deploy'
  'cerebro-ecossistema'              = 'Eduardo|Diretor'
  'cerebro-editor-in-chief'          = 'Beatriz|Editora-Chefe'
  'cerebro-empreendedor'             = 'Leandro|Novos Negocios'
  'cerebro-financeiro'               = 'Cristina|Financeiro'
  'cerebro-funil'                    = 'Marcelo|Funil de Vendas'
  'cerebro-gerador-criativos'        = 'Natalia|Criativos de Anuncio'
  'cerebro-growth-hacker'            = 'Diego|Growth'
  'cerebro-integrador'               = 'Patricia|Integradora Operacional'
  'cerebro-knowledge-architect'      = 'Henrique|Arquitetura do Conhecimento'
  'cerebro-memoria-solucao'          = 'Sandra|Memoria Tecnica'
  'cerebro-motion-designer'          = 'Bruno|Motion Design'
  'cerebro-performance'              = 'Rodrigo|Performance'
  'cerebro-product-architect'        = 'Leticia|Arquitetura de Produto'
  'cerebro-qa-automation'            = 'Felipe|QA Automatizado'
  'cerebro-qualidade'                = 'Adriana|Qualidade e Lean'
  'cerebro-reitor'                   = 'Antonio|Reitor'
  'cerebro-reverse-engineering'      = 'Caio|Engenharia Reversa'
  'cerebro-saas'                     = 'Juliana|SaaS'
  'cerebro-secretario'               = 'Renata|Secretaria Executiva'
  'cerebro-sentinela'                = 'Marcio|Sentinela de Operacoes'
  'cerebro-seo'                      = 'Larissa|SEO'
  'cerebro-social-media'             = 'Isabela|Social Media'
  'cerebro-trafego'                  = 'Marina|Trafego Pago'
  'cerebro-ux-research'              = 'Carolina|Pesquisa de UX'
  'cerebro-vendas'                   = 'Douglas|Vendas'
}
$NOMES_RESERVA = @('Alice','Nelson','Vera','Ricardo','Sofia','Elias','Marta','Ubirajara','Yara','Zeca')

function Get-Pessoa([string]$slug) {
  if ($PESSOAS.ContainsKey($slug)) {
    $p = $PESSOAS[$slug].Split('|')
    return [pscustomobject]@{ Nome = $p[0]; Cargo = $p[1]; Novo = $false }
  }
  # Agente criado depois desta tabela. Nome estavel derivado do proprio slug
  # (mesmo agente = sempre o mesmo nome, sem sortear a cada geracao), e o
  # cargo sai do slug legivel. Marcado como Novo pra aparecer sinalizado no
  # painel - um nome inventado em silencio esconderia que a tabela envelheceu.
  $soma = 0
  foreach ($ch in $slug.ToCharArray()) { $soma += [int]$ch }
  $nome = $NOMES_RESERVA[$soma % $NOMES_RESERVA.Count]
  $cargo = (($slug -replace '^cerebro-', '') -replace '-', ' ')
  $cargo = (Get-Culture).TextInfo.ToTitleCase($cargo)
  return [pscustomobject]@{ Nome = $nome; Cargo = $cargo; Novo = $true }
}

# Bonequinho na mesa, desenhado em SVG inline: sem imagem externa, sem
# dependencia nova, escala sem borrar. As partes que animam tem classe propria
# (bracos, cabeca, tela) - a animacao em si e ligada/desligada pelo CSS a
# partir da CLASSE DE ESTADO REAL da mesa, nunca por padrao.
function New-Boneco {
  $svg = '<svg class="boneco" viewBox="0 0 72 60" aria-hidden="true">'
  # monitor + brilho da tela
  $svg += '<rect class="tela" x="40" y="14" width="24" height="17" rx="2"/>'
  $svg += '<rect x="50" y="31" width="4" height="4" class="pe-monitor"/>'
  # cabeca e tronco
  $svg += '<circle class="cabeca" cx="22" cy="17" r="7"/>'
  $svg += '<path class="tronco" d="M12 42 q0-13 10-13 q10 0 10 13 z"/>'
  # bracos (o que digita)
  $svg += '<path class="braco be" d="M14 33 q-4 5 2 8"/>'
  $svg += '<path class="braco bd" d="M30 33 q4 5 -2 8"/>'
  # mesa e teclado
  $svg += '<rect class="mesa-svg" x="6" y="42" width="60" height="3" rx="1.5"/>'
  $svg += '<rect class="teclado" x="14" y="37" width="16" height="4" rx="1"/>'
  $svg += '</svg>'
  return $svg
}

# ---------------------------------------------------------------- graficos
# SVG inline gerado aqui mesmo. Sem Chart.js, sem CDN, sem npm: o painel abre
# por file:// e tem que funcionar com a internet caida.
# Toda funcao aceita serie vazia e devolve um aviso visivel - grafico que some
# em silencio faz o dono achar que o indicador esta zerado.

# Numero para dentro de SVG/CSS SEMPRE com ponto decimal. A maquina esta em
# pt-BR: "{0}" -f 558.5 gera "558,5", e num atributo points isso vira
# "558,5,26" - tres coordenadas em vez de duas. Custou um render quebrado em
# 21/08, achado no console do navegador, nao na leitura do codigo.
function Inv([double]$n) {
  return $n.ToString([System.Globalization.CultureInfo]::InvariantCulture)
}

function New-Linha {
  param([double[]]$Valores, [string[]]$Rotulos, [string]$Cor = '#58a6ff',
        [int]$W = 620, [int]$H = 130, [string]$Sufixo = '')
  if ($null -eq $Valores -or $Valores.Count -eq 0) {
    return '<div class="vazio">sem serie historica para este indicador</div>'
  }
  if ($Valores.Count -eq 1) {
    return ('<div class="vazio">1 unico ponto ({0}{1}) - serie comeca a partir da proxima medicao</div>' -f $Valores[0], $Sufixo)
  }
  $pad = 26
  $max = ($Valores | Measure-Object -Maximum).Maximum
  $min = ($Valores | Measure-Object -Minimum).Minimum
  # serie constante: eixo com folga, senao a linha cola na borda e some
  if ($max -eq $min) { $max = $max + 1; $min = [Math]::Max(0, $min - 1) }
  $faixa = $max - $min
  $largura = $W - ($pad * 2)
  $altura = $H - ($pad * 2)
  $pontos = @()
  for ($i = 0; $i -lt $Valores.Count; $i++) {
    $x = $pad + ($largura * $i / ($Valores.Count - 1))
    $y = $pad + $altura - ($altura * ($Valores[$i] - $min) / $faixa)
    $pontos += ('{0},{1}' -f (Inv ([Math]::Round($x, 1))), (Inv ([Math]::Round($y, 1))))
  }
  $linha = $pontos -join ' '
  $area = ('{0},{1} ' -f $pad, ($pad + $altura)) + $linha + (' {0},{1}' -f ($pad + $largura), ($pad + $altura))
  $id = 'g' + [Math]::Abs($linha.GetHashCode())
  $svg = ('<svg class="gr" viewBox="0 0 {0} {1}" preserveAspectRatio="none">' -f $W, $H)
  $svg += ('<defs><linearGradient id="{0}" x1="0" x2="0" y1="0" y2="1"><stop offset="0" stop-color="{1}" stop-opacity=".28"/><stop offset="1" stop-color="{1}" stop-opacity="0"/></linearGradient></defs>' -f $id, $Cor)
  # grade horizontal
  for ($k = 0; $k -le 2; $k++) {
    $gy = $pad + ($altura * $k / 2)
    $svg += ('<line class="grade" x1="{0}" y1="{1}" x2="{2}" y2="{1}"/>' -f $pad, (Inv ([Math]::Round($gy, 1))), ($pad + $largura))
  }
  $svg += ('<polygon fill="url(#{0})" points="{1}"/>' -f $id, $area)
  $svg += ('<polyline fill="none" stroke="{0}" stroke-width="2" stroke-linejoin="round" points="{1}"/>' -f $Cor, $linha)
  $ult = $pontos[-1].Split(',')
  $svg += ('<circle cx="{0}" cy="{1}" r="3.5" fill="{2}"/>' -f $ult[0], $ult[1], $Cor)
  $svg += ('<text class="eixo" x="2" y="{0}">{1}{2}</text>' -f ($pad + 4), $max, $Sufixo)
  $svg += ('<text class="eixo" x="2" y="{0}">{1}{2}</text>' -f ($pad + $altura), $min, $Sufixo)
  if ($Rotulos -and $Rotulos.Count -eq $Valores.Count) {
    $svg += ('<text class="eixo" x="{0}" y="{1}">{2}</text>' -f $pad, ($H - 6), (Esc $Rotulos[0]))
    $svg += ('<text class="eixo fim" x="{0}" y="{1}">{2}</text>' -f ($pad + $largura), ($H - 6), (Esc $Rotulos[-1]))
  }
  $svg += '</svg>'
  return $svg
}

# Barras verticais. Recebe objetos {Rotulo, Valor, Cor, Titulo} - a cor vem de
# quem chama porque quase sempre ela carrega informacao (verde=rodou,
# vermelho=falhou), nao e enfeite.
function New-Barras {
  param($Itens, [int]$H = 120)
  if ($null -eq $Itens -or @($Itens).Count -eq 0) {
    return '<div class="vazio">sem dado para este indicador</div>'
  }
  $itens = @($Itens)
  $max = ($itens | ForEach-Object { $_.Valor } | Measure-Object -Maximum).Maximum
  if ($max -le 0) { $max = 1 }
  $html = '<div class="barras" style="height:' + $H + 'px">'
  foreach ($it in $itens) {
    $pct = [Math]::Max(2, [Math]::Round(100 * $it.Valor / $max))
    $t = $it.Rotulo
    if ($it.PSObject.Properties.Name -contains 'Titulo') { $t = $it.Titulo }
    $html += ('<div class="barra" title="{0}"><i style="height:{1}%;background:{2}"></i><b>{3}</b></div>' -f (Esc $t), $pct, $it.Cor, (Esc $it.Rotulo))
  }
  $html += '</div>'
  return $html
}

# Barras horizontais, para ranking (nivel por agente).
function New-BarrasH {
  param($Itens, [int]$Max = 5)
  if ($null -eq $Itens -or @($Itens).Count -eq 0) {
    return '<div class="vazio">sem dado para este indicador</div>'
  }
  $html = '<div class="barrasH">'
  foreach ($it in @($Itens)) {
    $pct = [Math]::Round(100 * $it.Valor / $Max)
    $html += ('<div class="bh"><span class="bh-rot">{0}</span><span class="bh-tr"><i style="width:{1}%;background:{2}"></i></span><span class="bh-val">{3}</span></div>' -f (Esc $it.Rotulo), $pct, $it.Cor, (Esc ([string]$it.Valor)))
  }
  $html += '</div>'
  return $html
}

# Anel de progresso com o numero no meio. Usado para "X de Y" onde o Y e real
# e conhecido - nunca para inventar percentual sobre total desconhecido.
function New-Anel {
  param([double]$Valor, [double]$Total, [string]$Cor = '#2dd4bf',
        [string]$Centro = '', [string]$Rotulo = '')
  if ($Total -le 0) { $Total = 1 }
  $pct = [Math]::Min(100, [Math]::Round(100 * $Valor / $Total))
  $r = 34; $circ = 2 * [Math]::PI * $r
  $dash = Inv ([Math]::Round($circ * $pct / 100, 1))
  $resto = Inv ([Math]::Round($circ - [double]($circ * $pct / 100), 1))
  if ($Centro -eq '') { $Centro = [string]$Valor }
  $svg = '<div class="anel"><svg viewBox="0 0 84 84">'
  $svg += ('<circle cx="42" cy="42" r="{0}" class="anel-trilho"/>' -f $r)
  $svg += ('<circle cx="42" cy="42" r="{0}" fill="none" stroke="{1}" stroke-width="7" stroke-linecap="round" stroke-dasharray="{2} {3}" transform="rotate(-90 42 42)"/>' -f $r, $Cor, $dash, $resto)
  $svg += ('<text x="42" y="47" class="anel-num">{0}</text>' -f (Esc $Centro))
  $svg += '</svg>'
  if ($Rotulo) { $svg += ('<span class="anel-rot">{0}</span>' -f (Esc $Rotulo)) }
  $svg += '</div>'
  return $svg
}

# Barra de progresso rotulada (referencia visual do dono, 21/08).
function New-Progresso {
  param([string]$Rotulo, [double]$Valor, [double]$Total, [string]$Cor = '#2dd4bf', [string]$Direita = '')
  if ($Total -le 0) { $Total = 1 }
  $pct = [Math]::Min(100, [Math]::Round(100 * $Valor / $Total))
  if ($Direita -eq '') { $Direita = ('{0}/{1}' -f $Valor, $Total) }
  $h = '<div class="prog">'
  $h += ('<div class="prog-top"><span>{0}</span><b>{1}</b></div>' -f (Esc $Rotulo), (Esc $Direita))
  $h += ('<div class="prog-tr"><i style="width:{0}%;background:{1}"></i></div>' -f $pct, $Cor)
  $h += '</div>'
  return $h
}

# Matriz de pontos: 1 ponto = 1 item real (1 agente, 1 execucao). Conta
# unidade, nao percentual - da pra conferir no olho contando os pontos.
function New-Pontos {
  param($Itens, [string]$Legenda = '')
  if ($null -eq $Itens -or @($Itens).Count -eq 0) {
    return '<div class="vazio">sem dado para este indicador</div>'
  }
  $h = '<div class="pontos">'
  foreach ($it in @($Itens)) {
    $h += ('<i title="{0}" style="background:{1}"></i>' -f (Esc $it.Titulo), $it.Cor)
  }
  $h += '</div>'
  if ($Legenda) { $h += ('<div class="pontos-leg">{0}</div>' -f $Legenda) }
  return $h
}

# ---------------------------------------------------------------- series
# Snapshot datado ja existe desde 03/08 (Armadilha 8) - e a unica serie
# historica real de nivel do time que o ecossistema tem. Aqui ela vira grafico
# em vez de ficar so no arquivo.
function Get-SerieSnapshots {
  $saida = @()
  foreach ($f in @(Get-ChildItem -LiteralPath $AUD -Filter 'snapshot-*.json' -File | Sort-Object Name)) {
    try { $s = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json } catch { continue }
    $linhas = 0
    if ($s.tamanhos) { foreach ($p in $s.tamanhos.PSObject.Properties) { $linhas += [int]$p.Value } }
    $saida += [pscustomobject]@{
      Data       = [string]$s.data
      Media      = [double]$s.mediaNivel
      Licoes     = [int]$s.licoes
      Lacunas    = [int]$s.lacunasAbertas
      LinhasBase = $linhas
      Arquivos   = @($s.tamanhos.PSObject.Properties).Count
      Niveis     = $s.niveis
    }
  }
  return $saida
}

# duracoes.csv registra CADA disparo da pesquisa diaria com o veredito real
# (digest_escrito True/False). E a unica serie de confiabilidade de rotina que
# existe medida na origem, nao reconstruida depois.
function Get-Duracoes {
  $p = Join-Path $RAIZ 'pesquisa-diaria\duracoes.csv'
  if (-not (Test-Path -LiteralPath $p)) { return @() }
  $saida = @()
  foreach ($l in (Get-Content -LiteralPath $p -Encoding UTF8 | Select-Object -Skip 1)) {
    if ([string]::IsNullOrWhiteSpace($l)) { continue }
    $c = $l.Split(';')
    if ($c.Count -lt 4) { continue }
    $dt = $c[0].Trim()
    $dia = $dt
    if ($dt -match '^(\d{4}-\d{2}-\d{2})') { $g = $Matches; $dia = $g[1] }
    $min = 0.0
    [void][double]::TryParse($c[2].Replace(',', '.'), [ref]$min)
    $saida += [pscustomobject]@{
      Data = $dia; Minutos = $min; Ok = ($c[3].Trim() -eq 'True')
    }
  }
  return $saida
}

function Get-Tokens {
  $p = Join-Path $AUD 'uso-tokens-real.json'
  if (-not (Test-Path -LiteralPath $p)) { return @() }
  try { $j = Get-Content -LiteralPath $p -Raw -Encoding UTF8 | ConvertFrom-Json } catch { return @() }
  if (-not $j.porDia) { return @() }
  $saida = @()
  foreach ($p2 in ($j.porDia.PSObject.Properties | Sort-Object Name)) {
    $saida += [pscustomobject]@{
      Data = $p2.Name
      Output = [double]$p2.Value.output
      CacheRead = [double]$p2.Value.cacheRead
      Turnos = [int]$p2.Value.turnos
    }
  }
  return $saida
}

# riscos.md tem 11 colunas, MAS nem toda linha respeita isso: o risco #1 tem 13
# celulas (dois pipes soltos no meio do texto), verificado contando as celulas
# linha a linha em 21/08. Ler Status pela posicao 9 nessa linha devolve um
# pedaco do meio da frase ("Glob\") e o risco entra na conta errada.
# Por isso o Status aqui e lido por CONTEUDO, nao por posicao: risco mitigado
# carrega o marcador de fechamento na propria linha. Errar para o lado de
# "ainda aberto" e o lado seguro - risco escondido e pior que risco repetido.
function Get-Riscos {
  $linhas = (Read-Safe (Join-Path $AUD 'riscos.md')) -split "`r?`n"
  $saida = @()
  foreach ($row in $linhas) {
    if (-not $row.TrimStart().StartsWith('|')) { continue }
    $partes = ($row -replace '\\\|', $SENTINELA_PIPE).Split('|')
    if ($partes.Count -lt 13) { continue }
    $c = @($partes[1..($partes.Count - 2)] | ForEach-Object { $_.Trim().Replace($SENTINELA_PIPE, '|') })
    if ($c[0] -notmatch '^\d+$') { continue }
    $regular = ($c.Count -eq 11)
    $sev = 'formato irregular'
    $resp = ''
    if ($regular) { $sev = ($c[5] -replace '\*', ''); $resp = $c[6] }
    else {
      # acha a severidade pelo proprio texto da linha, sem depender da coluna
      if ($row -match '(Cr[ií]tica|Alta|M[eé]dia|Baixa)') { $g = $Matches; $sev = $g[1] }
    }
    # Status e a PENULTIMA coluna (a ultima e "Desde"). Contar do FIM e estavel
    # mesmo quando sobra pipe no meio do texto - foi assim que o #1, com 13
    # celulas, voltou a ser lido certo. Procurar o marcador na linha inteira
    # NAO serve: o ✅ tambem aparece na coluna Mitigacao, e ai risco aberto
    # vira "mitigado" - mesmo erro do DONE solto no meio da frase.
    $statusCel = $c[$c.Count - 2]
    $aberto = ($statusCel -notmatch '✅')
    $st = 'aberto'
    if (-not $aberto) { $st = 'mitigado' }
    $saida += [pscustomobject]@{
      Id = $c[0]; Risco = $c[1]; Categoria = $c[2]
      Severidade = $sev; Responsavel = $resp; Aberto = $aberto; Status = $st
      Regular = $regular
    }
  }
  return $saida
}

function Get-Recados([int]$Limite = 6) {
  $txt = Read-Safe (Join-Path $AUD 'recados-dono.md')
  if (-not $txt) { return @() }
  $saida = @()
  foreach ($b in ($txt -split "`n(?=## )")) {
    if (-not $b.StartsWith('## ')) { continue }
    if ($b -match '^##\s+(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2})\s+—\s+William\s*\r?\n([\s\S]*)') {
      $g = $Matches
      $saida += [pscustomobject]@{ Data = $g[1]; Hora = $g[2]; Texto = $g[3].Trim() }
    }
  }
  return @($saida | Select-Object -Last $Limite)
}

function Get-OndeEncontrar {
  $linhas = (Read-Safe (Join-Path $AUD 'source-of-truth.md')) -split "`r?`n"
  $idx = -1
  for ($i = 0; $i -lt $linhas.Count; $i++) {
    if ($linhas[$i].TrimStart().StartsWith('| Categoria | Fonte oficial')) { $idx = $i }
  }
  if ($idx -lt 0) { return @() }
  $saida = @()
  for ($j = $idx + 2; $j -lt $linhas.Count; $j++) {
    $row = $linhas[$j]
    if (-not $row.TrimStart().StartsWith('|')) { break }
    $p = $row.Split('|')
    $c = @($p[1..($p.Count - 2)] | ForEach-Object { $_.Trim() })
    if ($c.Count -lt 3) { continue }
    $saida += [pscustomobject]@{ Categoria = $c[0]; Onde = $c[2] }
  }
  return $saida
}

function Get-Higiene {
  $p = Join-Path $AUD 'higiene-sessao-status.json'
  if (-not (Test-Path -LiteralPath $p)) { return $null }
  try { return (Get-Content -LiteralPath $p -Raw -Encoding UTF8 | ConvertFrom-Json) } catch { return $null }
}

function Get-Escada {
  $linhas = (Read-Safe (Join-Path $AUD 'decisoes.md')) -split "`r?`n"
  $idx = -1
  for ($i = 0; $i -lt $linhas.Count; $i++) {
    if ($linhas[$i].TrimStart().StartsWith('| Categoria | Nível |')) { $idx = $i }
  }
  if ($idx -lt 0) { return @() }
  $saida = @()
  for ($j = $idx + 2; $j -lt $linhas.Count; $j++) {
    $row = $linhas[$j]
    if (-not $row.TrimStart().StartsWith('|')) { break }
    $c = @($row.Split('|')[1..($row.Split('|').Count - 2)] | ForEach-Object { $_.Trim() })
    if ($c.Count -lt 5) { continue }
    $saida += [pscustomobject]@{
      Categoria = $c[0]; Nivel = $c[1]; Falta = $c[3]; Responsavel = $c[4]
    }
  }
  return $saida
}

# ---------------------------------------------------------------- historico
# Quadro de problemas NAO tem serie historica em lugar nenhum - so o estado de
# hoje. Em vez de fingir tendencia com dado que nao existe, o painel comeca a
# gravar a propria serie: 1 linha por dia, idempotente (rodar 10x no mesmo dia
# nao duplica, atualiza). Amanha ja ha 2 pontos; a curva nasce de medicao real,
# nunca de reconstrucao retroativa.
function Save-Historico {
  param([int]$Abertos, [int]$Vencidos, [double]$Media, [int]$AtivosHoje, [int]$LinhasBase)
  $p = Join-Path $AUD 'historico-painel.csv'
  $hoje = (Get-Date).ToString('yyyy-MM-dd')
  $cab = 'data;abertos;vencidos;mediaNivel;ativosHoje;linhasBase'
  $linhas = @()
  if (Test-Path -LiteralPath $p) {
    $linhas = @(Get-Content -LiteralPath $p -Encoding UTF8 | Where-Object { $_ -and ($_ -ne $cab) -and (-not $_.StartsWith($hoje + ';')) })
  }
  # decimal SEMPRE com ponto: a maquina esta em pt-BR e o '-f' gravaria "1,93",
  # que na releitura vira 193 ou erro. Serie historica corrompida em silencio e
  # pior que serie inexistente.
  $mediaTxt = $Media.ToString([System.Globalization.CultureInfo]::InvariantCulture)
  $linhas += ('{0};{1};{2};{3};{4};{5}' -f $hoje, $Abertos, $Vencidos, $mediaTxt, $AtivosHoje, $LinhasBase)
  $conteudo = @($cab) + @($linhas | Sort-Object)
  [System.IO.File]::WriteAllLines($p, $conteudo, (New-Object System.Text.UTF8Encoding $true))
}

function Get-Historico {
  $p = Join-Path $AUD 'historico-painel.csv'
  if (-not (Test-Path -LiteralPath $p)) { return @() }
  $saida = @()
  foreach ($l in (Get-Content -LiteralPath $p -Encoding UTF8 | Select-Object -Skip 1)) {
    if ([string]::IsNullOrWhiteSpace($l)) { continue }
    $c = $l.Split(';')
    if ($c.Count -lt 6) { continue }
    $m = 0.0
    [void][double]::TryParse($c[3].Replace(',', '.'), [System.Globalization.NumberStyles]::Float,
      [System.Globalization.CultureInfo]::InvariantCulture, [ref]$m)
    $saida += [pscustomobject]@{
      Data = $c[0]; Abertos = [int]$c[1]; Vencidos = [int]$c[2]
      Media = $m; AtivosHoje = [int]$c[4]; LinhasBase = [int]$c[5]
    }
  }
  return $saida
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
  $alvo = 'N8N-Servidor-Persistente|ReuniaoDiretorTime|BackupGitEcossistema|Cerebro'
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
.salas{display:grid;grid-template-columns:repeat(auto-fill,minmax(420px,1fr));gap:14px}
.sala{background:#0d1117;border:1px solid #21262d;border-radius:10px;padding:14px}
.sala h3{margin:0 0 10px;font-size:13px;font-weight:600;display:flex;justify-content:space-between;gap:8px}
.sala h3 em{font-style:normal;color:#7d8590;font-weight:400;font-size:11px}
.mesas{display:grid;grid-template-columns:repeat(auto-fill,minmax(132px,1fr));gap:6px}
.mesa{position:relative;padding:8px 6px 9px;border-radius:8px;text-align:center;border:1px solid transparent}
.mesa:hover{background:#161b22;border-color:#21262d}
.dot{position:absolute;top:7px;right:7px;width:7px;height:7px;border-radius:50%}
.hoje .dot{background:#3fb950;box-shadow:0 0 0 3px rgba(63,185,80,.15)}
.ativo .dot{background:#58a6ff} .quieto .dot{background:#d29922} .mudo .dot{background:#30363d}

/* --- bonequinho --- */
.boneco{width:72px;height:60px;display:block;margin:0 auto 2px}
.cabeca,.tronco{fill:#6e7681}
.braco{stroke:#6e7681;stroke-width:3;stroke-linecap:round;fill:none}
.mesa-svg{fill:#30363d}
.teclado{fill:#21262d}
.tela{fill:#161b22;stroke:#30363d;stroke-width:1}
.pe-monitor{fill:#30363d}
/* verde = tem registro escrito de hoje. So ESTE digita. */
.hoje .cabeca,.hoje .tronco{fill:#3fb950}
.hoje .braco{stroke:#3fb950}
.hoje .tela{fill:#0f2f18;stroke:#3fb950}
.hoje .teclado{fill:#1c3a24}
.hoje .braco{animation:digitar .5s ease-in-out infinite}
.hoje .bd{animation-delay:.25s}
.hoje .cabeca{animation:balanco 2.6s ease-in-out infinite}
.hoje .tela{animation:brilho 3.2s ease-in-out infinite}
/* azul = registro nos ultimos 3 dias. Respira, nao digita. */
.ativo .cabeca,.ativo .tronco{fill:#58a6ff}
.ativo .braco{stroke:#58a6ff}
.ativo .tela{stroke:#1f6feb}
.ativo .tronco{animation:respirar 4s ease-in-out infinite;transform-origin:22px 42px}
/* ambar e cinza = parados de verdade, entao ficam parados na tela tambem */
.quieto .cabeca,.quieto .tronco{fill:#d29922}
.quieto .braco{stroke:#d29922}
.mudo .boneco{opacity:.35}
@keyframes digitar{0%,100%{transform:translateY(0)}50%{transform:translateY(-2px)}}
@keyframes balanco{0%,100%{transform:translateX(0)}50%{transform:translateX(1.2px)}}
@keyframes brilho{0%,100%{opacity:1}50%{opacity:.62}}
@keyframes respirar{0%,100%{transform:scaleY(1)}50%{transform:scaleY(1.05)}}
@media (prefers-reduced-motion:reduce){.boneco *{animation:none !important}}

.nome{display:block;font-size:12px;font-weight:600;letter-spacing:-.1px}
.cargo{display:block;font-size:10px;color:#8b949e;margin-top:1px;line-height:1.3}
.slug{display:block;font-family:ui-monospace,Consolas,monospace;font-size:9px;color:#484f58;margin-top:2px;word-break:break-all}
.mudo .nome{color:#6e7681}
.tags{display:flex;gap:3px;justify-content:center;flex-wrap:wrap;margin-top:4px}
.tag{font-size:9.5px;padding:1px 5px;border-radius:20px;border:1px solid #30363d;color:#8b949e;white-space:nowrap}
.tag.n{border-color:#1f6feb;color:#79c0ff}
.tag.p{border-color:#8b3a1f;color:#ffa657}
.tag.novo{border-color:#8957e5;color:#d2a8ff}
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
footer{padding:20px 24px 40px;color:#6e7681;font-size:11.5px;max-width:1700px;margin:0 auto;line-height:1.7}
footer b{color:#8b949e}
.card{background:#0d1117;border:1px solid #21262d;border-radius:10px;padding:4px 6px}

/* ---- grade de cards (referencia visual do dono, 21/08) ---- */
main{max-width:1700px}
.grade-cards{display:grid;grid-template-columns:repeat(12,1fr);gap:14px;margin-bottom:14px}
.c{background:#0d1117;border:1px solid #21262d;border-radius:12px;padding:14px 16px 16px;min-width:0}
.c4{grid-column:span 4}.c6{grid-column:span 6}.c8{grid-column:span 8}.c12{grid-column:span 12}
.c3{grid-column:span 3}.c5{grid-column:span 5}.c7{grid-column:span 7}.c9{grid-column:span 9}
@media(max-width:1250px){.c3,.c4,.c5{grid-column:span 6}.c7,.c8,.c9{grid-column:span 12}}
@media(max-width:760px){.c,.c3,.c4,.c5,.c6,.c7,.c8,.c9{grid-column:span 12}}
.c h4{margin:0 0 2px;font-size:12.5px;font-weight:600;letter-spacing:-.1px}
.c .fonte{display:block;color:#6e7681;font-size:10px;margin-bottom:12px;line-height:1.4}
.c .fonte code{font-size:10px;color:#6e7681}
.gr{width:100%;height:130px;display:block}
.gr .grade{stroke:#21262d;stroke-width:1}
.gr .eixo{fill:#6e7681;font-size:9px;font-family:ui-monospace,Consolas,monospace}
.gr .eixo.fim{text-anchor:end}
.vazio{color:#6e7681;font-size:11.5px;padding:16px 0;text-align:center;border:1px dashed #21262d;border-radius:8px}

.barras{display:flex;align-items:flex-end;gap:3px}
.barra{flex:1;display:flex;flex-direction:column;justify-content:flex-end;align-items:center;height:100%;min-width:0}
.barra i{width:100%;border-radius:3px 3px 0 0;display:block;min-height:2px}
.barra b{font-size:8.5px;color:#6e7681;font-weight:400;margin-top:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:100%}

.barrasH{display:flex;flex-direction:column;gap:5px}
.bh{display:flex;align-items:center;gap:8px;font-size:11px}
.bh-rot{flex:0 0 40%;color:#8b949e;font-family:ui-monospace,Consolas,monospace;font-size:10px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.bh-tr{flex:1;height:8px;background:#161b22;border-radius:6px;overflow:hidden}
.bh-tr i{display:block;height:100%;border-radius:6px}
.bh-val{flex:0 0 34px;text-align:right;color:#e6edf3;font-weight:600;font-size:11px}

.aneis{display:flex;gap:10px;flex-wrap:wrap;justify-content:space-around}
.anel{text-align:center}
.anel svg{width:84px;height:84px}
.anel-trilho{fill:none;stroke:#161b22;stroke-width:7}
.anel-num{fill:#e6edf3;font-size:19px;font-weight:600;text-anchor:middle;font-family:"Segoe UI",system-ui,sans-serif}
.anel-rot{display:block;font-size:10px;color:#7d8590;margin-top:2px;max-width:96px;line-height:1.3}

.prog{margin-bottom:11px}
.prog-top{display:flex;justify-content:space-between;font-size:11px;margin-bottom:4px;gap:8px}
.prog-top span{color:#8b949e;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.prog-top b{color:#e6edf3;font-weight:600;white-space:nowrap}
.prog-tr{height:7px;background:#161b22;border-radius:6px;overflow:hidden}
.prog-tr i{display:block;height:100%;border-radius:6px}

.pontos{display:flex;flex-wrap:wrap;gap:5px}
.pontos i{width:11px;height:11px;border-radius:3px;display:block}
.pontos-leg{margin-top:10px;font-size:10px;color:#6e7681;line-height:1.6}
.leg{display:inline-flex;align-items:center;gap:4px;margin-right:10px}
.leg i{width:8px;height:8px;border-radius:2px;display:inline-block}

.numerao{font-size:30px;font-weight:600;letter-spacing:-1px;line-height:1.1}
.numerao small{font-size:12px;color:#7d8590;font-weight:400;letter-spacing:0}
.lista{font-size:11.5px}
.lista div{padding:6px 0;border-top:1px solid #161b22;display:flex;gap:8px;justify-content:space-between}
.lista div:first-child{border-top:0}
.lista .q{color:#8b949e;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.lista .v{color:#e6edf3;font-weight:600;white-space:nowrap}
.scroll{max-height:270px;overflow-y:auto}
.scroll::-webkit-scrollbar{width:8px}.scroll::-webkit-scrollbar-thumb{background:#21262d;border-radius:8px}
.tabwrap{overflow-x:auto}
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

  # ================================================================ analitico
  $serie   = Get-SerieSnapshots
  $duracoes= Get-Duracoes
  $tokens  = Get-Tokens
  $riscos  = Get-Riscos
  $escada  = Get-Escada
  $higiene = Get-Higiene

  # grava a serie propria ANTES de desenhar, pra o ponto de hoje ja entrar
  $linhasBaseHoje = 0
  if ($serie.Count -gt 0) { $linhasBaseHoje = $serie[-1].LinhasBase }
  $mediaHoje = 0.0
  if ($snap) { $mediaHoje = [double]$snap.mediaNivel }
  Save-Historico -Abertos $problemas.Count -Vencidos $vencidos.Count -Media $mediaHoje -AtivosHoje $trabHoje -LinhasBase $linhasBaseHoje
  $hist = Get-Historico

  $VERDE='#3fb950'; $TEAL='#2dd4bf'; $ROXO='#a371f7'; $AZUL='#58a6ff'
  $AMBAR='#d29922'; $VERM='#f85149'; $CINZA='#30363d'

  # ---------------- Bloco 1: time e conhecimento
  Add '<h2>Time e conhecimento &mdash; o que o Diretor acompanha primeiro</h2>'
  Add '<div class="grade-cards">'

  # nivel medio ao longo do tempo
  Add '<div class="c c8"><h4>Nivel medio do time</h4>'
  Add ('<span class="fonte">Serie real de {0} snapshots datados em <code>auditoria/snapshot-*.json</code>, o mais antigo de {1}. Escala 1 a 5.</span>' -f $serie.Count, (Esc $(if ($serie.Count -gt 0) { $serie[0].Data } else { '-' })))
  if ($serie.Count -gt 0) {
    $delta = 0.0
    if ($serie.Count -ge 2) { $delta = [Math]::Round($serie[-1].Media - $serie[0].Media, 2) }
    $sinal = '+'; if ($delta -lt 0) { $sinal = '' }
    Add ('<div class="numerao">{0}<small>/5 &nbsp;&middot;&nbsp; {1}{2} desde {3}</small></div>' -f $serie[-1].Media, $sinal, $delta, (Esc $serie[0].Data))
  }
  Add (New-Linha -Valores @($serie | ForEach-Object { $_.Media }) -Rotulos @($serie | ForEach-Object { $_.Data }) -Cor $TEAL)
  Add '</div>'

  # aneis de cobertura
  $medidos = 0
  if ($snap -and $snap.niveis) { $medidos = @($snap.niveis.PSObject.Properties).Count }
  $diasSemEvo = 0
  if ($snap) { $diasSemEvo = [int]$snap.diasSemEvolucao }
  Add '<div class="c c4"><h4>Cobertura da medicao</h4>'
  Add '<span class="fonte">Quantos agentes tem nivel medido de fato. O resto nao e nivel zero: e agente sem medicao, coisa diferente.</span>'
  Add '<div class="aneis">'
  Add (New-Anel -Valor $medidos -Total $agentes.Count -Cor $TEAL -Centro ("{0}/{1}" -f $medidos, $agentes.Count) -Rotulo 'agentes com nivel medido')
  Add (New-Anel -Valor $mediaHoje -Total 5 -Cor $ROXO -Centro ([string]$mediaHoje) -Rotulo 'nivel medio (de 5)')
  $corEvo = $VERDE; if ($diasSemEvo -ge 3) { $corEvo = $AMBAR }; if ($diasSemEvo -ge 7) { $corEvo = $VERM }
  Add (New-Anel -Valor ([Math]::Min($diasSemEvo, 14)) -Total 14 -Cor $corEvo -Centro ([string]$diasSemEvo) -Rotulo 'dias sem evolucao de nivel')
  Add '</div></div>'

  # nivel por agente
  Add '<div class="c c6"><h4>Nivel por agente</h4>'
  Add '<span class="fonte">Do snapshot mais recente. Nome de pessoa entre parenteses e so apelido de exibicao.</span>'
  $itensNivel = @()
  if ($snap -and $snap.niveis) {
    foreach ($p in ($snap.niveis.PSObject.Properties | Sort-Object { [int]$_.Value } -Descending)) {
      $pe = Get-Pessoa $p.Name
      $cor = $VERM; $v = [int]$p.Value
      if ($v -ge 2) { $cor = $AMBAR }; if ($v -ge 3) { $cor = $AZUL }; if ($v -ge 4) { $cor = $VERDE }
      $itensNivel += [pscustomobject]@{ Rotulo = ('{0} ({1})' -f $p.Name, $pe.Nome); Valor = $v; Cor = $cor }
    }
  }
  Add ('<div class="scroll">' + (New-BarrasH -Itens $itensNivel -Max 5) + '</div>')
  Add '</div>'

  # quem nao tem nivel
  Add '<div class="c c6"><h4>Quem esta medido e quem nao esta</h4>'
  Add '<span class="fonte">1 quadrado = 1 agente real de <code>~/.claude/agents/</code>. Da pra conferir contando no olho.</span>'
  $pts = @()
  foreach ($a in $agentes) {
    $temNivel = $false
    if ($snap -and $snap.niveis) { $temNivel = ($null -ne $snap.niveis.PSObject.Properties[$a]) }
    $cor = $CINZA; $t = ('{0} - sem nivel medido' -f $a)
    if ($temNivel) { $cor = $TEAL; $t = ('{0} - nivel {1}' -f $a, $snap.niveis.PSObject.Properties[$a].Value) }
    $pts += [pscustomobject]@{ Cor = $cor; Titulo = $t }
  }
  $semNivel = $agentes.Count - $medidos
  Add (New-Pontos -Itens $pts -Legenda ('<span class="leg"><i style="background:' + $TEAL + '"></i>' + $medidos + ' com nivel medido</span><span class="leg"><i style="background:' + $CINZA + '"></i>' + $semNivel + ' sem medicao</span> &mdash; os sem medicao sao a maior lacuna de formacao aberta hoje, e ja tem item proprio no quadro (#58).'))
  Add '</div>'

  # base de conhecimento
  Add '<div class="c c6"><h4>Base de Conhecimento &mdash; total de linhas</h4>'
  Add '<span class="fonte">Soma de todos os arquivos de <code>~/.claude/knowledge/</code>, medida em cada snapshot. Mede o trabalho produzido, nao so o digest do dia.</span>'
  if ($serie.Count -gt 0) {
    Add ('<div class="numerao">{0:N0}<small> linhas em {1} arquivos</small></div>' -f $serie[-1].LinhasBase, $serie[-1].Arquivos)
  }
  Add (New-Linha -Valores @($serie | ForEach-Object { $_.LinhasBase }) -Rotulos @($serie | ForEach-Object { $_.Data }) -Cor $ROXO)
  Add '</div>'

  # licoes e lacunas
  Add '<div class="c c3"><h4>Licoes registradas</h4><span class="fonte"><code>lessons-learned.md</code>, por snapshot.</span>'
  Add (New-Linha -Valores @($serie | ForEach-Object { $_.Licoes }) -Rotulos @($serie | ForEach-Object { $_.Data }) -Cor $VERDE)
  Add '</div>'
  Add '<div class="c c3"><h4>Lacunas abertas</h4><span class="fonte"><code>lacunas-conhecidas.md</code>, por snapshot. Aqui subir e ruim.</span>'
  Add (New-Linha -Valores @($serie | ForEach-Object { $_.Lacunas }) -Rotulos @($serie | ForEach-Object { $_.Data }) -Cor $AMBAR)
  Add '</div>'
  Add '</div>'

  # ---------------- Bloco 2: quadro, risco e decisao
  Add '<h2>Quadro, risco e decisao</h2><div class="grade-cards">'

  $g100 = @($problemas | Where-Object { (Get-Gut $_.Titulo) -ge 100 }).Count
  $g60  = @($problemas | Where-Object { $v = Get-Gut $_.Titulo; $v -ge 60 -and $v -lt 100 }).Count
  $g30  = @($problemas | Where-Object { $v = Get-Gut $_.Titulo; $v -ge 30 -and $v -lt 60 }).Count
  $gBx  = @($problemas | Where-Object { (Get-Gut $_.Titulo) -lt 30 }).Count

  Add '<div class="c c4"><h4>Quadro aberto por prioridade GUT</h4>'
  Add '<span class="fonte">Score GUT lido de dentro da celula do proprio item em <code>problemas.md</code>.</span>'
  Add '<div class="aneis">'
  Add (New-Anel -Valor $g100 -Total $problemas.Count -Cor $VERM -Centro ([string]$g100) -Rotulo 'criticos (GUT 100)')
  Add (New-Anel -Valor $vencidos.Count -Total $problemas.Count -Cor $AMBAR -Centro ([string]$vencidos.Count) -Rotulo 'com prazo vencido')
  Add (New-Anel -Valor $problemas.Count -Total $problemas.Count -Cor $AZUL -Centro ([string]$problemas.Count) -Rotulo 'total aberto')
  Add '</div></div>'

  Add '<div class="c c4"><h4>Distribuicao por faixa</h4><span class="fonte">Cada barra e a contagem real de itens abertos naquela faixa.</span>'
  Add (New-Barras -Itens @(
    [pscustomobject]@{ Rotulo='GUT 100'; Valor=$g100; Cor=$VERM; Titulo=("$g100 criticos") },
    [pscustomobject]@{ Rotulo='60-99';   Valor=$g60;  Cor='#ffa657'; Titulo=("$g60 muito altos") },
    [pscustomobject]@{ Rotulo='30-59';   Valor=$g30;  Cor=$AMBAR; Titulo=("$g30 medios") },
    [pscustomobject]@{ Rotulo='ate 29';  Valor=$gBx;  Cor=$VERDE; Titulo=("$gBx baixos") }
  ) -H 130)
  Add '</div>'

  Add '<div class="c c4"><h4>Historico do quadro</h4>'
  Add '<span class="fonte">Serie NOVA, gravada por este painel em <code>auditoria/historico-painel.csv</code> a cada geracao. Nao foi reconstruida do passado: comeca no dia em que o painel passou a rodar.</span>'
  Add (New-Linha -Valores @($hist | ForEach-Object { $_.Abertos }) -Rotulos @($hist | ForEach-Object { $_.Data }) -Cor $AZUL)
  Add '</div>'

  # problemas por dono
  Add '<div class="c c6"><h4>Carga por dono &mdash; quem esta segurando o quadro</h4>'
  Add '<span class="fonte">Coluna Dono de cada item aberto. Item com dois donos conta para os dois, de proposito.</span>'
  $porDono = @()
  foreach ($a in $agentes) {
    $n = @($problemas | Where-Object { $_.Dono -like ("*{0}*" -f $a) }).Count
    if ($n -gt 0) {
      $pe = Get-Pessoa $a
      $porDono += [pscustomobject]@{ Rotulo = ('{0} ({1})' -f $a, $pe.Nome); Valor = $n; Cor = $ROXO }
    }
  }
  $nDiretor = @($problemas | Where-Object { $_.Dono -match 'Diretor' }).Count
  if ($nDiretor -gt 0) { $porDono += [pscustomobject]@{ Rotulo = 'Diretor (Eduardo)'; Valor = $nDiretor; Cor = $VERM } }
  $nWilliam = @($problemas | Where-Object { $_.Dono -match 'William' }).Count
  if ($nWilliam -gt 0) { $porDono += [pscustomobject]@{ Rotulo = 'William (dono)'; Valor = $nWilliam; Cor = $TEAL } }
  $porDono = @($porDono | Sort-Object Valor -Descending)
  $maxDono = 1
  if ($porDono.Count -gt 0) { $maxDono = ($porDono | Measure-Object Valor -Maximum).Maximum }
  Add ('<div class="scroll">' + (New-BarrasH -Itens $porDono -Max $maxDono) + '</div>')
  Add '</div>'

  # riscos
  $rAbertos = @($riscos | Where-Object { $_.Aberto })
  Add '<div class="c c6"><h4>Registro de riscos</h4>'
  Add ('<span class="fonte">Fonte: <code>auditoria/riscos.md</code>. {0} risco(s) na tabela, {1} ainda em aberto.</span>' -f $riscos.Count, $rAbertos.Count)
  $sev = @('Critica','Alta','Media','Baixa')
  $padraoSev = @{ 'Critica'='Cr[ií]tica'; 'Alta'='Alta'; 'Media'='M[eé]dia'; 'Baixa'='Baixa' }
  $coresSev = @{ 'Critica'=$VERM; 'Alta'='#ffa657'; 'Media'=$AMBAR; 'Baixa'=$VERDE }
  $itensSev = @()
  foreach ($s in $sev) {
    $n = @($rAbertos | Where-Object { $_.Severidade -match $padraoSev[$s] }).Count
    $itensSev += [pscustomobject]@{ Rotulo=$s; Valor=$n; Cor=$coresSev[$s]; Titulo=("$n risco(s) $s") }
  }
  Add (New-Barras -Itens $itensSev -H 96)
  Add '<div class="lista" style="margin-top:10px">'
  foreach ($r in ($rAbertos | Select-Object -First 5)) {
    $t = $r.Risco; if ($t.Length -gt 78) { $t = $t.Substring(0,78) + '...' }
    Add ('<div><span class="q">#{0} {1}</span><span class="v">{2}</span></div>' -f (Esc $r.Id), (Esc $t), (Esc $r.Severidade))
  }
  Add '</div></div>'

  # escada de decisao
  Add '<div class="c c12"><h4>Escada de autonomia &mdash; quanto o time ja decide sozinho</h4>'
  Add '<span class="fonte">Fonte: tabela de niveis de decisao em <code>auditoria/decisoes.md</code>. Cada barra e uma categoria; cheia significa autonomia total naquela categoria.</span>'
  if ($escada.Count -eq 0) { Add '<div class="vazio">tabela de escada nao encontrada em decisoes.md</div>' }
  else {
    Add '<div class="grade-cards" style="margin:0">'
    foreach ($e in $escada) {
      $nv = 0
      if ($e.Nivel -match '(\d)') { $g = $Matches; $nv = [int]$g[1] }
      $cor = $VERM; if ($nv -ge 2) { $cor = $AMBAR }; if ($nv -ge 3) { $cor = $AZUL }; if ($nv -ge 4) { $cor = $VERDE }
      Add ('<div class="c4" style="padding:0">' + (New-Progresso -Rotulo $e.Categoria -Valor $nv -Total 4 -Cor $cor -Direita ('N' + $nv)) + '</div>')
    }
    Add '</div>'
  }
  Add '</div></div>'

  # ---------------- Bloco 3: motor
  Add '<h2>Motor &mdash; as rotinas que rodam sozinhas</h2><div class="grade-cards">'

  $okD = @($duracoes | Where-Object { $_.Ok }).Count
  Add '<div class="c c8"><h4>Pesquisa diaria &mdash; cada disparo, com veredito real</h4>'
  Add ('<span class="fonte">Fonte: <code>pesquisa-diaria/duracoes.csv</code>, gravado pela propria rotina. Verde = digest escrito de verdade; vermelho = disparou e morreu sem produzir. {0} de {1} execucoes produziram digest.</span>' -f $okD, $duracoes.Count)
  $itensD = @()
  foreach ($d in $duracoes) {
    $cor = $VERM; $txt = 'sem digest'
    if ($d.Ok) { $cor = $VERDE; $txt = 'digest escrito' }
    $itensD += [pscustomobject]@{ Rotulo=$d.Data.Substring(5); Valor=[Math]::Max(1,$d.Minutos); Cor=$cor; Titulo=('{0} - {1} - {2} min' -f $d.Data, $txt, $d.Minutos) }
  }
  Add (New-Barras -Itens $itensD -H 130)
  Add '</div>'

  Add '<div class="c c4"><h4>Confiabilidade da rotina</h4><span class="fonte">Mesma fonte. Altura da barra acima = minutos que durou.</span>'
  Add '<div class="aneis">'
  $corTaxa = $VERM; if ($duracoes.Count -gt 0 -and ($okD / $duracoes.Count) -ge 0.5) { $corTaxa = $AMBAR }
  if ($duracoes.Count -gt 0 -and ($okD / $duracoes.Count) -ge 0.8) { $corTaxa = $VERDE }
  $pctTaxa = 0; if ($duracoes.Count -gt 0) { $pctTaxa = [Math]::Round(100 * $okD / $duracoes.Count) }
  Add (New-Anel -Valor $okD -Total ([Math]::Max(1,$duracoes.Count)) -Cor $corTaxa -Centro ("$pctTaxa%") -Rotulo ('digest escrito em {0} de {1} disparos' -f $okD, $duracoes.Count))
  Add '</div></div>'

  # tokens
  $ult14 = @($tokens | Select-Object -Last 14)
  Add '<div class="c c8"><h4>Consumo de token por dia</h4>'
  Add '<span class="fonte">Fonte: <code>auditoria/uso-tokens-real.json</code> (medido dos arquivos de sessao, nao estimado). Barra = tokens de saida; dia sem barra e dia sem uso.</span>'
  $itensT = @()
  foreach ($t in $ult14) {
    $cor = $AZUL; if ($t.Output -gt 400000) { $cor = $AMBAR }; if ($t.Output -gt 800000) { $cor = $VERM }
    $itensT += [pscustomobject]@{ Rotulo=$t.Data.Substring(5); Valor=$t.Output; Cor=$cor; Titulo=('{0}: {1:N0} tokens de saida, {2} turnos' -f $t.Data, $t.Output, $t.Turnos) }
  }
  Add (New-Barras -Itens $itensT -H 130)
  Add '</div>'

  Add '<div class="c c4"><h4>Higiene de sessao</h4>'
  Add '<span class="fonte">Fonte: <code>auditoria/higiene-sessao-status.json</code>.</span>'
  if ($higiene) {
    $corH = $VERDE; if ($higiene.recomendacao -ne 'ok') { $corH = $AMBAR }
    Add ('<div class="numerao">{0}<small> dias ativos</small></div>' -f (Esc ([string]$higiene.diasAtivos)))
    Add ('<div class="lista" style="margin-top:8px"><div><span class="q">Recomendacao</span><span class="v" style="color:{0}">{1}</span></div><div><span class="q">Handoff atualizado</span><span class="v">{2}</span></div></div>' -f $corH, (Esc ([string]$higiene.recomendacao)), (Esc ([string]$higiene.handoffAtualizadoEm)))
    Add '<div class="fonte" style="margin-top:8px">Ressalva registrada no item #105 do quadro: <code>diasAtivos</code> conta dias do projeto inteiro, nao da sessao atual. O numero acima e o que o arquivo diz, com o defeito conhecido.</div>'
  } else { Add '<div class="vazio">arquivo de higiene nao encontrado</div>' }
  Add '</div>'
  Add '</div>'

  # ---- salas
  Add '<h2>Salas do escritorio</h2><div class="salas">'
  $ordem = @($salas.Values | Sort-Object -Unique)
  foreach ($sala in $ordem) {
    $doSala = @($agentes | Where-Object { $salas[$_] -eq $sala })
    if ($doSala.Count -eq 0) { continue }
    $ativosSala = @($doSala | Where-Object { $mesas[$_].Classe -eq 'hoje' }).Count
    Add '<div class="sala">'
    Add ('<h3><span>{0}</span><em>{1} de {2} no registro de hoje</em></h3>' -f (Esc $sala), $ativosSala, $doSala.Count)
    Add '<div class="mesas">'
    foreach ($a in $doSala) {
      $m = $mesas[$a]
      $pes = Get-Pessoa $a
      $titulo = ('{0} ({1}) - {2} - {3}' -f $pes.Nome, $pes.Cargo, $a, $m.Rotulo)
      Add ('<div class="mesa {0}" title="{1}">' -f $m.Classe, (Esc $titulo))
      Add '<i class="dot"></i>'
      Add (New-Boneco)
      Add ('<span class="nome">{0}</span>' -f (Esc $pes.Nome))
      Add ('<span class="cargo">{0}</span>' -f (Esc $pes.Cargo))
      Add ('<span class="slug">{0}</span>' -f (Esc $a))
      Add '<div class="tags">'
      if ($m.Nivel) { Add ('<span class="tag n">niv {0}</span>' -f (Esc $m.Nivel)) }
      if ($m.Itens.Count -gt 0) { Add ('<span class="tag p">{0} aberto(s)</span>' -f $m.Itens.Count) }
      if ($pes.Novo) { Add '<span class="tag novo">sem nome na tabela</span>' }
      Add ('<span class="tag">{0}</span>' -f (Esc $m.Rotulo))
      Add '</div></div>'
    }
    Add '</div></div>'
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
  Add '</table></div>'

  # ---------------- Bloco 4: governanca e fonte de verdade
  Add '<h2>Governanca &mdash; recados, fonte de verdade e o que o painel NAO faz</h2><div class="grade-cards">'

  $recados = Get-Recados
  Add '<div class="c c6"><h4>Recados do dono para o time</h4>'
  Add '<span class="fonte">Fonte: <code>auditoria/recados-dono.md</code>, lido pelo Diretor no inicio de toda sessao.</span>'
  if ($recados.Count -eq 0) { Add '<div class="vazio">nenhum recado registrado</div>' }
  else {
    Add '<div class="lista scroll">'
    foreach ($r in ($recados | Sort-Object Data -Descending)) {
      $t = $r.Texto -replace '\s+', ' '
      if ($t.Length -gt 150) { $t = $t.Substring(0,150) + '...' }
      Add ('<div><span class="q" style="white-space:normal">{0}</span><span class="v">{1} {2}</span></div>' -f (Esc $t), (Esc $r.Data), (Esc $r.Hora))
    }
    Add '</div>'
  }
  Add '<div class="fonte" style="margin-top:10px"><b>Limite real deste painel:</b> ele so LE. O painel VS Code conseguia gravar recado novo; um arquivo HTML aberto por <code>file://</code> nao escreve em disco. Para deixar recado, editar <code>auditoria/recados-dono.md</code> direto.</div>'
  Add '</div>'

  $onde = Get-OndeEncontrar
  Add '<div class="c c6"><h4>Onde voce olha cada coisa</h4>'
  Add '<span class="fonte">Fonte: <code>auditoria/source-of-truth.md</code>. Serve pra nao existirem duas verdades sobre o mesmo assunto.</span>'
  if ($onde.Count -eq 0) { Add '<div class="vazio">tabela de fonte de verdade nao encontrada</div>' }
  else {
    Add '<div class="lista scroll">'
    foreach ($o in $onde) {
      $v = $o.Onde -replace '`', ''
      if ($v.Length -gt 46) { $v = $v.Substring(0,46) + '...' }
      Add ('<div><span class="q">{0}</span><span class="v" style="font-family:ui-monospace,Consolas,monospace;font-size:10px;font-weight:400">{1}</span></div>' -f (Esc $o.Categoria), (Esc $v))
    }
    Add '</div>'
  }
  Add '</div></div></main>'

  # ---- rodape: de onde vem cada sinal (sem isso o painel vira achismo bonito)
  Add '<footer>'
  Add '<b>De onde vem cada sinal, para nao virar achismo formatado:</b><br>'
  Add ('&bull; <b>Mesas e salas</b>: agentes descobertos ao vivo em <code>~/.claude/agents/*.md</code> ({0} arquivos); a sala vem de <code>auditoria/organograma.md</code>.<br>' -f $agentes.Count)
  Add '&bull; <b>Ponto verde "aparece no registro de hoje"</b> significa exatamente isto: o nome do agente aparece por escrito num arquivo datado de hoje em <code>auditoria/</code> ou <code>pesquisa-diaria/</code>. <b>Nao</b> quer dizer que ha um processo rodando agora - esse sinal nao existe em arquivo nenhum, e inventar um seria alerta falso.<br>'
  Add '&bull; <b>O bonequinho so digita quando o ponto esta verde.</b> Azul respira (registro nos ultimos 3 dias), ambar e cinza ficam imoveis - a animacao e amarrada ao mesmo sinal do ponto, nunca decorativa. Escritorio com pouca gente se mexendo e informacao, nao defeito.<br>'
  Add '&bull; <b>Os nomes de pessoa (Marina, Eduardo, Renata...) sao apelido de exibicao, escolha do dono em 21/08.</b> Nao existem em arquivo nenhum do ecossistema e nao substituem nada: o slug tecnico segue impresso embaixo de cada mesa, e e ele que aparece na coluna Dono do quadro. Agente que ainda nao esta na tabela de nomes recebe um nome estavel derivado do slug e vem marcado <b>"sem nome na tabela"</b> - nunca batizado em silencio.<br>'
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

  # todo agente do diretorio tem nome na tabela? se um cair no fallback, o
  # painel mostra "sem nome na tabela" - o teste avisa antes de o dono ver
  $semNome = @($agentes | Where-Object { (Get-Pessoa $_).Novo })
  if ($semNome.Count -gt 0) { Write-Host ("AVISO sem nome na tabela: " + ($semNome -join ', ')) }
  else { Write-Host "ok  todos os $($agentes.Count) agentes tem nome e cargo" }
  $nomes = @($agentes | ForEach-Object { (Get-Pessoa $_).Nome })
  $nomesDup = @($nomes | Group-Object | Where-Object { $_.Count -gt 1 })
  if ($nomesDup.Count -gt 0) { Write-Host "FALHA nome repetido: $($nomesDup.Name -join ', ')"; $falhas++ }
  else { Write-Host 'ok  nenhum nome de pessoa repetido' }

  # Caso de resposta conhecida, conferido lendo a CELULA DE STATUS de cada
  # risco (penultima coluna), nao a linha inteira: riscos.md tem 6 riscos e 2
  # abertos (#3 e #6). O #1 parece aberto para qualquer instrumento que leia a
  # coluna pela posicao 9 (ele tem 13 celulas, nao 11) - a primeira versao
  # deste teste errou exatamente assim e cobrou 3.
  $rk = Get-Riscos
  $rkAb = @($rk | Where-Object { $_.Aberto })
  if ($rk.Count -eq 6) { Write-Host 'ok  6 riscos lidos' } else { Write-Host "FALHA riscos lidos: $($rk.Count), esperado 6"; $falhas++ }
  $idsAb = ($rkAb | ForEach-Object { $_.Id }) -join ','
  if ($idsAb -eq '3,6') { Write-Host 'ok  2 riscos abertos, exatamente #3 e #6' }
  else { Write-Host "FALHA riscos abertos: [$idsAb], esperado [3,6]"; $falhas++ }

  # regressao do render quebrado de 21/08: virgula decimal dentro de SVG
  if ((Inv 558.5) -eq '558.5') { Write-Host 'ok  numero em SVG sai com ponto decimal' }
  else { Write-Host "FALHA Inv devolveu '$(Inv 558.5)'"; $falhas++ }
  $svgTeste = New-Linha -Valores @(1.93, 2.07, 1.5, 3.25) -Rotulos @('a','b','c','d')
  if ($svgTeste -match 'points="([^"]*)"') {
    $g = $Matches
    $pares = $g[1].Trim().Split(' ')
    $ruim = @($pares | Where-Object { ($_.Split(',')).Count -ne 2 })
    if ($ruim.Count -gt 0) { Write-Host "FALHA coordenada com virgula decimal: $($ruim[0])"; $falhas++ }
    else { Write-Host "ok  $($pares.Count) coordenadas SVG bem formadas" }
  } else { Write-Host 'FALHA grafico de linha nao gerou points'; $falhas++ }

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
