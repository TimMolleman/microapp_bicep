// Global parameters
param resource_location string = resourceGroup().location

// Secure params
@secure()
param cosmos_db_endpoint string

@secure()
param cosmos_db_key string

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

// Storage account for Azure Function App
@allowed([
  'Standard_LRS'
  'Standard_GRS'
])
param sku string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'spawnerstorage'
  location: resource_location
  sku: {
    name: sku
  }
  kind: 'Storage'
  properties: {
    accessTier: 'Cool'
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
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
  name: 'spawner'
  location: resource_location
  kind: 'functionapp,linux'
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
            name: 'FUNCTIONS_WORKER_RUNTIME'
            value: 'python' 
          }
          {
            name: 'FUNCTIONS_EXTENSION_WORKTIME'
            value: '~4' 
          }
          {
            name: 'IMAGE_NAME'
            value: 'appregistry.azurecr.io/worker:latest'
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
            value: cosmos_db_endpoint
          }
          {
            name: 'COSMOS_DB_KEY'
            value: cosmos_db_key
          }
          {
            name: 'servicebusforapp_SERVICEBUS'
            value: servicebus_endpoint
          }
          {
            name: 'AZURE_SUBSCRIPTION_ID'
            value: azure_subscription_id
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
            value: acr_username
          }
          {
            name: 'ACR_PASSWORD'
            value: acr_password
          }
          {
            name: 'ACR_SERVER'
            value: acr_server
          }

        ]
      }
      httpsOnly: true
  }
}
