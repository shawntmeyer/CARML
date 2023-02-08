@description('Optional. The location to deploy resources to.')
param location string = resourceGroup().location

@description('Optional. Name of the Deployment Script that creates the SSH Public Key.')
param generateSshPubKeyScriptName string

@description('Generated. Do not provide a value! This date value is used to generate a unique image template name.')
param baseTime string = utcNow('yyyy-MM-dd-HH-mm-ss')

resource generateSshPubKeyScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
    name: generateSshPubKeyScriptName
    location: location
    kind: 'AzurePowerShell'
    properties: {
        azPowerShellVersion: '8.0'
        retentionInterval: 'P1D'
        arguments: ''
        scriptContent: 'ssh-keygen.exe -m PEM -t rsa -q -b 2048 -C tempkey -f $env:Temp\\tempkey -N \'\';$publicKeyValue = (Get-Content -Path $env:Temp\\tempkey.pub).Replace("`r`n","");Write-Output $publicKeyValue;$DeploymentScriptOutputs = @{};$DeploymentScriptOutputs[\'publicKey\'] = $publicKeyValue'
        cleanupPreference: 'OnSuccess'
        forceUpdateTag: baseTime
    }
    dependsOn: [
    ]
}

@description('The public key to be added to the SSH Public Key resource.')
output publicKey string = generateSshPubKeyScript.properties.outputs.publicKey
