@description('The name of the Dev Center resource.')
param name string 

@description('Location for the Dev Center resource.')
param location string 

@description('Dev Center settings')
param devCenterSettings object = {}

@description('Dev Center Resource')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' = {
  name: name
  location: location
  tags: devCenterSettings.tags
  identity: {
    type: devCenterSettings.identity.type
    userAssignedIdentities: devCenterSettings.identity.type == 'UserAssigned' ? devCenterSettings.identity.userAssignedIdentities : null
  }
  properties: {
    projectCatalogSettings: {
      catalogItemSyncEnableStatus: devCenterSettings.catalogItemSyncEnableStatus
    }
    networkSettings: {
      microsoftHostedNetworkEnableStatus: devCenterSettings.microsoftHostedNetworkEnableStatus
    }
    devBoxProvisioningSettings:{
      installAzureMonitorAgentEnableStatus: devCenterSettings.installAzureMonitorAgentEnableStatus
    }
  }
}

@description('The principal ID of the identity to assign the roles to.')
output principalId string = devCenter.identity.principalId
