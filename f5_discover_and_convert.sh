#!/bin/bash
read -p "Enter F5 IP: " f5_ip
read -p "Enter User: " f5_user
read -s -p "Enter Password: " f5_password
echo
read -p "F5 version (10 or 11): " f5_version
read -p "Enter Avi Controller Version: " controller_version

mkdir -p /root/${f5_ip}/f5_converter
mkdir -p /root/${f5_ip}/f5_discovery

f5_converter.py --f5_host_ip "${f5_ip}" \
  --f5_ssh_user "${f5_user}" \
  --f5_ssh_password "${f5_password}" \
  --no_object_merge \
  --controller_version ${controller_version} \
  --ansible \
  -o /root/${f5_ip}/f5_converter

f5_discovery.py -v "${f5_version}" \
  --f5_ip "${f5_ip}" \
  --f5_user "${f5_user}" \
  --f5_password "${f5_password}" \
  -o /root/${f5_ip}/f5_discovery
