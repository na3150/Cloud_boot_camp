#cloud-boothook
#!/bin/sh
ansible-playbook --connection=local --inventory 127.0.0.1, --limit 127.0.0.1 /home/ec2-user/wordpress.yaml -b
