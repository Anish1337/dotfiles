#!/bin/bash

while true; do
    journalctl -b -f | rg BadTLP
    sleep 2
done
