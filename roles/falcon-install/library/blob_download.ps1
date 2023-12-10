#!powershell

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -OSVersion 6.2
#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options = @{
        storageAccountName = @{ type = "str" }
        storageAccountKey = @{ type = "str" }
        containerName = @{ type = "str" }
        blobName = @{ type = "str" }
        destinationPath = @{ type = "str" }
    }
    # required_if = @(@("actiontype", "get", @("identity", "storageAccountName", "storageAccountKey", "containerName", "blobName", "destinationPath")))
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

try {
    $module.Result.context = New-AzStorageContext -StorageAccountName $module.Params.storageAccountName -StorageAccountKey $module.Params.storageAccountKey
    get-AzStorageBlobContent -Container $module.Params.containerName -Blob $module.Params.blobName -Destination $module.Params.destinationPath -Context $module.Result.context -Force
    $module.Result.changed=$true
}
catch {
    Fail-Json -obj @{} -message  "Failed download blob file: $($_.Exception.Message)"
}

# Return result
$module.ExitJson()