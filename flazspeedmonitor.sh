#!/bin/bash

# Internet Speed Monitoring Script
# Monitors upload and download speeds with configurable intervals
# Saves results to CSV file
#
# Copyright (c) 2024 Mulyawan Sentosa - FlazHost.Com
# Licensed under the GNU General Public License v3.0 (GPL-3.0)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

CSV_FILE="speed_results.csv"
INTERVAL=300  # Default: 5 minutes in seconds

# Function to check if speedtest-cli is installed
check_speedtest() {
    # Check for speedtest-cli in PATH or local speedtest.py
    if command -v speedtest-cli &> /dev/null; then
        SPEEDTEST_CMD="speedtest-cli"
    elif [ -f "./speedtest.py" ]; then
        SPEEDTEST_CMD="./speedtest.py"
    else
        echo "Error: speedtest-cli is not installed."
        echo "Please install it using: pip install speedtest-cli"
        echo "Or on Ubuntu/Debian: sudo apt install speedtest-cli"
        exit 1
    fi
}

# Function to get user input for interval
get_interval() {
    echo "Choose speedtest interval:"
    echo "1. Every 1 minute"
    echo "2. Every 2 minutes"
    echo "3. Every 5 minutes (default)"
    echo "4. Every 10 minutes"
    echo "5. Every 15 minutes"
    echo "6. Every 30 minutes"
    echo "7. Custom interval"
    echo ""
    read -p "Select interval option (1-7): " interval_choice

    case $interval_choice in
        1)
            INTERVAL=60
            echo "Interval set to: 1 minute"
            ;;
        2)
            INTERVAL=120
            echo "Interval set to: 2 minutes"
            ;;
        3)
            INTERVAL=300
            echo "Interval set to: 5 minutes"
            ;;
        4)
            INTERVAL=600
            echo "Interval set to: 10 minutes"
            ;;
        5)
            INTERVAL=900
            echo "Interval set to: 15 minutes"
            ;;
        6)
            INTERVAL=1800
            echo "Interval set to: 30 minutes"
            ;;
        7)
            read -p "Enter custom interval in minutes: " custom_minutes
            if ! [[ "$custom_minutes" =~ ^[0-9]+([.][0-9]+)?$ ]] || [ $(echo "$custom_minutes <= 0" | bc -l) -eq 1 ]; then
                echo "Invalid interval. Please enter a positive number."
                exit 1
            fi
            INTERVAL=$(echo "$custom_minutes * 60" | bc -l | cut -d. -f1)
            echo "Interval set to: $custom_minutes minutes"
            ;;
        *)
            echo "Invalid option. Using default 5 minutes."
            INTERVAL=300
            ;;
    esac
    echo ""
}

# Function to get user input for end time
get_end_time() {
    echo "Internet Speed Monitoring Tool"
    echo "=============================="
    echo ""
    echo "Choose monitoring duration:"
    echo "1. Enter end time (HH:MM format, 24-hour)"
    echo "2. Enter duration in hours"
    echo "3. Run indefinitely (Ctrl+C to stop)"
    echo ""
    read -p "Select option (1/2/3): " choice

    case $choice in
        1)
            read -p "Enter end time (HH:MM): " end_time_input
            # Validate time format
            if [[ ! $end_time_input =~ ^[0-2][0-9]:[0-5][0-9]$ ]]; then
                echo "Invalid time format. Please use HH:MM (24-hour format)"
                exit 1
            fi

            # Convert to timestamp
            today=$(date +%Y-%m-%d)
            end_timestamp=$(date -d "$today $end_time_input" +%s)
            current_timestamp=$(date +%s)

            # If end time is earlier than current time, assume it's for tomorrow
            if [ $end_timestamp -le $current_timestamp ]; then
                tomorrow=$(date -d "tomorrow" +%Y-%m-%d)
                end_timestamp=$(date -d "$tomorrow $end_time_input" +%s)
            fi

            echo "Monitoring will stop at: $(date -d @$end_timestamp)"
            ;;
        2)
            read -p "Enter duration in hours: " duration_hours
            if ! [[ "$duration_hours" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
                echo "Invalid duration. Please enter a positive number."
                exit 1
            fi

            duration_seconds=$(echo "$duration_hours * 3600" | bc -l)
            end_timestamp=$(echo "$(date +%s) + $duration_seconds" | bc -l | cut -d. -f1)
            echo "Monitoring will run for $duration_hours hours until: $(date -d @$end_timestamp)"
            ;;
        3)
            end_timestamp=0
            echo "Monitoring will run indefinitely. Press Ctrl+C to stop."
            ;;
        *)
            echo "Invalid option selected."
            exit 1
            ;;
    esac
}

