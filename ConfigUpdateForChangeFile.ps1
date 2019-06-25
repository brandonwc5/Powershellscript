$configsPath = ".\RangerApp\config"
$changeFilePath = ".\RangerApp\config\ChangeFiles"

$configChangeFileGen = ".\RangerApp\Commands\ConfigChangeFileGen.ps1"

$allConfigFiles = gci $configsPath -Filter *.conf

$materialConfigFiles = gci $configsPath -Filter *.conf  | Where-Object {$_ -notmatch "Machine.conf"}

$inputRange = 2..200
$randomRange = $inputRange | Where-Object { $exclude -notcontains $_ }
$index = Get-Random -InputObject $RandomRange

function UndoConfigChanges{
	$warnUser = Write-Warning "Would you like to reset the config file updates in your working tree? Press H to keep your changes." -WarningAction Inquire
	git checkout RangerApp\config\*
}

function RemoveChangeFileDirectory{
    if(Test-Path $changeFilePath){
		Remove-Item -Path $changeFilePath -recurse
    } else{
        Write-Host "Change File directory does not exist, so is not being deleted"
    }
}

function RunConfigChangeFileGenTool{
	# *** Run the Config Change tool ***
	.\RangerApp\Commands\ConfigChangeFileGen.ps1
}
function UpdateValueForSameKey
{
	$lIndex = Get-Random -InputObject $inputRange
    ForEach($f in $allConfigFiles){    
        [string[]]$fileContent = Get-Content -Path $configsPath\$f -Encoding UTF8
        $keyBeingUpdated = ($fileContent[$lIndex] -split "=")[0]
        $fileContent[$lIndex] = "$keyBeingUpdated=$lIndex"
		Write-Host $fileContent[$lIndex]
        $fileContent | Set-Content $configsPath\$f
    }
}

function UpdateValueForSingleMaterialFile
{
	# Updates single value for some key in one of the material config files
	$allConfigFiles = Get-Random -Maximum 7
	
	$fileBeingUpdated = $materialConfigFiles[$allConfigFiles]
	Write-Host $fileBeingUpdated " file being updated"

	[string[]]$fileContent = Get-Content -Path $configsPath\$fileBeingUpdated -Encoding UTF8
	$keyBeingUpdated = ($fileContent[$index] -split "=")[0]
	$valueToUpdate = ($fileContent[$index] -split "=")[1]
	$fileContent[$index] = "$keyBeingUpdated=$index"
	$fileContent | Set-Content $configsPath\$fileBeingUpdated
}

