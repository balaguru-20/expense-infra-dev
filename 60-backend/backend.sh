#!/bin/bash

dnf install ansible -y
#This is for push
# ansible-playbook -i inventory mysql.yaml

#This is for pull
ansible-pull -i localhost, -U https://github.com/balaguru-20/expense-ansible-roles-tf.git main.yaml -e COMPONENT=backend -e ENVIRONMENT=$1