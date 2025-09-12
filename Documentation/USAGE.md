# Usage Guide - IT-ToolBox

## Overview
This guide provides comprehensive instructions for using the IT-ToolBox interactive remote management utility.

## Getting Started

### System Requirements
- **Operating System**: Windows 7/2008 R2 or later
- **PowerShell**: Version 5.1 or later (PowerShell Core 6.0+ supported)
- **Privileges**: Administrative rights on local and target machines
- **Network**: TCP connectivity to target computers
- **Services**: WMI and RPC services running on target systems

### Quick Launch
```powershell
# Navigate to the IT-ToolBox directory
cd C:\Path\To\IT-ToolBox

# Run the main script
.\Scripts\IT-ToolBox.ps1
```

## Interactive Workflow

### Step 1: Operation Selection
The script presents a menu with available operations:

```
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

Select operation to perform (1, 2, 3, or Q to quit):
```

**Input Options:**
- `1` - Print Spooler service restart
- `2` - Remote Desktop Services restart  
- `3` - Adobe Acrobat DC registry fix
- `Q` or `q` - Quit without making changes

### Step 2: Target Computer
After selecting an operation, specify the target computer:

```
Enter the target computer name or IP address: 
```

**Valid Inputs:**
- Computer name: `PC001`, `SERVER-01`, `WORKSTATION`
- FQDN: `computer.domain.com`
- IP address: `192.168.1.100`, `10.0.0.50`

### Step 3: Confirmation
Review and confirm the operation:

```
Proceed with 'Print Spooler' on 'PC001'? (Y/N):
```

**Input Options:**
- `Y` or `y` - Proceed with operation
- `N` or `n` - Cancel operation and exit

### Step 4: Connectivity Testing
The script automatically tests connectivity:

```
Testing connectivity to PC001...
[OK] Ping successful
[OK] WMI/RPC connectivity successful
```

**Possible Results:**
- ✅ **Success**: Both ping and WMI/RPC tests pass
- ❌ **Failure**: Connection issues prevent remote operations

### Step 5: Operation Execution
The selected operation is performed with real-time feedback:

```
Service Status on PC001:
==================================================
[RUNNING] Print Spooler (Spooler)

Restarting Print Spooler on PC001...
Stopping Print Spooler...
[OK] Stop command sent successfully
Waiting for service to stop...
[OK] Service stopped successfully
Starting Print Spooler...
[OK] Start command sent successfully
Waiting for service to start...
[OK] Service started successfully
[SUCCESS] Print Spooler restarted successfully
```

## Detailed Operation Guides

### 1. Print Spooler Service Restart

**When to Use:**
- Print jobs stuck in queue
- Printer shows offline when online
- "Print Spooler service not running" errors
- General printing problems

**What It Does:**
1. Shows current service status
2. Stops the Spooler service gracefully
3. Waits for complete shutdown (up to 30 seconds)
4. Starts the service
5. Verifies service is running
6. Shows final status

**Troubleshooting:**
- If service won't stop: Check for applications holding print handles
- If service won't start: Verify spooler files aren't corrupted
- If operation times out: Service may be hung, consider system reboot

### 2. Remote Desktop Services Restart

**When to Use:**
- "Remote Desktop can't connect" errors
- RDP sessions hanging during login
- Terminal Services not responding
- Multiple connection failures

**What It Does:**
1. Shows current TermService status
2. Stops Remote Desktop Services
3. Waits for service shutdown
4. Restarts the service
5. Verifies RDP is accepting connections

**⚠️ Important Notes:**
- **Existing RDP sessions will be disconnected**
- Users will lose unsaved work in remote sessions
- Plan this operation during maintenance windows
- Inform users before restarting RDP services

**Troubleshooting:**
- If can't connect after restart: Check Windows Firewall settings
- If service fails to start: Verify licensing configuration
- If still having issues: Check network connectivity and routing

### 3. Adobe Acrobat DC Sign-in Fix

**When to Use:**
- Adobe Acrobat DC repeatedly prompts for sign-in
- "Sign in required" messages appear constantly
- Adobe Creative Cloud integration issues
- Corporate environments blocking Adobe sign-in

**What It Does:**
1. Connects to remote registry on target computer
2. Creates registry path: `HKLM\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown`
3. Sets value: `bIsSCReducedModeEnforcedEx = 1 (DWORD)`
4. Verifies the registry change was applied
5. Closes remote registry connections

**Technical Details:**
- **Registry Hive**: HKEY_LOCAL_MACHINE
- **Key Path**: SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown
- **Value Name**: bIsSCReducedModeEnforcedEx
- **Value Type**: DWORD
- **Value Data**: 1

**Post-Operation:**
- Adobe Acrobat DC may need to be restarted
- Changes take effect immediately for new document opens
- Setting persists across reboots and updates

## Error Handling and Troubleshooting

### Connectivity Issues

**Ping Failure:**
```
[FAIL] Ping failed
```
**Solutions:**
- Verify computer name/IP is correct
- Check network connectivity
- Confirm target computer is powered on
- Verify network routing and switches

