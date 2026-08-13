$ErrorActionPreference = 'Continue'
Set-Location "C:\Users\usuario\Desktop\Projeto-professor-William"
& git add -A 2>$null
$status = & git status --porcelain
if ($status) {
  $msg = "Backup automatico - " + (Get-Date -Format 'yyyy-MM-dd HH:mm')
  & git commit -m $msg 2>$null
  & git push origin main 2>$null
}
