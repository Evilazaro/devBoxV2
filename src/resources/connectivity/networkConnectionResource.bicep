@description('Network Connection name')
param name string

@description('Virtual NetWork Name')
param subnetId string

@description('Network Connection Tags')
param tags object

@description('Network Connection Resource')
resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-10-01-preview'= {
  name: name
  location: resourceGroup().location
  tags: tags
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: subnetId
  }
}
