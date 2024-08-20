#!/bin/bash


sudo nmap -sn 192.168.1.0/24 192.168.10.0/24 | grep "Nmap scan report for" | awk '{print $5}' > /home/cybersecurity-tool/aliveHosts.txt
sudo nmap -sV -iL /home/cybersecurity-tool/aliveHosts.txt | awk '
/Nmap scan report for/ {
    if (host != "") {
        # Cierra el JSON del host anterior y agrega la MAC y OS si existen
        json_host = json_host "]"
        if (mac != "") {
            json_host = json_host ", \"MAC\": \"" mac "\""
        }
        if (os != "") {
            json_host = json_host ", \"OS\": \"" os "\""
        }
        print json_host "},"
    }
    host = $5
    json_host = "{ \"Host\": \"" host "\", \"Services\": ["
    first = 1
    mac = ""
    os = ""
}
/open/ {
    if (!first) {
        json_host = json_host ","
    }
    first = 0
    port = $1
    status = $2
    protocol = $3
    service = $4
    json_host = json_host "{ \"Port\": \"" port "\", \"Status\": \"" status "\", \"Protocol\": \"" protocol "\", \"Service\": \"" service "\"}"
}
/MAC Address:/ {
    mac = $3
    for (i=4; i<=NF; i++) {
        mac = mac " " $i
    }
}
/Service Info: OS:/ {
    os = substr($0, index($0, "OS:") + 4)
}
END {
    if (host != "") {
        # Cierra el JSON del último host y agrega la MAC y OS si existen
        json_host = json_host "]"
        if (mac != "") {
            json_host = json_host ", \"MAC\": \"" mac "\""
        }
        if (os != "") {
            json_host = json_host ", \"OS\": \"" os "\""
        }
        print json_host "}"
    }
}' > /home/cybersecurity-tool/results.json
