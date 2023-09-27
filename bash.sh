#!/bin/bash 

# check if the argument is provided
if [ $# -lt 1 ]; then
  echo "Please provide a Host name. Usage: $0 <url>"
  exit 1
fi

url="$1"

#check to see if this is a subdomain
dot_count=$(grep -o '\.' <<< $url | wc -l)

#commands to run on the asset 
commands=("nmap -Pn -sT -p- -A" "testssl" "dig caa" "sublist3r -n -b -v -t 5 -d")

exec () {
  url="$1"
  for command in "${commands[@]}"; do
    echo "Command: $command $url"
    output="$($command $url)"
    echo "$output" | tee -a $url
    echo "-----------------------++++++++++++++++++++++++-------------------------" | tee -a $url
  done
}

reduct () {
  url="$1"
  url="$(echo $url | sed 's/^[^.]*\.//' )"
}

#run the commands on the main URL
exec $url

#check to see if it is a subdomain and run the same commands on the main domain
if [ "$dot_count" -ge 2 ]; then
  reduct $url
  echo $url
  exec $url
  if [ "$dot_count" -ge 3 ]; then
    reduct $url
    echo $url
    exec $url
  else
    echo "Input does not contain three dots."
  fi
else
  echo "Input does not contain two."
fi
