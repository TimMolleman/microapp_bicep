targetScope = 'subscription'

// parameters
param deploy_location string = deployment().location
param cosmos_db_endpoint string
param servicebus_endpoint string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'micro-app'
  location: deploy_location
}

module serviceBusDeploy 'servicebusdeploy.bicep' = {
  name: 'serviceBusDeploy'
  scope: rg
}

module cosmosDbDeploy 'cosmos_db.bicep' = {
  name: 'cosmosDbDeploy'
  scope: rg
}

module containerRegistryDeploy 'container_registry.bicep' = {
  name: 'containerRegistryDeploy'
  scope: rg
}

module functionAppDeploy 'function_app.bicep' = {
  name: 'functionAppDeploy'
  scope: rg
  params: {
    cosmos_db_endpoint: cosmos_db_endpoint
    servicebus_endpoint: service_bus_endpoint
  }
}
