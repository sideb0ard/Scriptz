#/bin/bash

netstat -ant | grep ':80' | awk '{print $5}' | egrep -v '(MYOWNIPADDRESS)' | sed 's/:[0-9]*$//' | sort | uniq -c | sort -rnk 1 | awk '{if ($1 > 1200)  print $1,$2}' | while read line
	do count=$(echo $line | cut -f1 -d" "); ip=$(echo $line | cut -f2 -d" ")
	ip route add $ip via 127.0.0.1 dev lo
	echo "Blocked $ip with $count connections" | mail -s "Bot Killer" me@myemailaddress.com 
done
