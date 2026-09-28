#!/bin/bash

# stop command from externally is = screen -S bedrock -X stuff "stop"$'\r'
# start command from externally is =  screen -S bedrock -X stuff "bash ./Runner.sh"$'\r'

# countdown colours = §a [green] -> §g [yellow] -> §m [red] -> §4 [dark red]
# server message main colour = §w [light blue]
# server bold test = §l

#screen to run commands under
ScreenName="bedrock"

#offset hour early for the unix clock (22:55 is 23:55 gmt)
TargetTime="23:55"

#timeout time before force stopping server on shutdown
TimeoutLimit=300





#func to run the say (server message) commands to the server for the countdown in the screen this script is run from will provide time stamp in terminal
broadcast() {
	screen -S "$ScreenName" -X stuff "say §l§w[AUTO SERVER RESTART]§r$1"$'\r'
}




#force shutdown check function used by the ctrl c check and main function
ShutdownCheckForce() {
    #time elasped since shutdown (for timeoutlimit check)
		TimeElapsed=0

    #shutdown loop check
		while pgrep -f "bedrock_server" > /dev/null; do
			#if timeout limit is exceeded force shutsdown server task to stop it (5 min timeout limit/grace period)
			if [ $TimeElapsed -ge $TimeoutLimit ]; then
				echo "[WARN] [$(date +'%Y-%m-%d %H:%M:%S')] force shutdown - server shutdown exceeded gracefull shutdown limit"
				pkill -9 -f "bedrock_server"
				break

			fi
			sleep 5
			((TimeElapsed+=5))
		done
}
#ctrl c shutdown
ShutdownAll() {
	broadcast "§lmanual server shutdown iniated - server shutdown in: §l§4 10 SECONDS §r§lNO RESTART INTENDED - CONTACT MODS FOR MORE INFO"

	sleep 10

	# Send graceful stop command to screen
	screen -S "$ScreenName" -X stuff "stop"$'\r'
	echo -e "\n[INFO] [$(date +'%Y-%m-%d %H:%M:%S')] Ctrl+C used - shutting down server"

	#uses shutdown check loop (if process gets stuck
	ShutdownCheckForce

	echo "[INFO] [$(date +'%Y-%m-%d %H:%M:%S')] Minecraft server stopped cleanly. Exiting daemon."
	exit 0
}

# Attach shutdown function to Ctrl+C (SIGINT) and termination signals (SIGTERM)
trap 'ShutdownAll' SIGINT SIGTERM





#initial script start for server starts screen if not one and server itself

echo -e "\n[INFO] [$(date +'%Y-%m-%d %H:%M:%S')] =====PROGRAM STARTED====="

if ! screen -ls | grep -q "\.${ScreenName}\b"; then
	screen -dmS "$ScreenName"
	echo "[INFO] [$(date +'%Y-%m-%d %H:%M:%S')] screen not found - creating screen session for server"
	screen -S "$ScreenName" -X stuff "cd '/home/ubuntu/server/bedrock-server-1.26.12.2 - 15.4.26 copy'"$'\r'
	sleep 1
fi

if ! pgrep -f "bedrock_server" > /dev/null; then
	screen -S "$ScreenName" -X stuff "bash ./Runner.sh"$'\r'
	echo "[INFO] [$(date +'%Y-%m-%d %H:%M:%S')] initial server start - intial turn on"
	#wait a minute after incase still booting
	sleep 60
fi





#infinite loop for the restarts
while true; do
	#gets the current time (unix format which is why restart target time is hour behind)
	CurrentTime=$(date +%H:%M)

	#when it matches current time to target time start the announcement countdown
	if [ "$CurrentTime" = "$TargetTime" ]; then
		broadcast "restart will be in: §l§a 5 MINUTES"
		sleep 120

		broadcast "restart will be in: §l§g 3 MINUTES"
		sleep 120

		broadcast "restart will be in: §l§m 1 MINUTES"
		sleep 30

		broadcast "restart will be in: §l§4 30 SECONDS"
		sleep 20

		#itterate the last 10 seconds with announcement with while loop
		I=0
		while (($I < 10)); do	
			broadcast "restart will be in: §l§4 $((10-$I)) SECONDS"
			sleep 1
			((I++))
		done

		broadcast "§lnow restarting"

		sleep 2

		screen -S "$ScreenName" -X stuff "stop"$'\r'
		echo "[INFO] [$(date +'%Y-%m-%d %H:%M:%S')] shutdown initiated - server turned off from auto restart"

	  #uses shutdown check loop (if process gets stuck
	  ShutdownCheckForce

		#after waiting for server shutdown restart the server again
		screen -S "$ScreenName" -X stuff "bash ./Runner.sh"$'\r'
		echo "[INFO] [$(date +'%Y-%m-%d %H:%M:%S')] restart initiated - server turned back on after auto restart"

		#wait a minute after incase still on time target time and it tries to rerun it
		sleep 60


	#checks if the server has crashed for any reason outside of stopping at auto restart point
	else
		if ! pgrep -f "bedrock_server" > /dev/null; then
			#console output about crash detection
			echo "[WARN] [$(date +'%Y-%m-%d %H:%M:%S')] crash detected - bedrock_server not running"
			echo "[INFO] [$(date +'%Y-%m-%d %H:%M:%S')] crash restarting soon - automatically restarting server in 5 seconds"
			
			#wait then restart server
			sleep 5

			screen -S "$ScreenName" -X stuff "bash ./Runner.sh"$'\r'
			echo "[INFO] [$(date +'%Y-%m-%d %H:%M:%S')] crash restart initiated - server turned back on after crash"
			
			#wait a minute after incase still booting
			sleep 60
		fi
	fi

	#to help prevent high cpu usage
	sleep 30

done