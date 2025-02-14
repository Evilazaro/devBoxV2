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
