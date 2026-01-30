# System Health Monitor - Bash Learning Reference

## Overview
A comprehensive Bash script that demonstrates all major Bash programming concepts, standards, principles, and best practices while serving as a functional system health monitoring tool.

## Project Structure
```
/
├── system_monitor.sh   # Main script with all Bash concepts demonstrated
├── monitor.conf        # Configuration file (created on demand)
├── monitor.log         # Log file (created at runtime)
├── report.txt          # Report file (created with -r flag)
└── replit.md           # Project documentation
```

## Bash Concepts Demonstrated

### Section 1: Strict Mode
- `set -euo pipefail` for error handling
- `IFS` configuration for word splitting

### Section 2: Variables
- Global vs local variables
- `readonly` for constants
- `declare -i` for integers

### Section 3: Arrays
- Indexed arrays (numeric indices)
- Associative arrays (`declare -A`)

### Section 4: Functions
- Function definitions with parameters
- Local variables inside functions
- Return values

### Section 5-6: System Checks
- Command substitution `$()`
- While-read loops
- Arithmetic expressions `(( ))`
- Process substitution `< <()`
- File I/O and parsing

### Section 7-8: Output Formatting
- JSON and CSV generation
- Report file creation
- Here-docs for multi-line strings

### Section 9: Signal Handling
- `trap` for cleanup on exit
- SIGINT and SIGTERM handling

### Section 10: Argument Parsing
- `getopts` for short options
- Long option conversion pattern
- Input validation

### Section 11-12: Main Execution
- Main function pattern
- Source vs execute detection

## Usage
```bash
# Basic run
./system_monitor.sh

# Verbose mode
./system_monitor.sh -v

# Continuous monitoring
./system_monitor.sh -c -i 10

# JSON output
./system_monitor.sh -f json

# Generate report
./system_monitor.sh -r

# Help
./system_monitor.sh -h
```

## Recent Changes
- 2026-01-30: Initial creation with full Bash concepts coverage
