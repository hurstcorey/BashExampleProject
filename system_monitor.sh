#!/bin/bash
#
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    SYSTEM HEALTH MONITOR                                  ║
# ║  A comprehensive Bash script demonstrating concepts, standards,           ║
# ║  principles, and best practices                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Author: Bash Learning Reference
# Description: Monitors system health (disk, memory, CPU, services)
#              while demonstrating Bash programming concepts
#
# Usage: ./system_monitor.sh [OPTIONS]
#        Run with -h for help
#

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 1: STRICT MODE AND SHELL OPTIONS
# ═══════════════════════════════════════════════════════════════════════════════
# Best Practice: Always use strict mode to catch errors early
#
# -e: Exit immediately if a command exits with non-zero status
# -u: Treat unset variables as an error
# -o pipefail: Return value of a pipeline is the status of the last command
#              to exit with a non-zero status, or zero if all exited successfully

set -euo pipefail

# Best Practice: Set IFS (Internal Field Separator) explicitly
# This prevents word splitting issues with spaces in filenames
IFS=$'\n\t'

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 2: GLOBAL VARIABLES AND CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════
# Best Practice: Use UPPERCASE for constants and exported variables
# Best Practice: Use readonly for constants that should never change

readonly SCRIPT_NAME="${0##*/}"                    # Parameter expansion: get basename
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"  # Get script directory
readonly SCRIPT_VERSION="1.0.0"
readonly CONFIG_FILE="${SCRIPT_DIR}/monitor.conf"
readonly LOG_FILE="${SCRIPT_DIR}/monitor.log"
readonly REPORT_FILE="${SCRIPT_DIR}/report.txt"

# Default threshold values (can be overridden by config or CLI)
declare -i DISK_THRESHOLD=80        # -i declares integer
declare -i MEMORY_THRESHOLD=80
declare -i CPU_THRESHOLD=90
declare -i CHECK_INTERVAL=5

# Runtime options (lowercase for non-constants)
verbose=false
colorize=true
output_format="text"                # text, json, or csv
generate_report=false
continuous_mode=false

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 3: ARRAYS - INDEXED AND ASSOCIATIVE
# ═══════════════════════════════════════════════════════════════════════════════
# Bash supports two types of arrays:
# 1. Indexed arrays: Elements accessed by numeric index (0, 1, 2...)
# 2. Associative arrays: Elements accessed by string keys (requires declare -A)

# Indexed array of services to monitor
declare -a SERVICES_TO_MONITOR=(
    "sshd"
    "cron"
)

# Associative array for storing check results
# Best Practice: Always declare -A before using associative arrays
declare -A check_results
declare -A alert_counts

# Associative array for color codes
declare -A COLORS=(
    [reset]='\033[0m'
    [red]='\033[0;31m'
    [green]='\033[0;32m'
    [yellow]='\033[0;33m'
    [blue]='\033[0;34m'
    [magenta]='\033[0;35m'
    [cyan]='\033[0;36m'
    [bold]='\033[1m'
)

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 4: FUNCTIONS - HELPER UTILITIES
# ═══════════════════════════════════════════════════════════════════════════════
# Best Practice: Define functions before they're called
# Best Practice: Use local variables inside functions to avoid side effects
# Best Practice: Document function purpose and parameters

# Function: print_color
# Description: Print colored text if colorize is enabled
# Parameters: $1 = color name, $2 = text to print
# Returns: None
print_color() {
    local color="${1:-reset}"
    local text="${2:-}"
    
    if [[ "$colorize" == true ]] && [[ -t 1 ]]; then
        # -t 1 checks if stdout is a terminal (not piped/redirected)
        echo -e "${COLORS[$color]}${text}${COLORS[reset]}"
    else
        echo "$text"
    fi
}

