#!/bin/bash
cd data
if [ ! -f ./server.jar ]; then
    cp ../server.jar ./server.jar
fi
java -Xms1G -Xmx8G -jar ./server.jar nogui
