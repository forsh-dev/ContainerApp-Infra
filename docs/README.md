# Security Configuration Template

This directory contains security configuration templates and examples for the Container Apps infrastructure.

## Files

- `security-parameters.bicepparam` - Secure parameter configuration template
- `security-checklist.md` - Pre and post-deployment security validation checklist
- `monitoring-queries.kql` - Security monitoring KQL queries for Log Analytics

## Usage

1. Copy the security parameter template and customize for your environment
2. Follow the security checklist for each deployment
3. Import monitoring queries into your Log Analytics workspace
4. Review and update configurations regularly

## Security Hardening Recommendations

### Immediate Actions (High Priority)
- [ ] Disable Container Registry admin user
- [ ] Implement private-only access for Container Registry
- [ ] Move Azure DevOps PAT to Key Vault
- [ ] Enable NSG Flow Logs

### Medium Priority
- [ ] Implement Azure Firewall for centralized network security
- [ ] Add container image vulnerability scanning
- [ ] Implement automated backup strategies
- [ ] Configure Azure Security Center policies

### Long-term Improvements
- [ ] Integrate with Azure Sentinel for advanced threat detection
- [ ] Implement automated incident response playbooks
- [ ] Add compliance monitoring and reporting
- [ ] Conduct regular penetration testing