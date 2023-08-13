$currentFolder = Get-Location

Get-ChildItem -Path $currentFolder -Recurse -Include @(".terraform", "*.hcl", "*.tfstate", "*.backup") | Where-Object { $_.PSIsContainer -eq $false } | Remove-Item -Force

Get-ChildItem -Path $currentFolder -Recurse -Directory -Filter ".terraform" | Remove-Item -Force -Recurse