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

@description('Resource Group Name')
output connectivityResourceGroupName string = connectivityResourceGroup.name

@description('Resource Group Id')
output connectivityResourceGroupId string = connectivityResourceGroup.id

@description('Deploy Connectivity Module')
module connectivity '../src/connectivity/connectivityModule.bicep' = {
  scope: connectivityResourceGroup
  name: 'connectivity'
  params: {
    name: '${workloadName}-${uniqueString(workloadName,connectivityResourceGroup.id)}'
    environment: environment
  }
}

@description('Connectivity Outputs')
output connectivity object = connectivity.outputs

@description('Connectivity Resource Group')
resource managementResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${workloadName}-${landingZone.management.name}-${environment}'
  location: location
  tags: landingZone.management.tags
}

@description('Resource Group ID')
output managementResourceGroupId string = managementResourceGroup.id

@description('Resource Group Name')
output managementResourceGroupName string = managementResourceGroup.name

@description('Connectivity Resource Group')
resource workloadResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${workloadName}-${landingZone.workload.name}-${environment}'
  location: location
  tags: landingZone.workload.tags
}

@description('Resource Group ID')
output workloadResourceGroupId string = workloadResourceGroup.id

@description('Resource Group Name')
output workloadResourceGroupName string = workloadResourceGroup.name

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
