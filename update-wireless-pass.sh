#!/bin/bash

while getopts 'a:d:f:p:su:v' opt; do
    case $opt in
        a)
            ip=$OPTARG
            ;;
        d)
            WKEY_FILENAME="$OPTARG"
            ;;
        f)
            AUTH_FILENAME="$OPTARG"
            ;;
        p)
            pass=$OPTARG
            ;;
        s)
            SILENT=1
            ;;
        u)
            user=$OPTARG
            ;;
        v)
            VERBOSE=1
            ;;
    esac
done

shift $((OPTIND - 1))

if [ -z $ip ]; then
    ip=$1
fi

if [ -z $user ]; then
    user=$2
fi

if [ -z $pass ]; then
    pass=$3
fi

if [ -z "$WKEY_FILENAME" ]; then
    WKEY_FILENAME=wkey
fi

if [ -z $ip ] || [ -z $user ] || [ -z $pass ]; then
    if [ -z "$AUTH_FILENAME" ]; then
        AUTH_FILENAME=auth
    fi

    read -r F_ip F_user F_pass < "$AUTH_FILENAME"

    if [ -n $F_ip ] && [ -z $ip ]; then
        ip=$F_ip
    fi

    if [ -n $F_user ] && [ -z $user ]; then
        user=$F_user
    fi

    if [ -n $F_pass ] && [ -z $pass ]; then
        pass=$F_pass
    fi
fi

WKEY=$(<"$WKEY_FILENAME")

if [ -n $VERBOSE ]; then
    echo 'Sweex router wireless security automatic enable utility'
    echo '(tested on the Sweex LW055 model)'
    echo
    echo 'Beginning enable.'
    echo "Connected to $ip with authentication as $user."
fi

if [ -z $SILENT ]; then
    curl http://$ip/wirel_sec_set.cgi  -u $user:$pass  \
            -d wpaMode=WPA_WPA2_Mixed  -d wpaAuthMethod=pre_shared_keys  \
            -d wpaCipherSuite=AES      -d wpa2CipherSuite=AES            \
            -d wpaPhrase=$WKEY         -d wpa2Phrase=$WKEY               \
            -d wpaGrpReKeyTime=86400
else
    curl -s http://$ip/wirel_sec_set.cgi  -u $user:$pass  \
            -d wpaMode=WPA_WPA2_Mixed  -d wpaAuthMethod=pre_shared_keys  \
            -d wpaCipherSuite=AES      -d wpa2CipherSuite=AES            \
            -d wpaPhrase=$WKEY         -d wpa2Phrase=$WKEY               \
            -d wpaGrpReKeyTime=86400
fi

if [ -n $VERBOSE ]; then
    echo "Reset passphrase (AES) and enabled WPA/WPA2 wireless security successfully."
fi
