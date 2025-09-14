# Security Validation Checklist

## Pre-Deployment Security Checklist

### 1. Infrastructure Code Review
- [ ] **Parameter Security**: Review `parameters.bicepparam` for hardcoded secrets
- [ ] **Network Configuration**: Validate NSG rules and subnet configurations
- [ ] **Access Controls**: Verify managed identity assignments and role permissions
- [ ] **Resource Naming**: Follow organizational naming conventions
- [ ] **Version Control**: Ensure all changes are committed and reviewed

### 2. Azure DevOps Configuration
- [ ] **PAT Security**: Azure DevOps Personal Access Token stored in Key Vault
- [ ] **Service Connections**: Use managed identity instead of service principals
- [ ] **Pipeline Security**: Security scanning integrated into CI/CD pipeline
- [ ] **Approval Gates**: Production deployment approvals configured
- [ ] **Branch Protection**: Main branch protected with required reviews

### 3. Container Registry Security
- [ ] **Admin User**: Container Registry admin user disabled (for production)
- [ ] **Network Access**: Public access restricted to specific IP addresses
- [ ] **Private Endpoints**: Private endpoint configuration validated
- [ ] **Image Scanning**: Vulnerability scanning enabled and configured
- [ ] **Content Trust**: Image signing and content trust enabled

### 4. Network Security Validation
- [ ] **NSG Rules**: Network Security Group rules follow least-privilege principle
- [ ] **Subnet Isolation**: Proper subnet segmentation implemented
- [ ] **Private DNS**: Private DNS zones configured for Azure services
- [ ] **Firewall Rules**: Azure Firewall configured (if applicable)
- [ ] **VNet Peering**: Cross-VNet access properly restricted

### 5. Monitoring and Logging Setup
- [ ] **Log Analytics**: Workspace configured with appropriate retention
- [ ] **Data Sources**: All required log sources configured
- [ ] **Alert Rules**: Security alerts configured and tested
- [ ] **Dashboard**: Security monitoring dashboard created
- [ ] **SIEM Integration**: Azure Sentinel or third-party SIEM configured

### 6. Compliance and Documentation
- [ ] **Security Policies**: SECURITY.md reviewed and approved
- [ ] **Change Documentation**: Deployment changes documented
- [ ] **Compliance Check**: Configuration meets compliance requirements
- [ ] **Risk Assessment**: Security risk assessment completed
- [ ] **Incident Response**: Response procedures updated for new infrastructure

## Deployment Security Steps

### 1. Infrastructure Deployment
```bash
# 1. Validate Bicep template
az bicep build --file bicep/main.bicep

# 2. Preview deployment changes
az deployment sub create --location swedencentral --template-file bicep/main.bicep --parameters bicep/parameters.bicepparam --what-if

# 3. Deploy with confirmation
az deployment sub create --location swedencentral --template-file bicep/main.bicep --parameters bicep/parameters.bicepparam --confirm-with-what-if
```

### 2. Security Validation During Deployment
- [ ] **Resource Creation**: Monitor Azure Activity Log for deployment progress
- [ ] **Role Assignments**: Verify managed identity role assignments are created
- [ ] **Network Configuration**: Confirm NSGs and private endpoints are properly configured
- [ ] **Error Handling**: Address any deployment errors immediately
- [ ] **Resource Tags**: Verify security and compliance tags are applied

### 3. Post-Deployment Immediate Checks
```bash
# Verify resource group and resources
az group show --name rg-containers-[env]
az resource list --resource-group rg-containers-[env] --output table

# Check network security groups
az network nsg list --resource-group rg-containers-[env] --output table
az network nsg rule list --resource-group rg-containers-[env] --nsg-name nsg-containerapps-[env]

# Verify container registry configuration
az acr show --name [registry-name] --query "{adminUserEnabled:adminUserEnabled,publicNetworkAccess:publicNetworkAccess}"

# Test private endpoint connectivity
nslookup [registry-name].azurecr.io
```

## Post-Deployment Security Validation

### 1. Network Security Testing
- [ ] **Private Endpoint Resolution**: Verify DNS resolution to private IP addresses
- [ ] **Network Isolation**: Test that container apps cannot access unauthorized resources
- [ ] **NSG Effectiveness**: Confirm denied traffic is properly blocked
- [ ] **Outbound Connectivity**: Verify only authorized outbound connections work
- [ ] **Cross-Subnet Communication**: Test subnet-to-subnet communication rules

### 2. Container Security Validation
- [ ] **Image Pull**: Test container image pulls through private registry
- [ ] **Registry Authentication**: Verify managed identity authentication works
- [ ] **Container Startup**: Confirm containers start successfully with security configurations
- [ ] **Resource Limits**: Test container resource limits and scaling
- [ ] **Secrets Access**: Verify secrets are properly injected (not hardcoded)

