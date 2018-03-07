# avitoolsbox
Docker container with avi sdk, ansible modules, terraform provider and migration tools
- docker run -td --name avitoolsbox --hostname avitoolsbox --net=host -v /opt/terraform/workspace:/opt/terraform -v /opt/ansible/workspace:/opt/ansible -v /opt/ansible/modules:/usr/share/ansible/plugins/modules smarunich/avitoolsbox bash
