// Global parameters
param resource_location string
param tenant_id string = subscription().tenantId

// Secure params
@secure()
param azure_client_id string

@secure()
param azure_client_secret string

@secure()
param azure_tenant_id string

// References to keyvault and the azure container registry name + storage name and function name
param acr_name string
param secret_ref_servicebus_endpoint string
param secret_ref_acr_key string
param secret_ref_cosmos_db_key string 
param secret_ref_cosmos_db_endpoint string
param storage_name string
param function_name string
param keyvault_name string

// Storage account for Azure Function App
@allowed([
  'Standard_LRS'
  'Standard_GRS'
])
param sku string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storage_name
  location: resource_location
  sku: {
    name: sku
  }
  kind: 'Storage'
}

// AppInsights for the function app
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appInsightsSpawner'
  location: resource_location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Serverfarm for the function app
resource plan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: 'FunctionPlan'
  location: resource_location
  kind: 'linux'
  sku: {
    name: 'Y1'
  }
  properties: {
    reserved: true
  }
}

// Functionapp configuration
resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: function_name
  location: resource_location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
      serverFarmId: plan.id
      siteConfig: {
        linuxFxVersion: 'python|3.8'
        appSettings: [
          {
            name: 'AzureWebJobsStorage'
            value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
          }
          {
            name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
            value: appInsights.properties.InstrumentationKey
          }
          {
            name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
            value: 'InstrumentationKey=${appInsights.properties.InstrumentationKey}'
          }
          {
            name: 'AZURE_LOCATION'
            value: 'northeurope'
          }
          {
            name: 'AZURE_RESOURCE_GROUP'
            value: 'micro-app'
          }
          {
            name: 'FUNCTIONS_WORKER_RUNTIME'
            value: 'python' 
          }
          {
            name: 'FUNCTIONS_EXTENSION_VERSION'
            value: '~4' 
          }
          {
            name: 'IMAGE_NAME'
            value: '${acr_name}.azurecr.io/worker:latest'
          }
          {
            name: 'BASE_NAME_CONTAINER'
            value: 'worker'
          }
          {
            name: 'COSMOS_APP_DB'
            value: 'app-db'
          }
          {
            name: 'COSMOS_DB_ENDPOINT'
            value: secret_ref_cosmos_db_endpoint
          }
          {
            name: 'COSMOS_DB_KEY'
            value: secret_ref_cosmos_db_key
          }
          {
            name: 'servicebusforapp_SERVICEBUS'
            value: secret_ref_servicebus_endpoint
          }
          {
            name: 'AZURE_SUBSCRIPTION_ID'
            value: subscription().id
          }
          {
            name: 'AZURE_CLIENT_ID'
            value: azure_client_id
          }
          {
            name: 'AZURE_CLIENT_SECRET'
            value: azure_client_secret
          }
          {
            name: 'AZURE_TENANT_ID'
            value: azure_tenant_id
          }
          {
            name: 'ACR_USERNAME'
            value: acr_name
          }
          {
            name: 'ACR_PASSWORD'
            value: secret_ref_acr_key
          }
          {
            name: 'ACR_SERVER'
            value: '${acr_name}.azurecr.io'
          }
        ]
      }
      httpsOnly: true
  }
}

// Add the managed identity ID to the keyvault
resource accessPolicyFunctionAppMI 'Microsoft.KeyVault/vaults/accessPolicies@2021-11-01-preview' = {
  name: '${keyvault_name}/add'
  properties: {
    accessPolicies: [
      {
        objectId: functionApp.identity.principalId
        tenantId: tenant_id
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}
