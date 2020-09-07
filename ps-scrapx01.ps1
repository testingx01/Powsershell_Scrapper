# @Author Juned Ansari
# .\ps-wget0x1.ps1 -origin https://nginx.org -MainSite https://nginx.org/packages/rhel/7/ -LocalOutputPath C:\Users\Public -FileExtensions xml,rpm,tar.gz,exe,pdf,xml,mp4

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
$inputValue = 0
do {Write-Host 'Enter the number of files you want to download at a time: ' -NoNewline -ForegroundColor Yellow
    $inputValid = [int]::TryParse((Read-Host), [ref]$inputValue)
    if (-not $inputValid) {
        Write-Host "your input was not an integer..." -ForegroundColor Red
    }
} while (-not $inputValid)
if ($inputValue -eq 0){return}
$maincounter = $inputValue
$tempcounter = $maincounter
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
  if ($i -eq $maincounter)
        {   Write-Host "Total Files Downloaded: $i" -ForegroundColor Cyan
		    $remain = $iTotal-$i
		    Write-Host "`nRemaining Available Files to Download are: $remain `n" -ForegroundColor Cyan
			if ($remain -eq 0){return}
			Write-Host 'Press 1 to continue downloading' -NoNewline -ForegroundColor Green 
			Write-Host ' OR ' -NoNewline -ForegroundColor Yellow  
			Write-Host 'press 0 to abort' -NoNewline -ForegroundColor Green 
			Write-Host ' OR ' -NoNewline -ForegroundColor Yellow 
			Write-Host 'press 2 to change counter value: ' -NoNewline -ForegroundColor Green
			$flag = Read-Host 
			if ($flag -eq 0){
				break
				}
			elseif ($flag -eq 2){
				$inputValue = 0
				do {Write-Host 'Reset the counter value to: ' -NoNewline -ForegroundColor Cyan
					$inputValid = [int]::TryParse((Read-Host), [ref]$inputValue)
					if (-not $inputValid) {
						Write-Host "your input was not an integer..." -ForegroundColor Red
					}
				} while (-not $inputValid)
				$tempcounter = $inputValue
				$maincounter = $maincounter + $tempcounter
				
				$flag = 1
				}
			else {
			$maincounter = $maincounter + $tempcounter
			}
        }
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
$var=$sublink -split $origin
$stri = $var[1]
$localpath = $LocalOutputPath+$stri -replace "/","\"
Write-Host "`nReplicating from $sublink  to $localpath" -ForegroundColor DarkGreen
Get-Files -Site $sublink -OutputPath $localpath 
}
Write-Host "`nReplication Completed. Bye!!`n" -ForegroundColor DarkCyan