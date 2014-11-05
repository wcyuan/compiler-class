#!/bin/sh
sudo apt-get -y update
sudo apt-get -y  install flex bison build-essential csh openjdk-6-jdk libxaw7-dev
sudo apt-get -y emacs24 git
sudo mkdir /usr/class
sudo chown $USER /usr/class
cd /usr/class
wget http://spark-university.s3.amazonaws.com/stanford-compilers/vm/student-dist.tar.gz
tar -xf student-dist.tar.gz
ln -s /usr/class/cs143/cool ~/cool
echo PATH=/usr/class/cs143/cool/bin:\$PATH >> ~/.bashrc
wget https://raw.githubusercontent.com/wcyuan/Scripts/master/dotfiles/dot.screenrc -O ~/.screenrc

