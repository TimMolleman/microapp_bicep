// Define parameters used in cosmos_db bicep file
param resource_location string = resourceGroup().location
param database_name string = 'app-db'
param container_raw_name string = 'raw-data'
param container_aggregated_name string = 'aggregated-data'

// Create the Cosmos DB account
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' = {
  name: 'cosmos-db-for-app'
  location: resource_location
  properties: {
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: resource_location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
  }
}

// Create a database
resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-10-15' = {
  name: database_name
  parent: cosmosDbAccount
  dependsOn: [
    cosmosDbAccount
  ]
  properties: {
    resource: {
      id: database_name
    }
  }
}

// Create container for the raw user input data
resource rawContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-04-15' = {
  name: container_raw_name
  parent: cosmosDb
  dependsOn: [
    cosmosDbAccount
    cosmosDb
  ]
  properties: {
    resource: {
      id: container_raw_name
      partitionKey: {
        paths: [
          '/name'
        ]
        kind: 'Hash'
      }
    }
    options: {
      throughput: 400
    }
  }
}

// Create container for the aggregated user input data
resource aggregatedContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-04-15' = {
  name: container_aggregated_name
  parent: cosmosDb
  dependsOn: [
    cosmosDbAccount
    cosmosDb
  ]
  properties: {
    resource: {
      id: container_aggregated_name
      partitionKey: {
        paths: [
          '/name'
        ]
        kind: 'Hash'
      }
      uniqueKeyPolicy: {
        uniqueKeys: [
          {
            paths: [
              '/name'
            ]
          }
        ]
      }
    }
    options: {
      throughput: 400
    }
  }
}
