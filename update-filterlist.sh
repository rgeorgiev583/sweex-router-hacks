#!/bin/bash
read -r USER PASS IP < auth

while read -r mac desc; do 
    curl http://$USER:$PASS@$IP/wire_filter_mac_set.cgi \
            -d add_mac=en -d mac_address=$mac -d submitbutton=Add \
            -d FilterMode=Off -d mac_describe="$desc"
done < mactab

curl http://$USER:$PASS@$IP/wire_filter_mac_set.cgi \
        -d FilterMode=Allow -d enable_filter=2 -d submitbutton=Apply
