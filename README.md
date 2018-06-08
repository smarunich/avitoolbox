# avitoolsbox
Docker container with avi sdk, ansible modules, terraform provider and migration tools
- docker run -td --name avitoolbox --hostname avitoolbox --net=host -v /opt/terraform/workspace:/opt/terraform -v /opt/ansible/workspace:/opt/ansible -v /opt/ansible/modules:/usr/share/ansible/plugins/modules smarunich/avitoolbox bash
