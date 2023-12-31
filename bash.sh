#!/bin/bash 
# Function to handle Ctrl+C
ctrl_c() {
    echo "Ctrl+C pressed. Exiting..."
    exit 1
}

# Trap the SIGINT signal (Ctrl+C) and call ctrl_c function
trap ctrl_c SIGINT
# check if the argument is provided
if [ $# -lt 1 ]; then
  echo "Please provide a Host name. Usage: $0 <url>"
  exit 1
fi

host="$1"


#check to see if this is a subdomain
dot_count=$(grep -o '\.' <<< $host | wc -l)

#commands to run on the asset 
commands=("nmap -Pn -sT -p- -A" "testssl" "dig caa" "sublist3r -b -n -v -t 5 -d")
commandsHTTP=("jsleak -l -s -c 20 -e" "curl -kvL -X TRACE")

exec () {
  for command in "${commands[@]}"; do
    echo "Command: $command $host"
    output="$($command $host)"
    echo "$output" | tee -a $host
    echo "-----------------------++++++++++++++++++++++++-------------------------" | tee -a $host
  done
  for command in "${commandsHTTP[@]}"; do
    urlHTTP="https://$host"
    urlHTTPS="http://$host"
    echo "Command: $command $urlHTTP"
    output="$(echo $urlHTTP | $commandsHTTP)"
    echo "$output" | tee -a $host
    echo "-----------------------++++++++++++++++++++++++-------------------------" | tee -a $host
    echo "Command: $command $urlHTTPS"
    output="$(echo $urlHTTPS | $commandsHTTP )"
    echo "$output" | tee -a $host
    echo "-----------------------++++++++++++++++++++++++-------------------------" | tee -a $host
  done
}

reduct () {
  host="$1"
  host="$(echo $host | sed 's/^[^.]*\.//' )"
}

#run the commands on the main URL
exec $host

#check to see if it is a subdomain and run the same commands on the main domain
if [ "$dot_count" -ge 2 ]; then
  reduct $host
  echo $host
  exec $host
  if [ "$dot_count" -ge 3 ]; then
    reduct $url
    echo $host
    exec $host
  else
    echo "Input does not contain three dots."
  fi
else
  echo "Input does not contain two."
fi
