# Minecraft Docker Server
Dedicated server for [Minecraft Java Edition](https://www.minecraft.net/en-us/store/minecraft-java-edition).

## About
Dedicated Docker image for video game Minecraft.  No mods are included with image.  This image is self contained, 
with everything needed to standup a headless Minecraft dedicated server.

## Setup
### Build Docker Image
If you are pulling down this repo and building the image yourself, use `$ docker build -t minecraft-server .`.

### Installing on hosted machine
The repository comes with an install.sh script, for setting up the host machine not the docker image.  
The install.sh script sets up the bind mount that persistant files will be located, 
a systemctl minecraft.service for better controlability, and a backup.sh script to create backups of the minecraft world.

This isn't required to do, instead a docker image can be built but mounted to a Docker volume instead.  
It will be less managed but if access to host system is nill, this will be an alternative.  
Modify docker-compose file or Docker CLI command to point to named volume.

Install script usage: `$ ./install.sh -s <install|unistall|verify> -d <path>`.  Sudo or root access is required, new user and group
are created.  If a path is not given the default location is */opt/minecraft*.  Minecraft server repo has
additional tools avaliable if user has access to entire host server.  These tools include a minecraft systemctl file, and a backup scipt.

### Network
The network port is set in the Docker compose file or in the Docker command from CMI.  The default port is 25565 tcp.  If standing up multiple Minecraft servers, change the port (along with map directory used).  

### Volumes
Server uses one volume. The volume will be mounted inside docker image at /opt/minecraft/data
and contain all server files.

## Usage
### Installed with install.sh
Run command `$ systemctl start minecraft`, to stop the server it will be `$ systemctl stop minecraft`

### Docker Compose
The docker-compose.yaml is included. Use `docker-compose up -d` to bring up the server, and then `docker-compose down` to bring the server down.

### Docker CLI
```bash
docker run -it --rm \
    --name minecraft-server \
    -p 7777:7777 \
    --volume=minecraft_server:/opt/minecraft/data \
    -d minecraft-server
```
While running Docker Compose or Docker CLI interactively (not `-d` mode), you can simply press `CTRL+C` once to gracefully stop the server.

The volume doesn't have to be a named volume. If you prefer bind mount change the 
minecraft_server with file path.  The distination will need to have open permissions or
the user/group needs to be the same uid as the one in the dockerfile (1003). 

## Maintance