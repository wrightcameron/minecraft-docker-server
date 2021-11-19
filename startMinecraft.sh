#!/bin/bash
cd data
wget https://launcher.mojang.com/v1/objects/0a269b5f2c5b93b1712d0f5dc43b6182b9ab254e/server.jar -O server.jar
java -Xms1G -Xmx8G -jar ./server.jar nogui