# Container Apps Infrastructure

Azure Container Apps infrastructure deployment using Bicep templates for hosting Azure DevOps agents.

## 🔒 Security

This repository includes comprehensive security policies and implementation guidelines:

- **[SECURITY.md](SECURITY.md)** - Complete security policy document covering governance, network security, identity management, and incident response
- **[Security Implementation Guide](docs/security-implementation.md)** - Detailed technical implementation guidance for security controls
- **[Security Checklist](docs/security-checklist.md)** - Pre and post-deployment security validation procedures
- **[Security Configuration Template](docs/security-parameters.bicepparam)** - Secure parameter configuration examples
- **[Security Monitoring Queries](docs/monitoring-queries.kql)** - KQL queries for security monitoring and alerting

## 🏗️ Infrastructure Components

- **Azure Container Apps** - Hosting Azure DevOps build agents
- **Azure Container Registry** - Private container image storage with private endpoints
- **Virtual Network** - Isolated network with dedicated subnets for containers and private endpoints
- **Network Security Groups** - Network-level security controls
- **Log Analytics** - Centralized logging and monitoring
- **Managed Identity** - Secure authentication without secrets

## 🚀 Quick Start

1. **Review Security Requirements**: Start with [SECURITY.md](SECURITY.md) to understand security policies
2. **Configure Parameters**: Copy and customize [security-parameters.bicepparam](docs/security-parameters.bicepparam)
3. **Deploy Infrastructure**: Use the provided Bicep templates
4. **Validate Security**: Follow the [security checklist](docs/security-checklist.md)
5. **Configure Monitoring**: Import [monitoring queries](docs/monitoring-queries.kql) into Log Analytics

## 📋 Pre-Deployment Requirements

- Azure subscription with appropriate permissions
- Azure DevOps organization and agent pool
- Review and approval of security policies
- Completion of security configuration checklist

## 🔧 Deployment

```bash
# Validate template
az bicep build --file bicep/main.bicep

# Preview changes
az deployment sub create \
  --location swedencentral \
  --template-file bicep/main.bicep \
  --parameters bicep/parameters.bicepparam \
  --what-if

# Deploy infrastructure
az deployment sub create \
  --location swedencentral \
  --template-file bicep/main.bicep \
  --parameters bicep/parameters.bicepparam
```

## 📊 Monitoring and Security

After deployment, configure security monitoring:

1. Import KQL queries into Log Analytics
2. Set up security alerts and dashboards
3. Configure automated backup procedures
4. Test incident response procedures

## 🛡️ Security Best Practices

- **Network Isolation**: All components deployed in private subnets
- **Private Endpoints**: Container registry accessible only through private endpoints
- **Managed Identity**: No stored credentials for service authentication
- **Least Privilege**: Minimal required permissions for all components
- **Monitoring**: Comprehensive logging and security alerting
- **Compliance**: Configuration follows Azure security benchmarks

## 📚 Documentation

- **Architecture**: [Infrastructure architecture and design decisions]
- **Security**: [Complete security documentation in /docs]
- **Operations**: [Operational procedures and runbooks]
- **Troubleshooting**: [Common issues and solutions]

## 🔄 Maintenance

- Monthly security configuration reviews
- Quarterly security assessments
- Regular vulnerability scanning and updates
- Incident response plan testing

## 📞 Support

For security-related questions or incidents:
- Security Team: [security@forsh-lab.com]
- Infrastructure Team: [infrastructure@forsh-lab.com]
- Emergency Escalation: [On-call procedures]

---

**Note**: This infrastructure follows security-first principles. All configurations should be reviewed and approved by the security team before deployment to production environments.