# Function: log_message
# Description: Log messages with timestamp and severity level
# Parameters: $1 = level (INFO, WARN, ERROR, DEBUG), $2 = message
# Returns: None
# Demonstrates: Command substitution, conditional logic, file redirection
log_message() {
    local level="${1:-INFO}"
    local message="${2:-}"
    local timestamp
    
    # Command substitution: $(command) captures command output
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    local log_entry="[${timestamp}] [${level}] ${message}"
    
    # Always write to log file (append mode)
    echo "$log_entry" >> "$LOG_FILE"
    
    # Print to console based on verbosity and level
    case "$level" in
        ERROR)
            print_color red "$log_entry" >&2   # Redirect errors to stderr
            ;;
        WARN)
            print_color yellow "$log_entry"
            ;;
        INFO)
            if [[ "$verbose" == true ]]; then
                print_color cyan "$log_entry"
            fi
            ;;
        DEBUG)
            if [[ "$verbose" == true ]]; then
                print_color magenta "$log_entry"
            fi
            ;;
        *)
            echo "$log_entry"
            ;;
    esac
}

# Function: show_usage
# Description: Display help message and usage information
# Parameters: None
# Returns: Exits with code 0
# Demonstrates: Here-doc (heredoc) for multi-line strings
show_usage() {
    # Here-doc: <<EOF allows multi-line strings
    # Using <<- allows indentation with tabs (not spaces)
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════╗
║                    SYSTEM HEALTH MONITOR - HELP                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

USAGE:
    ./system_monitor.sh [OPTIONS]

DESCRIPTION:
    Monitors system health including disk usage, memory, CPU load, and services.
    This script also serves as a comprehensive Bash learning reference.

OPTIONS:
    -h, --help          Show this help message and exit
    -v, --verbose       Enable verbose output (show DEBUG and INFO messages)
    -V, --version       Show version information
    -n, --no-color      Disable colored output
    -c, --continuous    Run continuously (every N seconds)
    -i, --interval N    Set check interval to N seconds (default: 5)
    -r, --report        Generate a detailed report file
    -f, --format FMT    Output format: text, json, csv (default: text)
    -d, --disk N        Set disk usage threshold to N% (default: 80)
    -m, --memory N      Set memory usage threshold to N% (default: 80)
    -p, --cpu N         Set CPU usage threshold to N% (default: 90)
    -s, --service SVC   Add a service to monitor (can be used multiple times)

EXAMPLES:
    ./system_monitor.sh                     # Run once with defaults
    ./system_monitor.sh -v                  # Verbose mode
    ./system_monitor.sh -c -i 10            # Continuous mode, 10s interval
    ./system_monitor.sh -d 90 -m 85         # Custom thresholds
    ./system_monitor.sh -f json             # JSON output
    ./system_monitor.sh -s nginx -s mysql   # Monitor specific services

EXIT CODES:
    0   All checks passed
    1   One or more warnings
    2   One or more critical alerts
    3   Script error or invalid usage

EOF
    exit 0
}

# Function: show_version
# Description: Display version information
show_version() {
    echo "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
    echo "Bash version: ${BASH_VERSION}"
    exit 0
}

