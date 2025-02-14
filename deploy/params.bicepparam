using 'deploy.bicep'

@description('Location to deploy')
param location = 'eastus2'

@description('Environment to deploy')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment = 'dev'
