# IT-ToolBox 🧰

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)](https://www.microsoft.com/en-us/windows)
[![Version](https://img.shields.io/badge/Version-3.2-orange)](CHANGELOG.md)

> **Interactive Remote Management Utility** - Your complete IT support toolkit for managing Windows services and applying fixes on remote computers.

## 🚀 Overview

IT-ToolBox is a professional interactive PowerShell script designed for system administrators and IT support teams. It provides a user-friendly menu-driven interface for performing common remote management tasks with built-in safety features and comprehensive error handling.

### 🎯 Key Features

- **🎛️ Interactive Menu System**: User-friendly selection interface
- **🔌 Remote Connectivity Testing**: Automatic ping and WMI/RPC validation
- **📊 Service Status Monitoring**: Before and after operation status checks
- **🔧 Service Management**: Reliable remote service restart capabilities
- **🗂️ Registry Operations**: Safe remote registry modifications
- **⚡ Real-time Feedback**: Color-coded status messages and progress indicators
- **🛡️ Safety First**: Multiple confirmation steps and error handling
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

### 📋 Interactive Workflow

The script follows a simple 5-step process:

1. **🎛️ Operation Selection**: Choose from available operations via interactive menu
2. **🖥️ Target Specification**: Enter computer name or IP address
3. **✅ Confirmation**: Confirm operation before execution
4. **🔌 Connectivity Test**: Automatic connectivity validation
5. **⚡ Execution**: Perform selected operation with real-time feedback

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

Options:
Q. Quit

Select operation to perform (1, 2, 3, or Q to quit): 1

Selected operation:
  - Print Spooler (Spooler)

Step 2: Specify target computer
Enter the target computer name or IP address: PC001

Target Computer: PC001

Step 3: Final confirmation
Proceed with 'Print Spooler' on 'PC001'? (Y/N): Y

Step 4: Testing connectivity
Testing connectivity to PC001...
[OK] Ping successful
[OK] WMI/RPC connectivity successful

Step 5: Executing operations

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

==================================================
Final Status Check:

Service Status on PC001:
==================================================
[RUNNING] Print Spooler (Spooler)

Script completed.
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

### Future Enhancement Ideas
- **Additional Services**: DHCP, DNS, IIS, SQL Server services
- **Batch Operations**: Multiple computers at once
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

- **🎛️ User-Friendly Design**: Interactive menu system for non-PowerShell experts
- **🛡️ Production-Ready**: Comprehensive error handling and safety features
- **🔧 Extensible Architecture**: Easy to add new operations and services
- **📊 Professional Presentation**: Color-coded feedback and detailed status reporting
- **⚡ Efficient Operations**: Optimized remote management workflows

---

⭐ **If this tool helped you, please give it a star!** ⭐

*"Your Complete IT Support Toolkit"* - Making remote system management efficient and safe.