# Function: print_header
# Description: Print a formatted section header
# Parameters: $1 = header text
print_header() {
    local text="${1:-}"
    local width=60
    local padding=$(( (width - ${#text}) / 2 ))
    
    echo
    print_color bold "$(printf '═%.0s' $(seq 1 $width))"
    print_color bold "$(printf '%*s%s%*s' $padding '' "$text" $padding '')"
    print_color bold "$(printf '═%.0s' $(seq 1 $width))"
}

# Function: print_status
# Description: Print a status line with OK/WARN/CRIT indicator
# Parameters: $1 = label, $2 = value, $3 = status (ok/warn/crit)
print_status() {
    local label="${1:-}"
    local value="${2:-}"
    local status="${3:-ok}"
    local indicator
    
    case "$status" in
        ok)   indicator="[$(print_color green ' OK ')]" ;;
        warn) indicator="[$(print_color yellow 'WARN')]" ;;
        crit) indicator="[$(print_color red 'CRIT')]" ;;
        *)    indicator="[    ]" ;;
    esac
    
    printf "  %-25s %s %s\n" "$label" "$indicator" "$value"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 5: SYSTEM CHECK FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════
# These functions demonstrate various Bash concepts while performing actual
# system health checks

# Function: check_disk_usage
# Description: Check disk usage for all mounted filesystems
# Demonstrates: Command substitution, while-read loop, arithmetic, arrays
check_disk_usage() {
    log_message "DEBUG" "Checking disk usage..."
    print_header "DISK USAGE"
    
    local has_warning=false
    local has_critical=false
    
    # Process df output line by line using awk for reliable parsing
    # df -h output columns: Filesystem, Size, Used, Avail, Use%, Mounted on
    while IFS='|' read -r filesystem size used avail percent mountpoint; do
        # Skip if any field is empty
        [[ -z "$percent" || -z "$mountpoint" ]] && continue
        
        # Remove % sign and convert to integer
        # Parameter expansion: ${var%pattern} removes suffix
        local usage_int=${percent%\%}
        
        # Skip if not a valid number
        [[ ! "$usage_int" =~ ^[0-9]+$ ]] && continue
        
        # Determine status based on threshold
        local status="ok"
        if (( usage_int >= DISK_THRESHOLD )); then
            if (( usage_int >= 95 )); then
                status="crit"
                has_critical=true
                log_message "ERROR" "Critical: ${mountpoint} at ${percent} usage"
            else
                status="warn"
                has_warning=true
                log_message "WARN" "Warning: ${mountpoint} at ${percent} usage"
            fi
        fi
        
        # Store result in associative array
        check_results["disk_${mountpoint}"]="${percent}"
        
        print_status "$mountpoint" "${used}/${size} (${percent})" "$status"
        
    done < <(df -h 2>/dev/null | awk 'NR>1 && /^\// {print $1"|"$2"|"$3"|"$4"|"$5"|"$6}')
    
    # Return appropriate exit code (for function return value)
    if [[ "$has_critical" == true ]]; then
        return 2
    elif [[ "$has_warning" == true ]]; then
        return 1
    fi
    return 0
}

# Function: check_memory_usage
# Description: Check RAM and swap usage
# Demonstrates: Process substitution, arithmetic expressions, bc for floats
check_memory_usage() {
    log_message "DEBUG" "Checking memory usage..."
    print_header "MEMORY USAGE"
    
    local has_warning=false
    local has_critical=false
    
    # Read memory info from /proc/meminfo
    # Demonstrates: Reading specific values from a file
    local mem_total mem_available mem_free buffers cached
    
    while IFS=: read -r key value; do
        # Remove leading/trailing whitespace and 'kB' suffix
        value=$(echo "$value" | tr -d ' kB')
        case "$key" in
            MemTotal)     mem_total=$value ;;
            MemAvailable) mem_available=$value ;;
            MemFree)      mem_free=$value ;;
            Buffers)      buffers=$value ;;
            Cached)       cached=$value ;;
        esac
    done < /proc/meminfo
    
    # Calculate usage percentage
    # Bash only does integer math; use bc for floating point
    local mem_used=$((mem_total - mem_available))
    local mem_percent
    
    # Using bc for floating point calculation
    if command -v bc &>/dev/null; then
        mem_percent=$(echo "scale=1; $mem_used * 100 / $mem_total" | bc)
    else
        # Fallback to integer math
        mem_percent=$((mem_used * 100 / mem_total))
    fi
    
    # Remove decimal for comparison
    local mem_percent_int=${mem_percent%.*}
    
    local status="ok"
    if (( mem_percent_int >= MEMORY_THRESHOLD )); then
        if (( mem_percent_int >= 95 )); then
            status="crit"
            has_critical=true
            log_message "ERROR" "Critical: Memory at ${mem_percent}%"
        else
            status="warn"
            has_warning=true
            log_message "WARN" "Warning: Memory at ${mem_percent}%"
        fi
    fi
    
    # Convert to human-readable format
    local mem_total_gb mem_used_gb
    mem_total_gb=$(echo "scale=2; $mem_total / 1024 / 1024" | bc 2>/dev/null || echo "$((mem_total / 1024 / 1024))")
    mem_used_gb=$(echo "scale=2; $mem_used / 1024 / 1024" | bc 2>/dev/null || echo "$((mem_used / 1024 / 1024))")
    
    check_results["memory_percent"]="${mem_percent}%"
    print_status "RAM Usage" "${mem_used_gb}GB / ${mem_total_gb}GB (${mem_percent}%)" "$status"
    
    # Check swap if available
    local swap_total swap_free
    swap_total=$(grep -E '^SwapTotal:' /proc/meminfo | awk '{print $2}')
    swap_free=$(grep -E '^SwapFree:' /proc/meminfo | awk '{print $2}')
    
    if (( swap_total > 0 )); then
        local swap_used=$((swap_total - swap_free))
        local swap_percent=$((swap_used * 100 / swap_total))
        local swap_status="ok"
        
        if (( swap_percent >= 80 )); then
            swap_status="warn"
        fi
        
        check_results["swap_percent"]="${swap_percent}%"
        print_status "Swap Usage" "${swap_percent}%" "$swap_status"
    else
        print_status "Swap" "Not configured" "ok"
    fi
    
    if [[ "$has_critical" == true ]]; then
        return 2
    elif [[ "$has_warning" == true ]]; then
        return 1
    fi
    return 0
}

