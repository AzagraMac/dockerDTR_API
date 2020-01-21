FROM ubuntu:16.04

MAINTAINER Jose l. Azagra

RUN apt-get update && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y openssh-server apt-transport-https curl vim wget jq apt-utils

RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - 
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update && \
  apt-get install -y kubectl && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd
RUN echo 'root:XXXXXXXX' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

COPY ./createNameSpace.sh /usr/bin/createNameSpace.sh
RUN chmod a+x /usr/bin/createNameSpace.sh

WORKDIR /tmp
VOLUME /tmp:/tmp

ENV TERM=xterm

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
