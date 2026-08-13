# Auditoria diaria do ecossistema — FASE 5 do processo-empresa.md
#
# Responde as 5 perguntas do dono (2026-08-02):
#   1. Os processos estao funcionando?
#   2. O processo e a memoria estao sendo usados pela equipe?
#   3. As trilhas de conhecimento estao rodando para todo o time?
#   4. Isso esta desenvolvendo habilidade de verdade?
#   5. Os niveis de conhecimento estao avancando?
#
# Nao usa julgamento: le arquivo, conta, compara com o snapshot de ontem.
# Numero que ninguem auditou foi o que deixou tres reunioes relatarem
# "time em 1,45" com a trilha que alimenta esse numero parada ha semanas.
#
# Roda sem Claude, sem token, sem rede. Saida: relatorio .md + snapshot .json.

param([switch]$Encadeado)

$ErrorActionPreference = 'Stop'
$bt = [char]96   # backtick literal, fora do parser de string

$RAIZ      = 'C:\Users\usuario\Desktop\Projeto-professor-William'
$AUD       = Join-Path $RAIZ 'auditoria'
$PESQ      = Join-Path $RAIZ 'pesquisa-diaria'
$KNOW      = 'C:\Users\usuario\.claude\knowledge'
$CMDS      = 'C:\Users\usuario\.claude\commands'
$MEM       = 'C:\Users\usuario\.claude\projects\c--Users-usuario-Desktop-Projeto-professor-William\memory'

$hoje      = Get-Date -Format 'yyyy-MM-dd'
$relatorio = Join-Path $AUD "$hoje.md"
$snapAtual = Join-Path $AUD "snapshot-$hoje.json"

# Snapshot anterior — sem ele a primeira execucao so estabelece a linha de base
# Comparar sempre com o snapshot de um DIA ANTERIOR, nunca com o de hoje.
# Sobrescrever um snapshot unico fazia a segunda execucao do dia comparar
# consigo mesma e reportar "nada mudou" — falso por construcao.
$anterior = $null
$anteriores = Get-ChildItem (Join-Path $AUD 'snapshot-*.json') -ErrorAction SilentlyContinue |
              Where-Object { $_.Name -ne "snapshot-$hoje.json" } | Sort-Object Name -Descending
if ($anteriores) {
  try { $anterior = Get-Content $anteriores[0].FullName -Raw -Encoding UTF8 | ConvertFrom-Json } catch { $anterior = $null }
}

$L = New-Object System.Collections.ArrayList
function Escreve($t) { [void]$L.Add($t) }

# Cada alerta vira uma linha do resumo executivo no topo do relatorio
$alertas = New-Object System.Collections.ArrayList
function Alerta($nivel, $txt) { [void]$alertas.Add("$nivel $txt") }

Escreve "# Auditoria do ecossistema — $hoje"
Escreve ""
Escreve "> Gerada por script, sem julgamento de modelo. Todo numero aqui saiu de arquivo lido agora."
Escreve ""

# ---------------------------------------------------------------- 1. TRILHAS
Escreve "## 1. Trilhas de conhecimento"
Escreve ""

$digestHoje = Join-Path $PESQ "$hoje.md"

# A pesquisa das 08:15 e a auditoria das 09:30 disparam JUNTAS quando a maquina
# passou a noite desligada (StartWhenAvailable). Sem esperar, a auditoria corre
# na frente e acusa "nao produziu arquivo hoje" com a pesquisa ainda rodando —
# alerta vermelho falso, que e pior que alerta nenhum.
#
# So espera quando chamada DE FORA (o gatilho de seguranca das 22:00). Quando e
# o proprio run-daily.ps1 chamando em corrente (-Encadeado), esperar e deadlock:
# CerebroAnalistaMercado so para de mostrar "Running" QUANDO ESTE PROPRIO
# PROCESSO FILHO retornar — descoberto em 2026-08-06, auditoria travada ~60min
# esperando uma condicao que so ela mesma pode liberar.
$esperou = 0
if (-not $Encadeado) {
  try {
    while ((Get-ScheduledTask -TaskName 'CerebroAnalistaMercado' -ErrorAction Stop).State -eq 'Running') {
      if ($esperou -ge 60) { break }
      Start-Sleep -Seconds 120
      $esperou += 2
    }
  } catch { }
}