# Function: check_cpu_usage
# Description: Check CPU load average and usage
# Demonstrates: Reading /proc files, arithmetic with decimals, process handling
check_cpu_usage() {
    log_message "DEBUG" "Checking CPU usage..."
    print_header "CPU STATUS"
    
    local has_warning=false
    local has_critical=false
    
    # Get number of CPU cores
    local cpu_cores
    cpu_cores=$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo)
    
    # Read load averages from /proc/loadavg
    # Format: 1min 5min 15min running/total last_pid
    # Note: We need to reset IFS temporarily because we set IFS=$'\n\t' at script start
    local load_1 load_5 load_15 running_procs
    IFS=' ' read -r load_1 load_5 load_15 running_procs _ < /proc/loadavg
    
    # Calculate load percentage relative to cores
    # Load of 1.0 per core = 100% utilized
    # Note: Bash doesn't support float arithmetic, so we use bc or awk
    local load_percent
    if command -v bc &>/dev/null; then
        load_percent=$(echo "scale=0; $load_1 * 100 / $cpu_cores" | bc 2>/dev/null || echo "0")
    else
        # Fallback: use awk for float arithmetic (note: 'load' is reserved, use 'loadval')
        load_percent=$(awk -v loadval="$load_1" -v cores="$cpu_cores" 'BEGIN {printf "%d", loadval * 100 / cores}')
    fi
    
    local status="ok"
    if (( load_percent >= CPU_THRESHOLD )); then
        if (( load_percent >= 100 )); then
            status="crit"
            has_critical=true
            log_message "ERROR" "Critical: CPU load at ${load_percent}%"
        else
            status="warn"
            has_warning=true
            log_message "WARN" "Warning: CPU load at ${load_percent}%"
        fi
    fi
    
    check_results["cpu_load"]="$load_1"
    print_status "CPU Cores" "$cpu_cores" "ok"
    print_status "Load Average (1m)" "$load_1" "$status"
    print_status "Load Average (5m)" "$load_5" "ok"
    print_status "Load Average (15m)" "$load_15" "ok"
    print_status "Running Processes" "$running_procs" "ok"
    
    # Get top CPU-consuming processes
    if [[ "$verbose" == true ]]; then
        echo
        print_color cyan "  Top 5 CPU consumers:"
        ps aux --sort=-%cpu 2>/dev/null | head -6 | tail -5 | while read -r line; do
            echo "    $line"
        done
    fi
    
    if [[ "$has_critical" == true ]]; then
        return 2
    elif [[ "$has_warning" == true ]]; then
        return 1
    fi
    return 0
}

