@description('Solution Name')
param workloadName string

module logAnalytics './logAnalytics.bicep' = {
  name: 'logAnalytics'
  scope: resourceGroup()
  params: {
    name: workloadName
  }
}

output logAnalyticsId string = logAnalytics.outputs.workspaceId
output logAnalyticsName string = logAnalytics.name
