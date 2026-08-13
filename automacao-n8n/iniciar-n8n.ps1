$env:NODE_FUNCTION_ALLOW_BUILTIN = "fs,path,child_process"
Set-Location "c:\Users\usuario\Desktop\Projeto-professor-William\automacao-n8n"
$logPath = "c:\Users\usuario\Desktop\Projeto-professor-William\automacao-n8n\n8n-start.log"

while ($true) {
    $ja_rodando = Get-CimInstance Win32_Process -Filter "Name='node.exe'" | Where-Object { $_.CommandLine -like "*n8n*start*" }
    if (-not $ja_rodando) {
        & ".\node_modules\.bin\n8n.cmd" start *> $logPath
    }
    Start-Sleep -Seconds 30
}
