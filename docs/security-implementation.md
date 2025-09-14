# Security Configuration Implementation Guide

## Overview

This guide provides specific implementation details for securing the Azure Container Apps infrastructure based on the security policies outlined in [SECURITY.md](../SECURITY.md).

## Quick Security Checklist

### Pre-Deployment Security Checklist
- [ ] Review and update parameters.bicepparam with secure values
- [ ] Ensure Azure DevOps PAT is stored in Key Vault
- [ ] Verify IP allowlist in Container Registry configuration
- [ ] Confirm managed identity assignments
- [ ] Review network security group rules
- [ ] Validate private DNS zone configurations

### Post-Deployment Security Checklist
- [ ] Verify private endpoints are functional
- [ ] Test container registry access through private endpoint
- [ ] Confirm Azure DevOps agent connectivity
- [ ] Validate logging and monitoring
- [ ] Run security assessment tools
- [ ] Document deployment-specific security configurations

## Infrastructure Security Configurations

### 1. Network Security Implementation

#### Current NSG Rules Analysis
The infrastructure implements the following security controls:

**Private Endpoints NSG (`nsg-private-endpoints`)**:
```bicep
// Denies all internet outbound traffic
{
  name: 'DenyInternetOutBound'
  priority: 4096
  access: 'Deny'
  protocol: '*'
  sourcePortRange: '*'
  sourceAddressPrefix: '*'
  destinationPortRange: '*'
  destinationAddressPrefix: 'Internet'
}
```

**Container Apps NSG (`nsg-containerapps`)**:
```bicep
// Allows necessary outbound traffic for container operations
{
  name: 'AllowHTTPSOutBound'    // Priority 100
  name: 'AllowHTTPOutBound'     // Priority 150  
  name: 'DenyInternetOutBound'  // Priority 4096
}
```

#### Security Recommendations
1. **Add Inbound Security Rules**: Consider adding explicit inbound deny rules
2. **Logging**: Enable NSG Flow Logs for security monitoring
3. **Service Tags**: Use Azure service tags instead of broad Internet access where possible

### 2. Azure Container Registry Security

#### Current Configuration Assessment
```bicep
// Security analysis of current ACR settings
properties: {
  publicNetworkAccess: 'Enabled'           // ⚠️ Security Risk
  networkRuleSetDefaultAction: 'Allow'     // ⚠️ Security Risk
  adminUserEnabled: true                   // ⚠️ Security Risk
  zoneRedundancy: 'Enabled'               // ✅ Good
}
```

#### Security Hardening Recommendations

**High Priority Changes**:
```bicep
properties: {
  publicNetworkAccess: 'Disabled'          // Recommended change
  networkRuleSetDefaultAction: 'Deny'      // Recommended change
  adminUserEnabled: false                  // Recommended change
  
  // Keep existing secure configurations
  networkRuleBypassOptions: 'AzureServices'
  zoneRedundancy: 'Enabled'
}
```

**IP Allowlist Review**:
```bicep
ipRules: [
  {
    action: 'Allow'
    value: '51.175.214.38'  // Document purpose and review regularly
  }
  {
    action: 'Allow' 
    value: '91.184.138.88'  // Document purpose and review regularly
  }
]
```

### 3. Container Apps Security Configuration

#### Current Security Analysis
```bicep
properties: {
  vnetConfiguration: {
    infrastructureSubnetId: containerAppsSubnetId
    internal: true                          // ✅ Good - No public access
  }
  zoneRedundant: true                      // ✅ Good - High availability
  workloadProfiles: [{
    maximumCount: 20                       // ✅ Reasonable scaling limit
    minimumCount: 0                        // ✅ Allows scale to zero
  }]
}
```

#### Security Hardening for Container Apps Jobs

**Environment Variables Security**:
```bicep
// Current configuration analysis
env: [
  {
    name: 'AZP_TOKEN'
    secretRef: personalAccessToken        // ⚠️ Hardcoded token in code
  }
  {
    name: 'AZP_URL'
    value: azDevOpsUrl                   // ✅ Non-sensitive value
  }
]
```

**Recommended Security Improvements**:
1. Move PAT to Azure Key Vault
2. Use managed identity for authentication where possible
3. Implement token rotation strategy

### 4. Managed Identity Configuration

#### Current Implementation Review
```bicep
// Good: User-assigned managed identity
resource agentAppMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  location: location
  name: 'mi-docker-agent-app-job'
}

// Good: Proper role assignment
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: conReg
  properties: {
    principalId: agentAppMi.properties.principalId
    roleDefinitionId: acrPullRoleDefinition.id  // AcrPull role
    principalType: 'ServicePrincipal'
  }
}
```

#### Security Best Practices Compliance
✅ **Implemented Correctly**:
- User-assigned managed identity
- Least-privilege role assignment (AcrPull only)
- Proper scope limitation

## Security Monitoring and Alerting

### Log Analytics Security Configuration

#### Required Log Sources
1. **Azure Activity Logs**: Track resource changes and access
2. **Container Apps Logs**: Monitor application behavior
3. **NSG Flow Logs**: Network traffic analysis
4. **Container Registry Logs**: Access and pull activity

#### Security Alert Recommendations

