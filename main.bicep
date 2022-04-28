targetScope = 'subscription'

// Parameters
param deploy_location string
param resource_group string
param keyvault_name string
param acr_name string
param cosmos_db_name string

// Secure parameters
@secure()
param azure_client_id string

@secure()
param azure_client_secret string

@secure()
param azure_tenant_id string

@secure()
param contributor_object_id string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resource_group
  location: deploy_location
}

module keyVaultDeploy 'modules/keyvault.bicep' = {
  name: 'keyVaultDeploy'
  scope: rg
  params: {
    keyvault_name: keyvault_name
    contributor_object_id: contributor_object_id
  }
}

module serviceBusDeploy 'modules/servicebusdeploy.bicep' = {
  name: 'serviceBusDeploy'
  scope: rg
  params: {
    keyvault_name: keyvault_name
  }
  dependsOn: [
    keyVaultDeploy
  ]
}

// module cosmosDbDeploy 'modules/cosmos_db.bicep' = {
//   name: 'cosmosDbDeploy'
//   scope: rg
//   params: {
//     keyvault_name: keyvault_name
//     cosmos_db_name: cosmos_db_name
//   }
//   dependsOn: [
//     keyVaultDeploy
//   ]
// }

module containerRegistryDeploy 'modules/container_registry.bicep' = {
  name: 'containerRegistryDeploy'
  scope: rg
  params: {
    acr_name: acr_name
    keyvault_name: keyvault_name
  }
  dependsOn: [
    keyVaultDeploy
  ]
}

module functionAppDeploy 'modules/function_app.bicep' = {
  name: 'functionAppDeploy'
  scope: rg
  params: {
    secret_ref_servicebus_endpoint: serviceBusDeploy.outputs.secret_ref_servicebus_endpoint
    secret_ref_acr_key: containerRegistryDeploy.outputs.secret_ref_acr_key
    secret_ref_cosmos_db_key: 'secret'
    secret_ref_cosmos_db_endpoint: 'secret'
    acr_name: acr_name
    azure_client_id: azure_client_id
    azure_client_secret: azure_client_secret
    azure_tenant_id: azure_tenant_id
  }
  dependsOn: [
    keyVaultDeploy
  ]
}
