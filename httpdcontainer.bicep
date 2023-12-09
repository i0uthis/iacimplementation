param appName1 string 
param appName2 string 
param location string 

@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string 

resource httpdContainer1 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: '${appName1}-httpcontainer1'
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
      ip: '10.10.0.1'
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
  name: '${appName2}-httpcontainer2'
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
