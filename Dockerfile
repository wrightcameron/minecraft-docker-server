FROM openjdk:17

ARG server_type="vanilla"
ARG version="latest"

RUN mkdir -p /minecraft/data
WORKDIR /minecraft
COPY startMinecraft.sh .

RUN if [ $version = "latest" ]; then  \
    curl https://serverjars.com/api/fetchJar/$server_type -o ./server.jar; \
  else \
    curl https://serverjars.com/api/fetchJar/$server_type/$version -o ./server.jar; \
  fi

RUN groupadd --gid 1003 minecraft \
  && useradd -g minecraft --uid 1003 minecraft
RUN chmod +x startMinecraft.sh \
    && chown minecraft:minecraft -R /minecraft
USER minecraft

CMD ["./startMinecraft.sh"]
