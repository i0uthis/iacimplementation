param appName string = 'httpsite'
param location string = resourceGroup().location

@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'Always'

param acrName string
param acrUser string
param acrPass string

resource acrCreds 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: '${acrName}/${acrUser}'
  properties: {
    contentType: 'username'
    value: 'iacRegistry1'
  }
}

resource acrPassword 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: '${acrName}/${acrPass}'
  properties: {
    contentType: 'password'
    value: '+zPPeYvSljIsuuwdOErcXQlfCfXOw/VTYc6Rj6deGo+ACRBsFKoS'
  }
}

resource httpdContainer1 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: '${appName}-httpcontainer1'
  location: location
  properties: {
    containers: [
      {
        name: 'httpd-container-1'
        properties: {
          image: '${acrName}.azurecr.io/iacdocker:v1'
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
          image: '${acrName}.azurecr.io/iacdocker:v1'
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
