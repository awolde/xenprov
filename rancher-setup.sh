sudo apt install curl -y
curl -fsSL https://experimental.docker.com/ | sh
#curl -fsSL https://get.docker.com/ | sh
sudo usermod -aG docker awolde
#sudo docker run -d --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v1.0.1 http://192.168.1.122:8080/v1/scripts/EDEF26BA46B239DD3F98:1463281200000:gRBmQN3xbsdsVCfvzvUKthDNRE
