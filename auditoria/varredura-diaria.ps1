# Disparado diariamente pelo workflow n8n "varreduraDiariaN8n01" (id real n4LCdeH8Usn1ZS6v,
# 15:30 America/Sao_Paulo) -- construido em 20/08 (item #92 de problemas.md). A Tarefa
# Agendada do Windows "CerebroVarreduraDiaria" citada abaixo nunca chegou a existir --
# o dono barrou a criacao via Tarefa Agendada na hora, regra de 15/08 (so cerebro-automacao
# cria automacao, e via n8n).
# Pedido direto do dono, 2026-08-19: "quero esta varredura todos os dias... tira
# um horario que o notebook estiver ligado e resolva as acoes e delegue para
# outros resolver tambem, rode em segundo plano, coloque isto como meta."
#
# Roda o Claude Code headless com escopo de Diretor, mas com a MESMA fronteira
# de seguranca que o Diretor aplicou sozinho na sessao de 19/08 (nao publicou
# em producao sem a palavra do dono, parou antes de matar processo quando
# bloqueado, delegou n8n em vez de tentar): correcao local esta liberada,
# producao/dinheiro/decisao N0-N1/n8n exigem aprovacao explicita, nunca execucao
# silenciosa.
$ProgressPreference = 'SilentlyContinue'  # gotcha de PowerShell nao-interativo, ver #87
Set-Location "c:\Users\usuario\Desktop\Projeto-professor-William"

$prompt = @'
Voce e o Diretor (cerebro-ecossistema) fazendo a varredura diaria automatica de acoes pendentes. Isto e uma execucao automatica, nao supervisionada -- decida e execute o que estiver DENTRO da fronteira de seguranca abaixo, sem parar pra perguntar "como quer seguir". Fora da fronteira, NUNCA execute -- registre como pendente de aprovacao.

FRONTEIRA DE SEGURANCA -- NAO NEGOCIAVEL NESTA EXECUCAO:

PODE fazer sozinho, sem pedir aprovacao (mesma classe dos fixes reais de 19/08 -- #56, #57, #61, #71, #85):
- Corrigir bug/config/script/doc DENTRO deste repositorio local (auditoria/, automacao-n8n/, painel-vscode/, pesquisa-diaria/, ~/.claude/knowledge/).
- Testar a correcao de verdade antes de marcar DONE (rodar o script, compilar o codigo, ler o arquivo gerado) -- nunca marcar DONE so por ter editado o arquivo.
- Atualizar problemas.md (status, prazo, dono, prova) e decisoes.md (registro de decisao N2) seguindo o formato fixo do cabecalho de cada arquivo.
- Delegar item pra outro agente/cerebro-automacao quando o dono certo ja estiver definido no processo.

NUNCA fazer sozinho -- so registrar como "aguardando aprovacao do dono" em problemas.md, com o que falta pra aprovar:
- Publicar/fazer deploy em producao (Lovable, Vercel, qualquer app ao vivo de cliente).
- Qualquer coisa que gaste dinheiro (categoria N0 "Dinheiro saindo").
- Matar processo do sistema, instalar/desinstalar software fora deste repositorio, mexer em tarefa agendada do Windows que nao seja a propria varredura.
- Editar workflow n8n -- e mandato exclusivo do cerebro-automacao (decisao de 15/08), a varredura so registra o achado com dono=cerebro-automacao.
- Qualquer decisao de categoria N0 ou N1 da Escada de Autonomia (decisoes.md, cabecalho "Placar por categoria") -- estrutura de time, marca/voz, saida externa, dado apagado.
- Escolha subjetiva/criativa que e do dono (ex: qual variante de anuncio, qual referencia visual) -- nunca decidir por ele.
- Bump de versao MAJOR de dependencia com risco funcional (tipo react-router-dom v6->v7) sem teste dedicado -- so bump de patch/minor com prova de audit limpo.

O QUE FAZER, NA ORDEM:

1. Ler auditoria/problemas.md INTEIRO (nao so o topo -- tem 500+ linhas, itens recentes ficam perto do fim e da secao Resolvidos).
2. Pra cada item aberto (READY/ASSIGNED/IN_PROGRESS, nunca DONE/CANCELLED/BLOCKED por decisao consciente), classificar: dentro da fronteira (resolver agora, com teste real) ou fora (registrar pendencia de aprovacao, nunca fingir que resolveu).
3. Pros itens dentro da fronteira: investigar causa raiz de verdade (ler codigo/log real, nunca supor), aplicar a correcao, TESTAR (rodar/compilar/ler saida), e so entao atualizar problemas.md com Status=DONE e a prova real igual ao padrao ja usado no arquivo (ver itens #56/#57/#61/#71/#85 como exemplo de formato).
4. Pros itens fora da fronteira que ainda nao tem essa marcacao: adicionar ao texto do item "AGUARDANDO APROVACAO DO DONO: [o que falta decidir]" sem mudar Dono/Prazo.
5. Se achar problema NOVO durante a varredura (nao listado ainda), seguir a regra do arquivo: registrar na hora, nunca guardar.
6. NUNCA apagar linha, nunca inventar problema que nao existe, nunca reabrir item ja fechado sem prova nova real.
7. Escrever um resumo curto em auditoria/varredura-diaria-ultima-execucao.md (SOBRESCREVER o de ontem -- e resumo vivo): quantos itens resolvidos hoje (com numero), quantos ficaram fora da fronteira aguardando aprovacao (com numero e 1 linha cada), quantos delegados a outro agente.

Se nao achar nenhum item acionavel dentro da fronteira hoje, escreva isso mesmo no resumo -- silencio nao e opcao, mas inventar resolucao pra preencher tambem nao.
'@

$SAIDA = "c:\Users\usuario\Desktop\Projeto-professor-William\auditoria\varredura-diaria-ultima-execucao.log"
$env:CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS = "0"
$null | claude -p $prompt --dangerously-skip-permissions --output-format text 2>&1 | Out-File -FilePath $SAIDA -Encoding utf8

# Jidoka (Shingo): guarda anti-sucesso-falso, mesmo padrao do item #77 -- saida
# suspeita (vazia, cota semanal batida, erro de sessao) nunca conta como
# execucao boa. Escreve um alerta real em vez de deixar o log mentir sozinho.
$conteudo = Get-Content $SAIDA -Raw -ErrorAction SilentlyContinue
$ALERTAS = "c:\Users\usuario\Desktop\Projeto-professor-William\auditoria\alertas-automaticos.md"
$suspeito = (-not $conteudo) -or $conteudo.Length -lt 200 -or ($conteudo -match 'weekly limit|usage limit|session limit|rate limit|quota exceeded')
if ($suspeito) {
  $agora = Get-Date
  $motivo = if ($conteudo -match 'weekly limit|usage limit|session limit|rate limit|quota exceeded') { 'cota de uso esgotada' } else { 'saida vazia/curta demais pra ser execucao real' }
  $bloco = "`n## $($agora.ToString('yyyy-MM-dd HH:mm')) (America/Sao_Paulo) - varredura-diaria.ps1 (automatico, FALHA)`n`nVarredura diaria nao produziu resultado real hoje -- motivo: $motivo. Nenhum item foi marcado DONE por essa execucao; conferir amanha.`n"
  Add-Content -Path $ALERTAS -Value $bloco -Encoding utf8
}
