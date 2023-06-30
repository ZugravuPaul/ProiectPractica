#!/bin/bash

install_updates() {
    echo "Installing updates..."
    apt-get update && apt-get upgrade -y 
    if [ $? -eq 0 ]; then
	    	echo "Updates installed successfully."
	    else
	    	echo "Error: Failed to install updates."
    fi
    
}



while [[ $# -eq 0 ]]; do
clear
printf "=== Update Installer ===\n1. Update Package Manager\n2. Upgrade Packages\n3. Install Specific Package\n4. Install All Available Updates\n5. Upgrade Distribution\n6. Exit\n"
read -p "Enter your choice: " choice
case $choice in
	1)
	    echo "Updating package manager..."
	    apt-get update
	    if [ $? -eq 0 ]; then
	    	echo "Package manager updated successfully."
	    else
	    	echo "Error: Failed to update package manager."
    	    fi	
	    
	    sleep 2   
	    ;;
	2)
	    echo "Upgrading packages..."
	    apt-get upgrade -y
	    if [ $? -eq 0 ]; then
	    	echo "Packages upgraded successfully."
	    else
	    	echo "Error: Failed to upgrade packages."
    	    fi	
	    
	    sleep 2    
	    ;;
	3)
	    read -p "Enter the name of the package to install: " package
	    echo "Installing package: $package..."
	    apt-get install $package
	    if [ $? -eq 0 ]; then
	    	echo "Package installed successfully."
	    else
	    	echo "Error: Failed to install package '$package'."
	    fi
	    
	    sleep 4 
	    ;;
	4)
	    install_updates
	    sleep 2
	    ;;
	5)
	    echo "Upgrading distribution..."
	    apt-get dist-upgrade
	    if [ $? -eq 0 ]; then
	    	echo "Distribution upgraded successfully."
	    else
	    	echo "Error: Failed to upgrade distribution!"
	    fi
	    
	    sleep 2
	    ;;
	6)
	    echo "Exiting..."
	    exit 0
	    ;;
	*)
	    echo "Invalid choice. Please try again."
	    sleep 2
	    ;;
esac
done



