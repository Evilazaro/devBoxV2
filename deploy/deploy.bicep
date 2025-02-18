targetScope = 'subscription'

@description('Solution Name')
param workloadName string

@description('Location for the deployment')
param location string

@description('Deployment Environment')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

@description('Landing Zone Information')
var landingZone = environment == 'dev'
  ? loadJsonContent('settings/resourceOrganization/settings-dev.json')
  : loadJsonContent('settings/resourceOrganization/settings-prod.json')

@description('Connectivity Resource Group')
resource connectivityResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${workloadName}-${landingZone.connectivity.name}-${environment}'
  location: location
  tags: landingZone.connectivity.tags
}

@description('Deploy Connectivity Module')
module connectivity '../src/connectivity/connectivityModule.bicep' = {
  scope: connectivityResourceGroup
  name: 'connectivity'
  params: {
    name: '${workloadName}-${uniqueString(workloadName,connectivityResourceGroup.id)}'
    environment: environment
  }
}

@description('Connectivity Resource Group')
resource workloadResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${workloadName}-${landingZone.workload.name}-${environment}'
  location: location
  tags: landingZone.workload.tags
}

@description('Deploy Workload Module')
module workload '../src/workload/devCenterModule.bicep' = {
  scope: workloadResourceGroup
  name: 'devCenter'
  params: {
    name: '${workloadName}-devCenter'
    networkConnections: connectivity.outputs.networkConnections
    environment: environment
  }
}
