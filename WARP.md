# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

IT-ToolBox is a professional interactive PowerShell tool for remote Windows system management. It provides a menu-driven interface for IT support teams to perform common remote maintenance tasks including service management and registry modifications.

## Key Commands

### Running the Main Tool
```powershell
# Primary usage - run from IT-ToolBox directory
.\Scripts\IT-ToolBox.ps1

# Alternative execution methods
pwsh -File .\Scripts\IT-ToolBox.ps1
powershell.exe -File .\Scripts\IT-ToolBox.ps1
```

### Development and Testing
```powershell
# Test PowerShell syntax
Get-Command Test-Path  # Verify PowerShell environment

# Validate remote connectivity
Test-Connection -ComputerName <target> -Count 2 -Quiet
Get-WmiObject -Class Win32_OperatingSystem -ComputerName <target>

# Test service control commands
sc.exe \\<computer> query <service>
sc.exe \\<computer> stop <service>
sc.exe \\<computer> start <service>
```

### File Operations (Related Utilities)
```powershell
# WMI-based remote file operations (from parent Utilities folder)
.\..\Utilities\WMI-FileOperations.ps1 -ComputerName <target> -Operation List
.\..\Utilities\WMI-FileOperations.ps1 -ComputerName <target> -Operation Count -FilePattern "*.tmp"
```

## Architecture Overview

### Core Structure
```
IT-ToolBox/
├── Scripts/IT-ToolBox.ps1          # Main interactive tool
├── Documentation/USAGE.md          # Comprehensive usage guide
├── Examples/workflow-examples.md   # Real-world scenarios
└── README.md                       # Project documentation
```

### Main Script Architecture
The `IT-ToolBox.ps1` script follows a modular design:

1. **Interactive Menu System** - User-friendly operation selection
2. **Connectivity Module** - Network and WMI/RPC validation  
3. **Service Management** - Windows service control via SC commands
4. **Registry Operations** - Safe remote registry modifications
5. **Status Monitoring** - Before/after operation verification
6. **Error Handling** - Comprehensive exception management

### Key Functions
- `Test-RemoteConnectivity` - Validates ping and WMI/RPC access
- `Get-RemoteServiceStatus` - Retrieves service status via WMI
- `Restart-RemoteService` - Performs safe service restart cycle
- `Set-AdobeRegistryFix` - Applies Adobe Acrobat DC registry modification
- `Show-ServiceSelectionMenu` - Interactive operation selection
- `Show-ServiceStatus` - Service status display

## Current Operations

### 1. Print Spooler Management
- **Service**: `Spooler`
- **Purpose**: Resolves print queue issues and printer communication problems
- **Common Use**: Stuck print jobs, printer offline errors

### 2. Remote Desktop Services  
- **Service**: `TermService`
- **Purpose**: Fixes RDP connection issues
- **Warning**: Disconnects existing RDP sessions
- **Common Use**: RDP login failures, connection refused errors

### 3. Adobe Acrobat DC Sign-in Fix
- **Type**: Registry modification
- **Registry Path**: `HKLM\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown`
- **Value**: `bIsSCReducedModeEnforcedEx = 1 (DWORD)`
- **Purpose**: Stops persistent Adobe sign-in prompts

## Technical Requirements

### Prerequisites
- Windows PowerShell 5.1+ (PowerShell Core 6.0+ supported)
- Administrative privileges on local and target machines
- Network connectivity to target computers
- WMI and RPC services running on targets
- Remote Registry service (for Adobe fix)

### Network Requirements  
- ICMP (ping) access
- WMI/RPC ports (typically 135, 445, dynamic RPC)
- SMB access for service control
- Remote Registry access (port 445)

## Extension Framework

### Adding New Operations
New services can be added to the `$availableServices` array:

```powershell
,(New-Object PSObject -Property @{
    Name = "ServiceName"           # Windows service name or custom ID
    DisplayName = "Display Name"   # User-friendly name  
    Description = "What it does"   # Brief description
    Type = "Service"               # "Service", "Registry", or "Custom"
})
```

### Custom Registry Operations
Follow the `Set-AdobeRegistryFix` pattern for new registry modifications:
- Secure remote registry connection
- Create registry paths if needed  
- Set values with proper data types
- Verify changes were applied
- Comprehensive error handling

## Safety Features

- **Multi-step Confirmation**: User must confirm operations before execution
- **Connectivity Validation**: Tests ping and WMI/RPC before proceeding
- **Timeout Protection**: Prevents hanging operations (30-second timeouts)
- **Status Verification**: Shows before/after service states
- **Graceful Error Handling**: Detailed error messages with suggested solutions

## Related Tools

This repository is part of a larger PowerShell toolkit:
- **Core/**: Advanced remote cleanup utilities using WMI
- **Utilities/**: File operations and system analysis tools
- **Advanced/**: Specialized cleanup and maintenance scripts

## Workflow Patterns

### Standard IT-ToolBox Workflow
1. **Menu Selection** → Choose operation (1-3 or Q)
2. **Target Specification** → Enter computer name/IP
3. **Confirmation** → Confirm operation (Y/N)
4. **Connectivity Test** → Automatic ping/WMI validation
5. **Execution** → Perform operation with real-time feedback

### Error Recovery
- Connection failures → Validate network/firewall settings
- Service operation failures → Check dependencies and event logs
- Registry access denied → Verify Remote Registry service and permissions
- Timeout issues → Consider system reboot or manual intervention

## Best Practices

### When Using IT-ToolBox
- Run during maintenance windows for service restarts
- Notify users before restarting Remote Desktop Services
- Verify operations completed successfully before closing
- Document operations in change management systems

### Code Modifications
- Maintain the existing error handling patterns
- Follow the modular function design
- Preserve the interactive workflow structure
- Test thoroughly with actual remote systems
- Update documentation when adding new operations

## Common Issues

### Connectivity Problems
- **WMI Access**: Ensure WMI service running and firewall exceptions
- **Administrative Rights**: Confirm local admin rights on target systems  
- **Network Routing**: Verify network paths between systems

### Service Operation Issues
- **Hung Services**: May require system reboot if timeouts occur
- **Dependencies**: Check that dependent services are running
- **Permissions**: Verify service control permissions

### Registry Operations
- **Remote Registry**: Service must be running on target
- **Access Rights**: Administrative privileges required
- **Group Policy**: May override registry changes

This tool represents production-ready PowerShell automation with comprehensive safety features and real-world IT support workflows.