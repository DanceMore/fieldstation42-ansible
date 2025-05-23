#!/bin/sh

ansible-playbook -i "hostname," -u root main.yml --become-user root
