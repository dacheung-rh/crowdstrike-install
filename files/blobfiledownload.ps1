$storageAccountName = $args[0] 
$storageAccountKey = $args[1] 
$containerName = $args[2] 
$blobName = $args[3] 
$destinationPath = $args[4]

$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
get-AzStorageBlobContent -Container $containerName -Blob $blobName -Destination $destinationPath -Context $context -Force