```kql
// Example: Failed container registry access
ContainerRegistryLoginEvents
| where Result == "Failed"
| summarize FailedAttempts = count() by Identity, bin(TimeGenerated, 5m)
| where FailedAttempts > 10

// Example: Unusual network traffic
AzureNetworkAnalytics_CL
| where FlowStatus_s == "D"  // Denied flows
| summarize Denied = count() by SrcIP_s, bin(TimeGenerated, 1h)
| where Denied > 100
```

## Deployment Security Procedures

### 1. Pre-Deployment Security Validation

#### Parameter Security Review
```bash
# Check for sensitive values in parameters
grep -r "password\|secret\|key\|token" bicep/parameters.bicepparam

# Validate IP allowlists are current
# Review and document each allowed IP address
```

#### Infrastructure Code Security Scan
```bash
# Example using checkov (if available)
checkov -f bicep/main.bicep --framework bicep
```

### 2. Deployment Security Steps

#### Step 1: Validate Network Configuration
```bash
# Test network isolation after deployment
az network nsg rule list --resource-group rg-containers --nsg-name nsg-containerapps-lab
```

#### Step 2: Verify Private Endpoint Connectivity
```bash
# Test private endpoint resolution
nslookup your-registry.azurecr.io
# Should resolve to private IP (10.0.1.x range)
```

#### Step 3: Container Security Validation
```bash
# Check container registry access
az acr login --name your-registry-name
az acr repository list --name your-registry-name
```

### 3. Post-Deployment Security Verification

#### Security Testing Checklist
- [ ] Verify no public endpoints are accessible
- [ ] Test container app scaling and resource limits
- [ ] Validate log collection and retention
- [ ] Confirm managed identity permissions
- [ ] Test backup and recovery procedures

## Incident Response Procedures

### 1. Security Incident Detection

#### Automated Alerting
- Failed authentication attempts
- Unusual network traffic patterns
- Container runtime anomalies
- Configuration changes

#### Manual Monitoring
- Daily security log reviews
- Weekly configuration audits
- Monthly access reviews

### 2. Incident Response Steps

#### Immediate Response (0-30 minutes)
1. **Assess Impact**: Determine scope and severity
2. **Contain Threat**: Isolate affected resources
3. **Preserve Evidence**: Capture logs and configurations
4. **Notify Team**: Alert security and management teams

#### Investigation Phase (30 minutes - 4 hours)
1. **Root Cause Analysis**: Identify attack vectors
2. **Impact Assessment**: Determine data or system compromise
3. **Evidence Collection**: Gather forensic data
4. **Communication**: Update stakeholders

#### Recovery Phase (4+ hours)
1. **Remediation**: Apply security fixes
2. **Verification**: Confirm threat elimination
3. **Monitoring**: Enhanced monitoring period
4. **Documentation**: Update incident records

## Compliance and Auditing

### Security Control Validation

#### Monthly Security Reviews
- Review access permissions and role assignments
- Validate network security group configurations
- Check container image vulnerability scans
- Audit log retention and monitoring

#### Quarterly Security Assessments
- Penetration testing of public endpoints
- Security configuration baseline review
- Incident response plan testing
- Security training compliance

### Documentation Requirements

#### Required Security Documentation
1. **Deployment Records**: All infrastructure changes
2. **Access Reviews**: User and service principal access
3. **Incident Reports**: Security events and responses
4. **Compliance Reports**: Audit results and remediation

## Security Tools and Integration

### Recommended Security Tools

#### Azure Native Security
- **Azure Security Center**: Security posture management
- **Azure Sentinel**: SIEM and threat detection
- **Azure Key Vault**: Secrets management
- **Azure Monitor**: Logging and alerting

#### Third-Party Integration
- **Container Scanning**: Twistlock, Aqua Security
- **SAST Tools**: SonarQube, Checkmarx
- **Vulnerability Management**: Qualys, Rapid7

### CI/CD Security Integration

#### Pipeline Security Gates
```yaml
# Example Azure DevOps pipeline security checks
- task: ContainerScanning@1
  inputs:
    scanType: 'vulnerability'
    failOnCritical: true
    
- task: AzureSecurityScan@1
  inputs:
    azureSubscription: 'production'
    resourceGroupName: 'rg-containers'
```

## Troubleshooting Security Issues

### Common Security Issues and Solutions

#### Issue: Container Registry Access Denied
**Symptoms**: Cannot pull images from ACR
**Diagnosis**: Check managed identity permissions and network connectivity
**Solution**: Verify role assignments and private endpoint configuration

#### Issue: Container Apps Not Starting
**Symptoms**: Container apps fail to start or scale
**Diagnosis**: Check resource quotas and network connectivity
**Solution**: Review container resource limits and subnet configuration

#### Issue: Monitoring Gaps
**Symptoms**: Missing security logs or alerts
**Diagnosis**: Check Log Analytics configuration and data retention
**Solution**: Verify data sources and alert rule configuration

## Contact Information

For security questions or incidents:

- **Security Team**: security@forsh-lab.com
- **Infrastructure Team**: infrastructure@forsh-lab.com
- **Emergency Escalation**: [On-call contact information]

---

**Document Version**: 1.0  
**Last Updated**: [Current Date]  
**Related Documents**: [SECURITY.md](../SECURITY.md)