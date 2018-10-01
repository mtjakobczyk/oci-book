#!/bin/bash
### Installing GIT
sudo yum install -y git

### Installing GOLANG
cd ~; mkdir tmp; cd tmp
wget https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.10.3.linux-amd64.tar.gz

### Set in ~/.profile
sudo echo 'export GOPATH=/home/opc/projects' >> ~/.profile
sudo echo 'export GOROOT=/usr/local/go' >> ~/.profile
sudo echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> ~/.profile
source ~/.profile

### Installing libraries
cd ~; mkdir projects; cd projects; cd $GOPATH
go get -u github.com/gorilla/mux
go get -u github.com/google/uuid

### Compiling Vistula API Service
cd $GOPATH/src/github.com
mkdir mtjakobczyk; cd mtjakobczyk
git clone https://github.com/mtjakobczyk/oci-book.git
go install github.com/mtjakobczyk/oci-book/chapter02/vistula

### Open port 8080
sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
sudo firewall-cmd --reload

### Prepare Vistula API Service
cat <<EOT >> ~/tmp/vistula.service
[Unit]
Description = Launching Vistula API
After = network.target
[Service]
Environment=VISTULA_PORT=8080
ExecStart = /home/opc/projects/bin/vistula
User = opc
[Install]
WantedBy = multi-user.target
EOT

chmod u+x ~/tmp/vistula.service
sudo mv ~/tmp/vistula.service /etc/systemd/system
sudo ln -s /etc/systemd/system/vistula.service \
	/etc/systemd/system/multi-user.target.wants/vistula.service
sudo systemctl enable vistula.service
