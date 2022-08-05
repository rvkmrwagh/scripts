#!/bin/bash
#Script: pair_bluetooth_device.sh
#About script: start bluetoot, filter bluetooth device and pair with it
#Last_update: Aug 6 2022
#######################################################################


function get_macaddress()
{
	if [[ -f "tmp/bluetooth_scan_result" ]]
	then
		rm -rf tmp/bluetooth_scan_result
	fi
	bluetoothctl --timeout 10 scan on >> /tmp/bluetooth_scan_result 
	if [[ $(grep -i $1 /tmp/bluetooth_scan_result | wc -l) -gt 0 ]]
	then
		mac_of_device=$(grep -i $1 /tmp/bluetooth_scan_result | tail -1 | awk '{print $3}')
		echo "found device $1 has mac address $mac_of_device"
		echo "pairing with $mac_of_device"
		bluetoothctl connect $mac_of_device
	else
		echo "no bluetooth device found to pair matching to provided arguments : $1"
		echo -e "\nhere is list of devices found \n"
		cat /tmp/bluetooth_scan_result
	fi
}
function start_bluetooth()
{
	if [[ $(systemctl is-active bluetooth | grep 'inactive' | wc -l) -eq 1 ]]
	then
		sudo systemctl start bluetooth
		echo "waiting to start bluetooth service.."
		sleep 10s
		if [[ $(systemctl is-active bluetooth | grep 'inactive' | wc -l) -ne 0 ]]
		then
			echo "Some issue in starting bluetooth"
			return 1
		fi
		get_macaddress $1
	fi
}

start_bluetooth $1
