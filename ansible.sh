ansible localhost -i inventory -m setup | less # run command
ansible-playbook playbook.yml -i inventory -vvvv # run playbook
ansible-playbook playbook.yml -i inventory -vv -t nginx

# playbook sample
- hosts: localhost
  vars:
    root_dir: 'HELLO_WORLD'
  tasks:
    - shell: uptime
    - name: create directory
      file: path=/tmp/hey state=directory

    - template: src=templates/nginx.conf.j2 dest=/etc/nginx.conf
      tags: nginx
      sudo: yes
