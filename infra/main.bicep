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

@description('Connectivity Resource Group Id')
output connectivityResourceGroupId string = resourceGroups.outputs.connectivityResourceGroupId
@description('Connectivity Resource Group Name')
output connectivityResourceGroupName string = resourceGroups.outputs.connectivityResourceGroupName
@description('Management Resource Group Id')
output managementResourceGroupId string = resourceGroups.outputs.managementResourceGroupId
@description('Management Resource Group Name')
output managementResourceGroupName string = resourceGroups.outputs.managementResourceGroupName
@description('Workload Resource Group Id')
output workloadResourceGroupId string = resourceGroups.outputs.workloadResourceGroupId
@description('Workload Resource Group Name')
output workloadResourceGroupName string = resourceGroups.outputs.workloadResourceGroupName


@description('Monitoring Resources')
module monitoring '../src/management/monitoringModule.bicep'= {
  scope: resourceGroup('${workloadName}-${landingZone.management.name}-${environment}')
  name: 'monitoring'
  params: {
    workloadName: workloadName	
  }
  dependsOn: [
    resourceGroups
  ]
}

@description('Monitoring Log Analytics Id')
output monitoringLogAnalyticsId string = monitoring.outputs.logAnalyticsId
@description('Monitoring Log Analytics Name')
output monitoringLogAnalyticsName string = monitoring.outputs.logAnalyticsName

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

