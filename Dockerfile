FROM ubuntu:18.04

ARG DRIVER_VERSION=2.7.0
ARG MONGODB_URI

RUN apt-get update && \
    apt-get install -y sudo \
    default-jdk \
    nano \
    vim \
    wget \
    git &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN export uid=1000 gid=1000 && \
    mkdir -p /home/ubuntu && \
    echo "ubuntu:x:${uid}:${gid}:Developer,,,:/home/ubuntu:/bin/bash" >> /etc/passwd && \
    echo "ubuntu:x:${uid}:" >> /etc/group && \
    echo "ubuntu ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu && \
    chown ${uid}:${gid} -R /home/ubuntu

ENV HOME /home/ubuntu
ENV SCALA_VERSION 2.12.8
ENV SBT_VERSION 1.3.3
ENV MONGODB_URI ${MONGODB_URI}
ENV DRIVER_VERSION ${DRIVER_VERSION}

WORKDIR ${HOME}

RUN wget http://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.deb && dpkg -i scala-${SCALA_VERSION}.deb
RUN wget https://dl.bintray.com/sbt/debian/sbt-${SBT_VERSION}.deb && dpkg -i sbt-${SBT_VERSION}.deb

ENV SCALA_HOME /usr/share/scala
ENV PATH ${PATH}:$SCALA_HOME/bin

RUN mkdir -p ${HOME}/scala
COPY ./scala/Getstarted.scala ./scala/build.sbt ./scala/Helpers.scala ${HOME}/scala/

RUN sed -i "s/x.x.x/${DRIVER_VERSION}/g" ${HOME}/scala/build.sbt

RUN chown -R ubuntu ${HOME}/scala && chmod -R 750 ${HOME}/scala

USER ubuntu

CMD ["/bin/bash"]  