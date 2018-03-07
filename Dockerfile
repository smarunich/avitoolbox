# Dockerfile for building ubuntu:16.04 with avi sdk, ansible modules, terraform provider and migration tools
#
# Version  1.0
#
FROM ubuntu:16.04

MAINTAINER Sergey Marunich <marunich.s@gmail.com>

ARG tf_version="0.11.3"

RUN echo "===> Adding Ansible's PPA..."  && \
    echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu xenial main" | tee /etc/apt/sources.list.d/ansible.list           && \
    echo "deb-src http://ppa.launchpad.net/ansible/ansible/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/ansible.list    && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7BB9C367    && \
    DEBIAN_FRONTEND=noninteractive  apt-get update  && \
    \
    \
    echo "===> Installing Ansible and AVI SDK dependencies, AVI migration tools..."  && \
    apt-get install -y ansible python-dev python-pip python-virtualenv python-cffi libssl-dev libffi-dev

RUN pip install avisdk --upgrade
RUN ansible-galaxy install avinetworks.avisdk
RUN pip install avimigrationtools

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common python-software-properties
RUN add-apt-repository -y ppa:gophers/archive

RUN DEBIAN_FRONTEND=noninteractive  apt-get update   && \
              echo "===> Updating TLS certificates..."         && \
              apt-get install -y openssl ca-certificates

RUN mkdir -p /opt/ansible

RUN echo "===> Installing Golang..." && \ 
    apt-get install -y golang-1.9-go
RUN echo "===> Installing Terraform, AVI provider and misc..." && \ 
    apt-get install -y git curl vim unzip make tmux httpie 
    
RUN curl https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip -o terraform_${tf_version}_linux_amd64.zip
RUN unzip terraform_${tf_version}_linux_amd64.zip -d /usr/local/bin
RUN echo "export GOROOT=/usr/lib/go-1.9" >> /etc/bash.bashrc
RUN echo "export GOPATH=$HOME/go" >> /etc/bash.bashrc
RUN echo "export PATH=$PATH:/usr/lib/go-1.9/bin:$HOME/go/bin" >> /etc/bash.bashrc

RUN mkdir -p /root/go/src/github.com/hashicorp
RUN cd /root/go/src/github.com/hashicorp && git clone https://github.com/avinetworks/terraform-provider-avi.git
RUN /usr/lib/go-1.9/bin/go get github.com/avinetworks/sdk/go/session
RUN mkdir -p /root/go/src/github.com/terraform-providers/terraform-provider-avi
RUN cp -r /root/go/src/github.com/hashicorp/terraform-provider-avi /root/go/src/github.com/terraform-providers/
RUN export PATH=$PATH:/usr/lib/go-1.9/bin && cd /root/go/src/github.com/terraform-providers/terraform-provider-avi  && make build


RUN mkdir -p /opt/terraform
