@description('Location for all resources.')
param location string = resourceGroup().location


param appName string = 'beesknee'

@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'Always'


var virtualNetworkName = 'myVNet'
var networkInterfaceName = 'net-int'
var ipconfigName = 'ipconfig'
var publicIPAddressName = 'public_ip'
var nsgName = 'vm-nsg'
var applicationGateWayName = 'myAppGateway'
var virtualNetworkPrefix = '10.0.0.0/16'
var subnetPrefix = '10.0.0.0/24'
var backendSubnetPrefix = '10.0.1.0/24'

resource httpdContainer1 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: '${appName}-httpcontainer1'
  location: location
  properties: {
    containers: [
      {
        name: 'httpd-container-1'
        properties: {
          image: 'iouthis/iacdockerhubrepo:latest'
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
          ports:[
            {
              port: 80
              protocol: 'TCP'
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: restartPolicy
    ipAddress:{
      type: 'Public'
      ip: '10.10.0.2'
      ports: [
        {
          port: 80
          protocol: 'TCP'
        }
      ]
    }
  }
}

resource httpdContainer2 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: '${appName}-httpcontainer2'
  location: location
  properties: {
    containers: [
      {
        name: 'httpd-container-2'
        properties: {
          image: 'iouthis/iacdockerhubrepo:latest'
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
          ports: [
            {
              port: 80
              protocol: 'TCP'
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: restartPolicy
    ipAddress:{
      type: 'Public'
      ip: '10.10.0.2'
      ports: [
        {
          port: 80
          protocol: 'TCP'
        }
      ]
    }
  }
}

output containerIPv4Address1 string = httpdContainer1.properties.ipAddress.ip
output containerIPv4Address2 string = httpdContainer2.properties.ipAddress.ip


resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-05-01'= {
  name: publicIPAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkPrefix
      ]
    }
    subnets: [
      {
        name: 'myAGSubnet'
        properties: {
          addressPrefix: subnetPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'myBackendSubnet'
        properties: {
          addressPrefix: backendSubnetPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource applicationGateWay 'Microsoft.Network/applicationGateways@2023-05-01' = {
  name: applicationGateWayName
  location: location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'myAGSubnet')
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', '${publicIPAddressName}0')
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'myBackendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: 'containerIPv4Address1'
            }
            {
              ipAddress: 'containerIPv4Address2'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'myHTTPSetting'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'myListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGateWayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGateWayName, 'port_80')
          }
          protocol: 'Http'
          requireServerNameIndication: false
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'myRoutingRule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGateWayName, 'myListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateWayName, 'myBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGateWayName, 'myHTTPSetting')
          }
          priority: 100
        }
      }
    ]
    enableHttp2: false
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 10
    }
  }
  dependsOn: [
    virtualNetwork
    publicIPAddress
  ]
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-05-01' = [for i in range(0, 2): {
  name: '${networkInterfaceName}${i + 1}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${ipconfigName}${i + 1}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', '${publicIPAddressName}${i + 1}')
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'myBackendSubnet')
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
          applicationGatewayBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateWayName, 'myBackendPool')
            }
          ]
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: resourceId('Microsoft.Network/networkSecurityGroups', '${nsgName}${i + 1}')
    }
  }
  dependsOn: [
    publicIPAddress
    applicationGateWay
  ]
}]



