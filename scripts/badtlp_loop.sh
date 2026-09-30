#!/bin/bash

while true; do
    journalctl -b 0 --no-pager | rg -c 'BadTLP'
    sleep 2
done
