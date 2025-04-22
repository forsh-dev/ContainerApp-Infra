param location string
param env string
param rgContainersName string
param logName string
param vnetName string
param nsgPepsName string
param nsgContainersName string
param containersSubnetName string
param privateEndpointSubnetName string
param acrPrivateEndpointName string
param agentTag string

targetScope = 'subscription'

resource rgContainers 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: rgContainersName
  location: location
}

module moduleLogs 'modules/logs.bicep' = {
  name: 'module-logs-${env}'
  scope: rgContainers
  params: {
    location: location
    logName: '${logName}-${env}'
  }
}

module moduleNetworks 'modules/network.bicep' = {
  name: 'module-network-${env}'
  scope: rgContainers
  params: {
    location: location
    env: env
    vnetName: vnetName
    nsgPepsName: nsgPepsName
    nsgContainerAppsName: nsgContainersName
    containerAppsSubnetName: containersSubnetName
    privateEndpointSubnetName: privateEndpointSubnetName
  }
}

module moduleRegistry 'modules/registry.bicep' = {
  name: 'module-acr-${env}'
  scope: rgContainers
  params: {
    conRegName: 'acragent${uniqueString(rgContainers.id)}${env}'
    location: location
    sku: 'Premium'
    adminUserEnabled: true
    networkRuleBypassOptions: 'AzureServices'
    networkRuleSetDefaultAction: 'Allow'
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: 'Enabled'
    acrPrivateEndpointName: acrPrivateEndpointName
    pepSubnetId: moduleNetworks.outputs.snetPepID
  }
}

module moduleContainers 'modules/agent.bicep' = {
  name: 'module-agentapp-${env}'
  scope: rgContainers
  params: {
    location: location
    lawCustomerID: moduleLogs.outputs.customerID
    lawSharedKey: moduleLogs.outputs.primarySharedKey
    containerEnvName: 'env-agent-${env}'
    containerAppsSubnetId: moduleNetworks.outputs.snetAgentId
    containerAppName: 'docker-agent-${env}'
    containerAppMi: moduleRegistry.outputs.containerAppMi
    containerRegLoginServer: moduleRegistry.outputs.containerRegLoginServer
    containerName: 'docker-agent-${env}'
    containerImage: '${moduleRegistry.outputs.containerRegLoginServer}/${agentTag}'
    azDevOpsUrl: 'https://dev.azure.com/crafor'
    poolName: 'Docker-agent-pool'
    poolAgentName: 'Agent0001'
  }
}
