#!/bin/bash

if ! which git; then
    sudo apt -yqq install git
fi

if git clone https://github.com/Upsylonbare/env.git; then
    cd env || exit
    ./setup.sh
    cd .. || exit
    rm -rf env
    rm myenv.sh
else
    echo "Could not clone repository!"
fi