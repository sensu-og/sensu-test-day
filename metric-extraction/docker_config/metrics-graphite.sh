cpu () {
	echo test-day-agent.cpu $(($RANDOM%100)) $(date +%s)
}

disk_io () {
	echo test-day-agent.disk_io $(($RANDOM%500)) $(date +%s)
}

disk_usage () {
	echo test-day-agent.disk_usage $(($(($RANDOM%10))+30)) $(date +%s)
}

heartbeat () {
	echo test-day-agent.heartbeat 1 $(date +%s)
}

memory () {
	echo test-day-agent.memory $(($RANDOM%50)) $(date +%s)
}

network_io () {
	echo test-day-agent.network_in $(($((`date "+%s"`)) % 60)) $(date +%s)
	echo test-day-agent.network_out $(($((`date "+%s"`+ 30 )) % 60)) $(date +%s)
}

ping_ok () {
	ping -c 1 $PING_REMOTE_HOST > /dev/null 2>&1
  	if [ $? -eq 0 ]; then
    	echo test-day-agent.ping_ok 1 $(date +%s)
  	else
    	echo test-day-agent.ping_ok 0 $(date +%s)
  	fi
}

cpu
disk_io
disk_usage
heartbeat
memory
network_io
ping_ok
