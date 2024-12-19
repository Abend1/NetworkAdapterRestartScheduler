try {
    # Define task parameters
    $TaskName = "0-RestartPhysicalNetworkAdapters"
    $ScriptPath = "C:\Windows\$TaskName.ps1"
    $Description = "Checks network category and restarts physical network adapters if not DomainAuthenticated after 30 seconds delay at startup and repetition every minute for 5 minutes.."
    $LogFile = "C:\Windows\$TaskName.log"

    # Define the PowerShell script content
    $ScriptContent = @'
# Script Name: 0-RestartPhysicalNetworkAdapters.ps1
# Description: Checks network category and restarts physical network adapters if not DomainAuthenticated.
# Called by: Task Scheduler
# Location: C:\Windows\0-RestartPhysicalNetworkAdapters.ps1

Start-Transcript -Path "C:\Windows\0-RestartPhysicalNetworkAdapters.log"

try {
    # Check the network category
    $Profiles = Get-NetConnectionProfile
    $RequiresRestart = $false

    foreach ($Profile in $Profiles) {
        if ($Profile.NetworkCategory -ne "DomainAuthenticated") {
            Write-Host "NetworkCategory is not DomainAuthenticated for interface '$($Profile.Name)'. Triggering network restart." -ForegroundColor Yellow
            $RequiresRestart = $true
            break
        }
    }

    # Restart network adapters if necessary
    if ($RequiresRestart) {
        Get-NetAdapter -Physical | Where-Object { $_.Status -eq "Up" } | Restart-NetAdapter
        Write-Host "Network adapters have been restarted." -ForegroundColor Green
    } else {
        Write-Host "All network interfaces are DomainAuthenticated. No action required." -ForegroundColor Green
    }
} catch {
    Write-Host "Error occurred: $_" -ForegroundColor Red
} finally {
    Stop-Transcript
    Exit 0
}
'@

    # Overwrite the script in C:\Windows
    Set-Content -Path $ScriptPath -Value $ScriptContent -Encoding UTF8 -Force
    Write-Host "PowerShell script created/overwritten at $ScriptPath." -ForegroundColor Green

    # Task XML template with a 5-minute duration repeating every minute
    $TaskXML = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns=http://schemas.microsoft.com/windows/2004/02/mit/task>
  <RegistrationInfo>
    <Description>$Description</Description>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
      <Delay>PT30S</Delay>
      <Repetition>
        <Interval>PT1M</Interval>
        <Duration>PT5M</Duration>
      </Repetition>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT15M</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>PowerShell.exe</Command>
      <Arguments>-NoProfile -ExecutionPolicy Bypass -File "$ScriptPath"</Arguments>
    </Exec>
  </Actions>
</Task>
"@

    # Check if the task exists and delete it if necessary
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Write-Host "Task '$TaskName' already exists. Deleting it..." -ForegroundColor Yellow
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
    }

    # Register the task using the XML definition
    $TempXMLPath = "$env:TEMP\$TaskName.xml"
    Set-Content -Path $TempXMLPath -Value $TaskXML -Encoding Unicode

    Register-ScheduledTask -TaskName $TaskName -Xml (Get-Content -Path $TempXMLPath | Out-String) -User "SYSTEM"

    # Cleanup temporary XML file
    Remove-Item -Path $TempXMLPath -Force

    Write-Host "Scheduled task '$TaskName' created successfully with a 30-second delay and repetition every minute for 5 minutes." -ForegroundColor Green

} catch {
    # Handle errors and provide feedback
    Write-Host "Error occurred while creating the scheduled task: $_" -ForegroundColor Red
}