$rodouHoje  = Test-Path $digestHoje
$aindaRodando = $false
try { $aindaRodando = ((Get-ScheduledTask -TaskName 'CerebroAnalistaMercado' -ErrorAction Stop).State -eq 'Running') } catch { }

if ($rodouHoje) {
  Escreve "**Digest de hoje:** existe ($hoje.md)"
} elseif ($aindaRodando) {
  Escreve "**Digest de hoje:** ainda nao — a pesquisa continua rodando (esperei $esperou min)."
  Alerta '🟡' "Pesquisa passou de $esperou min sem terminar; auditoria das trilhas ficou incompleta hoje."
} else {
  # Sem digest, mas os arquivos de conhecimento cresceram? Entao a pesquisa
  # TRABALHOU e morreu no fim — diagnostico completamente diferente de "nao fez
  # nada", e exige acao diferente. Em 2026-08-04 o alerta dizia "nao produziu"
  # enquanto SETE arquivos tinham crescido: o medidor media o digest, nao o
  # conhecimento, e mandava o time procurar o problema no lugar errado.
  $cresceuHoje = 0
  foreach ($k in (Get-ChildItem (Join-Path $KNOW '*.md') -ErrorAction SilentlyContinue)) {
    if ($k.LastWriteTime.Date -eq (Get-Date).Date) { $cresceuHoje++ }
  }
  if ($cresceuHoje -ge 3) {
    Escreve "**Digest de hoje:** NAO EXISTE — mas $cresceuHoje arquivo(s) de conhecimento foram gravados hoje."
    Escreve ""
    Escreve "> A pesquisa TRABALHOU e morreu antes de escrever o digest. Nao e 'nao rodou' — e 'nao terminou'."
    Alerta '🔴' "Pesquisa morreu ANTES do digest: $cresceuHoje arquivo(s) gravados, digest ausente. Ver duracoes.csv."
  } else {
    Escreve "**Digest de hoje:** NAO EXISTE"
    Alerta '🔴' "A pesquisa diaria nao produziu arquivo hoje - e nenhum arquivo de conhecimento foi tocado."
  }
}

# Quais trilhas realmente aparecem no digest. F/G/H/I/J/K sao as que nunca podem cair.
$trilhas      = 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O'
$intocaveis   = 'F','G','H','I','J','K','L','M','N','O'
$presentes    = @()
if ($rodouHoje) {
  $txt = Get-Content $digestHoje -Raw -Encoding UTF8
  foreach ($t in $trilhas) {
    if ($txt -match "Trilha\s+$t\b") { $presentes += $t }
  }
  Escreve ""
  Escreve "| Trilha | Rodou hoje | Pode ser cortada |"
  Escreve "|---|---|---|"
  foreach ($t in $trilhas) {
    $ok = '❌ nao'
    if ($presentes -contains $t) { $ok = '✅ sim' }
    $corte = 'sim'
    if ($intocaveis -contains $t) { $corte = '**NUNCA**' }
    Escreve "| $t | $ok | $corte |"
  }
  foreach ($t in $intocaveis) {
    if ($presentes -notcontains $t) {
      Alerta '🔴' "Trilha $t nao rodou hoje — ela nunca pode ser cortada."
    }
  }
}

