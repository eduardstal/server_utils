#!/bin/bash

#######################
##### Detect OS #######
#######################
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

#######################
#### Full Upgrade #####
#######################

sudo apt update && sudo apt upgrade -y

###########################
##### Temp shortcut #######
###########################

# Check if temp already exists
if command -v temp &> /dev/null; then
    echo "Temp utility already exists - skipping installation"
else
    echo "Setting up CPU temperature utility..."

    ################################
    #### Build Tools Check #########
    ################################
    if ! command -v gcc &> /dev/null; then
        echo "Installing gcc..."
        sudo apt install -y gcc  # Changed to only gcc
    fi

    ################################
    #### Create Temp Program #######
    ################################
    echo "Creating temp.c..."
    cat << 'EOF' > temp.c
#include <stdio.h>

int main(int argc, char *argv[]) 
{
   FILE *fp;

   int temp = 0;
   fp = fopen("/sys/class/thermal/thermal_zone0/temp", "r");
   if (fp == NULL) {
       printf(">> Error reading temperature! Check if thermal zone exists.\n");
       return 1;
   }
   fscanf(fp, "%d", &temp);
   printf(">> CPU Temp: %.2f°C\n", temp / 1000.0);
   fclose(fp);

   return 0;
}
EOF

    ################################
    #### Compile & Install #########
    ################################
    echo "Compiling temp.c..."
    gcc temp.c -o temp || {
        echo "Compilation failed - cleaning up"
        rm -f temp.c temp 2>/dev/null
        exit 1
    }

    echo "Installing temp utility..."
    sudo mv temp /usr/local/bin/
    rm -f temp.c  # Cleanup source file
    
    echo "Installation complete. Run 'temp' to check CPU temperature."
fi

##############################
##### OS Specific Tasks ######
##############################
if [ "$OS" = "Raspberry Pi OS" ]; then
    echo "Running Raspberry Pi OS specific tasks..."
    # Add RPi-specific commands here
    
elif [ "$OS" = "Ubuntu" ]; then
    echo "Running Ubuntu specific tasks..."
    # Add Ubuntu-specific commands here
fi

echo "Server setup script completed."

###########################
##### Install Display #####
###########################

#https://eduardstal.com/blogs/uctronics-rack-display/U6143_ssd1306.zip

For ubuntu:
cd /home/eduardstal
wget https://eduardstal.com/blogs/uctronics-rack-display/U6143_ssd1306.zip
sudo apt install unzip 
unzip U6143_ssd1306.zip
rm U6143_ssd1306.zip
cd U6143_ssd1306/C
sudo systemctl enable rc-local.service

Append to the end of rc.local

#!/bin/sh
cd /home/eduardstal/U6143_ssd1306/C
sudo make clean
sudo make
sudo ./display &

sudo systemctl restart rc-local.service



For Raspberry pi: 
1. Check if rc.local file exists. 



cd /home/pi
wget https://eduardstal.com/blogs/uctronics-rack-display/U6143_ssd1306.zip
cd U6143_ssd1306/C
sudo raspi-config nonint do_i2c 0
sudo make clean && sudo make

Apend to the end of rc.local 

cd /home/pi/U6143_ssd1306/C
sudo make clean 
sudo make 
sudo ./display &







