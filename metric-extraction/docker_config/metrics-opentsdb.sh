cpu () {
	echo test-day-agent.cpu $(date +%s) $(mpstat | awk '$11 ~ /[0-9.]+/ { print 100 - $11 }') host=test-day-agent
}

disk_io () {
	echo test-day-agent.disk_io $(date +%s) $(iostat -d -z ALL | awk 'NF==6 {s+=$2} END {print s}') host=test-day-agent
}

disk_usage () {
	echo test-day-agent.disk_usage $(date +%s) $(df -k / | awk 'NR > 1 {print $5}' | cut -d "%" -f 1) host=test-day-agent
}

heartbeat () {
	echo test-day-agent.heartbeat $(date +%s) 1 host=test-day-agent
}

memory () {
	echo test-day-agent.memory $(date +%s) $(free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }') host=test-day-agent
}

network_io () {
	echo test-day-agent.network_in $(date +%s)   $(($((`date "+%s"`)) % 120)) host=test-day-agent
        echo test-day-agent.network_out $(date +%s)  $(($((`date "+%s"`+ 60 )) % 120)) host=test-day-agent
}

ping_ok () {
	ping -c 1 $PING_REMOTE_HOST > /dev/null 2>&1
  	if [ $? -eq 0 ]; then
    	echo test-day-agent.ping_ok $(date +%s) 1 host=test-day-agent
  	else
    	echo test-day-agent.ping_ok $(date +%s) 0 host=test-day-agent
  	fi
}

cpu
disk_io
disk_usage
heartbeat
memory
network_io
ping_ok
