FROM centos:centos7
MAINTAINER Jose l. Azagra

COPY ./kubernetes.repo /etc/yum.repos.d/kubernetes.repo
RUN yum -y update; yum clean all
RUN yum -y install openssh-server passwd curl vim wget kubectl; yum clean all

RUN mkdir /var/run/sshd
RUN echo 'root:XXXXXX' | chpasswd

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''

COPY ./createNameSpace.sh /usr/bin/createNameSpace.sh
RUN chmod a+x /usr/bin/createNameSpace.sh

COPY ./jq /usr/bin/jq
RUN chmod a+x /usr/bin/jq

WORKDIR /tmp
VOLUME /tmp:/tmp

ENV TERM=xterm
EXPOSE 22
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
