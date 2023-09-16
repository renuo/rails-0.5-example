#!/bin/bash

# Function to stop apache2 and mysql server when receiving a signal
graceful_shutdown() {
    echo "Caught signal, stopping gracefully..."
    echo "Stopping Apache..."
    /usr/sbin/apache2ctl -k stop
    echo "Stopping MySQL..."
    service mysql stop
    exit 0
}

# Trap specific signals and call graceful_shutdown
trap "graceful_shutdown" SIGTERM SIGINT

# Start MySQL and Apache in the foreground
echo "Starting MySQL..."
service mysql start
echo "Starting Apache..."
/usr/sbin/apache2ctl -D FOREGROUND &

# Keep track of Apache's PID
APACHE_PID=$!

# Tail the logs
tail -f /var/www/rails/log/apache.log /var/www/rails/log/production.log &

# Wait for Apache to finish
wait $APACHE_PID
