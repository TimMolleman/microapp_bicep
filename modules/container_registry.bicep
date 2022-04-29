param resource_location string
param keyvault_name string

@secure()
param acr_name string

// Create container registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: acr_name
  location: resource_location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

// Create acr secret in azure keyvault
resource acrKeySecret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: '${keyvault_name}/acr-key-secret'
  properties: {
    attributes: {
      enabled: true
    }
    value: listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords[0].value
  }
}

// Output the keyvault reference to use in Azure Function app deployment
output secret_ref_acr_key string = '@Microsoft.KeyVault(SecretUri=${acrKeySecret.properties.secretUriWithVersion})'
