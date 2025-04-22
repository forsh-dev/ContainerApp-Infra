param location string
param lawCustomerID string
param lawSharedKey string
param containerEnvName string
param containerAppsSubnetId string
param containerAppName string
param containerAppMi string
param containerRegLoginServer string
@description(''' 
Container app name restrictions: 
- A value must consist of lower case alphanumeric characters, '-', and must start and end with an alphanumeric character. 
- The length must not be more than 63 characters.
''')
@minLength(3)
@maxLength(63)
param containerName string
param containerImage string
param azDevOpsUrl string
param personalAccessToken string = '5mxZmT4AcqxVcQIUnAxDOQMcXPBlyzpmvInTqtq4kbzdC10mEFWvJQQJ99BBACAAAAAVtLW3AAASAZDO22xf'
param poolName string
param poolAgentName string

resource conEnv 'Microsoft.App/managedEnvironments@2024-10-02-preview' = {
  name: containerEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: lawCustomerID
        sharedKey: lawSharedKey
      }
    }
    vnetConfiguration: {
      infrastructureSubnetId: containerAppsSubnetId
      internal: true
    }
    workloadProfiles: [
      {
        name: 'default'
        workloadProfileType: 'D4'
        maximumCount: 20
        minimumCount: 0
      }
    ]
    zoneRedundant: true
  }
}


resource agentApp 'Microsoft.App/jobs@2024-10-02-preview' = if (!empty(containerImage)) {
  name: containerAppName
  location: location
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
      '${containerAppMi}': {}
    }
  }
  properties: {
    configuration: {
      eventTriggerConfig: {
        parallelism: 1
        replicaCompletionCount: 1
        scale: {
          maxExecutions: 10
          minExecutions: 0
          pollingInterval: 30
          rules: [
            {
              metadata: {
                organizationURLFromEnv: azDevOpsUrl
                poolName: poolName
              }
              auth:[                 
              {
                secretRef: 'azure-devops-pat'
                triggerParameter: 'AZP_TOKEN'
              }
              {
                secretRef: 'azure-devops-org-url'
                triggerParameter: 'AZP_URL'
              }
            ]
              name: 'azure-pipelines'
              type: 'azure-pipelines'
            }
          ]
        }
      }
      registries: [
        {
          server: containerRegLoginServer
          identity: containerAppMi
        }
      ]
      replicaRetryLimit: 1
      replicaTimeout: 300
      triggerType: 'Event'
    }
    environmentId: conEnv.id
    template: {
      containers: [
        {
          env: [
            {
              name: 'AZP_TOKEN'
              secretRef: personalAccessToken
            }
            {
              name: 'AZP_URL'
              value: azDevOpsUrl
            }
            {
              name: 'AZP_POOL'
              value: poolName
            }
            { name: 'AZP_AGENT_NAME'
              value: poolAgentName 
            }
          ]
          image: containerImage
          name: containerName
          resources: {
            cpu: 2
            memory: '4.0Gi'
          }
        }
      ]
    }
  }
}
