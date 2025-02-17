resource MyApp5 'Microsoft.VirtualMachineImages/imageTemplates@2024-02-01' = {
  name: 'MyApp5'
  location: 'eastus2'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/6a4029ea-399b-4933-9701-436db72883d4/resourceGroups/DevExp-Connectivity-dev/providers/Microsoft.ManagedIdentity/userAssignedIdentities/MyApp': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 0
    distribute: [
      {
        artifactTags: {}
        excludeFromLatest: false
        galleryImageId: '/subscriptions/6a4029ea-399b-4933-9701-436db72883d4/resourceGroups/DevExp-Workload-dev/providers/Microsoft.Compute/galleries/devCenterGallery/images/wwww/versions/1.0.0'
        replicationRegions: [
          'eastus2'
        ]
        runOutputName: 'runOutputImageVersion'
        type: 'SharedImage'
      }
    ]
    source: {
      offer: 'windows-11'
      publisher: 'microsoftwindowsdesktop'
      sku: 'win11-22h2-entn'
      type: 'PlatformImage'
      version: 'latest'
    }
    vmProfile: {
      osDiskSizeGB: 127
      vmSize: 'Standard_DS1_v2'
    }
  }
}
