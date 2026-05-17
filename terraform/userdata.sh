#!/bin/bash
set -x
# Log output to a file for debugging
exec > /var/log/user-data.log 2>&1

echo "Starting EC2 User Data initialization..."

# Wait for apt locks to be released (Ubuntu unattended-upgrades runs on boot)
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  echo "Waiting for dpkg lock..."
  sleep 5
done

# 1. Update & Install Prerequisites
apt-get update -y
apt-get install -y git make software-properties-common

# 2. Install Ansible
apt-add-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible

# 3. Clone Repository
cd /home/ubuntu
git clone https://github.com/Bhavikgadher/DevOps-Hackathon.git
cd DevOps-Hackathon
chown -R ubuntu:ubuntu /home/ubuntu/DevOps-Hackathon

# 4. Run Ansible Playbook locally
# (This installs Docker and adds the ubuntu user to the docker group)
ansible-playbook -c local -i localhost, ansible/playbook.yml

# 5. Run setup_kind.sh
# (This installs Kind and Kubectl)
chmod +x setup_kind.sh
./setup_kind.sh

# Force add ubuntu to docker group (setup_kind.sh adds root)
usermod -aG docker ubuntu

# 6. Run Makefile as the ubuntu user with the docker group active
# 'sg docker' applies the new group permissions instantly without a logout
sudo -u ubuntu bash -c 'sg docker -c "export PATH=$PATH:/usr/local/bin; cd /home/ubuntu/DevOps-Hackathon && make up"'

# 7. Ensure Kubernetes config is properly owned by the ubuntu user
if [ -d "/root/.kube" ]; then
  cp -r /root/.kube /home/ubuntu/
  chown -R ubuntu:ubuntu /home/ubuntu/.kube
fi
if [ -d "/home/ubuntu/.kube" ]; then
  chown -R ubuntu:ubuntu /home/ubuntu/.kube
fi

echo "Initialization Complete!"
# Trigger recreation 4