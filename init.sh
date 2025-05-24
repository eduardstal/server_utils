#!/bin/bash

# Detect OS
OS="Unknown"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" = "ubuntu" ]; then
        OS="Ubuntu"
    elif [ "$ID" = "raspbian" ] || [[ "$PRETTY_NAME" == *"Raspberry Pi OS"* ]]; then
        OS="Raspberry Pi OS"
    else
        echo "Unsupported OS: $ID"
        exit 1
    fi
else
    echo "Could not determine OS."
    exit 1
fi

echo "Detected OS: $OS"

if [ "$OS" = "Raspberry Pi OS" ]; then
    echo "Setting up CPU temperature utility..."

    # Check for gcc
    if ! command -v gcc &> /dev/null; then
        echo "Installing gcc..."
        sudo apt update && sudo apt install -y gcc
    fi

    # Create temp.c
    echo "Creating temp.c..."
    cat << 'EOF' > temp.c
#include <stdio.h>

int main(int argc, char *argv[]) 
{
   FILE *fp;

   int temp = 0;
   fp = fopen("/sys/class/thermal/thermal_zone0/temp", "r");
   if (fp == NULL) {
       printf(">> Error reading temperature!\n");
       return 1;
   }
   fscanf(fp, "%d", &temp);
   printf(">> CPU Temp: %.2f°C\n", temp / 1000.0);
   fclose(fp);

   return 0;
}
EOF

    # Compile
    echo "Compiling temp.c..."
    gcc temp.c -o temp
    if [ $? -ne 0 ]; then
        echo "Compilation failed."
        exit 1
    fi

    # Install to /usr/local/bin
    echo "Installing temp utility..."
    sudo mv temp /usr/local/bin/
    echo "Installation complete. Run 'temp' to check CPU temperature."

elif [ "$OS" = "Ubuntu" ]; then
    echo "Ubuntu detected. Add Ubuntu-specific setup steps here."
    # Placeholder for future Ubuntu tasks
fi

echo "Server setup script completed."
