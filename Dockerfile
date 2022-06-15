FROM openjdk:17

RUN mkdir -p /minecraft/data
WORKDIR /minecraft
COPY startMinecraft.sh .

RUN curl https://serverjars.com/api/fetchJar/vanilla -o ./server.jar

RUN groupadd --gid 1003 minecraft \
  && useradd -g minecraft --uid 1003 minecraft
RUN chmod +x startMinecraft.sh \
    && chown minecraft:minecraft -R /minecraft
USER minecraft

CMD ["./startMinecraft.sh"]
