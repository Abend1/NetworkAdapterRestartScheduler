# Workaround for Air-Gapped Lab System Issue

## Overview
This repository contains a PowerShell script designed as a workaround for network issues encountered on air-gapped lab systems where Windows Server 2025 AD machines fail to set their filewall profile to domain. The solution does not depend on Group Policy or similar configurations, providing a simple and effective mechanism to ensure network adapters are appropriately managed in cases where domain authentication is required.

## Problem Statement
Works on air-gapped systems, should work on Internet capable machines, maintaining network connectivity while ensuring domain authentication can be a persistent challenge. This script automates the process of monitoring network authentication status and restarts physical network adapters if they fail to authenticate with the domain.

## Key Features
- Writes a secondary PowerShell script to `C:\Windows`.
- Sets up a Task Scheduler task to execute the script:
  - Initial delay of 30 seconds at startup.
  - Repeats every minute for 5 minutes.
- Checks network category for `DomainAuthenticated` status.
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
