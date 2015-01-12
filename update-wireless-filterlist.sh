#!/bin/bash

while getopts 'a:d:f:p:su:v' opt; do
    case $opt in
        a)
            ip=$OPTARG
            ;;
        d)
            MACTAB_FILENAME="$OPTARG"
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

if [ -z "$MACTAB_FILENAME" ]; then
    MACTAB_FILENAME=mactab
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

if [ -n $VERBOSE ]; then
    echo 'Sweex router filter list automatic update utility'
    echo '(tested on the Sweex LW055 model)'
    echo
    echo 'Beginning update.'
    echo "Connected to $ip with authentication as $user."
fi

while read -r mac desc; do
    if [ -z $SILENT ]; then
        curl http://$ip/wire_filter_mac_set.cgi  -u $user:$pass  \
                -d add_mac=en      -d mac_address=$mac  \
                -d FilterMode=Off  -d mac_describe="$desc"
    else
        curl -s http://$ip/wire_filter_mac_set.cgi  -u $user:$pass  \
                -d add_mac=en      -d mac_address=$mac  \
                -d FilterMode=Off  -d mac_describe="$desc"
    fi

    if [ -n $VERBOSE ]; then
        echo "Added $mac ($desc) to filter list successfully."
    fi
done < "$MACTAB_FILENAME"

if [ -n $VERBOSE ]; then
    echo "Done adding MAC addresses."
fi

curl http://$ip/wire_filter_mac_set.cgi  -u $user:$pass \
        -d FilterMode=Allow  -d enable_filter=2

if [ -n $VERBOSE ]; then
    echo "Whitelisted said addresses and enabled Wireless Access Control successfully."
fi
