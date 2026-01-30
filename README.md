# BashExampleProject

## Overview

**BashExampleProject** is a comprehensive learning resource and reference implementation for Bash scripting. This project serves as a practical example demonstrating Bash programming concepts, standards, principles, and best practices through a real-world system health monitoring application.

## What is this project?

This is an educational Bash scripting project that contains:

1. **system_monitor.sh** - A fully-featured system health monitoring script that demonstrates advanced Bash concepts
2. **main.sh** - A simple "Hello World" starter script
3. **Documentation** - Comprehensive inline comments and external documentation explaining each concept

The project goes beyond basic "Hello World" examples to showcase production-grade Bash scripting patterns that you can use in real-world scenarios.

## What is it intended for?

This project is designed for:

- **Learning Bash** - Study well-documented, production-quality Bash code
- **Reference Material** - Quick lookup for Bash syntax and patterns
- **Best Practices** - See proper error handling, code organization, and documentation
- **Teaching Tool** - Use as a teaching resource for teams or students
- **Template** - Start your own Bash projects with proven patterns

### Target Audience

- Beginners wanting to learn Bash beyond basic tutorials
- Intermediate developers seeking best practices and advanced techniques
- System administrators building automation scripts
- DevOps engineers creating robust shell-based tooling
- Anyone looking for real-world Bash examples

## Key Features

The `system_monitor.sh` script demonstrates:

### Core Bash Concepts

1. **Strict Mode** - Error handling with `set -euo pipefail`
2. **Variables** - Constants, integers, local vs global scope
3. **Arrays** - Both indexed and associative arrays
4. **Functions** - Parameter passing, local variables, return values
5. **System Information** - CPU, memory, disk, and service monitoring
6. **Output Formats** - Text, JSON, and CSV output
7. **Signal Handling** - Graceful cleanup with `trap`
8. **Argument Parsing** - Using `getopts` for CLI options
9. **File I/O** - Reading configs, writing logs and reports
10. **Process Management** - Background jobs and service checks

### Advanced Features

- Configuration file support
- Logging with timestamps
- Report generation
- Continuous monitoring mode
- Colored output (with disable option)
- Multiple output formats (text/JSON/CSV)
- Input validation and error handling
- Comprehensive help documentation

## Getting Started

### Prerequisites

- Bash 4.0 or later (for associative arrays)
- Linux/Unix environment
- Basic command-line knowledge

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/hurstcorey/BashExampleProject.git
   cd BashExampleProject
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x main.sh system_monitor.sh
   ```

3. **Run the simple example:**
   ```bash
   ./main.sh
   ```

4. **Run the system monitor:**
   ```bash
   ./system_monitor.sh
   ```

## Usage Examples

### Basic System Check
```bash
./system_monitor.sh
```

### Verbose Output
```bash
./system_monitor.sh -v
```

### Continuous Monitoring
Monitor system health every 10 seconds:
```bash
./system_monitor.sh -c -i 10
```

### JSON Output
Get results in JSON format:
```bash
./system_monitor.sh -f json
```

### Generate Report
Create a detailed report file:
```bash
./system_monitor.sh -r
```

### Custom Thresholds
Set custom alert thresholds:
```bash
./system_monitor.sh -d 90 -m 85 -p 95
```

### View Help
See all available options:
```bash
./system_monitor.sh -h
```

## Project Structure

```
BashExampleProject/
├── main.sh              # Simple Hello World script
├── system_monitor.sh    # Comprehensive system monitoring script
├── replit.md           # Additional documentation
├── .gitignore          # Git ignore rules
├── README.md           # This file
└── (Generated files)
    ├── monitor.conf    # Configuration file (created on demand)
    ├── monitor.log     # Log file (created at runtime)
    └── report.txt      # Report file (created with -r flag)
```

## Learning Path

1. **Start with main.sh** - Understand basic script structure
2. **Read system_monitor.sh top-to-bottom** - Each section introduces new concepts
3. **Run with different options** - See how features work in practice
4. **Modify and experiment** - Change thresholds, add checks, customize output
5. **Reference the inline comments** - Every section is thoroughly documented

## Bash Concepts Coverage

The project covers these major Bash topics:

| Concept | Location | Description |
|---------|----------|-------------|
| Strict Mode | Section 1 | Error handling and safety |
| Variables & Constants | Section 2 | Scoping and declarations |
| Arrays | Section 3 | Indexed and associative |
| Functions | Section 4+ | Definitions and usage |
| File I/O | Throughout | Reading/writing files |
| Command Substitution | Throughout | Capturing command output |
| Process Substitution | Sections 5-6 | Advanced I/O redirection |
| Arithmetic | Sections 5-6 | Integer operations |
| String Manipulation | Throughout | Parameter expansion |
| Signal Handling | Section 9 | Cleanup and interrupts |
| Argument Parsing | Section 10 | getopts and validation |
| Loops | Throughout | for, while, until |
| Conditionals | Throughout | if, case statements |

## Contributing

This is an educational project. Feel free to:
- Report issues or suggest improvements
- Submit pull requests with additional examples
- Use this code in your own projects
- Share with others learning Bash

## License

This project is provided as-is for educational purposes. Feel free to use, modify, and distribute as needed.

## Additional Resources

- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck](https://www.shellcheck.net/) - For linting your scripts
- [Bash Guide](https://mywiki.wooledge.org/BashGuide) - Comprehensive Bash wiki

## Author

Created as a comprehensive Bash learning resource and reference implementation.

---

**Happy Bash Scripting! 🚀**
