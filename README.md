# IT-ToolBox 🧰

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)](https://www.microsoft.com/en-us/windows)
[![Version](https://img.shields.io/badge/Version-5.1-orange)](CHANGELOG.md)

> **Interactive Remote Management Utility** - Your complete IT support toolkit for managing Windows services, applying fixes, and recovering disk space on remote computers.

## 🚀 Overview

IT-ToolBox is a professional interactive PowerShell script designed for system administrators and IT support teams. It provides a user-friendly menu-driven interface for performing common remote management tasks with built-in safety features and comprehensive error handling.

### 🎯 Key Features

- **🔄 Continuous Operation Loop**: Perform multiple operations without restarting the script
- **🎛️ Enhanced Interactive Menu**: User-friendly selection interface with return-to-menu capability
- **👥 Advanced Session Management**: Manual session selection with account lockout prevention
- **🔌 Smart Connectivity Testing**: Automatic ping and WMI/RPC validation with recovery options
- **📊 Service Status Monitoring**: Before and after operation status checks
- **🔧 Service Management**: Reliable remote service restart capabilities
- **🗂️ Registry Operations**: Safe remote registry modifications
- **💾 Disk Space Recovery**: Advanced MSP cleanup can free 100+ GB per machine
- **⚡ Real-time Feedback**: Color-coded status messages and progress indicators
- **🛡️ Enhanced Safety**: Multiple confirmation steps, graceful error handling, and recovery options
- **🔄 Extensible Design**: Easy to add new operations and services

## 📁 Repository Structure

```
IT-ToolBox/
├── Scripts/                    # Main PowerShell scripts
│   └── IT-ToolBox.ps1         # Primary interactive management tool
├── Documentation/             # User guides and technical docs
│   ├── USAGE.md              # Detailed usage instructions
│   └── TROUBLESHOOTING.md    # Common issues and solutions
├── Examples/                  # Usage examples and scenarios
│   └── workflow-examples.md   # Step-by-step usage scenarios
├── README.md                  # This file
├── LICENSE                    # MIT License
└── CHANGELOG.md              # Version history
```

## ✨ Current Operations

### 1. 🖨️ Print Spooler Service Restart
- **Service**: `Spooler`
- **Purpose**: Resolves print queue issues and printer communication problems
- **Common Issues Fixed**: Stuck print jobs, printer offline errors, spooler crashes

### 2. 🖥️ Remote Desktop Services Restart  
- **Service**: `TermService`
- **Purpose**: Fixes Remote Desktop connection issues
- **Common Issues Fixed**: RDP login failures, session timeout problems, connection refused errors

### 3. 📄 Adobe Acrobat DC Sign-in Fix
- **Type**: Registry Modification
- **Purpose**: Stops persistent Adobe Acrobat DC sign-in prompts
- **Registry Path**: `HKLM\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown`
- **Value**: `bIsSCReducedModeEnforcedEx = 1 (DWORD)`

### 4. 💾 Advanced MSP Cleanup
- **Type**: Disk Space Recovery
- **Purpose**: Cleans old MSP files from Windows Installer cache
- **Target**: Files older than 7 days (aggressive cleanup)
- **Potential Recovery**: 100+ GB of disk space per machine
- **Features**: Progress tracking, size analysis, administrative share validation

### 5. 👥 Remote Session Management **NEW!**
- **Type**: Session Administration
- **Purpose**: View active user sessions and logoff stale sessions (prevents account lockouts)
- **Features**: 
  - Auto-cleanup mode for stale disconnected sessions (1+ days)
  - Manual selection mode for choosing specific sessions to logoff
  - View-only mode for monitoring sessions without changes
  - Color-coded session display (Active/Disconnected/Stale)
  - Graceful handling of systems with no active sessions
- **Commands Used**: `quser /server:` and `logoff /server:` (WinRM-free compatibility)

## 🚀 Quick Start

### Prerequisites
- Windows PowerShell 5.1 or later
- Administrative privileges on both local and target machines
- Network connectivity to target computers
- WMI/RPC access to remote systems

### Basic Usage

```powershell
# Simply run the script - no parameters needed!
.\Scripts\IT-ToolBox.ps1

# From PowerShell Core
pwsh -File .\Scripts\IT-ToolBox.ps1

# From Command Prompt
powershell.exe -File .\Scripts\IT-ToolBox.ps1
```

### 📋 Enhanced Interactive Workflow **NEW!**

The script now features a continuous operation loop with a 6-step process:

1. **🎛️ Operation Selection**: Choose from available operations via interactive menu
2. **🖥️ Target Specification**: Enter computer name or IP address
3. **✅ Confirmation**: Confirm operation before execution
4. **🔌 Connectivity Test**: Automatic connectivity validation with recovery options
5. **⚡ Execution**: Perform selected operation with real-time feedback
6. **🔄 Continue Choice**: Return to main menu or exit → **[Loop back to step 1]**

**Key Enhancement**: No need to restart the script! Perform multiple operations seamlessly.

## 📊 Usage Example

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
4. Advanced MSP Cleanup (MSPCleanup)
   Description: Cleans up old MSP files from Windows Installer cache (can recover 100+ GB)
5. Remote Session Management (SessionManagement)
   Description: View active user sessions and logoff stale sessions (prevents account lockouts)

Options:
Q. Quit

Select operation to perform (1, 2, 3, 4, 5, or Q to quit): 5

Selected operation:
  - Remote Session Management (SessionManagement)

Step 2: Specify target computer
Enter the target computer name or IP address: PC001

Target Computer: PC001

Step 3: Final confirmation
Proceed with 'Remote Session Management' on 'PC001'? (Y/N): Y

Step 4: Testing connectivity
Testing connectivity to PC001...
[OK] Ping successful
[OK] WMI/RPC connectivity successful

Step 5: Executing operations

Starting Remote Session Management on PC001...
Retrieving active user sessions...

[ACTIVE SESSIONS on PC001]
 USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
1. john                 rdp-tcp#0           2  Active          .  9/20/2025 8:30 AM
2. mary                 rdp-tcp#1           3  Disc        5+00  9/18/2025 2:15 PM
3. admin               console             1  Active       1:20  9/20/2025 9:45 AM

[SESSION MANAGEMENT OPTIONS]
1. Auto-cleanup stale sessions (disconnected 1+ days)
2. Manually select sessions to logoff
3. View only (no changes)
Q. Return to main menu

Select option (1, 2, 3, or Q): 2

[MANUAL SESSION SELECTION]
Available sessions:
1. User: john, ID: 2, State: Active, Idle: .
2. User: mary, ID: 3, State: Disc, Idle: 5+00
3. User: admin, ID: 1, State: Active, Idle: 1:20

Enter session number(s) to logoff (comma-separated, or 'C' to cancel): 2

[SELECTED SESSIONS FOR LOGOFF]
  User: mary, ID: 3, State: Disc

Proceed to logoff 1 session(s)? (Y/N): Y
Logging off session ID 3 (User: mary)...
[SUCCESS] Logged off session ID 3

[UPDATED SESSION LIST]
 USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
 john                  rdp-tcp#0           2  Active          .  9/20/2025 8:30 AM
 admin                 console             1  Active       1:25  9/20/2025 9:45 AM
[SUCCESS] Remote Session Management completed successfully

Operation completed.

[CONTINUE OPTIONS]
1. Return to main menu (perform another operation)
2. Exit IT-ToolBox

Select option (1 or 2): 1

Returning to main menu...
============================================================

[Menu displays again for next operation...]
```

## 🔧 Technical Features

### Remote Connectivity Testing
- **Ping Test**: Verifies basic network connectivity
- **WMI/RPC Test**: Ensures remote management capabilities
- **Error Handling**: Graceful failure with detailed error messages

### Service Management
- **Status Monitoring**: Real-time service status checking
- **Safe Restart Process**: Proper stop → wait → start sequence
- **Timeout Protection**: Prevents indefinite waiting
- **Verification**: Post-operation status confirmation

### Registry Operations
- **Remote Registry Access**: Secure connection to remote registry
- **Key Creation**: Automatic registry path creation if needed
- **Value Verification**: Confirms registry changes were applied
- **Error Recovery**: Comprehensive exception handling

### Disk Space Recovery Operations
- **MSP File Analysis**: Intelligent analysis of Windows Installer MSP files
- **Age-Based Targeting**: Focuses on files older than 7 days for safe cleanup
- **Progress Tracking**: Real-time progress updates during cleanup operations
- **Administrative Share Validation**: Ensures secure remote access before operations
- **Size Calculations**: Shows potential and actual space recovery metrics

## 🛡️ Safety Features

- **🔐 Confirmation Prompts**: Multiple user confirmations before execution
- **📡 Connectivity Validation**: Ensures target is accessible before operations
- **⏱️ Timeout Protection**: Prevents hanging operations
- **📝 Detailed Logging**: Comprehensive status reporting
- **🔄 Status Verification**: Before and after operation validation
- **❌ Graceful Failures**: Proper error handling and user notification

## 📈 Extensibility

The script is designed for easy expansion. To add new operations:

```powershell
# Add to the $availableServices array in the script:
,(New-Object PSObject -Property @{
    Name = "YourServiceName"           # Windows service name or custom ID
    DisplayName = "Your Display Name"  # User-friendly name
    Description = "What it does"       # Brief description  
    Type = "Service"                   # "Service", "Registry", or "Custom"
})
```

### Recent Major Enhancements (v5.1) **NEW!**
- **🔄 Continuous Operation Loop**: Perform multiple operations without restarting the script
- **👥 Enhanced Session Management**: Manual session selection with account lockout prevention
- **🛡️ Improved Error Handling**: Graceful handling of "No User exists" scenarios
- **🎛️ Better User Experience**: Continue/exit options after each operation with menu return

### Previous Major Enhancement (v4.0)
- **💾 Advanced MSP Cleanup**: Revolutionary disk space recovery feature
- **📊 Intelligent Analysis**: Smart file analysis with age and size reporting
- **⚡ Progress Tracking**: Real-time progress updates during operations
- **🛡️ Enhanced Safety**: Administrative share validation and user confirmations

### Future Enhancement Ideas
- **Additional Services**: DHCP, DNS, IIS, SQL Server services
- **Batch Operations**: Multiple computers at once
- **Advanced Disk Cleanup**: Additional file types and cleanup targets
- **Configuration Management**: Save/load computer lists
- **Logging System**: Detailed operation logs
- **Reporting**: HTML/CSV reports of operations
- **Remote File Operations**: File copy, deletion, permissions
- **System Information**: Hardware/software inventory
- **Health Checks**: System performance monitoring

## 🔍 Real-World Applications

### Help Desk Scenarios
- **Print Issues**: "Printer not responding" → Restart Print Spooler
- **Remote Access**: "Can't RDP to server" → Restart Remote Desktop Services  
- **Adobe Problems**: "Adobe keeps asking to sign in" → Apply registry fix
- **Disk Space Issues**: "Server running out of space" → Advanced MSP Cleanup (can recover 100+ GB)
- **Account Lockouts**: "User account keeps getting locked out" → Remote Session Management (cleanup stale sessions)
- **Session Issues**: "Need to disconnect a specific user" → Manual session selection and logoff

### System Administration
- **Maintenance Windows**: Quick service restarts during maintenance
- **Troubleshooting**: Rapid diagnosis and resolution of common issues
- **User Support**: Self-service tools for junior administrators

### Enterprise Environment
- **Standardized Procedures**: Consistent approach across all systems
- **Documentation**: Built-in operation tracking and confirmation
- **Safety**: Multiple safeguards prevent accidental system damage

## 📚 Documentation

- [**USAGE.md**](Documentation/USAGE.md) - Detailed usage instructions
- [**TROUBLESHOOTING.md**](Documentation/TROUBLESHOOTING.md) - Common issues and solutions
- [**CHANGELOG.md**](CHANGELOG.md) - Version history and updates
- [**Examples**](Examples/) - Real-world usage scenarios

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests for:
- New service operations
- Enhanced error handling
- Additional safety features
- Documentation improvements
- Bug fixes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Thinh Le** - System Network Administrator  
- LinkedIn: [Connect with me](https://linkedin.com/in/thinh-le)
- GitHub: [@mamamia0729](https://github.com/mamamia0729)
- Expertise: PowerShell Automation, Remote Management, IT Support Solutions

## 🏆 Key Achievements

- **🔄 Continuous Operation Loop**: Revolutionary workflow - perform multiple operations seamlessly
- **👥 Advanced Session Management**: Prevent account lockouts with intelligent session cleanup
- **🎛️ User-Friendly Design**: Enhanced interactive menu system for non-PowerShell experts
- **💾 Massive Disk Space Recovery**: Advanced MSP cleanup can recover 100+ GB per machine
- **🛡️ Production-Ready**: Comprehensive error handling, recovery options, and safety features
- **🔧 Extensible Architecture**: Easy to add new operations and services
- **📊 Professional Presentation**: Color-coded feedback and detailed status reporting
- **⚡ Efficient Operations**: Optimized remote management workflows without WinRM dependency
- **🚀 Continuous Innovation**: Regular feature updates based on real-world enterprise needs

---

⭐ **If this tool helped you, please give it a star!** ⭐

*"Your Complete IT Support Toolkit"* - Making remote system management efficient and safe.