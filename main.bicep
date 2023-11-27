// Parameters
param appName string = 'beeskneesapp'
param location string = 'canadacentral'

// Include Application Gateway Template
module appGatewayModule 'appgateway.bicep' = {
  name: 'appGatewayModule'
  params: {
    appName: appName
    location: location
    // Add any other parameters required by the appGateway.bicep file
  }
}

// Include HTTPD Containers Template
module httpdContainersModule 'httpdcontainer.bicep' = {
  name: 'httpdContainersModule'
  params: {
    appName: appName
    location: location
    // Add any other parameters required by the httpdContainers.bicep file
  }
}

// Output any necessary information
output appGatewayModuleOutput object = {
  // Add output from the appGatewayModule if needed
}

output httpdContainersModuleOutput object = {
  // Add output from the httpdContainersModule if needed
}

