docker rm -f avitoolbox
docker pull smarunich/avitoolbox
docker run -td --name avitoolbox --hostname avitoolbox --net=host -v /Users/smarunich/workspace/terraform:/opt/terraform -v /Users/smarunich/workspace/ansible/workspace:/opt/ansible -v /Users/smarunich/workspace/ansible/modules:/usr/share/ansible/plugins/modules smarunich/avitoolbox bash
