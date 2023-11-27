param appName string
param location string

resource appGateway 'Microsoft.Network/applicationGateways@2023-05-01' = {
  name: '${appName}-appgateway'
  location: location
  properties: {
    
  }
}

