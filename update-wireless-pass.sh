#!/bin/bash

while getopts 'a:d:f:p:su:v' opt; do
    case $opt in
        a)
            IP=$OPTARG
            ;;
        d)
            WKEY_FILENAME="$OPTARG"
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

if [ -z "$WKEY_FILENAME" ]; then
    WKEY_FILENAME=wkey
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

WKEY=$(<"$WKEY_FILENAME")

if [ -n $VERBOSE ]; then
    echo 'Sweex router wireless security automatic enable utility'
    echo '(tested on the Sweex LW055 model)'
    echo
    echo 'Beginning enable.'
    echo "Connected to $IP with authentication as $USER."
fi

if [ -z $SILENT ]; then
    curl http://$IP/wirel_sec_set.cgi  -u $USER:$PASS  \
            -d wpaMode=WPA_WPA2_Mixed  -d wpaAuthMethod=pre_shared_keys  \
            -d wpaCipherSuite=AES      -d wpa2CipherSuite=AES            \
            -d wpaPhrase=$WKEY         -d wpa2Phrase=$WKEY               \
            -d wpaGrpReKeyTime=86400
else
    curl -s http://$IP/wirel_sec_set.cgi  -u $USER:$PASS  \
            -d wpaMode=WPA_WPA2_Mixed  -d wpaAuthMethod=pre_shared_keys  \
            -d wpaCipherSuite=AES      -d wpa2CipherSuite=AES            \
            -d wpaPhrase=$WKEY         -d wpa2Phrase=$WKEY               \
            -d wpaGrpReKeyTime=86400
fi

if [ -n $VERBOSE ]; then
    echo "Reset passphrase (AES) and enabled WPA/WPA2 wireless security successfully."
fi
