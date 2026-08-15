$env:NODE_FUNCTION_ALLOW_BUILTIN = "fs,path,child_process"
$env:N8N_MCP_ACCESS_ENABLED = "true"
# Teto default do Task Broker pra uma task de Code node e 300s (5min) -- baixo
# demais pros workflows diarios que chamam claude CLI e podem levar minutos
# (achado real, 14/08: integradorN8n00001 abortou em "Task execution timed
# out after 300 seconds"). 2700s (45min) cobre com folga ate a rotina mais
# pesada (trilhas, ate 10 trilhas de pesquisa).
$env:N8N_RUNNERS_TASK_TIMEOUT = "2700"
Set-Location "c:\Users\usuario\Desktop\Projeto-professor-William\automacao-n8n"
$logPath = "c:\Users\usuario\Desktop\Projeto-professor-William\automacao-n8n\n8n-start.log"

while ($true) {
    $ja_rodando = Get-CimInstance Win32_Process -Filter "Name='node.exe'" | Where-Object { $_.CommandLine -like "*n8n*start*" }
    if (-not $ja_rodando) {
        & ".\node_modules\.bin\n8n.cmd" start *> $logPath
    }
    Start-Sleep -Seconds 30
}
