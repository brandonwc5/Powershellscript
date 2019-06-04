$configsPath = ".\RangerApp\config"
$changeFilePath = ".\RangerApp\config\ChangeFiles"

$path = Split-Path $MyInvocation.MyCommand.Path
$configChangeFileGen = ".\RangerApp\Commands\ConfigChangeFileGen.ps1"

$allConfigFiles = gci $configsPath -Filter *.conf

$materialConfigFiles = gci $configsPath -Filter *.conf  | Where-Object {$_ -notmatch "Machine.conf"}

$inputRange = 2..150
$randomRange = $inputRange | Where-Object { $exclude -notcontains $_ }
$index = Get-Random -InputObject $RandomRange

$warnUser = Write-Warning "Would you like to reset the config file updates in your working tree? Press H to keep your changes" -WarningAction Inquire

# *** Start Fresh ***
git checkout RangerApp\config\*
Remove-Item -Path $changeFilePath -recurse
# ***

function UpdateValueForSameKey
{
    ForEach($f in $allConfigFiles){    
        [string[]]$fileContent = Get-Content -Path $configsPath\$f -Encoding UTF8
        $keyBeingUpdated = ($fileContent[$index] -split "=")[0]
        $fileContent[$index] = "$keyBeingUpdated=$index"
        $fileContent | Set-Content $configsPath\$f
    }
}

function UpdateValueForSingleMaterialFile
{
	$configIndex = Get-Random -Maximum 7
	$fileBeingUpdated = $materialConfigFiles[$configIndex]
	[string[]]$fileContent = Get-Content -Path $configsPath\$fileBeingUpdated -Encoding UTF8
	$keyBeingUpdated = ($fileContent[$index] -split "=")[0]
	$valueToUpdate = ($fileContent[$index] -split "=")[1]
	$fileContent[$index] = "$keyBeingUpdated=$index"
	$fileContent | Set-Content $configsPath\$fileBeingUpdated
}

function DeleteSameKeyValueAllFiles
{
    ForEach($f in $allConfigFiles){    
        [string[]]$fileContent = Get-Content -Path $configsPath\$f -Encoding UTF8
        $randomKeyValue = $fileContent[$index]

        $deletingKey = [string]($fileContent -match $randomKeyValue)

        $fileContent | Where-Object {$_ -notmatch $deletingKey} | Set-Content $configsPath\$f
    }
}

function DeleteDifferentKeyValuesAllFiles
{
    ForEach($f in $allConfigFiles){    
        [string[]]$fileContent = Get-Content -Path $configsPath\$f -Encoding UTF8
        $lIndex = Get-Random -Minimum 2 -Maximum 200
        $randomKeyValue = $fileContent[$lIndex]

        $deletingKey = [string]($fileContent -match $randomKeyValue)

        $fileContent | Where-Object {$_ -notmatch $deletingKey} | Set-Content $configsPath\$f
    }
}

function AddNewKeyValue
{
    ForEach($f in $allConfigFiles){    
        [System.Collections.ArrayList]$fileContentList = Get-Content -Path $configsPath\$f -Encoding UTF8
        $newKeyValue = "new.test.key$index=value"
        $fileContentList.Insert($index, $newKeyValue)
        $fileContentList | Set-Content $configsPath\$f
    }
}

function AddDifferentKeyValueEachFile
{
    ForEach($f in $allConfigFiles){    
        [System.Collections.ArrayList]$fileContentList = Get-Content -Path $configsPath\$f -Encoding UTF8
        $newKeyValue = "new.test.key$index=value"
        $fileContentList.Insert(++$index, $newKeyValue)
        $fileContentList | Set-Content $configsPath\$f
    }
}

function RenameSameKeyAllMaterialFiles
{
    ForEach($f in $allConfigFiles){
        [string[]]$fileContent = Get-Content -Path $configsPath\$f -Encoding UTF8

        $randomKeyValue = $fileContent[$index]
        $updatedKeyName = "build.roller.speed.up$index=$index"
        $keyBeingRenamed = [string]($fileContent -match $randomKeyValue)
        $fileContent | ForEach {$_ -replace $keyBeingRenamed, $updatedKeyName} | Set-Content $configsPath\$f
    }
}

