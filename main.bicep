targetScope = 'subscription'

// parameters
param deploy_location string = deployment().location

// Secure params
@secure()
param cosmos_db_endpoint string

@secure()
param servicebus_endpoint string

@secure()
param azure_subscription_id string

@secure()
param azure_client_id string

@secure()
param azure_client_secret string

@secure()
param azure_tenant_id string

@secure()
param acr_username string

@secure()
param acr_password string

@secure()
param acr_server string

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
    servicebus_endpoint: servicebus_endpoint
    azure_subscription_id: azure_subscription_id
    azure_client_id: azure_client_id
    azure_client_secret: azure_client_secret
    azure_tenant_id: azure_tenant_id
    acr_username: acr_username
    acr_password: acr_password
    acr_server: acr_server
  }
}

