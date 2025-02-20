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
module resourceGroups '../src/resourceOrganization/resourceGroups.bicep'= {
  name: 'resourceOrganization'
  scope: subscription()
  params: {
    location: location
    environment: environment
    landingZone: landingZone
    workloadName: workloadName
  }
}

@description('Monitoring Resources')
module monitoring '../src/management/monitoringModule.bicep'= {
  scope: resourceGroup('${workloadName}-${landingZone.management.name}-${environment}')
  name: 'monitoring'
  params: {
    workloadName: workloadName	
  }
}

@description('Deploy Connectivity Module')
module connectivity '../src/connectivity/connectivityModule.bicep' = {
  scope: resourceGroup('${workloadName}-${landingZone.connectivity.name}-${environment}')
  name: 'connectivity'
  params: {
    name: '${workloadName}-${uniqueString(workloadName,resourceGroups.outputs.connectivityResourceGroupId)}'
    environment: environment
    workspaceId: monitoring.outputs.logAnalyticsId
  }
}

@description('Connectivity vNet Id')
output connectivityVNetId string = connectivity.outputs.virtualNetworkId

@description('Connectivity vNet Subnets')
output connectivityVNetSubnets array = connectivity.outputs.virtualNetworkSubnets

@description('Connectivity vNet Name')
output connectivityVNetName string = connectivity.outputs.virtualNetworkName

@description('Deploy Workload Module')
module workload '../src/workload/devCenterModule.bicep' = {
  scope: resourceGroup('${workloadName}-${landingZone.workload.name}-${environment}')
  name: 'workload'
  params: {
    name: '${workloadName}-devCenter'
    networkConnections: connectivity.outputs.networkConnections
    environment: environment
    workspaceId: monitoring.outputs.logAnalyticsId
  }
}

@description('Workload Dev Center Id')
output workloadDevCenterId string = workload.outputs.devCenterId

@description('Workload Dev Center Name')
output workloadDevCenterName string = workload.outputs.devCenterName