# Buraco no historico: dia sem digest e trilha que nao rodou, nao "dia de folga"
$ultimos = 0..13 | ForEach-Object { (Get-Date).AddDays(-$_).ToString('yyyy-MM-dd') }
$faltando = @()
foreach ($d in $ultimos) {
  if (-not (Test-Path (Join-Path $PESQ "$d.md"))) { $faltando += $d }
}
# Dia anterior ao motor existir e cicatriz, nao ferida: ninguem pesquisa numa
# data passada. Contar os dois juntos gerava amarelo permanente ate ~15/08,
# que treina o dono a ignorar o painel e esconde o proximo vermelho de verdade.
$GOLIVE = '2026-08-02'
$congelados = @($faltando | Where-Object { $_ -lt $GOLIVE })
$reais      = @($faltando | Where-Object { $_ -ge $GOLIVE })
Escreve ""
Escreve "**Cobertura desde o go-live do motor ($GOLIVE):** $(if ($reais.Count -eq 0) { 'sem buraco' } else { "$($reais.Count) dia(s) sem digest" })"
if ($reais.Count -gt 0) {
  Escreve ""
  Escreve "Dias vivos sem digest: $($reais -join ', ')"
  Alerta '🔴' "$($reais.Count) dia(s) sem pesquisa desde o go-live - falha real do motor."
}
if ($congelados.Count -gt 0) {
  Escreve ""
  Escreve "Buraco congelado (anterior ao motor, irrecuperavel, nao alerta): $($congelados -join ', ')"
}

# Resultado 0 da tarefa agendada NAO e prova — so diz que o processo terminou
try {
  $info = Get-ScheduledTaskInfo -TaskName 'CerebroAnalistaMercado' -ErrorAction Stop
  Escreve ""
  Escreve "**Tarefa agendada:** ultima execucao $($info.LastRunTime), codigo $($info.LastTaskResult), proxima $($info.NextRunTime)"
  Escreve ""
  Escreve "> Codigo 0 nao e prova de que rodou — prova e o digest acima existir e conter as trilhas."
} catch {
  Escreve ""
  Escreve "**Tarefa agendada:** NAO ENCONTRADA"
  Alerta '🔴' "A tarefa agendada CerebroAnalistaMercado sumiu."
}

# ---------------------------------- 1.b POKA-YOKE DA TRILHA C (fonte primaria)
# Regra que ninguem mede apodrece. A Trilha C OBRIGAVA video e estava em 60% de
# texto sem nenhum sinal disparar — desvio normalizado (Vaughan). Agora a regra
# e "1 fonte primaria/dia", e a aderencia passa a ser medida todo dia.
if ($rodouHoje) {
  $fase = 0
  $arqUni = Join-Path $KNOW 'universidade-diretor.md'
  if (Test-Path $arqUni) {
    $mf = Select-String -Path $arqUni -Pattern '\*\*Fase:\*\*\s*(\d+)' | Select-Object -First 1
    if ($mf) { $fase = [int]$mf.Matches[0].Groups[1].Value }
  }
  # Recorta so a secao da Trilha C do digest
  $secC = ''
  if ($txt -match '(?s)\n## [^\n]*Trilha C(.*?)(?=\n## |\z)') { $secC = $Matches[1] }
  $linksC = [regex]::Matches($secC, 'https?://[^\s\)\]]+')
  $videoC = @($linksC | Where-Object { $_.Value -match 'youtu|vimeo|instagram\.com/p|tiktok' })

  Escreve ""
  Escreve "**Trilha C — aderencia a fonte primaria** (Fase $fase): $($linksC.Count) fonte(s), $($videoC.Count) de video"
  if ($linksC.Count -eq 0) {
    Alerta '🟡' "Trilha C rodou sem nenhuma fonte com link - nao da para verificar o que foi estudado."
  } elseif ($videoC.Count -gt 0 -and $fase -ne 3 -and $fase -ne 4) {
    Escreve ""
    Escreve "> Video usado fora das Fases 3/4. Permitido se for a melhor fonte disponivel e o digest disser por que - conferir no texto."
  }
}

