param appName string
param location string

resource httpdContainer1 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: '${appName}-httpcontainer1'
  location: location
  properties: {
    containers: [
      {
        name: 'httpd-container-2'
        properties: {
          image: 
          resources: {
            requests: {
              cpu: 
              memoryInGB: 
            }
          }
        }
      }
    ]
    osType: 'Linux'
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
          image: 
          resources: {
            requests: {
              cpu: 
              memoryInGB: 
            }
          }
        }
      }
    ]
    osType: 'Linux'
  }
}