# Function to create CSV header
create_csv_header() {
    if [ ! -f "$CSV_FILE" ]; then
        echo "Timestamp,Date,Time,Download_Speed_Mbps,Upload_Speed_Mbps,Ping_ms,Server_Location,ISP" > "$CSV_FILE"
        echo "Created CSV file: $CSV_FILE"
    else
        echo "Using existing CSV file: $CSV_FILE"
    fi
}

# Function to run speed test and save to CSV
run_speed_test() {
    echo "Running speed test at $(date)..."

    # Run speedtest and capture output
    speedtest_output=$($SPEEDTEST_CMD --simple 2>/dev/null)

    if [ $? -eq 0 ]; then
        # Parse speedtest output
        download=$(echo "$speedtest_output" | grep "Download:" | awk '{print $2}')
        upload=$(echo "$speedtest_output" | grep "Upload:" | awk '{print $2}')
        ping=$(echo "$speedtest_output" | grep "Ping:" | awk '{print $2}')

        # Get additional server info
        server_info=$($SPEEDTEST_CMD --list 2>/dev/null | head -1 | cut -d')' -f2 | xargs)
        if [ -z "$server_info" ]; then
            server_info="Unknown"
        fi

        # Get ISP info (simplified)
        isp_info=$($SPEEDTEST_CMD --simple 2>/dev/null | grep -o "testing from.*" | cut -d'(' -f2 | cut -d')' -f1)
        if [ -z "$isp_info" ]; then
            isp_info="Unknown"
        fi

        # Get current timestamp and formatted date/time
        timestamp=$(date +%s)
        current_date=$(date +%Y-%m-%d)
        current_time=$(date +%H:%M:%S)

        # Save to CSV
        echo "$timestamp,$current_date,$current_time,$download,$upload,$ping,$server_info,$isp_info" >> "$CSV_FILE"

        echo "Results saved - Download: ${download} Mbps, Upload: ${upload} Mbps, Ping: ${ping} ms"
    else
        echo "Speed test failed at $(date). Retrying in next cycle..."
        timestamp=$(date +%s)
        current_date=$(date +%Y-%m-%d)
        current_time=$(date +%H:%M:%S)
        echo "$timestamp,$current_date,$current_time,ERROR,ERROR,ERROR,ERROR,ERROR" >> "$CSV_FILE"
    fi
}

# Function to show current status
show_status() {
    if [ -f "$CSV_FILE" ]; then
        echo ""
        echo "=== Latest Results ==="
        tail -5 "$CSV_FILE" | column -t -s ','
        echo ""
    fi
}

# Main monitoring loop
monitor_speed() {
    echo ""
    echo "Starting speed monitoring..."
    echo "Results will be saved to: $CSV_FILE"

    # Convert interval to human readable format
    if [ $INTERVAL -lt 60 ]; then
        interval_text="${INTERVAL} seconds"
    else
        interval_minutes=$((INTERVAL / 60))
        if [ $interval_minutes -eq 1 ]; then
            interval_text="1 minute"
        else
            interval_text="${interval_minutes} minutes"
        fi
    fi

    echo "Testing every $interval_text..."
    echo ""

    while true; do
        current_time=$(date +%s)

        # Check if we should stop (if end_timestamp is set and reached)
        if [ $end_timestamp -ne 0 ] && [ $current_time -ge $end_timestamp ]; then
            echo ""
            echo "Monitoring period completed at $(date)"
            break
        fi

        run_speed_test
        show_status

        # Calculate next test time
        if [ $INTERVAL -lt 60 ]; then
            next_test=$(date -d "$(date) + ${INTERVAL} seconds" "+%H:%M:%S")
        else
            interval_minutes=$((INTERVAL / 60))
            next_test=$(date -d "$(date) + ${interval_minutes} minutes" "+%H:%M:%S")
        fi
        echo "Next test at: $next_test"
        echo "----------------------------------------"

        sleep $INTERVAL
    done
}

# Cleanup function for graceful exit
cleanup() {
    echo ""
    echo "Monitoring stopped by user at $(date)"
    echo "Results saved in: $CSV_FILE"

    if [ -f "$CSV_FILE" ]; then
        total_tests=$(tail -n +2 "$CSV_FILE" | wc -l)
        echo "Total tests completed: $total_tests"

        if [ $total_tests -gt 0 ]; then
            echo ""
            echo "=== Final Summary ==="
            echo "Last 5 results:"
            tail -5 "$CSV_FILE" | column -t -s ','
        fi
    fi

    exit 0
}

# Set up signal handling for graceful exit
trap cleanup SIGINT SIGTERM

# Main execution
main() {
    check_speedtest
    get_interval
    get_end_time
    create_csv_header
    monitor_speed

    echo ""
    echo "Monitoring completed successfully!"
    echo "All results saved in: $CSV_FILE"
}

# Run main function
main