function AddNewKeyValueSingleMaterialFile
{
    $fIndex = Get-Random -Maximum 7  # can get count of avialble material files
    $newKeyValue = "config.test.key=value"
    $fileBeingUpdated = $materialConfigFiles[$fIndex]
    [System.Collections.ArrayList]$fileContentList = Get-Content -Path $configsPath\$fileBeingUpdated -Encoding UTF8

    $fileContentList.Insert(++$index, $newKeyValue)
    $fileContentList | Set-Content $configsPath\$fileBeingUpdated
}

function DeleteKeyValueSingleMaterialFile
{
    $fileIndex = Get-Random -Maximum 7
    $keyIndex = Get-Random -Minimum 2 -Maximum 200

    $fileBeingUpdated = $materialConfigFiles[$fileIndex]
    [string[]]$fileContent = Get-Content -Path $configsPath\$fileBeingUpdated -Encoding UTF8
    $randomKeyValue = $fileContent[$keyIndex]

 #   $deletingKey = [string]($fileContent -match $randomKeyValue)

    $fileContent | Where-Object {$_ -notmatch $randomKeyValue} | Set-Content $configsPath\$fileBeingUpdated
}

# Scenarios

function IncrementMajorVersionNumber{
	$warnUser
	# Previously this erroneously warned user to add same key/values for all material config files
    Write-Host -ForegroundColor Yellow "`nTest: Update a value in a single material file and then Delete a single (same) key value in all files (including Machine)"
    
	DeleteSameKeyValueAllFiles

    Write-Host -ForegroundColor DarkGray "`nExpected Result:`n"
    Write-Host -ForegroundColor Green " No errors from the ConfigChangeFileGen tool"
    Write-Host -ForegroundColor Green " All conf files are listed in the output"
	Write-Host -ForegroundColor Green " Major Version number (first index) is incremented"
    Write-Host -ForegroundColor Green " Warning: Please build the solution..."
    Write-Host -ForegroundColor Green " Total change files count: 8`n"
    Pause
}

function IncrementMinorVersionNumber{
	$warnUser
	# Add same Key/value pair to each config file to increment Minor number 
    Write-Host -ForegroundColor Yellow "`nTest: Add same key/value pair in all files (including Machine)`n"
    
	AddNewKeyValue
    
	Write-Host -ForegroundColor DarkGray "Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
    Write-Host -ForegroundColor Green "`n The only warning should be to build the solution"
	Write-Host -ForegroundColor Green "`n Change File Minor number (second index) is incremented by 1 in each file"
    Write-Host -ForegroundColor Green "`n Total change files count: 8`n"

	Pause
}


function IncrementPatchNumber{
	$warnUser
	# Update a single value for the same key/value pair in all config files
    Write-Host -ForegroundColor Yellow "`nTest: Update value for same key in all files (including Machine)`n"
   
    UpdateValueForSameKey
    
	Write-Host -ForegroundColor DarkGray "Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
    Write-Host -ForegroundColor Green "`n Each file gets a Warning for 'Default' actions. Request to review for 'Forced' actions"
	Write-Host -ForegroundColor Green "`n Change File Patch number (third index) is incremented by 1 in each file"
	Write-Host -ForegroundColor Green "`n WARNING to build the solution at the end"
    Write-Host -ForegroundColor Green "`n Total change files count: 8`n"

	Pause
}

function DeleteKeyAllFilesChangeValueSingleFile{
	$warnUser

	# Previously this erroneously warned user to add same key/values for all material config files
    Write-Host -ForegroundColor Yellow "`nTest: Update a value in a single material file and then Delete a single (same) key value in all files (including Machine)"
    
	UpdateValueForSingleMaterialFile
    DeleteSameKeyValueAllFiles

    Write-Host -ForegroundColor DarkGray "`nExpected Result:`n"
    Write-Host -ForegroundColor Green " No errors from the ConfigChangeFileGen tool"
    Write-Host -ForegroundColor Green " All conf files are listed in the output"
    Write-Host -ForegroundColor Green " Major Version number (first index) is incremented"
    Write-Host -ForegroundColor Green " Warning: Please build the solution..."
    Write-Host -ForegroundColor Green " Total change files count: 8`n"
    Pause
}

