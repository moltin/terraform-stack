# Changelog


## 0.1.7 (2017-08-01)

### Changes

* Bump version of terraform modules to 0.2.2. [Israel Sotomayor]


## 0.1.6 (2017-06-10)

### Changes

* Bump version of terraform modules to 0.2.0. [Israel Sotomayor]

* Assign ingress cidr blocks on bastion ssh sg. [Israel Sotomayor]

### Fix

* Editorconfig file Makefile rule. [Israel Sotomayor]


## 0.1.5 (2017-05-19)

### New

* Backup and maintenance options. [Israel Sotomayor]

### Changes

* Update source URL to use SSH auth + ref version. [Israel Sotomayor]


## 0.1.4 (2017-05-18)

### Fix

* Avoid recreation of hosts if Ubuntu AMI gets updated. [Israel Sotomayor]

  See more info in this Terraform [issue](https://github.com/hashicorp/terraform/issues/13044#issuecomment-289046234)

* Editorconfig file. [Israel Sotomayor]

* Forgotten spaces on Makefile. [Israel Sotomayor]


## 0.1.3 (2017-05-17)

### New

* Add editorconfig support. [Israel Sotomayor]

* Bastion support. [Israel Sotomayor]

### Changes

* Add changelog support improve pulling extra docs. [Israel Sotomayor]


## 0.1.2 (2017-04-27)

### Changes

* Dont force private or public subnets instead let the user decide. [Israel Sotomayor]


## 0.1.1 (2017-04-27)

### Changes

* Place db cluster on private subnet instead on the public ones. [Israel Sotomayor]


