# Changelog

All notable changes to the IT-ToolBox project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0] - 2025-09-23

### Added
- **🆕 Advanced MSP Cleanup Operation**: Revolutionary disk space recovery feature
- **📊 Intelligent File Analysis**: Smart analysis of Windows Installer MSP files with size and age reporting
- **⚡ Real-time Progress Tracking**: Progress updates every 25 files during cleanup operations
- **🛡️ Administrative Share Validation**: Secure remote access validation before operations
- **💾 Massive Space Recovery**: Potential to recover 100+ GB per machine from old MSP files
- **📋 Enhanced Interactive Menu**: Updated menu system with 4th operation option
- **📚 WARP.md Development Guide**: Comprehensive development guidance for enhanced collaboration

### Enhanced
- **🔧 Extended Architecture**: Custom operation type framework (Service/Registry/Custom)
- **🎛️ Improved Menu Instructions**: Clear guidance for 4 operation choices
- **📈 Enhanced Extensibility**: Framework supports custom operations beyond services and registry
- **🔍 Better Error Handling**: Enhanced error messages with actionable guidance
- **✅ User Confirmation Workflow**: Multiple confirmation steps for destructive operations
- **📊 Size Calculation Engine**: Before/after analysis with precise space recovery metrics

### Technical Improvements
- **Custom Operation Processing**: New execution path for custom operations like MSP cleanup
- **UNC Path Validation**: Robust administrative share access checking
- **Progress Reporting System**: Real-time feedback during long-running operations
- **Batch File Processing**: Efficient handling of large file sets with progress tracking
- **Memory Optimization**: Optimized for processing thousands of files without memory issues
- **Cross-Platform Compatibility**: Maintained PowerShell 5.1+ and Core compatibility

### User Experience
- **4-Operation Menu**: Expanded from 3 to 4 operations with clear descriptions
- **Progress Indicators**: Visual feedback during cleanup operations
- **Size Reporting**: Clear before/after space analysis
- **Enhanced Confirmations**: User-friendly confirmation dialogs with space impact info
- **Better Instructions**: Updated menu instructions to include all 4 operations

### Documentation
- **WARP.md Guide**: Comprehensive development and collaboration guide
- **Updated README**: Reflects new capabilities and usage examples
- **Enhanced Examples**: Real-world usage scenarios for disk space recovery
- **Technical Architecture**: Detailed extension patterns and customization guides

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