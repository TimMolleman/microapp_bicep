param resource_location string = resourceGroup().location

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: 'appregistrytim'
  location: resource_location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}
