param resource_location string = resourceGroup().location

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