# ------------------------------------------ 1.c DURACAO REAL DA PESQUISA (MSA)
# Limite de execucao definido por chute foi o que matou a pesquisa. Agora o
# numero existe: o run-daily grava cada execucao em duracoes.csv.
$arqDur = Join-Path $PESQ 'duracoes.csv'
if (Test-Path $arqDur) {
  $linhas = @(Get-Content $arqDur -Encoding UTF8 | Select-Object -Skip 1 | Where-Object { $_ -match ';' })
  if ($linhas.Count -gt 0) {
    $mins = @($linhas | ForEach-Object { [double]($_ -split ';')[2] })
    $media = [math]::Round(($mins | Measure-Object -Average).Average, 1)
    $pior  = [math]::Round(($mins | Measure-Object -Maximum).Maximum, 1)
    $limite = 0
    try { $limite = ([System.Xml.XmlConvert]::ToTimeSpan((Get-ScheduledTask -TaskName 'CerebroAnalistaMercado' -ErrorAction Stop).Settings.ExecutionTimeLimit)).TotalMinutes } catch { }
    Escreve ""
    Escreve "**Duracao da pesquisa** ($($linhas.Count) execucao/oes medidas): media $media min - pior caso $pior min - limite atual $limite min"
    if ($limite -gt 0 -and $pior -gt ($limite * 0.8)) {
      Alerta '🟡' "Pior caso ($pior min) passou de 80% do limite ($limite min) - o teto vai ser atingido."
    }
  }
} else {
  Escreve ""
  Escreve "**Duracao da pesquisa:** ainda sem medicao (duracoes.csv sera criado na proxima execucao completa)."
}

# ------------------------------------------------- 2. NIVEIS DOS ESPECIALISTAS
Escreve ""
Escreve "## 2. Niveis dos especialistas"
Escreve ""

$arqNiveis = Join-Path $KNOW 'mestres-marketing-agencia.md'
$niveis = @{}
if (Test-Path $arqNiveis) {
  foreach ($linha in (Get-Content $arqNiveis -Encoding UTF8)) {
    # Nao usar backtick no padrao: "$bt?" e absorvido no nome da variavel pelo
    # parser e some do regex. Casa a linha inteira e limpa o nome depois.
    if ($linha -match '^\|([^|]+)\|\s*(\d+)\s*\|') {
      # Guardar o numero ANTES do segundo -match: qualquer -match reescreve
      # $Matches, e o nivel virava 0 em todo mundo sem erro nenhum.
      $nome = $Matches[1].Trim().Trim([char]96).Trim()
      $valor = [int]$Matches[2]
      if ($nome -match '^[a-z][a-z0-9\-]+$') { $niveis[$nome] = $valor }
    }
  }
}

if ($niveis.Count -eq 0) {
  Escreve "Nenhum nivel encontrado em mestres-marketing-agencia.md."
  Alerta '🟡' "A tabela de niveis nao pode ser lida — auditoria de evolucao cega."
} else {
  $soma  = ($niveis.Values | Measure-Object -Sum).Sum
  $media = [math]::Round($soma / $niveis.Count, 2)
  Escreve "**$($niveis.Count) especialistas · media $media/5**"
  Escreve ""
  Escreve "| Especialista | Nivel | vs. ultima auditoria |"
  Escreve "|---|---|---|"
  foreach ($k in ($niveis.Keys | Sort-Object)) {
    $delta = 'linha de base'
    if ($anterior -and $anterior.niveis) {
      $antes = $anterior.niveis.$k
      if ($null -ne $antes) {
        if ($niveis[$k] -gt $antes)      { $delta = "⬆ subiu de $antes" }
        elseif ($niveis[$k] -lt $antes)  { $delta = "⬇ CAIU de $antes" }
        else                             { $delta = '= parado' }
      } else { $delta = 'novo' }
    }
    Escreve "| $bt$k$bt | $($niveis[$k]) | $delta |"
  }

  if ($anterior -and $null -ne $anterior.mediaNivel) {
    if ($media -gt $anterior.mediaNivel) {
      Escreve ""
      Escreve "Media subiu: $($anterior.mediaNivel) → $media"
    } else {
      $dias = 1
      if ($anterior.diasSemEvolucao) { $dias = [int]$anterior.diasSemEvolucao + 1 }
      Escreve ""
      Escreve "Media parada em $media ha **$dias dia(s)**."
      if ($dias -ge 7) { Alerta '🟡' "Nenhum especialista subiu de nivel ha $dias dias." }
      $script:diasParado = $dias
    }
  }
}
if (-not $script:diasParado) { $script:diasParado = 0 }