function WarningNewUniqueKeyEachFile{
	$warnUser
    Write-Host -ForegroundColor Yellow "`nTest: Add new, unique key to each config file`n"

	AddDifferentKeyValueEachFile

    Write-Host -ForegroundColor Green "Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
	Write-Host -ForegroundColor Green "`n Change File Minor number (second index) is incremented by 1 in each file"
    Write-Host -ForegroundColor Green "`n We get WARNING for config files that do not have same 'New' and 'Deleted' actions"
    Write-Host -ForegroundColor Green "`n Total change files count: 8`n"

	Pause
}

function WarningDeleteUniqueKeyEachFile
{
	$warnUser
    Write-Host -ForegroundColor Yellow "`nTest: Delete unique key from each config file`n"

	DeleteDifferentKeyValuesAllFiles

    Write-Host -ForegroundColor Green "Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
	Write-Host -ForegroundColor Green "`n Change File Major number (first index) is incremented by 1 in each file"
    Write-Host -ForegroundColor Green "`n We get WARNING for config files that do not have same 'New' and 'Deleted' actions"
    Write-Host -ForegroundColor Green "`n Total change files count: 8`n"

	Pause
}

function RenameKeyAllFiles{

	$warnUser
    Write-Host -ForegroundColor Yellow "`nTest: Rename same key from each config file`n"

	RenameSameKeyAllMaterialFiles

    Write-Host -ForegroundColor Green "Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
	Write-Host -ForegroundColor Green "`n Change File Major number (first index) is incremented by 1 in each file"
    Write-Host -ForegroundColor Green "`n We get WARNING for config files that do not have same 'New' and 'Deleted' actions. 
		Review to see if should be 'Renamed'"
    Write-Host -ForegroundColor Green "`n Total change files count: 8`n"

	Pause
}

function AddKeySingleMaterialFile{

	$warnUser
    Write-Host -ForegroundColor Yellow "`nTest: Add a new key/value pair to a single material file`n"

	AddNewKeyValueSingleMaterialFile


    Write-Host -ForegroundColor Green "Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
	Write-Host -ForegroundColor Green "`n Change File Minor number (second index) is incremented by 1"
    Write-Host -ForegroundColor Green "`n We get WARNING for config files that do not have same 'New' and 'Deleted' actions. 
		Only 1 out of 7 material config files have the action defined"
    Write-Host -ForegroundColor Green "`n Total change files count: 1`n"

	Pause
}

function RunAllActions
{
	$warnUser
    Write-Host -ForegroundColor Yellow "`nTest: Update a value, delete a key/value, rename a key, Add new key to all files`n"

	UpdateValueForSameKey
	RenameSameKeyAllMaterialFiles
	DeleteSameKeyValueAllFiles
	AddNewKeyValue

    Write-Host -ForegroundColor Green "Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
	Write-Host -ForegroundColor Green "`n Change File Major number (first index) is incremented by 1 in each file"
    Write-Host -ForegroundColor Green "`n We get WARNING for config files that do not have same 'New' and 'Deleted' actions. 
		Prompted to check if these should be 'Renamed'"
	Write-Host -ForegroundColor Green "`n We get WARNING to build the solution." 
    Write-Host -ForegroundColor Green "`n Total change files count: 8`n"

	Pause
}

# *** Function Calls ***
IncrementMajorVersionNumber
IncrementMinorVersionNumber
IncrementPatchNumber
DeleteKeyAllFilesChangeValueSingleFile
WarningNewUniqueKeyEachFile
WarningDeleteUniqueKeyEachFile
RenameKeyAllFiles
AddKeySingleMaterialFile
RunAllActions

# *** Run the Config Change tool ***
.\RangerApp\Commands\ConfigChangeFileGen.ps1