# Dockerfile for building ubuntu:16.04 with avi sdk, ansible modules, terraform provider and migration tools
#
# Version  1.1.2
#
FROM ubuntu:16.04

MAINTAINER Sergey Marunich <marunich.s@gmail.com>

ARG tf_version="0.11.7"

RUN echo "===> Adding Ansible's PPA..."  && \
    echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu xenial main" | tee /etc/apt/sources.list.d/ansible.list           && \
    echo "deb-src http://ppa.launchpad.net/ansible/ansible/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/ansible.list    && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7BB9C367    && \
    DEBIAN_FRONTEND=noninteractive  apt-get update  && \
    \
    \
    echo "===> Installing Ansible and AVI SDK dependencies, AVI migration tools..."  && \
    apt-get install -y ansible wget python-dev python-pip python-virtualenv python-cffi ipython libssl-dev libffi-dev

RUN pip install avisdk --upgrade
RUN ansible-galaxy install avinetworks.avisdk avinetworks.avicontroller avinetworks.avise avinetworks.aviconfig avinetworks.avicontroller-azure avinetworks.ansible-role-avicontroller-vmware avinetworks.avise-csp avinetworks.avicontroller-csp
RUN pip install avimigrationtools bigsuds f5-sdk

RUN mkdir -p /etc/ansible/library/avi
RUN cd /etc/ansible/library/avi && wget https://github.com/avinetworks/avi_ansible_modules/archive/master.tar.gz && tar -xvf master.tar.gz -C /etc/ansible/library
RUN echo "export ANSIBLE_LIBRARY=/etc/ansible/library/avi" >> /etc/bash.bashrc

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common python-software-properties
RUN add-apt-repository -y ppa:gophers/archive

RUN DEBIAN_FRONTEND=noninteractive  apt-get update   && \
              echo "===> Updating TLS certificates..."         && \
              apt-get install -y openssl ca-certificates

RUN mkdir -p /opt/ansible

RUN echo "===> Installing Golang..." && \
    apt-get install -y golang-1.9-go
RUN echo "===> Installing Terraform, AVI provider and misc..." && \
    apt-get install -y fish git curl vim unzip make tmux httpie apache2-utils

RUN curl https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip -o terraform_${tf_version}_linux_amd64.zip
RUN unzip terraform_${tf_version}_linux_amd64.zip -d /usr/local/bin
RUN echo "export GOROOT=/usr/lib/go-1.9" >> /etc/bash.bashrc
RUN echo "export GOPATH=$HOME/go" >> /etc/bash.bashrc
RUN echo "export PATH=$PATH:/usr/lib/go-1.9/bin:$HOME/go/bin" >> /etc/bash.bashrc

RUN mkdir -p /root/go/src/github.com/hashicorp/terraform-provider-avi/vendor/github.com/avinetworks
RUN cd /root/go/src/github.com/hashicorp/terraform-provider-avi/vendor/github.com/avinetworks && git clone https://github.com/avinetworks/terraform-provider-avi.git
RUN /usr/lib/go-1.9/bin/go get github.com/avinetworks/sdk/go/session
RUN export PATH=$PATH:/usr/lib/go-1.9/bin && cd /root/go/src/github.com/hashicorp/terraform-provider-avi/vendor/github.com/avinetworks/terraform-provider-avi  && make build
RUN mkdir -p /root/.terraform.d/plugins/ && ln -s /root/go/bin/terraform-provider-avi ~/.terraform.d/plugins/
RUN mkdir -p /opt/terraform

RUN cd /root && wget https://raw.githubusercontent.com/smarunich/avitoolsbox/master/f5_discover_and_convert.sh && chmod 755 /root/f5_discover_and_convert.sh