# ------------------------------------ 3. O CONHECIMENTO ESTA CRESCENDO MESMO?
Escreve ""
Escreve "## 3. A base de conhecimento cresceu?"
Escreve ""
Escreve "Trilha que roda mas nao engorda arquivo nenhum nao produziu conhecimento — produziu log."
Escreve ""
Escreve "| Arquivo | Linhas | vs. ultima auditoria |"
Escreve "|---|---|---|"

$tamanhos = @{}
$estagnados = 0
foreach ($f in (Get-ChildItem (Join-Path $KNOW '*.md') | Sort-Object Name)) {
  # .Count, nao Measure-Object -Line: este ultimo descarta linha vazia e
  # subnotificava o tamanho real (33 onde havia 50).
  $n = @(Get-Content $f.FullName -Encoding UTF8).Count
  $tamanhos[$f.Name] = $n
  $delta = 'linha de base'
  if ($anterior -and $anterior.tamanhos) {
    $antes = $anterior.tamanhos.($f.Name)
    if ($null -ne $antes) {
      $d = $n - $antes
      if ($d -gt 0)    { $delta = "+$d" }
      elseif ($d -lt 0){ $delta = "$d (encolheu)" }
      else             { $delta = '—'; $estagnados++ }
    } else { $delta = 'novo' }
  }
  Escreve "| $bt$($f.Name)$bt | $n | $delta |"
}

# Limite fixo de linhas era proxy ruim: chamava de "vazio" arquivo que tinha
# crescido 85% no dia. O sinal certo e CRESCIMENTO — trilha que roda e nao
# engorda o arquivo dela nao entregou, independente do tamanho absoluto.
$trilhaPorArquivo = @{ 'gestao.md' = 'G'; 'operacional.md' = 'H'; 'brand-inspiracao.md' = 'I'; 'mestres-marketing-agencia.md' = 'F'; 'mestres-copy.md' = 'E'; 'pedagogia.md' = 'J'; 'qualidade-lean.md' = 'K'; 'edicao-lingua.md' = 'L'; 'rotinas-operacionais.md' = 'M'; 'facilitacao-reuniao.md' = 'N'; 'integracao-operacional.md' = 'O' }
foreach ($crit in $trilhaPorArquivo.Keys) {
  if (-not $tamanhos.ContainsKey($crit)) { continue }
  if ($presentes -notcontains $trilhaPorArquivo[$crit]) { continue }
  if ($anterior -and $anterior.tamanhos -and $null -ne $anterior.tamanhos.$crit) {
    if ($tamanhos[$crit] -le $anterior.tamanhos.$crit) {
      Alerta '🟡' "Trilha $($trilhaPorArquivo[$crit]) rodou mas $crit nao cresceu - produziu log, nao conhecimento."
    }
  }
}

# ------------------------------------------- 4. PROCESSO E MEMORIA EM USO
Escreve ""
Escreve "## 4. O processo e a memoria estao sendo usados?"
Escreve ""

$skills = Get-ChildItem (Join-Path $CMDS '*.md')
$semPortao = @()
foreach ($s in $skills) {
  if ($s.Name -eq 'sono-bebe.md') { continue }
  if (-not (Select-String -Path $s.FullName -Pattern 'processo-empresa\.md' -Quiet)) {
    $semPortao += $s.Name
  }
}

