# Installation Scripts Documentation

This document describes the professional installation scripts added to the Alesqui Intelligence Distribution repository.

## Overview

The installation system provides an automated, interactive experience for deploying Alesqui Intelligence. It includes:

1. **`install.sh`** - Main interactive installation script
2. **`quick-install.sh`** - One-liner entry point for remote installation
3. **`test-install.sh`** - Automated test suite for validation

## Features

### Main Installation Script (`install.sh`)

The main installation script provides:

#### ✅ System Checks
- Operating system detection (Linux, macOS)
- Docker version check (requires 20.10+)
- Docker Compose version check (requires 2.0+)
- Utility availability (curl, wget, openssl)

#### ✅ Interactive Configuration
- Deployment type selection (Atlas or Local)
- Guided .env configuration with:
  - Company name
  - MongoDB connection (Atlas URI or local credentials)
  - Automatic JWT_SECRET generation
  - OpenAI API key
  - Optional SMTP configuration
  - Admin email customization

#### ✅ Installation Process
- Automatic repository cloning (if curled)
- Docker image pulling with progress
- Service deployment
- Health check validation
- Success/error reporting

#### ✅ Error Handling
- Comprehensive error messages
- Installation logging to `/tmp/alesqui-install.log`
- Signal handling (SIGINT, SIGTERM)
- Graceful cleanup on interruption

#### ✅ Cross-Platform Support
- Works on Linux and macOS
- Automatic sed command adaptation
- Platform-specific installation instructions

### Quick Install Script (`quick-install.sh`)

Minimal entry point that:
- Downloads the main installer
- Executes it automatically
- Enables one-command installation

### Test Suite (`test-install.sh`)

Automated validation that checks:
- Script existence and permissions
- Bash syntax correctness
- Required functions presence
- Documentation updates
- Error handling implementation
- Logging functionality

## Usage

### Method 1: One-Command Installation

```bash
curl -fsSL https://raw.githubusercontent.com/eloisa-alesqui/alesqui-intelligence-distribution/main/install.sh | bash
```

### Method 2: Clone and Install

```bash
git clone https://github.com/eloisa-alesqui/alesqui-intelligence-distribution.git
cd alesqui-intelligence-distribution
./install.sh
```

### Method 3: Download and Install

```bash
curl -O https://raw.githubusercontent.com/eloisa-alesqui/alesqui-intelligence-distribution/main/install.sh
chmod +x install.sh
./install.sh
```

## Installation Flow

1. **Welcome & System Check**
   - Display ASCII art logo
   - Check Docker and dependencies
   - Detect operating system

2. **Deployment Selection**
   - Choose between Atlas or Local deployment
   - Display feature comparison

3. **Configuration**
   - Interactive prompts for all required settings
   - Automatic secret generation (recommended)
   - Optional SMTP setup

4. **Deployment**
   - Navigate to deployment directory
   - Create .env file with configurations
   - Pull Docker images
   - Start services

5. **Verification**
   - Wait for services to become healthy
   - Perform health checks
   - Display access information

6. **Completion**
   - Show admin credentials location
   - Provide next steps
   - Display management commands

## Configuration Options

### Atlas Deployment

The installer prompts for:
- **MongoDB Atlas URI** - Connection string from MongoDB Atlas
- **JWT Secret** - Auto-generated or manual entry
- **OpenAI API Key** - Required for AI features
- **Frontend URL** - Production domain (HTTPS recommended)
- **API URL** - Backend API endpoint
- **SMTP Settings** - Optional email configuration
- **Admin Email** - Optional custom admin email

### Local Deployment

The installer prompts for:
- **MongoDB Password** - Auto-generated or manual entry
- **JWT Secret** - Auto-generated or manual entry
- **OpenAI API Key** - Required for AI features
- **Frontend URL** - Typically http://localhost
- **SMTP Settings** - Optional email configuration
- **Admin Email** - Optional custom admin email

## Logging

All installation activities are logged to:
```
/tmp/alesqui-install.log
```

The log includes:
- Timestamp for each action
- System information
- Configuration steps
- Docker operations
- Errors and warnings

## Error Recovery

If installation fails:

1. **Check the log file:**
   ```bash
   cat /tmp/alesqui-install.log
   ```

2. **Verify prerequisites:**
   ```bash
   docker --version
   docker compose version
   ```

3. **Try manual installation:**
   Follow the detailed guides in:
   - `atlas/README.md` for Atlas deployment
   - `local/README.md` for Local deployment

4. **Check troubleshooting guide:**
   See `TROUBLESHOOTING.md` for common issues

## Testing

Run the test suite to validate the installation scripts:

```bash
./test-install.sh
```

This will verify:
- Script syntax
- Required functions
- Documentation updates
- Error handling
- All dependencies

## Technical Details

### Script Structure

```
install.sh
├── Configuration
│   ├── Colors and formatting
│   ├── Logging setup
│   └── Repository detection
├── Utility Functions
│   ├── Print functions (header, success, error)
│   ├── Logging functions
│   └── sed helper (cross-platform)
├── Dependency Checks
│   ├── OS detection
│   ├── Docker check
│   ├── Docker Compose check
│   └── Utility checks
├── Deployment Selection
│   └── Interactive menu
├── Environment Configuration
│   ├── Atlas configuration
│   └── Local configuration
├── Installation
│   ├── Image pulling
│   └── Service startup
├── Health Checks
│   └── Service validation
└── Completion
    └── Display results
```

### Security Features

- ✅ Passwords never echoed to console (read -s)
- ✅ Automatic strong secret generation
- ✅ HTTPS recommended for production
- ✅ Secure defaults for all settings
- ✅ No secrets stored in logs

### Best Practices

- ✅ Error handling with `set -e`
- ✅ Undefined variable protection with `set -u`
- ✅ Signal trapping for cleanup
- ✅ Comprehensive logging
- ✅ User-friendly error messages
- ✅ Progress indicators
- ✅ Cross-platform compatibility

## Maintenance

### Updating Installation Scripts

After modifying installation scripts:

1. **Test syntax:**
   ```bash
   bash -n install.sh
   ```

2. **Run test suite:**
   ```bash
   ./test-install.sh
   ```

3. **Test actual installation:**
   ```bash
   ./install.sh
   ```

4. **Update documentation:**
   - Update relevant README files
   - Update TROUBLESHOOTING.md if needed
   - Update this document

### Version History

- **v1.0.0** - Initial release
  - Interactive installation
  - Atlas and Local deployment support
  - Automatic secret generation
  - Health checks
  - Comprehensive documentation

## Support

For issues or questions:
- Check `TROUBLESHOOTING.md`
- Review installation logs at `/tmp/alesqui-install.log`
- GitHub Issues: https://github.com/eloisa-alesqui/alesqui-intelligence-distribution/issues
- Email: support@alesqui.com
