FROM openjdk:8u151-jre-alpine

LABEL org.opencontainers.image.source=https://github.com/mongodb-developer/get-started-scala

ENV HOME=/home/gsuser \
 SCALA_VERSION=2.13.5 \
 SBT_VERSION=1.4.9 \
 SCALA_HOME=/usr/share/scala \
 PATH="/usr/local/sbt/bin:$PATH" 

RUN apk add --no-cache --virtual=.build-dependencies wget && \
    apk add --no-cache bash && \
    cd "/tmp" && \
    wget --no-verbose "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
    tar xzf "scala-${SCALA_VERSION}.tgz" && \
    mkdir "${SCALA_HOME}" && \
    rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
    mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
    ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
    apk del .build-dependencies && \
    rm -rf "/tmp/"*

RUN apk update && apk add ca-certificates wget tar && \
    mkdir -p "/usr/local/sbt" && \
    wget -qO - "https://github.com/sbt/sbt/releases/download/v1.4.9/sbt-1.4.9.tgz" | tar xz -C /usr/local/sbt --strip-components=1

RUN addgroup -S gsgroup && adduser -S gsuser -G gsgroup && \
    chown -R gsuser ${HOME} && chmod -R 750 ${HOME} 

USER gsuser

ENTRYPOINT ["/bin/sh", "-c"]  
