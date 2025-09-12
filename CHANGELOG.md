# Changelog

All notable changes to the IT-ToolBox project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.2.0] - 2025-01-12

### Added
- **Interactive Menu System**: Professional operation selection interface
- **Remote Connectivity Testing**: Automatic ping and WMI/RPC validation
- **Service Status Monitoring**: Before and after operation status checks
- **Registry Operations**: Safe remote registry modifications for Adobe fixes
- **Multi-step Workflow**: Organized 5-step process for all operations
- **Extensible Architecture**: Easy framework for adding new operations

### Features
- **Print Spooler Management**: Restart Spooler service on remote computers
- **Remote Desktop Services**: Restart TermService for RDP issues
- **Adobe Acrobat DC Fix**: Registry modification to stop sign-in prompts
- **Real-time Feedback**: Color-coded status messages and progress indicators
- **Safety Confirmations**: Multiple user confirmations before execution
- **Comprehensive Error Handling**: Graceful failure handling with detailed messages

### Technical Improvements
- **PowerShell 5.1+ Compatibility**: Cross-platform PowerShell support
- **WMI Integration**: Reliable remote service status checking
- **SC Command Integration**: Robust service control operations
- **Remote Registry Access**: Secure remote registry key creation and modification
- **Timeout Protection**: Prevents hanging operations with configurable timeouts
- **Status Verification**: Post-operation validation of changes

### User Experience
- **Step-by-Step Guidance**: Clear workflow with numbered steps
- **Operation Previews**: Shows selected operations before execution
- **Progress Indicators**: Real-time status updates during operations
- **Error Recovery**: Helpful error messages with suggested solutions
- **Input Validation**: Robust handling of user input and edge cases

### Documentation
- **Comprehensive README**: Professional project presentation
- **Usage Examples**: Real-world scenarios and step-by-step guides
- **Technical Documentation**: Detailed feature explanations
- **Future Enhancement Roadmap**: Planned features and improvements

## [Unreleased]

### Planned Features
- **Batch Operations**: Multiple computer support
- **Additional Services**: DHCP, DNS, IIS, SQL Server management
- **Configuration Management**: Save/load computer lists and preferences
- **Enhanced Logging**: Detailed operation logs with timestamps
- **Reporting System**: HTML/CSV reports of operations performed
- **Health Check Operations**: System performance and status monitoring
- **Custom Operation Framework**: User-defined operations and scripts

### Planned Improvements
- **GUI Version**: Windows Forms or WPF interface option
- **Configuration File**: External configuration for default settings
- **Credential Management**: Secure credential storage and management
- **Scheduling Integration**: Task Scheduler integration for automated operations
- **Network Discovery**: Automatic computer discovery on network
- **Permission Validation**: Pre-flight permission checking

## Release Notes

### Version 3.2.0 Highlights

This initial GitHub release represents a mature, production-ready interactive PowerShell tool that has been refined through real-world IT support scenarios.

**Key Achievements**:
- **User-Friendly Design**: Non-technical users can easily perform complex remote operations
- **Production-Ready Stability**: Comprehensive error handling and safety features
- **Extensible Framework**: Easy to add new services and operations
- **Professional Presentation**: Clean interface with color-coded feedback

**Target Audience**:
- IT Support Teams
- System Administrators  
- Help Desk Technicians
- PowerShell Enthusiasts
- Network Administrators

**Use Cases**:
- Daily IT support operations
- Remote troubleshooting
- Service maintenance tasks
- Standardized repair procedures
- Training tool for junior administrators

### Technical Architecture

The script follows a modular design pattern:
- **Main Controller**: Handles workflow orchestration
- **Connectivity Module**: Network and remote access validation
- **Service Manager**: Windows service control operations
- **Registry Manager**: Safe remote registry modifications
- **UI Manager**: Interactive menu and user feedback systems
- **Error Handler**: Comprehensive exception management

This architecture enables easy extension and maintenance while maintaining code quality and reliability.