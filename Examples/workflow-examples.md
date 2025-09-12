# IT-ToolBox Workflow Examples

This document provides step-by-step examples of using IT-ToolBox in real-world scenarios.

## Example 1: Fixing Printer Issues

### Scenario
A user calls the help desk: "My printer stopped working. It shows offline but the printer is on and connected."

### Solution Workflow

#### Step 1: Launch IT-ToolBox
```powershell
PS C:\IT-ToolBox> .\Scripts\IT-ToolBox.ps1
```

#### Step 2: Menu Selection
```
IT-ToolBox - Remote Management Utility
====================================
Your Complete IT Support Toolkit

Step 1: Select operation to perform

Available Operations:
============================================================
1. Print Spooler (Spooler)
   Description: Manages print jobs and printer communication
2. Remote Desktop Services (TermService)
   Description: Enables Remote Desktop connections
3. Adobe Acrobat DC Sign-in Fix (AdobeFix)
   Description: Applies registry fix to stop Adobe Acrobat DC sign-in prompts

Options:
Q. Quit

Select operation to perform (1, 2, 3, or Q to quit): 1
```

**User Input**: `1` (Print Spooler)

#### Step 3: Computer Specification
```
Selected operation:
  - Print Spooler (Spooler)

Step 2: Specify target computer
Enter the target computer name or IP address: USER-PC-001
```

**User Input**: `USER-PC-001`

#### Step 4: Confirmation
```
Target Computer: USER-PC-001

Step 3: Final confirmation
Proceed with 'Print Spooler' on 'USER-PC-001'? (Y/N): Y
```

**User Input**: `Y`

#### Step 5: Execution
```
Step 4: Testing connectivity
Testing connectivity to USER-PC-001...
[OK] Ping successful
[OK] WMI/RPC connectivity successful

Step 5: Executing operations

Service Status on USER-PC-001:
==================================================
[RUNNING] Print Spooler (Spooler)

Restarting Print Spooler on USER-PC-001...
Stopping Print Spooler...
[OK] Stop command sent successfully
Waiting for service to stop...
[OK] Service stopped successfully
Starting Print Spooler...
[OK] Start command sent successfully  
Waiting for service to start...
[OK] Service started successfully
[SUCCESS] Print Spooler restarted successfully

==================================================
Final Status Check:

Service Status on USER-PC-001:
==================================================
[RUNNING] Print Spooler (Spooler)

Script completed.
```

### Result
The print spooler service was successfully restarted. The user should now be able to print normally.

## Example 2: Remote Desktop Connection Issues

### Scenario
A system administrator cannot connect to a server via Remote Desktop. The connection is being refused.

### Solution Workflow

#### Step 1-2: Launch and Select Operation
```powershell
PS C:\IT-ToolBox> .\Scripts\IT-ToolBox.ps1

# Select option 2 for Remote Desktop Services
Select operation to perform (1, 2, 3, or Q to quit): 2
```

#### Step 3: Target Server
```
Selected operation:
  - Remote Desktop Services (TermService)

Step 2: Specify target computer
Enter the target computer name or IP address: SERVER-SQL-01
```

**User Input**: `SERVER-SQL-01`

#### Step 4: Confirmation with Warning
```
Target Computer: SERVER-SQL-01

Step 3: Final confirmation
Proceed with 'Remote Desktop Services' on 'SERVER-SQL-01'? (Y/N): Y
```

**⚠️ Important**: This will disconnect any existing RDP sessions!

#### Step 5: Execution
```
Step 4: Testing connectivity
Testing connectivity to SERVER-SQL-01...
[OK] Ping successful
[OK] WMI/RPC connectivity successful

Step 5: Executing operations

Service Status on SERVER-SQL-01:
==================================================
[RUNNING] Remote Desktop Services (TermService)

Restarting Remote Desktop Services on SERVER-SQL-01...
Stopping Remote Desktop Services...
[OK] Stop command sent successfully
Waiting for service to stop...
[OK] Service stopped successfully
Starting Remote Desktop Services...
[OK] Start command sent successfully
Waiting for service to start...
[OK] Service started successfully
[SUCCESS] Remote Desktop Services restarted successfully

==================================================
Final Status Check:

Service Status on SERVER-SQL-01:
==================================================
[RUNNING] Remote Desktop Services (TermService)

Script completed.
```

