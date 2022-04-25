param resource_location string = resourceGroup().location
param keyvault_name string

resource serviceBusApp 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: 'servicebus-for-app'
  location: resource_location
  sku: {
    name: 'Basic'
  }
}

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2017-04-01' = {
  name: 'app-queue'
  parent: serviceBusApp
}

// Endpoint for servicebusapp is different than regular
var listKeysEndpoint = '${serviceBusApp.id}/AuthorizationRules/RootManageSharedAccessKey'

// Add servicebus endpoint secret to keyvault
resource servicebusEndpointString 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: '${keyvault_name}/servicebus-endpoint'
  properties: {
    attributes: {
      enabled: true
    }
    value: listKeys(listKeysEndpoint, serviceBusApp.apiVersion).primaryConnectionString
  }
}

// Output the keyvault reference to use in Azure Function app deployment
output secret_ref_servicebus_endpoint string = '@Microsoft.KeyVault(SecretUri=${servicebusEndpointString.properties.secretUriWithVersion})'
