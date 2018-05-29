cpu () {
	cpu=$(mpstat | awk '$11 ~ /[0-9.]+/ { print 100 - $11 }')
}

disk_io () {
	disk_io=$(iostat -d -z ALL | awk 'NF==6 {s+=$2} END {print s}')
}

disk_usage () {
	disk_usage=$(df -k / | awk 'NR > 1 {print $5}' | cut -d "%" -f 1)
}

heartbeat () {
	heartbeat=1
}

memory () {
	memory=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }')
}

network_io () {
	network_in=$(($((`date "+%s"`)) % 20))
        network_out=$(($((`date "+%s"`+ 10 )) % 20))
}

ping_ok () {
	ping -c 1 $PING_REMOTE_HOST > /dev/null 2>&1
  	if [ $? -eq 0 ]; then
    	ping_ok=1
  	else
    	ping_ok=0
  	fi
}

cpu
disk_io
disk_usage
heartbeat
memory
network_io
ping_ok

echo METRICS ok \| test-day-agent.cpu=$cpu, test-day-agent.disk_io=$disk_io, test-day-agent.disk_usage=$disk_usage, test-day-agent.heartbeat=$heartbeat, test-day-agent.memory=$memory, test-day-agent.network_in=$network_in, test-day-agent.network_out=$network_out, test-day-agent.ping_ok=$ping_ok