# Os agentes globais (Agent tool) em ~/.claude/agents/ sao um mecanismo SEPARADO
# das skills acima — descoberto em 04/08 quando o dono pediu que todo agente do
# time tambem virasse "agente global" via Agent tool. Sem checar aqui, e um
# portao novo que escaparia exatamente como a lacuna #9 ja catalogada (skill de
# terceiro sem portao). So conta os NOSSOS (cerebro-*/ceo-*), direto na raiz de
# agents/ — as subpastas (marketing/, sales/, engineering/, design/) sao
# agentes genericos pre-instalados, nao o nosso time.
$AGENTS = 'C:\Users\usuario\.claude\agents'
$nossosAgents = Get-ChildItem (Join-Path $AGENTS '*.md') -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^(cerebro|ceo)-' }
foreach ($a in $nossosAgents) {
  if (-not (Select-String -Path $a.FullName -Pattern 'processo-empresa\.md' -Quiet)) {
    $semPortao += "agents/$($a.Name)"
  }
}

$totalChecado = ($skills.Count - 1) + $nossosAgents.Count
$comPortao = $totalChecado - $semPortao.Count
Escreve "**Portao do processo:** $comPortao de $totalChecado skills+agentes (cerebro-*/ceo-*) apontam para processo-empresa.md"
Escreve ""
Escreve "($($skills.Count - 1) skills em commands/ + $($nossosAgents.Count) agentes globais em agents/)"
if ($semPortao.Count -gt 0) {
  Escreve ""
  Escreve "Sem portao: $($semPortao -join ', ')"
  Alerta '🔴' "$($semPortao.Count) skill(s)/agente(s) rodando fora do processo obrigatorio."
}

$nMem = (Get-ChildItem (Join-Path $MEM '*.md') | Where-Object { $_.Name -ne 'MEMORY.md' }).Count
$idxMem = 0
if (Test-Path (Join-Path $MEM 'MEMORY.md')) {
  $idxMem = (Select-String -Path (Join-Path $MEM 'MEMORY.md') -Pattern '^\s*-\s*\[').Count
}
Escreve ""
Escreve "**Memoria:** $nMem arquivos, $idxMem indexados em MEMORY.md"
if ($nMem -ne $idxMem) {
  Alerta '🟡' "Memoria fora de sincronia: $nMem arquivos para $idxMem linhas no indice."
}

# Rastro que so aparece se a equipe realmente seguiu o processo
$licoes = 0
if (Test-Path (Join-Path $KNOW 'lessons-learned.md')) {
  $licoes = (Select-String -Path (Join-Path $KNOW 'lessons-learned.md') -Pattern '^##\s').Count
}
$lacAbertas = 0; $lacResolvidas = 0
$arqLac = Join-Path $KNOW 'lacunas-conhecidas.md'
if (Test-Path $arqLac) {
  $lac = Get-Content $arqLac -Raw -Encoding UTF8
  $lacAbertas    = ([regex]::Matches($lac, '(?m)^###\s')).Count
  $lacResolvidas = ([regex]::Matches($lac, 'resolvida', 'IgnoreCase')).Count
}
Escreve ""
Escreve "**Rastro do processo:** $licoes licoes registradas · $lacAbertas lacunas listadas · $lacResolvidas marcadas como resolvidas"
Escreve ""
Escreve "> ⚠️ **Limite honesto desta auditoria.** Nao existe telemetria que prove que um agente *leu* o processo numa sessao passada. O que este bloco mede e o **rastro** que o processo deixa quando e seguido: licao nova registrada, lacuna exposta, portao presente. Rastro parado por muitos dias e sinal de que o processo virou enfeite — nao e prova."

if ($anterior -and $null -ne $anterior.licoes -and $licoes -eq $anterior.licoes -and $lacAbertas -eq $anterior.lacunasAbertas) {
  Alerta '🟢' "Nenhuma licao ou lacuna nova desde a ultima auditoria."
}

