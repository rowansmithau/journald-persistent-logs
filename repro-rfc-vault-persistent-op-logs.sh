#!/usr/bin/env bash

# a script to configure an environment in line with the Vault RFC to persist operational logs
# designed to be run on a node without vault installed

sudo tee /etc/systemd/journald@vault.conf <<EOF
[Journal]
Storage=persistent
SystemMaxUse=1G
MaxRetentionSec=1month
EOF

if [ "$(which yum 2>/dev/null)" ]; then
  wget -O- https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo | sudo tee /etc/yum.repos.d/hashicorp.repo
elif [ "$(which apt 2>/dev/null)" ]; then
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg &&
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update
else
  echo "not rpm or deb based distro, exiting"
fi

if [ "$(which yum 2>/dev/null)" ]; then
  sudo yum -y install vault-enterprise
elif [ "$(which apt 2>/dev/null)" ]; then
  sudo apt -y install vault-enterprise
else
  echo "not rpm or deb based distro, exiting"
fi

sudo sed -i '32 i LogNamespace=vault' /usr/lib/systemd/system/vault.service
sudo systemctl daemon-reload

echo "#######################################################################################"
echo "### Vault Enterprise is now installed                                               ###"
echo "###                                                                                 ###"
echo "### /usr/lib/systemd/system/vault.service has been modified with LogNamespace=vault ###"
echo "###                                                                                 ###"
echo "### Next you should configure your Vault license and start the Vault service        ###"
echo "###                                                                                 ###"
echo "### Once running view the Vault logs using 'journalctl -u vault --namespace=vault'  ###"
echo "#######################################################################################"