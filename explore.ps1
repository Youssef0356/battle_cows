param([string]$Path='C:\Users\Youssef356\Documents\battle_cows')
Write-Output '=====LIB FILES====='
Get-ChildItem -Path "$Path\lib" -Recurse -File -Filter '*.dart' | ForEach-Object { $Paths=$_.FullName.Substring($Path.Length); $rel=$Paths.TrimStart('\'); Write-Output $rel }
Write-Output '=====GAME LOGIC REFS (battle cows names)====='
Get-ChildItem -Path "$Path\lib" -Recurse -File -Filter '*.dart' | Select-String -SimpleMatch -Pattern 'Battle Cows','BattleCows','battle_cows','battleCows','battle cows' | ForEach-Object { $rel=$_.Path.Substring($Path.Length); $rel+':'+$_.LineNumber+':'+$_.Line.Trim() } | Select-Object -First 80