# ------------------------------------------ 4.b ESCADA DE AUTONOMIA
# O dono quer que o time decida sozinho no futuro. Isso se conquista com taxa
# de reversao medida, nunca por declaracao. Aqui so se mede; quem promove ou
# rebaixa categoria e o Diretor, com o dono.
Escreve ""
Escreve "## 4.b Escada de Autonomia"
Escreve ""
$arqDec = Join-Path $AUD 'decisoes.md'
if (Test-Path $arqDec) {
  $dec = Get-Content $arqDec -Encoding UTF8
  # Linhas da tabela de decisoes: comecam com "| 2026-"
  $linhas    = @($dec | Where-Object { $_ -match '^\|\s*20\d\d-' })
  $pendentes = @($linhas | Where-Object { $_ -match 'pendente' })
  $revertidas= @($linhas | Where-Object { $_ -match 'revert(eu|ida)\s*\|' -or $_ -match '\|\s*sim\s*\|\s*$' })
  $vencidas  = @($linhas | Where-Object {
      if ($_ -match '\|\s*(20\d\d-\d\d-\d\d)\s*\|\s*\*?\(?pendente') { $Matches[1] -lt $hoje } else { $false } })

  Escreve "**$($linhas.Count) decisao(oes) registrada(s)** - $($pendentes.Count) aguardando revisao, $($revertidas.Count) revertida(s) pelo dono"
  if ($vencidas.Count -gt 0) {
    Alerta '🟡' "$($vencidas.Count) decisao(oes) com data de revisao vencida - ceo-orquestrador persegue."
  }
  Escreve ""
  Escreve "> Autonomia sobe por **taxa de reversao**, nunca por volume. Decidir muito e errar e dano com velocidade."
} else {
  Escreve "Registro de decisao ausente."
  Alerta '🔴' "auditoria/decisoes.md nao existe - a escada de autonomia esta sem instrumento."
}

# ------------------------------------------------------- 5. ENCAMINHAMENTO
# Regra do dono (2026-08-02): todo erro achado aqui vai para o Diretor
# (cerebro-ecossistema). Ele delega para a celula dona. Se a celula nao
# resolver, ele mesmo resolve — nao fica pendurado.
Escreve ""
Escreve "## 5. Encaminhamento dos alertas"
Escreve ""
if ($alertas.Count -eq 0) {
  Escreve "Nada a encaminhar."
} else {
  Escreve "| Alerta | Dono | Se nao resolver |"
  Escreve "|---|---|---|"
  foreach ($a in $alertas) {
    $dono = 'Diretor (cerebro-ecossistema)'
    $fallback = 'item nao-delegavel: o Diretor ja e o dono'
    if ($a -match 'Trilha|pesquisa|gestao\.md|operacional\.md|nivel') {
      $dono = 'Celula Conhecimento & Operacao (cerebro-knowledge-architect)'
      $fallback = 'Diretor assume em 2 dias'
    }
    if ($a -match 'portao|Memoria|tarefa agendada|licao') {
      $dono = 'Diretor (cerebro-ecossistema)'
      $fallback = 'item nao-delegavel: o Diretor resolve'
    }
    $limpo = $a -replace '^[^ ]+ ', ''
    Escreve "| $limpo | $dono | $fallback |"
  }
  Escreve ""
  Escreve "> Alerta que aparece em 3 auditorias seguidas deixa de ser alerta e vira lacuna: registrar em lacunas-conhecidas.md e levar para a reuniao."
}

# -------------------------------------------------------------- RESUMO NO TOPO
$cab = New-Object System.Collections.ArrayList
[void]$cab.Add("# Auditoria do ecossistema — $hoje")
[void]$cab.Add("")
if ($alertas.Count -eq 0) {
  [void]$cab.Add("## ✅ Nenhum alerta")
  [void]$cab.Add("")
  [void]$cab.Add("Trilhas rodaram, portao integro, niveis e base sem regressao.")
} else {
  [void]$cab.Add("## Alertas ($($alertas.Count))")
  [void]$cab.Add("")
  foreach ($a in $alertas) { [void]$cab.Add("- $a") }
}
[void]$cab.Add("")
[void]$cab.Add("---")
[void]$cab.Add("")