### Post-Operation Test
```powershell
# Test RDP connection
mstsc /v:SERVER-SQL-01
```

## Example 3: Adobe Acrobat Sign-in Issues

### Scenario  
Multiple users report that Adobe Acrobat DC keeps asking them to sign in, even though the organization doesn't use Adobe Creative Cloud services.

### Solution Workflow

#### Step 1-2: Launch and Select Registry Fix
```
Select operation to perform (1, 2, 3, or Q to quit): 3
```

#### Step 3: Target Computer
```
Selected operation:
  - Adobe Acrobat DC Sign-in Fix (AdobeFix)

Step 2: Specify target computer
Enter the target computer name or IP address: OFFICE-PC-025
```

#### Step 4: Confirmation
```
Target Computer: OFFICE-PC-025

Step 3: Final confirmation
Proceed with 'Adobe Acrobat DC Sign-in Fix' on 'OFFICE-PC-025'? (Y/N): Y
```

#### Step 5: Registry Modification
```
Step 4: Testing connectivity
Testing connectivity to OFFICE-PC-025...
[OK] Ping successful
[OK] WMI/RPC connectivity successful

Step 5: Executing operations

Applying Adobe Acrobat DC Sign-in Fix on OFFICE-PC-025...
Connecting to remote registry...
[OK] Connected to remote registry
Creating registry key structure...
[OK] Created registry key: HKLM\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown
Setting registry value: bIsSCReducedModeEnforcedEx = 1
[OK] Registry value set successfully
[OK] Verified: bIsSCReducedModeEnforcedEx = 1
[SUCCESS] Adobe Acrobat DC sign-in fix applied successfully

Script completed.
```

### Post-Operation Instructions
Inform the user to:
1. Close Adobe Acrobat DC if open
2. Restart Adobe Acrobat DC
3. The sign-in prompts should no longer appear

## Example 4: Troubleshooting Connection Failures

### Scenario
Attempting to manage a computer that has connectivity issues.

### Failed Connection Example

#### Step 1-3: Normal Workflow
```
Select operation to perform (1, 2, 3, or Q to quit): 1
Enter the target computer name or IP address: BROKEN-PC-099
Proceed with 'Print Spooler' on 'BROKEN-PC-099'? (Y/N): Y
```

#### Step 4: Connectivity Failure
```
Step 4: Testing connectivity
Testing connectivity to BROKEN-PC-099...
[FAIL] Ping failed

Cannot connect to BROKEN-PC-099. Exiting.
```

### Troubleshooting Steps
1. **Verify Computer Name**: Check if `BROKEN-PC-099` is the correct name
2. **Network Connectivity**: Ensure the computer is on the network
3. **Power State**: Confirm the target computer is powered on
4. **Network Path**: Test from a different network segment if possible

### WMI Failure Example
```
Step 4: Testing connectivity
Testing connectivity to PROBLEM-PC-050...
[OK] Ping successful
[FAIL] WMI/RPC connectivity failed: RPC server is unavailable

Cannot connect to PROBLEM-PC-050. Exiting.
```

### Solutions for WMI Issues
1. **Windows Firewall**: Check if WMI exceptions are enabled
2. **Services**: Verify WMI service is running on target
3. **RPC**: Ensure RPC service is running
4. **Permissions**: Confirm administrative access to target computer

## Example 5: Service Operation Failures

### Scenario
A service restart fails due to the service being unresponsive.

### Failed Service Restart
```
Step 5: Executing operations

Service Status on HUNG-PC-001:
==================================================
[RUNNING] Print Spooler (Spooler)

Restarting Print Spooler on HUNG-PC-001...
Stopping Print Spooler...
[OK] Stop command sent successfully
Waiting for service to stop...
[WARN] Service stop timeout - proceeding with start
Starting Print Spooler...
[FAIL] Start command failed: The service cannot be started

[FAILED] Failed to restart Print Spooler
```

