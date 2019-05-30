# 	Write-Host $contentPath\ "contentssssss"		#C:\Users\COWBRA\Desktop\EOS\rangerutility15\RangerApp\config\
# 	Write-Host $content[$i] + "contentttttt"	#HT23.conf
# 	Write-Host $contentPath\$content[$i] + "Now all together"	#C:\Users\COWBRA\Desktop\EOS\rangerutility15\RangerApp\config\FR106.conf HT23.conf Machine.conf none.conf PA2200.conf PA6.conf TPE.conf TPE300.conf[1] + Now all together




cd ".\EOS\rangerutility15\\"

$configsPath = ".\RangerApp\config"

$content = gci $configsPath -Filter *.conf 		#FR106.conf HT23.conf Machine.conf none.conf PA2200.conf PA6.conf TPE.conf TPE300.conf 

$contentPath = Resolve-Path -Path $configsPath

function GetBuildTemp
{
    param (
        [string[]] $fileContent
    )

	[string[]]$fileContent = Get-Content -Path $contentPath\$f -Encoding UTF8
    $BuildTemp = [string]($fileContent -match 'build.default.build.temp')
    $indexOfBuildTemp = [array]::IndexOf($fileContent, $BuildTemp)
    $BuildValue = ($fileContent[$indexOfBuildTemp] -split "=")[1]
    return $BuildValue
}

function UpdateBuildTempValue
{
    param (
        [string] $f
    )

    Write-Host "Updating build.default.build.temp to 100 in all config files"
	[string[]]$fileContent = Get-Content -Path $contentPath\$f -Encoding UTF8
	$BuildTheTemp = GetBuildTemp $fileContent
	$BuildTemp = [string]($fileContent -match 'build.default.build.temp')
	# Return -1 if does not exist in this file
    $indexOfBuildTemp = [array]::IndexOf($fileContent, $BuildTemp)
    $BuildKey = ($fileContent[$indexOfBuildTemp] -split "=")[0]
    $BuildValue = ($fileContent[$indexOfBuildTemp] -split "=")[1]
    # Arbitrary updated value
    $UpdatedBuildTemp = 100

    # Build temp key does not exist in material file
    if($indexOfBuildTemp -gt 0)
	{
	    $fileContent | ForEach {$_ -replace $BuildValue, $UpdatedBuildTemp} | Set-Content $contentPath\$f
	    Get-Content $contentPath\$f
	}
}

function DeleteRollerSpeedLeft
{
    param (
        [string] $f
        [string] $FileName
    )
    Write-Host "Deleting build.roller.speed.left from all config files"
	[string[]]$fileContent = Get-Content -Path $contentPath\$f -Encoding UTF8

    [string[]]$NewConfigFile = @()
    $RollerSpeed = [string]($fileContent -match 'build.roller.speed.left')

    ForEach($f in $fileContent)
    {
		$NewConfigFile += $f | where {$_ -ne $RollerSpeed}
    	#$f | where {$_ -ne $RollerSpeed} | out-file -FilePath RangerApp/config/$PA22000.txt
    }
    $NewConfigFile | out-file .\\RangerApp\\config\\$FileName
}

function AddNewKeyValue
{
    param (
        [string] $f
        [string] $FileName
    )
	[string[]]$fileContent = Get-Content -Path $contentPath\$f -Encoding UTF8
	$NewKeyValue = "new.test.key=value"

	$fileContent += $NewKeyValue
	#Get-Content $contentPath\$f
	Write-Host $fileContent
	Pause
}

ForEach ($f in $content){
	$FileName = [System.IO.Path]::GetFileName($f)
	#Write-Host $fileContent + "All contents of this config file"

	# $UpdateTheBuildTempValue = UpdateBuildTempValue $f
	# $DeleteTheRollerSpeed = DeleteRollerSpeedLeft $f $FileName
	$AddNewKeyValue = AddNewKeyValue $f $FileName
}

cd ../..

Pause