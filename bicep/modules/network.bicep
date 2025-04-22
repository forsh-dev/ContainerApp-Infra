param location string
param nsgPepsName string
param nsgContainerAppsName string
param vnetName string
param privateEndpointSubnetName string
param containerAppsSubnetName string
param env string
param dnsZoneNames array = [
  'privatelink.blob.${environment().suffixes.storage}'
  'privatelink.dfs.${environment().suffixes.storage}'
  'privatelink.vaultcore.azure.net'
  'privatelink.datafactory.azure.net'
  'privatelink.adf.azure.net'
  'privatelink.azurewebsites.net'
  'privatelink.azurecr.io'
]

resource nsgPeps 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: '${nsgPepsName}-${env}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'DenyInternetOutBound'
        properties: {
          direction: 'Outbound'
          priority: 4096
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: 'Internet'
        }
      }
    ]
  }
}

resource nsgContainerApps 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: '${nsgContainerAppsName}-${env}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHTTPSOutBound'
        properties: {
          direction: 'Outbound'
          priority: 100
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'Internet'
        }
      }
      {
        name: 'AllowHTTPOutBound'
        properties: {
          direction: 'Outbound'
          priority: 150
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '80'
          destinationAddressPrefix: 'Internet'
        }
      }
      {
        name: 'DenyInternetOutBound'
        properties: {
          direction: 'Outbound'
          priority: 4096
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: 'Internet'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: '${vnetName}-${env}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: '${privateEndpointSubnetName}-${env}'
        properties: {
          addressPrefix: '10.0.1.0/25'
          networkSecurityGroup: {
            id: nsgPeps.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: '${containerAppsSubnetName}-${env}'
        properties: {
          addressPrefix: '10.0.2.0/23'
          networkSecurityGroup: {
            id: nsgContainerApps.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
          delegations: [
            {
              name: 'ContainerAppsDelegtion'
              properties: {
                serviceName: 'Microsoft.App/environments'
              }
            }
          ]
        }
      }
    ]
  }

  resource snetPep 'subnets' existing = {
    name: '${privateEndpointSubnetName}-${env}'
  }

  resource snetAgent 'subnets' existing = {
    name: '${containerAppsSubnetName}-${env}'
  }
}

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = [
  for zone in dnsZoneNames: {
    name: zone
    location: 'global'
  }
]

resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [
  for (zone, i) in dnsZoneNames: {
    parent: dnsZone[i]
    name: '${zone}-link'
    location: 'global'
    properties: {
      virtualNetwork: {
        id: vnet.id
      }
      registrationEnabled: false
    }
  }
]

output snetAgentId string = vnet::snetAgent.id
output snetPepID string = vnet::snetPep.id
output dnsZoneBlob array = [
  for (name, i) in dnsZoneNames: {
    dnsZoneBlobName: dnsZone[i].name
    dnsZoneBlobId: dnsZone[i].id
  }
]