### Recovery Actions
1. **Check Service Dependencies**: Verify dependent services are running
2. **Event Logs**: Review Windows Event Logs for service errors
3. **Manual Intervention**: May require manual service management or reboot
4. **Service Files**: Check if service executable files are corrupted

## Example 6: Batch Operations (Future Enhancement)

### Scenario  
Need to restart print spooler on multiple computers during maintenance window.

### Planned Workflow (Future Version)
```powershell
# Future batch capability example
$computers = @("PC001", "PC002", "PC003", "PC004", "PC005")
$results = @()

foreach ($computer in $computers) {
    Write-Host "Processing $computer..." -ForegroundColor Cyan
    
    # Future: IT-ToolBox batch mode
    $result = .\Scripts\IT-ToolBox.ps1 -ComputerName $computer -Operation "PrintSpooler" -Batch
    
    $results += [PSCustomObject]@{
        Computer = $computer
        Status = $result.Status
        Details = $result.Message
        Timestamp = Get-Date
    }
}

$results | Export-Csv "maintenance-results.csv" -NoTypeInformation
```

## Example 7: Integration with Help Desk Workflow

### Scenario
Standardizing IT-ToolBox usage in help desk procedures.

### Help Desk Ticket Workflow

#### Ticket: Printer Offline Issues
1. **Initial Diagnosis**
   - User reports printer offline
   - Verify printer is powered and connected
   - Check print queue for stuck jobs

2. **IT-ToolBox Resolution**
   ```
   Technician Action: Run IT-ToolBox
   - Selected Operation: Print Spooler restart
   - Target Computer: [User's PC name]
   - Result: Service restarted successfully
   ```

3. **Verification**
   - Ask user to test printing
   - Verify printer status shows online
   - Close ticket with resolution notes

4. **Documentation**
   ```
   Resolution: Used IT-ToolBox to restart Print Spooler service on [PC Name].
   Service was restarted successfully at [timestamp].
   User confirmed printing functionality restored.
   ```

### Help Desk Training Scenarios

#### New Technician Training
1. **Print Issues**: Use IT-ToolBox option 1
2. **RDP Problems**: Use IT-ToolBox option 2  
3. **Adobe Sign-in**: Use IT-ToolBox option 3

#### Escalation Criteria
- Connection failures → Network team
- Service won't start → System administration
- Registry access denied → Security team

## Example 8: Maintenance Window Operations

### Scenario
Scheduled maintenance requiring service restarts on critical servers.

### Pre-Maintenance Checklist
1. **User Notification**: Inform users of planned service interruption
2. **Change Management**: Document planned operations
3. **Backup Verification**: Ensure recent backups exist
4. **Access Verification**: Test administrative access to all targets

### Maintenance Execution
```powershell
# Example maintenance window script
$maintenanceServers = @(
    "FILE-SERVER-01",
    "PRINT-SERVER-01", 
    "RDP-GATEWAY-01"
)

foreach ($server in $maintenanceServers) {
    Write-Host "=== Maintenance: $server ===" -ForegroundColor Yellow
    
    # Document pre-maintenance state
    Write-Host "Pre-maintenance: Documenting service states"
    
    # Run appropriate IT-ToolBox operations
    # This would be interactive per current version
    Write-Host "Execute IT-ToolBox operations for $server"
    
    # Verify operations completed successfully
    Write-Host "Post-maintenance: Verify service functionality"
}
```

### Post-Maintenance Verification
1. **Service Status**: Confirm all services are running
2. **Functionality Test**: Verify services work as expected
3. **User Communication**: Notify users that maintenance is complete
4. **Documentation**: Record all operations performed

These examples demonstrate the practical application of IT-ToolBox in various real-world scenarios, from simple help desk operations to complex maintenance procedures.