# @Author Juned Ansari
# .\download.ps1 -origin https://nginx.org -MainSite http://gemmaray.tv/content/wp-admin/user/admin.php -LocalOutputPath C:\Users\Public -FileExtensions php

Param (
 [Parameter(Mandatory = $true)][string]$origin,
 [Parameter(Mandatory = $true)][string]$MainSite,
 [Parameter(Mandatory = $true)][string]$LocalOutputPath,
 [Parameter(Mandatory = $true)][string]$FileExtensions
)
$DocumentType = @($FileExtensions.split(','))


Function Get-Files {
param (
 [Parameter(Mandatory = $true)][string]$OutputPath,
 [Parameter(Mandatory = $true)][string]$Site
)
try { $data = Invoke-WebRequest -Uri $site }
catch { "unable to gather data from $($site)" }
If (!(Test-Path $OutputPath))
{
$FolderResult = New-Item -Path $OutputPath -Type Directory -Force
if($FolderResult){Write-Host "Created Folder Path: $FolderResult" -ForegroundColor Yellow}
else {Write-Output "`nCan't create Folder Path: $OutputPath"; Write-Output "Create manually and Try again, Bye..`n";exit;}
}
$OutputPath = $OutputPath.TrimEnd("\")
if ($data)
{
 [array]$Links = @()
 $Links += ($data.Links).Href
 $Filter = '(?i)(' + (($DocumentType | % { [regex]::escape($_) }) -join "|") + ')$'
 [array]$FilesToDownload = $Links -match $Filter
 $flag = 1
 $i = 1
 $iTotal = $FilesToDownload.Count
Write-Host "Total Available Files to Download are: $iTotal" -ForegroundColor Yellow
if ($iTotal -eq 0){return}
 foreach ($File in $FilesToDownload)
 {
  $Filename = Split-Path $File -Leaf
  $File = $Site + $File
  $OutputFile = Join-Path $OutputPath -ChildPath $Filename
  Write-Progress -Activity "Downloading $($File)." -PercentComplete (($i/$iTotal) * 100) -Id 1 -Status "File $($i) of $($iTotal)"
  $params = @{ }
  $params.Add('Uri', $File)
  $params.Add('OutFile', $OutputFile)
  try { Invoke-WebRequest @params }
  catch { Write-Progress -Status "Error downloading $($File)." -Activity "Downloading $($File)." }
  $i++
 }
 Write-Progress -Activity "Finished." -Completed
}
}

function Generate-Href([string[]]$subdir,[string]$biglink) {
[array]$linker = @()
foreach ($subsublink in $subdir){
$finlinker = $biglink+$subsublink
$linker+=$finlinker
}
return $linker
}

$data = Invoke-WebRequest -Uri $MainSite
[array]$DocumentTypes = @("/")
[array]$Links = @()
[array]$link = @()
[array]$hreff = @()
$link+= $MainSite
$templink = $Mainsite
Write-Host "`nCaculating folder links available, It may take few minutes.." -ForegroundColor DarkYellow
while($templink)
{$hreff = @()
foreach($sublink in $templink){
$data = Invoke-WebRequest -Uri $sublink
$Links = ($data.Links).Href
$Filter = '(?i)(' + (($DocumentTypes | % { [regex]::escape($_) }) -join "|") + ')$'
$dir = $Links -match $Filter
$dir = $dir | Select-Object -Skip 1
if($dir){
	$hreff += Generate-Href -subdir $dir -biglink $sublink
	$link+=$hreff
	}	
}
$templink=$hreff
}
$link = $link | select -Unique
Write-Host "`nTotal folder links available" $link.Count -ForegroundColor DarkYellow
foreach($sublink in $link){
$localpath = $LocalOutputPath
Write-Host "`nReplicating from $sublink  to $localpath" -ForegroundColor DarkGreen
Get-Files -Site $sublink -OutputPath $localpath 
}
Write-Host "`nReplication Completed. Bye!!`n" -ForegroundColor DarkCyan