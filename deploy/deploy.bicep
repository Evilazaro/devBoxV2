targetScope = 'subscription'

@description('Solution Name')
param solutionName string

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
  ? loadJsonContent('../src/resources/resourceOrganization/settings/dev/resourceOrganizationSettings.json')
  : loadJsonContent('../src/resources/resourceOrganization/settings/prod/resourceOrganizationSettings.json')

@description('Connectivity Resource Group')
resource connectivityResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${solutionName}-${landingZone.connectivity.name}-${environment}'
  location: location
  tags: landingZone.connectivity.tags
}

@description('Deploy Connectivity Module')
module connectivity '../src/resources/connectivity/connectivityModule.bicep' = {
  scope: connectivityResourceGroup
  name: 'connectivity'
  params: {
    name: '${solutionName}-${uniqueString(solutionName,connectivityResourceGroup.id)}'
    environment: environment
  }
}

@description('Connectivity Resource Group')
resource workloadResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${solutionName}-${landingZone.workload.name}-${environment}'
  location: location
  tags: landingZone.workload.tags
}

@description('Deploy Workload Module')
module workload '../src/resources/workload/devCenter/devCenterModule.bicep' = {
  scope: workloadResourceGroup
  name: 'devCenter'
  params: {
    name: '${solutionName}-devCenter'
    networkConnections: connectivity.outputs.networkConnections
    environment: environment
  }
}
