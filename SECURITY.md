# Security Policy for Container Apps Infrastructure

## Overview

This document outlines the security policies, procedures, and best practices for the Azure Container Apps infrastructure deployment. Our infrastructure includes Azure Container Apps, Azure Container Registry, virtual networks, and Azure DevOps agents.

## Table of Contents

1. [Security Governance](#security-governance)
2. [Network Security](#network-security)
3. [Identity and Access Management](#identity-and-access-management)
4. [Container Security](#container-security)
5. [Monitoring and Logging](#monitoring-and-logging)
6. [Data Protection](#data-protection)
7. [Incident Response](#incident-response)
8. [Compliance and Auditing](#compliance-and-auditing)
9. [Vulnerability Management](#vulnerability-management)
10. [Security Configuration Guidelines](#security-configuration-guidelines)

## Security Governance

### Security Objectives
- **Confidentiality**: Protect sensitive data and configurations from unauthorized access
- **Integrity**: Ensure infrastructure and application code remain unmodified by unauthorized parties
- **Availability**: Maintain system availability and resilience against attacks
- **Compliance**: Adhere to industry standards and regulatory requirements

### Roles and Responsibilities

#### Security Team
- Define and maintain security policies
- Conduct security assessments and audits
- Respond to security incidents
- Monitor security compliance

#### Infrastructure Team
- Implement security controls in infrastructure code
- Maintain secure configuration baselines
- Deploy security monitoring tools
- Execute security remediation plans

#### Development Team
- Follow secure coding practices
- Implement application-level security controls
- Conduct security testing
- Maintain security documentation

## Network Security

### Virtual Network Security

#### Network Segmentation
- **Private Subnets**: Use dedicated subnets for different workloads
  - Container Apps subnet: `10.0.2.0/23`
  - Private Endpoints subnet: `10.0.1.0/25`
- **Network Security Groups**: Implement least-privilege access controls
- **Private Endpoints**: Use private connectivity for Azure services

#### Network Security Group (NSG) Rules

**Container Apps NSG Requirements:**
```
Priority 100: Allow HTTPS outbound (port 443) to Internet
Priority 150: Allow HTTP outbound (port 80) to Internet  
Priority 4096: Deny all other Internet outbound traffic
```

**Private Endpoints NSG Requirements:**
```
Priority 4096: Deny all Internet outbound traffic
```

#### DNS Security
- Use Azure Private DNS zones for service discovery
- Implement DNS filtering for malicious domains
- Regular DNS configuration audits

### Firewall and Access Controls
- Implement Azure Firewall for centralized network security
- Use Application Security Groups for micro-segmentation
- Regular review of network access rules

## Identity and Access Management

### Azure Active Directory Integration
- **Managed Identity**: Use system-assigned and user-assigned managed identities
- **Role-Based Access Control (RBAC)**: Implement least-privilege access
- **Conditional Access**: Enforce multi-factor authentication for administrative access

### Service Principal Security
- Rotate service principal credentials regularly (every 90 days)
- Use certificate-based authentication when possible
- Monitor service principal usage and access patterns

### Access Token Management
- **Azure DevOps Personal Access Tokens (PAT)**:
  - Rotate PATs every 30 days
  - Use minimum required scopes
  - Store tokens in Azure Key Vault
  - Monitor token usage and anomalous activity

### Required RBAC Roles
- **Container Registry**: AcrPull role for container apps
- **Networking**: Network Contributor for infrastructure deployment
- **Monitoring**: Log Analytics Contributor for logging configuration

## Container Security

### Container Registry Security

#### Azure Container Registry (ACR) Configuration
- **Network Access**: 
  - Enable private endpoints
  - Restrict public access to specific IP addresses
  - Use VNet integration for container pulls
- **Authentication**: 
  - Disable admin user when possible
  - Use managed identity for authentication
  - Implement content trust and image signing

#### Container Image Security
- **Base Images**: Use minimal, hardened base images
- **Vulnerability Scanning**: Enable Microsoft Defender for container registries
- **Image Policies**: Implement admission controllers for image validation
- **Secrets Management**: Never embed secrets in container images

### Container Apps Security

#### Runtime Security
- **Resource Limits**: Configure CPU and memory limits
- **Network Policies**: Implement container-level network restrictions
- **Secrets**: Use Container Apps secrets and Key Vault references
- **Environment Variables**: Avoid sensitive data in environment variables

#### Workload Profiles
- Use appropriate workload profiles (D4 for production workloads)
- Configure auto-scaling with security considerations
- Implement resource quotas and limits

## Monitoring and Logging

### Log Analytics Configuration
- **Data Retention**: Configure appropriate retention periods (minimum 90 days)
- **Access Control**: Restrict access to logs based on roles
- **Alert Rules**: Implement security-focused alerts

### Security Monitoring

#### Required Monitoring
- Failed authentication attempts
- Unusual network traffic patterns
- Container runtime security events
- Resource access anomalies
- Configuration changes

#### Log Sources
- Azure Activity Log
- Container Apps logs
- Network Security Group flow logs
- Azure Container Registry logs
- Azure DevOps audit logs

### Security Information and Event Management (SIEM)
- Integrate with Azure Sentinel for advanced threat detection
- Configure automated response playbooks
- Regular review of security alerts and incidents

## Data Protection

### Data Classification
- **Public**: No special handling required
- **Internal**: Accessible to authorized employees
- **Confidential**: Restricted access, encryption required
- **Restricted**: Highest level of protection

### Encryption

#### Data at Rest
- Enable encryption for all storage accounts
- Use Azure Key Vault for key management
- Implement customer-managed keys where required

#### Data in Transit
- Use TLS 1.2 or higher for all communications
- Implement certificate pinning where appropriate
- Regular certificate rotation and management

### Backup and Recovery
- Implement automated backup strategies
- Test backup restoration procedures quarterly
- Encrypt backup data
- Maintain off-site backup copies

## Incident Response

### Incident Classification

#### Severity Levels
- **Critical**: System compromise or data breach
- **High**: Service disruption or potential security impact
- **Medium**: Security policy violation or suspicious activity
- **Low**: Minor security issues or policy deviations

### Response Procedures

#### Immediate Response (0-1 hour)
1. Identify and contain the incident
2. Notify security team and management
3. Document initial findings
4. Preserve evidence

#### Investigation Phase (1-24 hours)
1. Detailed forensic analysis
2. Impact assessment
3. Root cause analysis
4. Communication to stakeholders

#### Recovery and Lessons Learned (24+ hours)
1. Implement remediation measures
2. Restore normal operations
3. Update security controls
4. Conduct post-incident review

### Communication Plan
- Internal notifications within 30 minutes
- Customer notifications within 4 hours (if applicable)
- Regulatory notifications within 72 hours (if required)

## Compliance and Auditing

### Compliance Frameworks
- Azure Security Benchmark
- NIST Cybersecurity Framework
- ISO 27001
- SOC 2 Type II

### Audit Requirements
- Monthly security configuration reviews
- Quarterly penetration testing
- Annual compliance assessments
- Continuous monitoring and reporting

### Documentation Requirements
- Maintain security architecture documentation
- Document all security controls and procedures
- Regular policy updates and reviews
- Training records and certifications

## Vulnerability Management

### Vulnerability Assessment
- **Infrastructure**: Monthly vulnerability scans
- **Container Images**: Continuous scanning with each build
- **Dependencies**: Automated dependency vulnerability checks
- **Configuration**: Weekly security configuration assessments

### Patch Management
- **Critical Vulnerabilities**: Patch within 7 days
- **High Vulnerabilities**: Patch within 30 days
- **Medium/Low Vulnerabilities**: Patch within 90 days
- **Emergency Patches**: Deploy within 24 hours

### Remediation Process
1. Vulnerability identification and classification
2. Risk assessment and prioritization
3. Remediation planning and testing
4. Deployment and verification
5. Documentation and reporting

## Security Configuration Guidelines

### Infrastructure as Code Security

#### Bicep/ARM Template Security
- Use parameter files for sensitive configurations
- Implement resource naming conventions
- Regular security reviews of template changes
- Version control for all infrastructure code

#### Deployment Security
- Use Azure DevOps service connections with managed identity
- Implement approval workflows for production deployments
- Automated security testing in CI/CD pipelines
- Rollback procedures for failed deployments

### Azure Container Apps Specific Guidelines

#### Environment Configuration
```bicep
// Recommended security configuration
properties: {
  vnetConfiguration: {
    infrastructureSubnetId: subnetId
    internal: true  // Disable public access
  }
  zoneRedundant: true  // Enable zone redundancy
  workloadProfiles: [
    {
      name: 'default'
      maximumCount: 20
      minimumCount: 0  // Allow scale to zero
    }
  ]
}
```

#### Container Configuration
```bicep
// Secure container configuration
template: {
  containers: [
    {
      resources: {
        cpu: 2.0        // Set appropriate limits
        memory: '4.0Gi' // Prevent resource exhaustion
      }
      env: [
        // Use secretRef for sensitive values
        {
          name: 'SENSITIVE_VALUE'
          secretRef: 'secret-name'
        }
      ]
    }
  ]
}
```

### Azure Container Registry Security

#### Network Configuration
```bicep
properties: {
  publicNetworkAccess: 'Enabled'  // Restrict to specific IPs
  networkRuleSet: {
    defaultAction: 'Allow'
    ipRules: [
      {
        action: 'Allow'
        value: '51.175.214.38'  // Allowed IP ranges only
      }
    ]
  }
  adminUserEnabled: true  // Disable in production if possible
}
```

## Security Best Practices

### Development Practices
- Implement security code reviews
- Use static application security testing (SAST)
- Implement dynamic application security testing (DAST)
- Regular dependency updates and security patches

### Operational Practices
- Implement least-privilege access principles
- Regular access reviews and recertification
- Automated security monitoring and alerting
- Incident response testing and tabletop exercises

### Container Best Practices
- Use non-root users in containers
- Implement read-only file systems where possible
- Regular container image updates
- Security scanning integration in CI/CD pipelines

## Contact Information

### Security Team
- **Email**: security@forsh-lab.com
- **Emergency**: +1-XXX-XXX-XXXX
- **Incident Portal**: [Security Incident Portal URL]

### Infrastructure Team
- **Email**: infrastructure@forsh-lab.com
- **On-call**: [On-call rotation contact]

## Review and Updates

This security policy is reviewed quarterly and updated as needed. The next scheduled review is [DATE].

**Document Version**: 1.0  
**Last Updated**: [DATE]  
**Next Review**: [DATE + 3 months]

---

*This document contains confidential and proprietary information. Distribution is restricted to authorized personnel only.*