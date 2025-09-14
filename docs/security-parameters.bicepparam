using 'main.bicep'

// Environment Configuration
param env = 'prod'  // Use 'prod', 'dev', 'test' etc.
param location = 'swedencentral'

// Resource Naming (follow organizational naming conventions)
param rgContainersName = 'rg-containers-prod'
param logName = 'log-containerapp'
param vnetName = 'vnet-containerapp'
param nsgPepsName = 'nsg-private-endpoints'
param nsgContainersName = 'nsg-containerapps'
param privateEndpointSubnetName = 'snet-private-endpoints'
param containersSubnetName = 'snet-containerapps'
param acrPrivateEndpointName = 'pep-acr'

// Container Configuration
param agentTag = 'adoagent:v1.0.0'  // Use specific version tags, not 'latest'

// SECURITY NOTES:
// 1. Store Azure DevOps PAT in Azure Key Vault and reference it in the bicep template
// 2. Review IP allowlist in registry.bicep module regularly
// 3. Consider disabling Container Registry admin user for production
// 4. Ensure all resources use managed identities instead of service principals
// 5. Enable audit logging for all resources
// 6. Implement resource tagging for cost management and compliance