# Function: check_services
# Description: Check if specified services are running
# Demonstrates: Arrays, loops, command existence checking
check_services() {
    log_message "DEBUG" "Checking services..."
    print_header "SERVICES"
    
    local has_warning=false
    
    # Check if we have any services to monitor
    if (( ${#SERVICES_TO_MONITOR[@]} == 0 )); then
        print_color cyan "  No services configured to monitor"
        return 0
    fi
    
    # Iterate over indexed array
    for service in "${SERVICES_TO_MONITOR[@]}"; do
        local status="ok"
        local state="running"
        
        # Check if service is running using pgrep
        if pgrep -x "$service" &>/dev/null; then
            state="running"
            log_message "DEBUG" "Service $service is running"
        elif systemctl is-active --quiet "$service" 2>/dev/null; then
            state="running (systemd)"
            log_message "DEBUG" "Service $service is running (via systemd)"
        else
            state="stopped"
            status="warn"
            has_warning=true
            log_message "WARN" "Service $service is not running"
        fi
        
        check_results["service_${service}"]="$state"
        print_status "$service" "$state" "$status"
    done
    
    if [[ "$has_warning" == true ]]; then
        return 1
    fi
    return 0
}

# Function: check_uptime
# Description: Display system uptime information
# Demonstrates: Command substitution, date formatting
check_uptime() {
    print_header "SYSTEM INFO"
    
    # Get uptime in human-readable format
    local uptime_str
    uptime_str=$(uptime -p 2>/dev/null || uptime)
    
    # Get boot time
    local boot_time
    boot_time=$(who -b 2>/dev/null | awk '{print $3, $4}' || echo "unknown")
    
    # Get hostname
    local hostname
    hostname=$(hostname -f 2>/dev/null || hostname)
    
    # Get kernel version
    local kernel
    kernel=$(uname -r)
    
    print_status "Hostname" "$hostname" "ok"
    print_status "Kernel" "$kernel" "ok"
    print_status "Uptime" "$uptime_str" "ok"
    print_status "Boot Time" "$boot_time" "ok"
    print_status "Current Time" "$(date '+%Y-%m-%d %H:%M:%S')" "ok"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 6: CONFIGURATION FILE HANDLING
# ═══════════════════════════════════════════════════════════════════════════════
# Demonstrates: File existence checks, sourcing files, safe parsing

# Function: load_config
# Description: Load configuration from file if it exists
load_config() {
    log_message "DEBUG" "Looking for config file: $CONFIG_FILE"
    
    # Check if config file exists and is readable
    # -f checks if it's a regular file
    # -r checks if it's readable
    if [[ -f "$CONFIG_FILE" && -r "$CONFIG_FILE" ]]; then
        log_message "INFO" "Loading configuration from $CONFIG_FILE"
        
        # Safe config parsing - don't source directly (security risk!)
        # Instead, parse known keys
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
            
            # Remove leading/trailing whitespace
            key=$(echo "$key" | tr -d ' ')
            value=$(echo "$value" | tr -d ' "'"'"'')
            
            case "$key" in
                DISK_THRESHOLD)    DISK_THRESHOLD=$value ;;
                MEMORY_THRESHOLD)  MEMORY_THRESHOLD=$value ;;
                CPU_THRESHOLD)     CPU_THRESHOLD=$value ;;
                CHECK_INTERVAL)    CHECK_INTERVAL=$value ;;
                VERBOSE)           [[ "$value" == "true" ]] && verbose=true ;;
                COLORIZE)          [[ "$value" == "false" ]] && colorize=false ;;
            esac
        done < "$CONFIG_FILE"
    else
        log_message "DEBUG" "No config file found, using defaults"
    fi
}

# Function: create_sample_config
# Description: Create a sample configuration file
create_sample_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat > "$CONFIG_FILE" << 'EOF'
# System Monitor Configuration File
# Uncomment and modify values as needed

