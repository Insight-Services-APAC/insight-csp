# Setup Azure CSP Permissions

## Admin on Behalf of (AOBO)

Insight require Admin On Behalf Of (AOBO) authorisation at subscription level in order for Insight to be able to access your Azure subscriptions and provide support. When existing subscriptions are migrated to Insight Azure CSP, a PowerShell script is required to add the relevant Insight identities to these subscriptions as outlined in this link [Microsoft documentation on revoking and reinstating CSP access](https://docs.microsoft.com/en-us/partner-center/revoke-reinstate-csp)

There are a number of ways you can run the powershell script to grant these permissions.

- If you are _NOT_ a regular Powershell user, we recommend using the Azure Cloud Shell. You can read about the Azure Cloud Shell in the [Azure Cloud Shell overview documentation](https://docs.microsoft.com/en-us/azure/cloud-shell/overview)
- If you are a regular Powershell user you can run the script directly.

## PowerShell Script

The `set-insight-aobo.ps1` script is used to grant the necessary permissions and can be found in the [scripts](./scripts) folder.
