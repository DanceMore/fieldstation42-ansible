#!/bin/sh

echo "[!] this is documentation right now, you can do better."
exit 1

# as root
apt install python3.11-venv

# as any user, maybe root if you wanna be lazy
mkdir ansible
cd ansible
python3 -m venv .
source bin/activate
pip install ansible

# you will always have to be in ansible/ and `source bin/activate` first.
# also yes that comma matters
ansible-playbook -c local -i localhost, example.yml