# Threshold values (percentage)
DISK_THRESHOLD=80
MEMORY_THRESHOLD=80
CPU_THRESHOLD=90

# Check interval in seconds (for continuous mode)
CHECK_INTERVAL=5

# Output options
VERBOSE=false
COLORIZE=true
EOF
        log_message "INFO" "Created sample config file: $CONFIG_FILE"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 7: OUTPUT FORMATTING (JSON/CSV)
# ═══════════════════════════════════════════════════════════════════════════════
# Demonstrates: Different output formats, string building, data serialization

# Function: output_json
# Description: Output results in JSON format
output_json() {
    local timestamp
    timestamp=$(date -Iseconds)
    
    echo "{"
    echo "  \"timestamp\": \"$timestamp\","
    echo "  \"hostname\": \"$(hostname)\","
    echo "  \"results\": {"
    
    local first=true
    for key in "${!check_results[@]}"; do
        if [[ "$first" == true ]]; then
            first=false
        else
            echo ","
        fi
        printf '    "%s": "%s"' "$key" "${check_results[$key]}"
    done
    
    echo
    echo "  }"
    echo "}"
}

# Function: output_csv
# Description: Output results in CSV format
output_csv() {
    local timestamp
    timestamp=$(date -Iseconds)
    
    # Header
    echo "timestamp,metric,value"
    
    # Data rows
    for key in "${!check_results[@]}"; do
        echo "${timestamp},${key},${check_results[$key]}"
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 8: REPORT GENERATION
# ═══════════════════════════════════════════════════════════════════════════════

# Function: generate_report
# Description: Generate a detailed text report file
generate_report() {
    log_message "INFO" "Generating report: $REPORT_FILE"
    
    {
        echo "═══════════════════════════════════════════════════════════════════"
        echo "              SYSTEM HEALTH REPORT"
        echo "              Generated: $(date)"
        echo "═══════════════════════════════════════════════════════════════════"
        echo
        echo "HOSTNAME: $(hostname)"
        echo "KERNEL:   $(uname -r)"
        echo
        echo "THRESHOLDS:"
        echo "  Disk:   ${DISK_THRESHOLD}%"
        echo "  Memory: ${MEMORY_THRESHOLD}%"
        echo "  CPU:    ${CPU_THRESHOLD}%"
        echo
        echo "───────────────────────────────────────────────────────────────────"
        echo "CHECK RESULTS:"
        echo "───────────────────────────────────────────────────────────────────"
        
        for key in "${!check_results[@]}"; do
            printf "  %-30s %s\n" "$key:" "${check_results[$key]}"
        done
        
        echo
        echo "═══════════════════════════════════════════════════════════════════"
        echo "                    END OF REPORT"
        echo "═══════════════════════════════════════════════════════════════════"
    } > "$REPORT_FILE"
    
    print_color green "Report saved to: $REPORT_FILE"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 9: SIGNAL HANDLING AND CLEANUP
# ═══════════════════════════════════════════════════════════════════════════════
# Demonstrates: trap command, signal handling, cleanup procedures
# Best Practice: Always clean up on exit

# Function: cleanup
# Description: Cleanup function called on script exit
cleanup() {
    local exit_code=$?
    log_message "DEBUG" "Cleaning up (exit code: $exit_code)"
    
    # Add any cleanup tasks here
    # For example: remove temp files, release locks, etc.
    
    exit $exit_code
}

# Function: handle_interrupt
# Description: Handle Ctrl+C (SIGINT) gracefully
handle_interrupt() {
    echo  # New line after ^C
    print_color yellow "Interrupted by user. Exiting..."
    log_message "INFO" "Script interrupted by user"
    exit 130  # Standard exit code for SIGINT
}

# Function: handle_term
# Description: Handle SIGTERM signal
handle_term() {
    print_color yellow "Received termination signal. Exiting..."
    log_message "INFO" "Script terminated by signal"
    exit 143  # Standard exit code for SIGTERM
}

# Set up signal traps
# trap 'command' SIGNAL
trap cleanup EXIT          # Run cleanup on exit
trap handle_interrupt INT  # Handle Ctrl+C
trap handle_term TERM      # Handle kill command

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 10: ARGUMENT PARSING WITH GETOPTS
# ═══════════════════════════════════════════════════════════════════════════════
# Demonstrates: getopts for short options, manual parsing for long options
# Best Practice: Always provide help and version options

# Function: parse_arguments
# Description: Parse command line arguments
# Demonstrates: getopts, case statements, shift for argument processing
parse_arguments() {
    # Handle long options by converting them to short options
    # This is a common pattern in Bash scripts
    local args=()
    while (( $# > 0 )); do
        case "$1" in
            --help)       args+=(-h) ;;
            --verbose)    args+=(-v) ;;
            --version)    args+=(-V) ;;
            --no-color)   args+=(-n) ;;
            --continuous) args+=(-c) ;;
            --interval)   args+=(-i "$2"); shift ;;
            --report)     args+=(-r) ;;
            --format)     args+=(-f "$2"); shift ;;
            --disk)       args+=(-d "$2"); shift ;;
            --memory)     args+=(-m "$2"); shift ;;
            --cpu)        args+=(-p "$2"); shift ;;
            --service)    args+=(-s "$2"); shift ;;
            --config)     args+=(-C) ;;
            -*)           args+=("$1") ;;
            *)            args+=("$1") ;;
        esac
        shift
    done
    
    # Reset positional parameters
    set -- "${args[@]}"
    
    # getopts loop
    # The colon after a letter means it requires an argument
    while getopts ":hvVncri:f:d:m:p:s:C" opt; do
        case "$opt" in
            h)  show_usage ;;
            v)  verbose=true ;;
            V)  show_version ;;
            n)  colorize=false ;;
            c)  continuous_mode=true ;;
            r)  generate_report=true ;;
            C)  create_sample_config; exit 0 ;;
            i)  
                # Validate interval is a positive integer
                if [[ "$OPTARG" =~ ^[0-9]+$ ]] && (( OPTARG > 0 )); then
                    CHECK_INTERVAL=$OPTARG
                else
                    print_color red "Error: Interval must be a positive integer"
                    exit 3
                fi
                ;;
            f)
                # Validate output format
                case "$OPTARG" in
                    text|json|csv) output_format="$OPTARG" ;;
                    *)
                        print_color red "Error: Invalid format '$OPTARG'. Use text, json, or csv"
                        exit 3
                        ;;
                esac
                ;;
            d)
                if [[ "$OPTARG" =~ ^[0-9]+$ ]] && (( OPTARG >= 0 && OPTARG <= 100 )); then
                    DISK_THRESHOLD=$OPTARG
                else
                    print_color red "Error: Disk threshold must be 0-100"
                    exit 3
                fi
                ;;
            m)
                if [[ "$OPTARG" =~ ^[0-9]+$ ]] && (( OPTARG >= 0 && OPTARG <= 100 )); then
                    MEMORY_THRESHOLD=$OPTARG
                else
                    print_color red "Error: Memory threshold must be 0-100"
                    exit 3
                fi
                ;;
            p)
                if [[ "$OPTARG" =~ ^[0-9]+$ ]] && (( OPTARG >= 0 )); then
                    CPU_THRESHOLD=$OPTARG
                else
                    print_color red "Error: CPU threshold must be a positive integer"
                    exit 3
                fi
                ;;
            s)
                # Add service to monitor
                SERVICES_TO_MONITOR+=("$OPTARG")
                ;;
            :)
                print_color red "Error: Option -$OPTARG requires an argument"
                exit 3
                ;;
            \?)
                print_color red "Error: Invalid option -$OPTARG"
                echo "Use -h for help"
                exit 3
                ;;
        esac
    done
    
    # Shift to get remaining non-option arguments
    shift $((OPTIND - 1))
    
    # Handle remaining arguments if needed
    if (( $# > 0 )); then
        log_message "DEBUG" "Additional arguments: $*"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 11: MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════
# Best Practice: Wrap main logic in a main() function
# Best Practice: Check for root privileges if needed

# Function: run_all_checks
# Description: Execute all system checks
# Returns: Highest severity exit code from all checks
run_all_checks() {
    local max_exit=0
    local check_exit
    
    # Run system info (no threshold checking)
    check_uptime
    
    # Run each check and track the highest exit code
    # set +e temporarily disables exit-on-error
    set +e
    
    check_disk_usage
    check_exit=$?
    (( check_exit > max_exit )) && max_exit=$check_exit
    
    check_memory_usage
    check_exit=$?
    (( check_exit > max_exit )) && max_exit=$check_exit
    
    check_cpu_usage
    check_exit=$?
    (( check_exit > max_exit )) && max_exit=$check_exit
    
    check_services
    check_exit=$?
    (( check_exit > max_exit )) && max_exit=$check_exit
    
    set -e
    
    return $max_exit
}

# Function: main
# Description: Main entry point
main() {
    # Parse command line arguments (pass all args)
    parse_arguments "$@"
    
    # Load configuration file
    load_config
    
    # Initialize log file
    log_message "INFO" "=== System Monitor Started ==="
    log_message "DEBUG" "Verbose mode: $verbose"
    log_message "DEBUG" "Output format: $output_format"
    
    # Print banner if in text mode
    if [[ "$output_format" == "text" ]]; then
        print_color bold "
╔═══════════════════════════════════════════════════════════════════════════╗
║                    SYSTEM HEALTH MONITOR v${SCRIPT_VERSION}                          ║
║                    $(date '+%Y-%m-%d %H:%M:%S')                               ║
╚═══════════════════════════════════════════════════════════════════════════╝
"
    fi
    
    # Run checks (continuous or single)
    local exit_code=0
    
    if [[ "$continuous_mode" == true ]]; then
        log_message "INFO" "Starting continuous monitoring (interval: ${CHECK_INTERVAL}s)"
        print_color cyan "Continuous mode - Press Ctrl+C to stop"
        echo
        
        # Infinite loop until interrupted
        local iteration=0
        while true; do
            ((iteration++))
            
            if [[ "$output_format" == "text" ]]; then
                print_color bold "━━━ Iteration $iteration ($(date '+%H:%M:%S')) ━━━"
            fi
            
            run_all_checks
            exit_code=$?
            
            # Output in requested format
            case "$output_format" in
                json) output_json ;;
                csv)  output_csv ;;
                # text is handled by the check functions
            esac
            
            # Wait for next iteration
            sleep "$CHECK_INTERVAL"
            
            # Clear screen for next iteration (text mode only)
            if [[ "$output_format" == "text" ]]; then
                clear 2>/dev/null || true
            fi
        done
    else
        # Single run
        run_all_checks
        exit_code=$?
        
        # Output in requested format
        case "$output_format" in
            json) output_json ;;
            csv)  output_csv ;;
        esac
        
        # Generate report if requested
        if [[ "$generate_report" == true ]]; then
            generate_report
        fi
    fi
    
    # Print summary
    echo
    if [[ "$output_format" == "text" ]]; then
        case $exit_code in
            0) print_color green "✓ All checks passed" ;;
            1) print_color yellow "⚠ One or more warnings" ;;
            2) print_color red "✗ One or more critical alerts" ;;
        esac
    fi
    
    log_message "INFO" "=== System Monitor Completed (exit: $exit_code) ==="
    
    return $exit_code
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 12: SCRIPT ENTRY POINT
# ═══════════════════════════════════════════════════════════════════════════════
# Best Practice: Only run main if script is executed, not sourced
# This allows functions to be sourced for testing

# Check if script is being sourced or executed
# BASH_SOURCE[0] is the current script
# $0 is the command used to invoke the script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
