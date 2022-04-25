param resource_location string = resourceGroup().location
param tenant_id string = subscription().tenantId
param keyvault_name string

@secure()
param contributor_object_id string

resource microappKeyvault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyvault_name
  location: resource_location
  properties: {
    accessPolicies: [
      {
        objectId: contributor_object_id
        tenantId: tenant_id
        permissions: {
          keys: []
          secrets: [
            'all'
          ]
        }
      }
    ]
    tenantId: tenant_id
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}
