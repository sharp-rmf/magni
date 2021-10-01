#!/usr/bin/env bash

if [`ip route show | grep -c default` == '2']
    then 
        echo "More then 2 default routes"
fi