**WMI/RPC Failure:**
```
[FAIL] WMI/RPC connectivity failed: RPC server is unavailable
```
**Solutions:**
- Ensure WMI service is running on target
- Check Windows Firewall exceptions
- Verify RPC service is running
- Test from different network segment

### Service Operation Issues

**Service Won't Stop:**
```
[WARN] Service stop timeout - proceeding with start
```
**Solutions:**
- Service may be hung - try system reboot
- Check for processes holding service handles
- Use Task Manager to end related processes
- Consider forceful service termination

**Service Won't Start:**
```
[FAIL] Start command failed: The service cannot be started
```
**Solutions:**
- Check Windows Event Logs for service errors
- Verify service dependencies are running
- Confirm service executable files exist
- Check service user account permissions

### Registry Operation Issues

**Registry Access Denied:**
```
[FAIL] Unable to connect to remote registry
```
**Solutions:**
- Verify Remote Registry service is running
- Check user permissions for registry access
- Ensure administrative privileges
- Test with different user account

**Key Creation Failed:**
```
[FAIL] Error applying Adobe registry fix: Access denied
```
**Solutions:**
- Run script as administrator
- Verify target system allows remote registry modification
- Check group policy restrictions
- Ensure registry path is not protected

## Best Practices

### Pre-Operation Checklist
1. **Verify Target**: Confirm computer name/IP is correct
2. **Check Timing**: Avoid business hours for service restarts
3. **User Notification**: Inform users of potential disconnections
4. **Backup Considerations**: Document current settings if needed
5. **Test Environment**: Try in development environment first

### During Operations
1. **Monitor Progress**: Watch for error messages and warnings
2. **Document Results**: Note any unusual behavior or errors
3. **Verify Success**: Confirm operations completed successfully
4. **Test Functionality**: Verify services work as expected

### Post-Operation
1. **Status Verification**: Confirm services are running properly
2. **User Testing**: Have users test functionality
3. **Documentation**: Record operation in change management system
4. **Follow-up**: Check for any delayed issues or side effects

## Advanced Usage Scenarios

### Batch Operations Planning
While the current version handles single operations, plan for multiple computers:

```powershell
# Example concept for future batch operations
$computers = @("PC001", "PC002", "PC003")
foreach ($computer in $computers) {
    # Run IT-ToolBox for each computer
    # Implement error handling and reporting
}
```

### Scheduled Maintenance
Use Windows Task Scheduler for regular maintenance:

1. Create batch file to run IT-ToolBox
2. Schedule during maintenance windows
3. Configure logging and reporting
4. Set up email notifications for failures

### Integration with Other Tools
- **SCCM Integration**: Deploy via Configuration Manager
- **Group Policy**: Use for Adobe registry settings
- **PowerShell DSC**: Ensure consistent configurations
- **Monitoring Tools**: Integrate with SCOM or similar

## Troubleshooting Common Scenarios

### Scenario 1: Printer Not Working
**Problem**: Users report printer is offline
**Solution**: Use Print Spooler restart operation
**Steps**: 
1. Run IT-ToolBox
2. Select option 1 (Print Spooler)
3. Enter printer server name
4. Confirm operation
5. Verify printer comes online

### Scenario 2: Can't Remote Desktop
**Problem**: RDP connections failing to server
**Solution**: Restart Remote Desktop Services
**Steps**:
1. **Warning**: Notify users of potential disconnection
2. Run IT-ToolBox
3. Select option 2 (Remote Desktop Services)
4. Enter server name
5. Confirm operation
6. Test RDP connection

### Scenario 3: Adobe Sign-in Prompts
**Problem**: Adobe Acrobat constantly asking for sign-in
**Solution**: Apply registry fix
**Steps**:
1. Run IT-ToolBox
2. Select option 3 (Adobe Fix)
3. Enter target computer
4. Confirm operation
5. Ask user to restart Adobe Acrobat

## Script Customization

### Adding New Services
To extend the script with additional services:

1. **Edit the Script**: Modify the `$availableServices` array
2. **Add Service Definition**:
```powershell
,(New-Object PSObject -Property @{
    Name = "YourService"
    DisplayName = "Your Service Name"
    Description = "What your service does"
    Type = "Service"
})
```
3. **Test Thoroughly**: Verify new service works correctly
4. **Update Documentation**: Add usage instructions

### Custom Registry Operations
For additional registry fixes:

1. **Create New Function**: Following the `Set-AdobeRegistryFix` pattern
2. **Add to Services Array**: With Type = "Registry"
3. **Update Main Logic**: Add handling in the execution section
4. **Test Extensively**: Registry changes can be dangerous

## Support and Troubleshooting

### Log Files
Currently the script provides real-time output. For production use, consider:
- Redirecting output to log files
- Adding timestamp logging
- Implementing structured logging

### Common Issues
1. **Permission Denied**: Ensure administrative privileges
2. **Network Timeout**: Check firewall and network settings
3. **Service Dependencies**: Verify prerequisite services are running
4. **Registry Protection**: Some systems may block remote registry access

### Getting Help
1. **Review Error Messages**: Most errors include specific guidance
2. **Check Event Logs**: Windows Event Viewer for detailed errors
3. **Test Connectivity**: Use basic ping and telnet tests
4. **Verify Permissions**: Ensure proper administrative access