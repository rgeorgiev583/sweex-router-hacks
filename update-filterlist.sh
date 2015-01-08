#!/bin/bash

while getopts 'a:d:f:p:su:v' opt; do
    case $opt in
        a)
            IP=$OPTARG
            ;;
        d)
            MACTAB_FILENAME="$OPTARG"
            ;;
        f)
            AUTH_FILENAME="$OPTARG"
            ;;
        p)
            PASS=$OPTARG
            ;;
        s)
            SILENT=1
            ;;
        u)
            USER=$OPTARG
            ;;
        v)
            VERBOSE=1
            ;;
    esac
done

shift $((OPTIND - 1))

if [ -z $IP ]; then
    IP=$1
fi

if [ -z $USER ]; then
    USER=$2
fi

if [ -z $PASS ]; then
    PASS=$3
fi

if [ -z "$MACTAB_FILENAME" ]; then
    MACTAB_FILENAME=mactab
fi

if [ -z $IP ] || [ -z $USER ] || [ -z $PASS ]; then
    if [ -z "$AUTH_FILENAME" ]; then
        AUTH_FILENAME=auth
    fi

    read -r F_IP F_USER F_PASS < "$AUTH_FILENAME"

    if [ -n $F_IP ] && [ -z $IP ]; then
        IP=$F_IP
    fi

    if [ -n $F_USER ] && [ -z $USER ]; then
        USER=$F_USER
    fi

    if [ -n $F_PASS ] && [ -z $PASS ]; then
        PASS=$F_PASS
    fi
fi

if [ -n $VERBOSE ]; then
    echo 'Sweex router filter list automatic update utility'
    echo '(tested on the Sweex LW055 model)'
    echo
    echo 'Beginning update.'
    echo "Connected to $IP with authentication as $USER."
fi

while read -r mac desc; do
    if [ -z $SILENT ]; then
        curl http://$USER:$PASS@$IP/wire_filter_mac_set.cgi \
                -d add_mac=en -d mac_address=$mac -d submitbutton=Add \
                -d FilterMode=Off -d mac_describe="$desc"
    else
        curl http://$USER:$PASS@$IP/wire_filter_mac_set.cgi \
                -d add_mac=en -d mac_address=$mac -d submitbutton=Add \
                -d FilterMode=Off -d mac_describe="$desc" -s
    fi

    if [ -n $VERBOSE ]; then
        echo "Added $mac ($desc) to filter list successfully."
    fi
done < "$MACTAB_FILENAME"

if [ -n $VERBOSE ]; then
    echo "Done adding MAC addresses."
fi

curl http://$USER:$PASS@$IP/wire_filter_mac_set.cgi \
        -d FilterMode=Allow -d enable_filter=2 -d submitbutton=Apply

if [ -n $VERBOSE ]; then
    echo "Whitelisted said addresses and enabled Wireless Access Control successfully."
fi
