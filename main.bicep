// Parameters
param location string = resourceGroup().location
param appName1 string = 'beesKnee1'
param appName2 string = 'beesKnee2'
param publicIPName string = 'public_ip'
param vNetName string = 'beesKneeVNet'
param appGatewayName string = 'beesKneeGateway'
param restartPolicy string = 'Always'


module httpdContainersModule './httpdcontainer.bicep' = {
  name: 'httpdContainersModule'
  params: {
    appName1: appName1
    appName2: appName2
    location: location
    restartPolicy: restartPolicy
    
  }
}

module appGatewayModule './appgateway.bicep' = {
  name: 'appGateway'
  params: {
    location: location
    publicIPName: publicIPName
    vNetName: vNetName
    appGatewayName: appGatewayName
    containerIPv4Address1: httpdContainersModule.outputs.containerIPv4Address1
    containerIPv4Address2: httpdContainersModule.outputs.containerIPv4Address2
  }
}

output containerIPv4Address1 string = httpdContainersModule.outputs.containerIPv4Address1
output containerIPv4Address2 string = httpdContainersModule.outputs.containerIPv4Address1
