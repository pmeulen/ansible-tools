# Ansible-tools
Ansible-tools serves as a starting point and an example of an 
[Ansible playbook](http://docs.ansible.com/ansible/playbooks.html) with some tools added that
make it easier to use the same playbooks and roles for multiple **environments**. 

In this context an **environment** is a server or set of servers i.e. your production environment, your staging environment or your local development environment. It is not related to the environment variables like PATH or HOME that are used by an operating system.

Ansible-tools demonstrates a way to use Ansible to effectively and securely manage multiple environments ranging from 
development to production.

Ansible-tools provides:

- Vagrant integration for creating a local development VM
- An automated way to create a new environment, including generating passwords and certificates
- Optional encryption of the passwords and private keys in an environment using a symmetric key (keyczar)

The setup used by Ansible-tools assumes that you will be managing multiple similar environments. It can be used to
manage a single environment of course, and the use of Vagrant and a keyczar based vault is entirely optional.

## Quick start
For a quick start jump to [Create a development VM](#quickstart) below.

# Organisation
Ansible-tools is organised such that it can be used as a starting point for your own Ansible project. It follows
a standard [Ansible playbook](http://docs.ansible.com/ansible/playbooks.html) layout containing:

- The _roles_ directory - containing the roles
- The _filter_plugins_ directory - containing custom Ansible plugins
- A top level Ansible playbook _site.yml_

When compared to a layouts described in the 
[Ansible playbook best practices](http://docs.ansible.com/ansible/playbooks_best_practices.html) you will notice that it 
is "missing" the inventory file(s) and the groups\_vars and host\_vars directories. In the organisation that Ansible-tools 
is promoting these are all part of an environment and are stored in a different part of the directory structure. 

This separation is what allows the configuration that is environment specific to be managed separately from the Ansible 
playbook(s) and roles. Environment specific configuration are things like Hostnames, IP addresses, Firewall rules,
Email addresses, Passwords, private keys, certificates etc.

An environment is a independent directory structure. This allows it to be maintained in a different (git, svn, ...)
repository than the ansible playbooks. For an open source project, this allows open sourcing the Ansible playbooks 
including everything that is required to setup a new environment without revealing any private infrastructure related 
configuration. 

All that is the same between the environments should be put in the playbook(s), and not in an environment:

- Updating a playbook needs only to be done once, updating an environment needs to be done for each environment.
- Because the playbooks are shared by all the environments, they will get more testing.

> Only put the variables and templates that are _different_ between environemnts in the environment. The rest goes in the
> playbook and roles

The other top level directories and files are:

- The _environemnts_ directory containg the template for a new environemnts
- The _scripts_ directory containg the various scripts used to create a new environment and manage secrets and work with
  the Vault
- A _Vagrantfile_ for creating a VM using Vagrant
- _ansible.cfg_ (optional) makes playbooks run faster by enabling SSH pipelining, 
- _provision-vagrant-vm.yml_ playbook used by the Vagrant provisioning step only.


# Creating a new environment
To get started you need an environment. Ansible-tools does not ship with a ready made environment, instead it ships
with the tools to create a new environments. In the environments directory of Ansible-tools you will find two 
directories:

- [template](#templatedir) - the starting point of all new environments
- [vm](#vmdir) - some configuration that matches the included Vagrant file.

## [About the environments/template directory](id:templatedir)
The environments/template directory contains the starting point of a new environment. It is only used during the
creation of a new environment. That means that when you start extending your playbooks, and find that you need to add
variables to a environment, you should also add these variable to the template. It is thus up to you to make sure that
the template is kept up to date as the playbooks evolve over time. Besides a tool for bootstrapping a new environment, 
think of the template as an excellent place to document the use of all variables that go into the environments.

The template directory contains one extra file: "environment.conf". This file contains a specification for the 
passwords and certificates to create when a new environment is created. This file is read by the script that creates
a new environment.

## [About the environments/vm directory](id:vmdir)
The "environments/vm" is not yet a complete environment, it contains just some configuration to work with the Vagrant 
VM. It contains:

* A symlink to the inventory file that was generated by Vagrant
* The static IP address for the VM that was configured in Vagrant

## Creating the environment
The "create_new_environment.sh" script is used to create a new environment based on the template stored in
"environments/template". The script reads the "environment.conf" file from the template. This file contains a 
specification for the passwords and certificates to create for the new environment.

To create a new environment call "create_new_environment.sh" and provide the path to the directory where to create
the new environment. E.g.: 

`$ ./scripts/create_new_environment.sh environments/vm`

This creates a new environment in the "environments/vm" directory. When the specified directory does not exists, 
the directory is created. The script will not overwrite any existing files or directories in the specified environment 
directory. Note that you can create an environemnt directory anywhere. 

The "create_new_environment.sh" script:

- Copies the "group_vars", "handlers", "tasks" and "template" directories from the template
- Generates a passwords, certificates, a keyszar key and root CA a specified in the "environment.conf" in the template.
 
Because it does not overwrite existing files, you can rerun the script to generate a password or certificate when the
"environment.conf" is updated.

## Running an Ansible playbook
When you run "ansible-playbook" you need to provide it with the location of the "inventory" file in the environment. You
do this by specifying its location using the "-i" or "--inventory" in "ansible-playbook" command. W.g.

`$ ansible-playbook site.yml -i environments/vm/inventory`

If you omit the inventory, Ansible will try to use an the inventory file from one of its default locations 
(/etc/ansible/hosts, ./inventory), which is probably not what you want.
 

# [Create a development VM](id:quickstart)
Getting started with a development VM using ansible-tools.

First install the tools:

* Install [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org). Virtualbox will run 
  the development VM and Vagrant is used to create, configure and manage the development VM instance.
* Install [Ansible](http://www.ansible.com). There are several ways to install Ansible. They are described in the 
  [Ansible installation guide](http://docs.ansible.com/ansible/intro_installation.html).

Next change into the "ansible-tools" directory (i.e. where this README is located) and create and start the development VM: 

    $ vagrant up

This prepares a VM that is ready to be managed by Ansible. It will call a simple Ansible playbook to make some changes to the VM. Run `$ vagrant provision` to rerun just the provisioning step and update the inventory.

Create the new environment for the VM:

    $ ./scripts/create_new_environment.sh environments/vm

A starting point for a playbook is provided. Run the playbook "site.yml": 

    $ ansible-playbook site.yml -i environments/vm/inventory

You can login to the VM using `$ vagrant ssh`

# Working with environments from a Playbook
Ansible tools comes with a working example playbook _site.yml_. This playbook applies the _common_ role to a server. 
This common role demonstrates two environment techniques:

- Getting file [templates](#environment_templates) from an environment
- Including [tasks](#environment_files) defined in an environment

Both techniques use the Ansible _inventory_dir_ variable to refer to files from the environment, instead of using files
from the role directory. This is a useful technique for dealing with differences between environments. The goal remains
to put as little as possible in the environment, and to keep most of the functionality in the playbooks and roles.

The example role, is just that, en example. It is not used from the playbook but contains a selection of common Anisble
patterns.

## [Using a template from an environment](id:environment_templates)
Look at _roles/common/tasks/main.yml_. First standard use of a template defined in the role. This tasks uses the
template file from _roles/common/templates/hostname.j2_:

    - name: Set /etc/hostname to {{ inventory_hostname }}
      template: src='hostname.j2' dest='/etc/hostname'

Next an example from the same file of using a template from the environment 

    - name: Put iptables configuration
      template: src={{ inventory_dir }}/templates/common/{{item}}.j2 dest=/etc/iptables/{{ item }}
      with_items:
        - rules.v4
        - rules.v6
      notify:
      - restart iptables-persistent

Note that we use _inventory_dir_ to reference the template. The adopted convention is to store templates under 
_templates/\<role name\>/_ in de environment.

## [Including tasks defined in an environment](id:environment_tasks)
At the end of _roles/common/tasks/main.yml_ tasks from the environment are included: 

    - include: "{{ inventory_dir }}/tasks/common.yml"

Because tasks might need handlers, _roles/common/handlers/main.yml_ includes them from the environment: 

    - include: "{{ inventory_dir }}/handlers/common.yml"

Note the convention used for storing the included tasks and handlers in the environment:

- tasks/\<role name\>.yml
- handlers/\<role name\>.yml

## About the group_vars directory
You may expect there to be a top level _group_vars_ directory next to your _role_ directory. There is none, and when you
add it, you will find that it is not used. This is because _group_vars_ (and _host_vars_) directories are resolved
relative to the _inventory_ directory.

_groups_vars_ go in the environments. This means that when you add a variable, you will have to add it to **all**
environments. This is where the template environment comes in.

## The template environment
The template environment is the prototype of all new environments. During development of your playbooks and roles you
should add the variables, jinja2 templates, files, tasks and handlers that required by your roles and playbooks to the
template environment. 

### Adding a new variable
When you add a variable in the _groups_vars_ directory of an environment, you should add it to the _groups_vars_
in the _environments/template_ directory as well. This way the template serves as a palace to document the use of the
variable for all environments.

> Add all variables that are used to the template environment and document them there

But what value to give to the new variable? Give it a value that works well (i.e. without requiring to be changed) with
the development VM. This allows you to verify that the template is still up to date: create a new vm using the template.
This test can be automated.

> Make the template environment testable: Set the group_var variables in the template to values that immediately work in the 
> vm

Variables used in a role that do not change between environments should not be stored in the environment. These can be
stored in the _vars_ directory of the role in the playbook.
