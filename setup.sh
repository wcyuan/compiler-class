#!/bin/sh
#
# Start an AWS instance.
# Should be 32-bit ubuntu
# If you do 64-bit, and there is no 32-bit support, then everything will
# work until you go to run spim.  Then, you'll get a
# "No such file or directory" error even though the file is there.
# That's just the error you get when you run a 32-bit program on
# 64-bit linux with no 32-bit support.  It's similar to what you
# would get if the shebang (#!) line is broken.
#

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
cd ~
git clone https://github.com/wcyuan/compiler-class.git
cd compiler-class
git config --global push.default simple
git config --global user.name "Conan Yuan"
git config --global user.email conanyuan@gmail.com
 
