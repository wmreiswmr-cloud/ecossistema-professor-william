# Disparado diariamente às 22h, encadeado pelo workflow n8n "auditoriaN8n000001"
# (nao chama este script direto -- gera a auditoria e o pipeline segue pra reuniao).
# Corrigido 20/08 (item #93 de problemas.md) -- a Tarefa Agendada do Windows
# "ReuniaoDiretorTime" existe mas esta Disabled e sem uso; decisao de remove-la
# ou nao ainda pendente do dono (nao removida por cerebro-automacao sem confirmar).
# Roda o Claude Code headless invocando a skill cerebro-ecossistema (Innovator Director)
# pra reportar o status de maturidade do time de marketing da agência.
Set-Location "c:\Users\usuario\Desktop\Projeto-professor-William"

$prompt = @'
Use a skill cerebro-ecossistema (Innovator Director) pra fazer a "reunião diária" de status do time de marketing da agência.

Passos obrigatórios:
1. Reler ~/.claude/knowledge/mestres-marketing-agencia.md (status + roadmap de cada especialista) e a escada de maturidade 0-10 registrada em ~/.claude/commands/ceo-orquestrador-agencia.md — nunca confiar em memória de execuções anteriores, reler os arquivos de verdade.
2. Reportar o status atual de cada um dos 11 especialistas (cerebro-copy, cerebro-funil, cerebro-vendas, cerebro-trafego, cerebro-branding, cerebro-seo, cerebro-growth-hacker, cerebro-financeiro, cerebro-analista-mercado-agencia, cerebro-social-media, ceo-orquestrador-agencia): nível atual (0-10) e o que mudou desde a última execução registrada no log do arquivo.
3. Avaliar se o objetivo (nível 10 = melhor time do mundo, referência Brasil + internacional, prazo até 2027-07-29) está avançando no ritmo esperado — nunca inventar progresso que não está documentado nos arquivos. Lembrar que níveis 6-10 exigem campanha real rodando, não só pesquisa — a Trilha F cobre só a metade "conhecimento" da meta.
4. Pra qualquer especialista estagnado (sem mudança desde a execução anterior), investigar a causa raiz real — falta de pesquisa nova? falta de teste em campanha real (nível 3 exige isso)? bloqueio identificado? — e propor um plano de ação concreto e específico pra esse especialista, nunca um conselho genérico tipo "precisa evoluir mais".
5. Atualizar ~/.claude/knowledge/mestres-marketing-agencia.md com o que mudou (nova linha no log, nunca reescrever a tabela inteira) e a seção de meta em ceo-orquestrador-agencia.md se algum nível mudou.
6. Reler a seção "Meta de Ferramentas" em ~/.claude/commands/cerebro-ecossistema.md e reportar o status de cada gap (Analytics, Stripe, context7, Email/CRM, WhatsApp Business API): mudou algo desde ontem (usuário autorizou algo, ferramenta nova apareceu em `claude mcp list`)? Rodar `claude mcp list` de verdade pra checar, nunca assumir. Isso é checagem, não pesquisa de ferramenta nova — só reportar o que existe hoje, nunca sugerir instalar algo sem o usuário pedir.
7. Escrever o relatório completo em reuniao-diretor/AAAA-MM-DD.md na raiz deste projeto — seção por especialista (causa raiz + plano de ação pra quem estagnou), seção de status de ferramentas, e um resumo geral de "estamos no ritmo ou não" ao final.

Lembrete crítico: esta execução é automática e não supervisionada. Nunca edite código de projeto, nunca rode git ou deploy, nunca instale pacotes, nunca invente nível/progresso que não esteja documentado em arquivo real. Esta rotina não gera nem republica o gráfico visual (Artifact) — isso só acontece numa sessão interativa quando o usuário pedir; aqui o registro é em texto/markdown.

Como último passo, envie uma PushNotification (status "proactive") resumindo o resultado em até 200 caracteres, sem markdown — ex: "Time: 3 especialistas evoluíram, 8 estagnados (causa: falta de teste real). Ritmo: [no prazo/atrasado]." Se a ferramenta não estiver disponível nesta execução, apenas ignore e siga em frente — o relatório em arquivo já é o registro que importa.
'@

# Lock global (#116, A3 22/08): impede que este "claude -p" rode ao mesmo tempo
# que qualquer outro do ecossistema e estoure a RAM da maquina.
. "c:\Users\usuario\Desktop\Projeto-professor-William\automacao-n8n\claude-p-lock.ps1"
Lock-ClaudeP
try {
  claude -p $prompt --dangerously-skip-permissions --output-format text *> "c:\Users\usuario\Desktop\Projeto-professor-William\reuniao-diretor\ultima-execucao.log"
} finally {
  Unlock-ClaudeP
}
