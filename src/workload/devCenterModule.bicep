@description('The name of the Dev Center resource.')
param name string

@description('Deployment Environment')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

@description('networkConnections')
param networkConnections array

@description('Dev Center settings')
var settings = environment == 'dev'
  ? loadJsonContent('../../deploy/settings/workload/workloadSettings-dev.json')
  : loadJsonContent('../../deploy/settings/workload/workloadSettings-prod.json')

// var devBoxDefinitionsSettings = environment == 'dev'
//   ? loadJsonContent('../../deploy/settings/workload/devBoxDefinitions-dev.json')
//   : loadJsonContent('../../deploy/settings/workload/devBoxDefinitions-prod.json')

var vmImageSettings = environment == 'dev'
  ? loadJsonContent('../../deploy/settings/workload/vmImageSettings-dev.json')
  : loadJsonContent('../../deploy/settings/workload/vmImageSettings-prod.json')

@description('Dev Center Resource')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' = {
  name: name
  location: resourceGroup().location
  tags: settings.tags
  identity: {
    type: settings.identity.type
    userAssignedIdentities: settings.identity.type == 'UserAssigned' ? settings.identity.userAssignedIdentities : null
  }
  properties: {
    projectCatalogSettings: {
      catalogItemSyncEnableStatus: settings.catalogItemSyncEnableStatus
    }
    networkSettings: {
      microsoftHostedNetworkEnableStatus: settings.microsoftHostedNetworkEnableStatus
    }
    devBoxProvisioningSettings: {
      installAzureMonitorAgentEnableStatus: settings.installAzureMonitorAgentEnableStatus
    }
  }
}

module roleAssignments '../identity/roleAssignmentsResource.bicep' = {
  name: 'roleAssignments'
  params: {
    scope: 'subscription'
    principalId: devCenter.identity.principalId
    roles: settings.identity.roles
  }
}

@description('Deploys Network Connections for the Dev Center')
resource vNetAttachment 'Microsoft.DevCenter/devcenters/attachednetworks@2024-10-01-preview' = [
  for connection in networkConnections: {
    name: connection.name
    parent: devCenter
    properties: {
      networkConnectionId: connection.id
    }
  }
]

@description('Compute Gallery')
resource computeGallery 'Microsoft.Compute/galleries@2024-03-03' = {
  name: 'devCenterGallery'
  location: resourceGroup().location
  tags: settings.tags
  properties: {
    description: 'Dev Center Compute Gallery'
  }
}

@description('Compute Gallery Image Definitions')
resource imageDefinitions 'Microsoft.Compute/galleries/images@2024-03-03' = [
  for vmImageSetting in vmImageSettings: {
    name: vmImageSetting.imageDefinition.name
    location: resourceGroup().location
    parent: computeGallery
    properties: {
      hyperVGeneration: 'V2'
      architecture: 'x64'
      features: [
        {
          name: 'SecurityType'
          value: 'TrustedLaunchSupported'
        }
      ]
      identifier: {
        publisher: vmImageSetting.imageDefinition.publisher
        offer: vmImageSetting.imageDefinition.offer
        sku: vmImageSetting.imageDefinition.sku
      }
      osState: 'Generalized'
      osType: 'Windows'
      recommended: {
        vCPUs: {
          min: 1
          max: 16
        }
        memory: {
          min: 1
          max: 32
        }
      }
    }
  }
]

resource vmImageTemplates 'Microsoft.VirtualMachineImages/imageTemplates@2024-02-01' = [
  for (vmImageSetting, i) in vmImageSettings: {
    name: '${vmImageSetting[i].imageDefinition.name}'
    location: resourceGroup().location
    identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
        '/subscriptions/6a4029ea-399b-4933-9701-436db72883d4/resourceGroups/DevExp-Connectivity-dev/providers/Microsoft.ManagedIdentity/userAssignedIdentities/MyApp': {}
      }
    }
    properties: {
      buildTimeoutInMinutes: 60
      distribute: [
        {
          artifactTags: {}
          excludeFromLatest: false
          galleryImageId: resourceId(
            'Microsoft.Compute/galleries/images/versions',
            computeGallery.name,
            imageDefinitions[i].name,
            '1.0.0'
          )
          replicationRegions: [
            'eastus2'
          ]
          runOutputName: 'runOutputImageVersion'
          type: 'SharedImage'
        }
      ]
      source: {
        offer: vmImageSetting[i].imageTemplate.source.offer
        publisher: vmImageSetting[i].imageTemplate.source.publisher
        sku: vmImageSetting[i].imageTemplate.source.sku
        type: 'PlatformImage'
        version: 'latest'
      }
      vmProfile: {
        osDiskSizeGB: 127
        vmSize: 'Standard_DS1_v2'
      }
    }
  }
]

// @description('DevCenter Compute Gallery')
// resource devCenterGallery 'Microsoft.DevCenter/devcenters/galleries@2024-10-01-preview' = {
//   name: computeGallery.name
//   parent: devCenter
//   properties: {
//     galleryResourceId: computeGallery.id
//   }
// }
