param location string
param conRegName string
param sku string
param publicNetworkAccess string
param networkRuleBypassOptions string
param networkRuleSetDefaultAction string
param adminUserEnabled bool
param zoneRedundancy string
param acrPrivateEndpointName string
param pepSubnetId string

resource conReg 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: conRegName
  location: location
  sku: {
    name: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: publicNetworkAccess
    networkRuleBypassOptions: networkRuleBypassOptions
    networkRuleSet: {
      defaultAction: networkRuleSetDefaultAction
      ipRules: [
        {
          action: 'Allow'
          value: '51.175.214.38'
        }
        {
          action: 'Allow'
          value: '91.184.138.88'
        }
      ]
    }
    adminUserEnabled: adminUserEnabled
    zoneRedundancy: zoneRedundancy
  }
}

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'privatelink.azurecr.io'
  scope: resourceGroup()
}

resource conRegPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: '${acrPrivateEndpointName}-${conReg.name}'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'registry'
        properties: {
          privateLinkServiceId: conReg.id
          groupIds: ['registry']
        }
      }
    ]
    subnet: {
      id: pepSubnetId
    }
  }

  resource privateEndpointDns 'privateDnsZoneGroups' = {
    name: 'registry-privateDnsZoneGroup'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink${environment().suffixes.acrLoginServer}'
          properties: {
            privateDnsZoneId: privateDNSZone.id
          }
        }
      ]
    }
  }
}

resource agentAppMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  location: location
  name: 'mi-docker-agent-app-job'
}

resource acrPullRoleDefinition 'Microsoft.Authorization/roleAssignments@2022-04-01' existing = {
  scope: subscription()
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, 'acrPullRoleAssignment')
  scope: conReg
  properties: {
    principalId: agentAppMi.properties.principalId
    roleDefinitionId: acrPullRoleDefinition.id
    principalType: 'ServicePrincipal'  
  }
}

output containerRegLoginServer string = conReg.properties.loginServer
output containerregIdentity string = conReg.identity.principalId
output containerRegistryName string = conReg.name
output containerAppMi string = agentAppMi.id