$saida = @($cab) + @($L | Select-Object -Skip 2)
if (-not (Test-Path $AUD)) { New-Item -ItemType Directory -Path $AUD | Out-Null }
$saida -join "`r`n" | Out-File -FilePath $relatorio -Encoding utf8

# Snapshot para o diff de amanha
$snap = [ordered]@{
  data            = $hoje
  niveis          = $niveis
  mediaNivel      = $(if ($niveis.Count -gt 0) { [math]::Round((($niveis.Values | Measure-Object -Sum).Sum / $niveis.Count), 2) } else { 0 })
  diasSemEvolucao = $script:diasParado
  tamanhos        = $tamanhos
  licoes          = $licoes
  lacunasAbertas  = $lacAbertas
  trilhasHoje     = $presentes
  alertas         = @($alertas)
}
$snap | ConvertTo-Json -Depth 4 | Out-File -FilePath $snapAtual -Encoding utf8

# ------------------------------------------- REUNIAO DIARIA AUTOMATICA
# Regra do dono (2026-08-03, ampliada 2026-08-04): "quero todos os dias as
# respostas das solucoes pelo Diretor" + "quero todo envolvimento do time de
# gestao na reuniao sem eu cobrar — diretor, ceo, qualidade, reitor, todos
# participando" + "o secretario tambem cobra a participacao do time".
# Uma execucao so, orquestrando os papeis — separar em tarefas viraria a
# mesma corrida que foi bug hoje. O script mede; quem propoe e decide e o time.
$respDiretor = Join-Path $AUD "$hoje-reuniao.md"
$promptDiretorPath = Join-Path $AUD "prompt-reuniao.txt"
# Prompt vive em arquivo texto separado, de proposito: nenhuma interpolacao ou
# escape de PowerShell dentro dele. So um .Replace() simples, sem risco de
# quebrar entre linguagens (Armadilha 1 do catalogo).
$promptDiretor = (Get-Content -Path $promptDiretorPath -Raw -Encoding UTF8).Replace('{{RELATORIO}}', $relatorio).Replace('{{DATA}}', $hoje)

# Escreve em temporario e move: duas execucoes no mesmo dia travavam o arquivo
# final e a resposta se perdia inteira por causa do lock.
$tmpDiretor = Join-Path $AUD "$hoje-reuniao.tmp"
try {
  # O operador de redirecionamento "*>" grava em UTF-16LE no PowerShell 5.1 —
  # nao e a mesma coisa que Out-File -Encoding utf8. A reuniao de 2026-08-04
  # saiu ilegivel (cada caractere com espaco) por causa disso. Out-File com
  # -Encoding explicito e o que garante UTF-8 de verdade.
  #
  # Mesmo teto de 600s do claude.exe headless achado em run-daily.ps1 em
  # 2026-08-06 tambem se aplica aqui — esta chamada roda de verdade todo dia,
  # encadeada apos a auditoria. Sem isso, a reuniao automatica corre o mesmo
  # risco de se matar sozinha aos 10min sem escrever nada.
  $env:CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS = "0"
  claude -p $promptDiretor --dangerously-skip-permissions --output-format text 2>&1 | Out-File -FilePath $tmpDiretor -Encoding utf8
  Move-Item $tmpDiretor $respDiretor -Force
  Write-Output "reuniao do dia: $respDiretor"
} catch {
  Write-Output "FALHOU a reuniao do dia: $($_.Exception.Message)"
}

Write-Output "auditoria: $relatorio"
Write-Output "alertas: $($alertas.Count)"
foreach ($a in $alertas) { Write-Output "  $a" }
