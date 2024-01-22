# Request source folder path from the user
$SourcePath = Read-Host "Enter the source folder path"
# Request target folder path from the user
$ReplicaPath = Read-Host "Enter the replica folder path"
# Request log folder path from the user
$LogPath = Read-Host "Enter the Log file (.txt) path"
# Get all files from source and replica folder
$SourceFiles = Get-ChildItem -Path $SourcePath
$ReplicaFiles = Get-ChildItem -Path $ReplicaPath
# if statement to check whether both folders are empty, either is empty, or both full
# this is due to Compare-Object cmdlet(line:40), the command can't handle $null Object
if ( $SourceFiles -eq $null -and $ReplicaFiles -eq $null ){
	$TimeStamp = Get-Date
	$LogText = "TimeStamp: " + $TimeStamp + " - Source and Replica folders are identical (Both folders are empty)"
	$LogText>>$LogPath
	Write-Host $LogText
}
elseif ( $ReplicaFiles -eq $null ){
	$TempPath = Join-Path -Path $SourcePath -ChildPath "\*"
	Copy-Item -Path $TempPath -Destination $ReplicaPath -Recurse
	$TimeStamp = Get-Date
	$LogText = "TimeStamp: " + $TimeStamp + " - Replica folder is synced "
	$LogText>>$LogPath
	Write-Host $LogText
}
elseif ( $SourceFiles -eq $null ){
	$TempPath = Join-Path -Path $ReplicaPath -ChildPath "\*"
	Remove-Item -Path $TempPath
	$TimeStamp = Get-Date
	$LogText = "TimeStamp: " + $TimeStamp + " - Replica folder is synced"
	$LogText>>$LogPath
	Write-Host $LogText
}
else {
# comparing the files in source and replica folder on base of the SideIndicator, hence
# knowing which files are to copy or remove from either source and remove from replica, respectively 
$FilesDiff = Compare-Object -ReferenceObject $SourceFiles -DifferenceObject $ReplicaFiles
# if statement to check whether source and replica folders are in sync or copy/remove files not in sync
# the sync is on way: source >> replica
if ( $FilesDiff -eq $null ){
	$TimeStamp = Get-Date
	$LogText = "TimeStamp: " + $TimeStamp + " - Source and Replica folders are in sync"
	$LogText>>$LogPath
	Write-Host $LogText
}
else {
	foreach ($File in $FilesDiff){
		if ( $File.SideIndicator -eq "<=" ){
			$TempPath = Join-Path -Path $SourcePath -ChildPath $File.InputObject
			Copy-Item -Path $TempPath -Destination $ReplicaPath -Recurse
			$TimeStamp = Get-Date
			$LogText = "TimeStamp: " + $TimeStamp + " - File copied to replica folder: " + $File.InputObject
			$LogText>>$LogPath
			Write-Host $LogText
		}
		elseif ( $File.SideIndicator -eq "=>" ){
			$TempPath = Join-Path -Path $ReplicaPath -ChildPath $File.InputObject
			Remove-Item -Path $TempPath
			$TimeStamp = Get-Date
			$LogText = "TimeStamp: " + $TimeStamp + " - File removed from replica folder: " + $File.InputObject
			$LogText>>$LogPath
			Write-Host $LogText
			}
		}  
	}
}