### 3. Access Control Verification
- [ ] **RBAC Testing**: Test role-based access controls for different users
- [ ] **Managed Identity**: Verify managed identity permissions work correctly
- [ ] **Service Principal**: Confirm no unnecessary service principals exist
- [ ] **Admin Access**: Test administrative access controls
- [ ] **Audit Logging**: Verify access attempts are logged

### 4. Monitoring and Alerting Validation
```bash
# Test Log Analytics connectivity
az monitor log-analytics workspace show --resource-group rg-containers-[env] --workspace-name [workspace-name]

# Verify data ingestion
az monitor log-analytics query --workspace [workspace-id] --analytics-query "Heartbeat | limit 10"

# Test security alerts
# Trigger a test security event and verify alert fires
```

- [ ] **Log Collection**: Verify logs are being collected from all sources
- [ ] **Alert Testing**: Test security alerts with simulated events
- [ ] **Dashboard Functionality**: Confirm security dashboard displays current data
- [ ] **Retention Policies**: Verify log retention settings are correct
- [ ] **Export Capabilities**: Test log export for compliance requirements

### 5. Business Continuity Testing
- [ ] **Backup Verification**: Test backup and restore procedures
- [ ] **Disaster Recovery**: Verify DR procedures work correctly
- [ ] **Scaling Testing**: Test auto-scaling under load
- [ ] **Failover Testing**: Test regional failover (if configured)
- [ ] **Data Recovery**: Verify data recovery procedures

### 6. Compliance Validation
- [ ] **Policy Compliance**: Run Azure Policy compliance scan
- [ ] **Security Center**: Review Azure Security Center recommendations
- [ ] **Regulatory Requirements**: Verify specific compliance requirements
- [ ] **Documentation**: Update compliance documentation
- [ ] **Audit Trail**: Ensure complete audit trail of deployment

## Security Testing Scripts

### Network Security Test Script
```bash
#!/bin/bash
# network-security-test.sh

RG_NAME="rg-containers-[env]"
VNET_NAME="vnet-network-[env]"

echo "Testing network security configuration..."

# Test NSG rules
echo "Checking NSG configurations..."
az network nsg list --resource-group $RG_NAME --query "[].{Name:name,Rules:length(securityRules)}" --output table

# Test private endpoint connectivity
echo "Testing private endpoint DNS resolution..."
# Add specific DNS resolution tests here

# Test container app connectivity
echo "Testing container app network isolation..."
# Add container connectivity tests here

echo "Network security test completed."
```

### Container Security Test Script
```bash
#!/bin/bash
# container-security-test.sh

REGISTRY_NAME="[your-registry-name]"
RG_NAME="rg-containers-[env]"

echo "Testing container security configuration..."

# Test registry access
echo "Testing container registry access..."
az acr login --name $REGISTRY_NAME

# Test managed identity
echo "Testing managed identity permissions..."
az containerapp show --resource-group $RG_NAME --name "docker-agent-[env]" --query "identity"

# Test image scanning
echo "Checking image vulnerability scanning..."
# Add vulnerability scanning tests here

echo "Container security test completed."
```

## Incident Response Testing

### 1. Security Incident Simulation
- [ ] **Unauthorized Access**: Simulate unauthorized access attempts
- [ ] **Network Intrusion**: Test network intrusion detection
- [ ] **Container Compromise**: Simulate container security breach
- [ ] **Data Exfiltration**: Test data loss prevention controls
- [ ] **Service Disruption**: Simulate DDoS or service disruption

### 2. Response Procedure Validation
- [ ] **Detection Time**: Measure time to detect security incidents
- [ ] **Alert Escalation**: Test alert escalation procedures
- [ ] **Team Response**: Verify incident response team procedures
- [ ] **Communication**: Test internal and external communication plans
- [ ] **Recovery Time**: Measure time to recover from incidents

### 3. Documentation Updates
- [ ] **Test Results**: Document all test results and findings
- [ ] **Procedure Updates**: Update procedures based on test outcomes
- [ ] **Training Needs**: Identify additional training requirements
- [ ] **Tool Improvements**: Recommend security tool enhancements
- [ ] **Policy Updates**: Update security policies based on lessons learned

## Sign-off Requirements

### Technical Sign-off
- [ ] **Infrastructure Team Lead**: Network and infrastructure security validated
- [ ] **Security Engineer**: Security controls tested and approved
- [ ] **DevOps Engineer**: CI/CD security and automation validated
- [ ] **Platform Architect**: Overall architecture security approved

### Business Sign-off
- [ ] **Security Manager**: Security policies and procedures approved
- [ ] **Compliance Officer**: Compliance requirements validated
- [ ] **Business Owner**: Business continuity and risk acceptance
- [ ] **Operations Manager**: Operational procedures and monitoring approved

---

**Checklist Version**: 1.0  
**Last Updated**: [Date]  
**Review Date**: [Date + 3 months]

**Note**: This checklist should be customized for your specific environment and compliance requirements. Regular updates are essential as the infrastructure evolves.