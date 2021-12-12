#!/bin/bash
cd data
# wget https://launcher.mojang.com/v1/objects/3cf24a8694aca6267883b17d934efacc5e44440d/server.jar -O server.jar
java -Xms1G -Xmx8G -jar ./server.jar nogui
