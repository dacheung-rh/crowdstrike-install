$storageAccountName = "afnseaprdsec01grs"
$storageAccountKey = "qRbw3+hrLvswziTKEHjVtpQ7JD25ZWbi1nR2hYK7V7DWJucEMJrZsOZqt2KLCJqwbvdxln1bLv1h+AStnRLIhg=="
$containerName = "agents"
$blobName = "WindowsSensor.exe"

$destinationPath = "c:\temp"

$blobServiceEndpoint = "https://afnseaprdsec01grs.privatelink.blob.core.windows.net"

$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

get-AzStorageBlobContent -Container $containerName -Blob $blobName -Destination $destinationPath -Context $context -Force


#!powershell

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -OSVersion 6.2
#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options = @{
        actiontype = @{ type = "str"; choices = "get", "set"; default = "get" }
        identity = @{ type = "str" }
        maxsize = @{ type = "str" }
        warningsize = @{ type = "str" }
    }
    required_if = @(@("actiontype", "get", @("identity")),
                    @("actiontype", "set", @("identity", "maxsize", "warningsize")))
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

# implementation
try {
    # Add-PSSnapin Microsoft.SharePoint.PowerShell
    Install-Module -Name Az.storage -Repository PSGallery -Force
}
catch {
    Fail-Json -obj @{} -message  "Failed to load Az Storage on the target: $($_.Exception.Message)"
}


switch ( $module.Params.actiontype) {
    "get" {
          $module.Result.collection = Get-SPSite -Identity $module.Params.identity | Select @{label="Warning Size (MB)";Expression={$_.quota.storagewarninglevel}},@{label="Quota Size (MB)";Expression={$_.quota.storagemaximumlevel}},@{label="Used Size (MB)";Expression={$_.usage.storage}}
    }
    "set" {
          try {
              Set-SPSite -Identity $module.Params.identity -Maxsize $module.Params.maxsize -WarningSize $module.Params.warningsize
              $module.Result.changed=$true
          }
          catch {
              Fail-Json -obj @{} -message  "Failed to Set-SPSite: $($_.Exception.Message)"
          }
    }
}

# Return result
$module.ExitJson()