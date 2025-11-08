# NixOS Configuration Build System

This repository now includes both a Makefile and a shell script (`build.sh`) to replace the individual scripts in the `bin/` directory. The build system provides better organization, dry-run capabilities, and cleaner output.

## Available Commands

### Core Commands

- **`switch`** - Commit changes, push to origin, and rebuild the NixOS system
- **`test`** - Build and run a NixOS VM for testing (qcow2 files stored in `vms/` directory)
- **`dry-run`** - Show what the switch command would do without executing
- **`dry-run-test`** - Show what the test command would do without executing
- **`clean`** - Remove build artifacts (result symlink, VM disk images)
- **`organize-vms`** - Move any existing qcow2 files to the `vms/` directory
- **`help`** - Show available commands

## Usage

### Using the Shell Script (recommended for systems without make)

```bash
# Show help
make help

# Switch system configuration with commit message
make switch "Update kernel to latest version"

# Test configuration in VM (uses current hostname by default)
make test

# Test configuration for specific host
make test dave

# Dry run to see what switch would do
make dry-run "Update kernel to latest version"

# Dry run to see what test would do
make dry-run-test

# Clean build artifacts
make clean
```

### Using Make (if available)

```bash
# Show help
make help

# Switch system configuration
make switch COMMIT_MSG="Update kernel to latest version"

# Test configuration in VM
make test

# Test with specific host
make test TARGET_HOST=dave

# Dry run
make dry-run COMMIT_MSG="Update kernel to latest version"

# Dry run for test
make dry-run-test

# Clean artifacts
make clean

# Example targets (with predefined messages)
make example-switch
make example-test
make example-dry-run
```

## Features

### Dry Run Mode
Both the Makefile and shell script include dry-run functionality that shows exactly what commands would be executed without actually running them. This is useful for:
- Verifying what changes will be made
- Testing the build process without side effects
- Learning what commands are executed

### Error Handling
- Validates that required parameters (like commit messages) are provided
- Uses proper exit codes for scripting integration
- Provides clear error messages with usage examples

### Colored Output
Both implementations use colored output to make it easier to distinguish between:
- Information messages (yellow)
- Success messages (green)
- Error messages (red)

### Host Detection
The test command automatically detects the current hostname but allows overriding with a specific target host.

## Migration from bin/ Scripts

The original `bin/switch` and `bin/test` scripts have been replaced with more robust implementations:

### New equivalent:
```bash
make switch "your commit message"
# or
make switch COMMIT_MSG="your commit message"
```

### Old `bin/test`:
```bash
TARGET_HOST_SETUP=$HOSTNAME
if [ $# -eq 1 ]; then
  TARGET_HOST_SETUP=$1
fi
if nixos-rebuild build-vm --show-trace --flake \#$TARGET_HOST_SETUP; then
  echo "Starting VM..."
  $(echo "./result/bin/run-${TARGET_HOST_SETUP}-vm")
else
  echo "Build failed. Skipping VM start."
fi
```

### New equivalent:
```bash
make test [hostname]
# or
make test [TARGET_HOST=hostname]
```

### VM Directory Commands

```bash
# Run VM test (automatically creates and uses vms/ directory)
make test TARGET_HOST=dave

# Clean all VM artifacts
make clean
```

The `test/` directory structure looks like:
```
test/
├── result/
├── dave.qcow2
├── kris.qcow2/
└── other-host.qcow2

```