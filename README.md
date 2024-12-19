# Workaround Server 2025 Domain Controller ‘Public’ Network

## Overview
Server 2025 Active Directory (AD) servers are prone to incorrectly setting the Windows Firewall to the domain profile. This script, designed to be copy-pasted into an elevated terminal window during the deployment of an AD server, creates a test-and-fix script and configures the machine's Task Scheduler to call this new script every minute, for five minutes. Its purpose is to restore the domain firewall profile by disabling and re-enabling the network interface card (NIC) if necessary.

This solution operates independently of Group Policy or similar configurations, providing a simple and effective mechanism to manage network adapters in scenarios where domain authentication is required.

## Problem Statement
Maintaining network connectivity and ensuring domain authentication on air-gapped systems can be a persistent challenge. This script automates the process of monitoring the network authentication status and restarts physical network adapters if they fail to authenticate with the domain.

## Key Features
- Writes a secondary PowerShell script to `C:\Windows`.
- Sets up a Task Scheduler task to execute the script:
  - Initial delay of 30 seconds at startup.
  - Repeats every minute for 5 minutes.
- Checks the network category for `DomainAuthenticated` status.
- Restarts network adapters if the required domain authentication is not detected.

## Usage
### Prerequisites
- The script is intended to run on Microsoft Active Directory servers.
- Administrator privileges are required.

### Steps to Implement
1. Clone this repository or download the script file.
2. Execute the provisioning script using an elevated PowerShell session.

   ```powershell
   .\ProvisionNetworkTask.ps1
   ```

3. The script will:
   - Create a secondary script at `C:\Windows\0-RestartPhysicalNetworkAdapters.ps1`.
   - Register a Task Scheduler instance to execute this script periodically.
4. Verify that the Task Scheduler task is created and running as expected.

## How It Works
- **Script Deployment**: The provisioning script creates a secondary script that monitors network authentication status.
- **Task Scheduler Setup**: A Task Scheduler task is configured to execute the secondary script at defined intervals, ensuring network adapters are reset if domain authentication fails.
- **Network Monitoring**: The secondary script checks network profiles for `DomainAuthenticated` status and restarts physical network adapters if required.

## Tested Environment
This solution has been tested in a controlled lab environment and found to work reliably. It is recommended for scenarios where traditional solutions like Group Policy cannot be applied.

## Disclaimer
This script is provided "as-is" without warranty of any kind. Use at your own risk. Always test in a non-production environment before deploying to critical systems.

## Contributions
Contributions and suggestions are welcome! Feel free to open an issue or submit a pull request.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact
If you have questions or need assistance, please reach out by creating an issue in this repository.