function DeleteSameKeyValueAllFiles
{
	$lIndex = Get-Random -InputObject $inputRange

    ForEach($f in $allConfigFiles){    
        [string[]]$fileContent = Get-Content -Path $configsPath\$f -Encoding UTF8
        $randomKeyValue = $fileContent[$lIndex]

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

function AddNewKeyValueAllConifgFiles
{
	$lIndex = Get-Random -InputObject $inputRange

    ForEach($f in $allConfigFiles){    
        [System.Collections.ArrayList]$fileContentList = Get-Content -Path $configsPath\$f -Encoding UTF8
        $newKeyValue = "new.test.key$lIndex=value"
        $fileContentList.Insert($lIndex, $newKeyValue)
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
	$lIndex = Get-Random -InputObject $inputRange

    ForEach($f in $allConfigFiles){
        [string[]]$fileContent = Get-Content -Path $configsPath\$f -Encoding UTF8

        $randomKeyValue = $fileContent[$lIndex]
        $updatedKeyName = "renamed.key.name$lIndex=$lIndex"
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

    $fileContent | Where-Object {$_ -notmatch $randomKeyValue} | Set-Content $configsPath\$fileBeingUpdated
}

# Scenarios

function IncrementMajorVersionNumber{
	$warnUser
	UndoConfigChanges

    Write-Host -ForegroundColor Yellow "`nTest: Delete a single (same) key value in all files (Machine key/value will be uniqe)"
    
	DeleteSameKeyValueAllFiles

    Write-Host -ForegroundColor DarkGray "`nExpected Result:`n"
    Write-Host -ForegroundColor Green " No errors from the ConfigChangeFileGen tool"
    Write-Host -ForegroundColor Green " All conf files are listed in the output"
	Write-Host -ForegroundColor Green " Major Version number (first index) is incremented"
	Write-Host -ForegroundColor Green " Warning: Update the Machine Config version number to (majorversion, 0)"
	Write-Host -ForegroundColor Green " Warning: Update the Material Config version number to (majorversion, 0)"
    Write-Host -ForegroundColor Green " Warning: Please build the solution..."
    Write-Host -ForegroundColor Green " Total change files count: 8`n"
    Pause

	RemoveChangeFileDirectory
	RunConfigChangeFileGenTool
}

function IncrementMinorVersionNumber{
	$warnUser
	UndoConfigChanges

	# Add same Key/value pair to each config file to increment Minor number 
    Write-Host -ForegroundColor Yellow "`nTest: Add same key/value pair in all files (including Machine)`n"
    
	AddNewKeyValueAllConifgFiles
    
	Write-Host -ForegroundColor DarkGray "Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
	Write-Host -ForegroundColor Green "`n Change File Minor number (second index) is incremented by 1 in each file"
	Write-Host -ForegroundColor Green " Warning: Update the Machine Config version number to (1, MinorVersionNumber)"
	Write-Host -ForegroundColor Green " Warning: Update the Material Config version number to (1, MinorVersionNumber)"
    Write-Host -ForegroundColor Green " Warning: Build the solution..."
    Write-Host -ForegroundColor Green "`n Total change files count: 8`n"

	Pause

	RemoveChangeFileDirectory
	RunConfigChangeFileGenTool
}


function IncrementPatchNumber{
	$warnUser
	UndoConfigChanges

	# Update a single value for the same key/value pair in all config files
    Write-Host -ForegroundColor Yellow "`nTest: Update value for same key in all files (including Machine)`n"
   
    UpdateValueForSameKey
    
	Write-Host -ForegroundColor DarkGray "Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
    Write-Host -ForegroundColor Green "`n Each file gets a Warning for 'Default' actions. Request to review for 'Forced' actions"
	Write-Host -ForegroundColor Green "`n Change File Patch number (third index) is incremented by 1 in each file"
	Write-Host -ForegroundColor Green " Warning: Update the Machine Config version number to (MajorVersionNumber, 0)"
	Write-Host -ForegroundColor Green " Warning: Update the Material Config version number to (MajorVersionNumber, 0)"
    Write-Host -ForegroundColor Green " Warning: Build the solution..."
	Write-Host -ForegroundColor Green "`n Total change files count: 8`n"

	Pause

	RemoveChangeFileDirectory
	Pause
	RunConfigChangeFileGenTool
}

function DeleteKeyAllFilesChangeValueSingleFile{
	$warnUser
	UndoConfigChanges

	# Previously this erroneously warned user to add same key/values for all material config files
    Write-Host -ForegroundColor Yellow "`nTest: Update a value in a single material file and then Delete a single (same) key value in all files (including Machine)"
    
	UpdateValueForSingleMaterialFile
    DeleteSameKeyValueAllFiles

    Write-Host -ForegroundColor DarkGray "`nExpected Result:`n"
    Write-Host -ForegroundColor Green " No errors from the ConfigChangeFileGen tool"
    Write-Host -ForegroundColor Green " `nAll conf files are listed in the output"
    Write-Host -ForegroundColor Green " `nMajor Version number (first index) is incremented"
	Write-Host -ForegroundColor Green " `nWarning: Update the Machine Config version number to (MajorVersionNumber, 0)"
	Write-Host -ForegroundColor Green " Warning: Update the Material Config version number to (MajorVersionNumber, 0)"
    Write-Host -ForegroundColor Green " Warning: Build the solution..."
	Write-Host -ForegroundColor Green " Total change files count: 8`n"
    Pause

	RemoveChangeFileDirectory
	RunConfigChangeFileGenTool
}

function NewUniqueKeyEachFile{
	$warnUser
	UndoConfigChanges

    Write-Host -ForegroundColor Yellow "`nTest: Add new, unique key to each config file`n"

	AddDifferentKeyValueEachFile

    Write-Host -ForegroundColor Green "Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
	Write-Host -ForegroundColor Green "`n No Files are updated"
    Write-Host -ForegroundColor Green "`n We get WARNING for config files that do not have same 'New' and 'Deleted' actions. 
		Please make necessary updates and re-run tool."
	Write-Host -ForegroundColor Green "`n Total change files count: 0`n"

	Pause

	RemoveChangeFileDirectory
	RunConfigChangeFileGenTool
}

function DeleteUniqueKeyEachFile
{
	$warnUser
	UndoConfigChanges

    Write-Host -ForegroundColor Yellow "`nTest: Delete unique key from each config file`n"

	DeleteDifferentKeyValuesAllFiles

    Write-Host -ForegroundColor Green "Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
	Write-Host -ForegroundColor Green "`n No Files are updated"
    Write-Host -ForegroundColor Green "`n We get WARNING for config files that do not have same 'New' and 'Deleted' actions. 
		Please make necessary updates and re-run tool."
	Write-Host -ForegroundColor Green "`n Total change files count: 0`n"

	Pause

	RemoveChangeFileDirectory
	RunConfigChangeFileGenTool
}

function RenameKeyAllFiles
{
	$warnUser
	UndoConfigChanges

    Write-Host -ForegroundColor Yellow "`nTest: Rename same key from each config file`n"

	RenameSameKeyAllMaterialFiles

    Write-Host -ForegroundColor Green "Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
	Write-Host -ForegroundColor Green "`n Change File Major number (first index) is incremented by 1 in each file"
    Write-Host -ForegroundColor Green "`n We get WARNING for config files that do not have same 'New' and 'Deleted' actions. 
		Review to see if should be 'Renamed'"
	Write-Host -ForegroundColor Green " Warning: Update the Machine Config version number to (MajorVersionNumber, 0)"
	Write-Host -ForegroundColor Green " Warning: Update the Material Config version number to (MajorVersionNumber, 0)"
    Write-Host -ForegroundColor Green " Warning: Build the solution..."
	Write-Host -ForegroundColor Green "`n Total change files count: 8`n"

	Pause

	RemoveChangeFileDirectory
	RunConfigChangeFileGenTool
}

function AddKeySingleMaterialFile
{
	$warnUser
	UndoConfigChanges

    Write-Host -ForegroundColor Yellow "`nTest: Add a new key/value pair to a single material file`n"

	AddNewKeyValueSingleMaterialFile


    Write-Host -ForegroundColor Green "Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
    Write-Host -ForegroundColor Green "`n No files are updated"
    Write-Host -ForegroundColor Green "`n We get WARNING for config files that do not have same 'New' and 'Deleted' actions.
		Only 1 out of 7 material config files have the action defined. Make necessary changes and rerun this tool."
    Write-Host -ForegroundColor Green "`n Total change files count: 0`n"

	Pause

	RemoveChangeFileDirectory
	RunConfigChangeFileGenTool
}

function RunAllActions
{
	$warnUser
	UndoConfigChanges

    Write-Host -ForegroundColor Yellow "`nTest: Update a value, delete a key/value, Add new key to all files`n"

	AddNewKeyValueAllConifgFiles
	UpdateValueForSameKey
	DeleteSameKeyValueAllFiles

    Write-Host -ForegroundColor Green "Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
	Write-Host -ForegroundColor Green "`n Change File Major number (first index) is incremented by 1 in each file"
    Write-Host -ForegroundColor Green "`n We get WARNING for config files that do not have same 'New' and 'Deleted' actions. 
		Prompted to check if these should be 'Renamed'"
	Write-Host -ForegroundColor Green " Warning: Update the Machine Config version number to (MajorVersionNumber, 0)"
	Write-Host -ForegroundColor Green " Warning: Update the Material Config version number to (MajorVersionNumber, 0)"
    Write-Host -ForegroundColor Green " Warning: Build the solution..."
	Write-Host -ForegroundColor Green "`n Total change files count: 8`n"

	Pause

	RemoveChangeFileDirectory
	RunConfigChangeFileGenTool
}

function MultipleRunsWithoutCheckingInChanges
{
	UndoConfigChanges
	RemoveChangeFileDirectory

    Write-Host -ForegroundColor Yellow "`nTest: Run all actions mutltiple runs without checking in code`n"

	# Run 1
	UpdateValueForSameKey
	RenameSameKeyAllMaterialFiles
	DeleteSameKeyValueAllFiles
	AddNewKeyValueAllConifgFiles	

    Write-Host -ForegroundColor Green "FIRST RUN Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
	Write-Host -ForegroundColor Green "`n Change File Major number (first index) is incremented by 1 in each file"
    Write-Host -ForegroundColor Green "`n We get WARNING for config files that do not have same 'New' and 'Deleted' actions. 
		Prompted to check if these should be 'Renamed'"
	Write-Host -ForegroundColor Green " Warning: Update the Machine Config version number to (MajorVersionNumber, 0)"
	Write-Host -ForegroundColor Green " Warning: Update the Material Config version number to (MajorVersionNumber, 0)"
    Write-Host -ForegroundColor Green " Warning: Build the solution..."
	Write-Host -ForegroundColor Green "`n Total change files count: 8`n"
	RunConfigChangeFileGenTool

	Write-Host -ForegroundColor Green "SECOND RUN Expected Result:"
    Write-Host -ForegroundColor Green "`n No errors from the ConfigChangeFileGen tool"
    Write-Host -ForegroundColor Green "`n We get WARNING: Regenerating Change file for xxx.conf, this will overwrite any updates made to the existing version
		Machine_x.x.x.x-x.x.x.x.cnfchg ..."
	Write-Host -ForegroundColor Green "`n Change File Major number (first index) has not changed again."
    Write-Host -ForegroundColor Green "`n We get WARNING for config files that do not have same 'New' and 'Deleted' actions. 
		Prompted to check if these should be 'Renamed'"
	Write-Host -ForegroundColor Green " Warning: Update the Machine Config version number to (MajorVersionNumber, 0)"
	Write-Host -ForegroundColor Green " Warning: Update the Material Config version number to (MajorVersionNumber, 0)"
    Write-Host -ForegroundColor Green " Warning: Build the solution..."
	Write-Host -ForegroundColor Green "`n Total change files count: 8`n"

	# Run 2 without commiting previous changes
	UpdateValueForSameKey
	RenameSameKeyAllMaterialFiles
	DeleteSameKeyValueAllFiles
	AddNewKeyValueAllConifgFiles	
	
	RunConfigChangeFileGenTool

	UndoConfigChanges
}

# *** Function Calls. Uncomment to run ***
#IncrementMajorVersionNumber		# Delete a single (same) key value in all files (Machine key/value will be uniqe)
#IncrementMinorVersionNumber		# Add same Key/value pair to each config file to increment Minor number 
#IncrementPatchNumber				# Update the value for the same key in all material config files, one in the machine file
#UpdateValueForSingleMaterialFile
#DeleteKeyAllFilesChangeValueSingleFile
#NewUniqueKeyEachFile
#DeleteSameKeyValueAllFiles
#DeleteUniqueKeyEachFile
#RenameKeyAllFiles
#AddKeySingleMaterialFile
#RunAllActions
#MultipleRunsWithoutCheckingInChanges