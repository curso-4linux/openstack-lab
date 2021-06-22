#!/bin/bash

### 01 - Cria a instância openstack-vm-temp com Ubuntu 20.04 LTS
gcloud compute instances create openstack-vm-temp --image-family=projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts --zone=us-central1-b --boot-disk-size=50GB --quiet

### 02 - Para a instância openstack-vm-temp
gcloud compute instances stop openstack-vm-temp  --zone=us-central1-b --quiet

### 03 - Cria a image openstack-image-base a partir do disco da instância openstack-vm-temp
gcloud compute images create openstack-image-base \
  --source-disk=openstack-vm-temp --source-disk-zone=us-central1-b \
  --licenses="https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"

### 04 - Deleta a instância openstack-vm-temp
gcloud compute instances delete openstack-vm-temp --zone=us-central1-b --quiet

### 05 - Reserva endereços estáticos para as instâncias openstack-controller, openstack-compute1 e openstack-compute2
gcloud compute addresses create openstack-controller openstack-compute1 openstack-compute2 --region=us-central1 --quiet

### 06 - Cria discos adicionais para as instâncias openstack-block-storage, openstack-object-storage1 e openstack-object-storage2
gcloud compute disks create openstack-block-storage-disk2 openstack-block-storage-disk3 \
 openstack-object-storage1-disk2 openstack-object-storage1-disk3 \
 openstack-object-storage2-disk2 openstack-object-storage2-disk3 \
 --type=pd-balanced --size=80GB --zone=us-central1-b --quiet

### 07 - Cria a instância openstack-controller com 4 vCPUs e 15 GB de memória e ip estático 
IP_CONTROLLER=$(gcloud compute addresses list --filter="name= ( 'openstack-controller' )" | awk -F" " '{print $2}' | tail -1)
gcloud compute instances create openstack-controller --zone us-central1-b --image=openstack-image-base --machine-type=n1-standard-4 --boot-disk-size=100GB --private-network-ip=10.128.0.30 --address $IP_CONTROLLER \
 --metadata=startup-script=cat\ \<\<\ EOF\ \>\>\ /etc/hosts$'\n'controller\ 10.128.0.30$'\n'compute1\ 10.128.0.31$'\n'compute2\ 10.128.0.32$'\n'block\ 10.128.0.33$'\n'file\ 10.128.0.34$'\n'object1\ 10.128.0.35$'\n'object2\ 10.128.0.36$'\n'EOF$'\n'apt\ update$'\n'apt\ dist-upgrade$'\n'apt\ install\ bridge-utils\ debootstrap\ openssh-server\ tcpdump\ vlan\ python3\ -y --quiet


### 08 - Cria a instância openstack-compute1 com 4 vCPUs e 15 GB de memória e ip estático 
IP_COMPUTE1=$(gcloud compute addresses list --filter="name= ( 'openstack-compute1' )" | awk -F" " '{print $2}' | tail -1)
gcloud compute instances create openstack-compute1 --zone us-central1-b --image=openstack-image-base --machine-type=n1-standard-4 --boot-disk-size=100GB --private-network-ip=10.128.0.31 --address $IP_COMPUTE1 \
 --metadata=startup-script=cat\ \<\<\ EOF\ \>\>\ /etc/hosts$'\n'controller\ 10.128.0.30$'\n'compute1\ 10.128.0.31$'\n'compute2\ 10.128.0.32$'\n'block\ 10.128.0.33$'\n'file\ 10.128.0.34$'\n'object1\ 10.128.0.35$'\n'object2\ 10.128.0.36$'\n'EOF$'\n'apt\ update$'\n'apt\ dist-upgrade$'\n'apt\ install\ bridge-utils\ debootstrap\ openssh-server\ tcpdump\ vlan\ python3\ -y --quiet


### 09 - Cria a instância openstack-compute2 com 4 vCPUs e 15 GB de memória e ip estático 
IP_COMPUTE2=$(gcloud compute addresses list --filter="name= ( 'openstack-compute2' )" | awk -F" " '{print $2}' | tail -1)
gcloud compute instances create openstack-compute2 --zone us-central1-b --image=openstack-image-base --machine-type=n1-standard-4 --boot-disk-size=100GB --private-network-ip=10.128.0.32 --address $IP_COMPUTE2 \
 --metadata=startup-script=cat\ \<\<\ EOF\ \>\>\ /etc/hosts$'\n'controller\ 10.128.0.30$'\n'compute1\ 10.128.0.31$'\n'compute2\ 10.128.0.32$'\n'block\ 10.128.0.33$'\n'file\ 10.128.0.34$'\n'object1\ 10.128.0.35$'\n'object2\ 10.128.0.36$'\n'EOF$'\n'apt\ update$'\n'apt\ dist-upgrade$'\n'apt\ install\ bridge-utils\ debootstrap\ openssh-server\ tcpdump\ vlan\ python3\ -y --quiet


### 10 - Cria a instância openstack-block-storage com 2 vCPUs, 8 GB de memória e 2 discos adicionais de 80GB cada  
gcloud compute instances create openstack-block-storage --zone us-central1-b --image=openstack-image-base --machine-type=e2-standard-2 --boot-disk-size=50GB --disk=name=openstack-block-storage-disk2 --disk=name=openstack-block-storage-disk3 --private-network-ip=10.128.0.33 \
 --metadata=startup-script=cat\ \<\<\ EOF\ \>\>\ /etc/hosts$'\n'controller\ 10.128.0.30$'\n'compute1\ 10.128.0.31$'\n'compute2\ 10.128.0.32$'\n'block\ 10.128.0.33$'\n'file\ 10.128.0.34$'\n'object1\ 10.128.0.35$'\n'object2\ 10.128.0.36$'\n'EOF$'\n'apt\ update$'\n'apt\ dist-upgrade$'\n'apt\ install\ bridge-utils\ debootstrap\ openssh-server\ tcpdump\ vlan\ python3\ -y$'\n'pvcreate\ --metadatasize\ 2048\ /dev/sdb\ /dev/sdc$'\n'vgcreate\ cinder-volumes\ /dev/sdb\ /dev/sdc --quiet

### 11 - Cria a instância openstack-file-storage com 2 vCPUs e 7.5 GB de memória  
gcloud compute instances create openstack-file-storage --zone us-central1-b --image=openstack-image-base --machine-type=n1-standard-2 --boot-disk-size=50GB --private-network-ip=10.128.0.34 \
 --metadata=startup-script=cat\ \<\<\ EOF\ \>\>\ /etc/hosts$'\n'controller\ 10.128.0.30$'\n'compute1\ 10.128.0.31$'\n'compute2\ 10.128.0.32$'\n'block\ 10.128.0.33$'\n'file\ 10.128.0.34$'\n'object1\ 10.128.0.35$'\n'object2\ 10.128.0.36$'\n'EOF$'\n'apt\ update$'\n'apt\ dist-upgrade$'\n'apt\ install\ bridge-utils\ debootstrap\ openssh-server\ tcpdump\ vlan\ python3\ -y --quiet

### 12 - Cria e para a instância openstack-object-storage1 com 2 vCPUs, 8 GB de memória e 2 discos adicionais de 80GB cada 
gcloud compute instances create openstack-object-storage1 --zone us-central1-b --image=openstack-image-base --machine-type=e2-standard-2 --boot-disk-size=50GB \
 --disk=name=openstack-object-storage1-disk2 --disk=name=openstack-object-storage1-disk3 --private-network-ip=10.128.0.35 \
 --metadata=startup-script=cat\ \<\<\ EOF\ \>\>\ /etc/hosts$'\n'controller\ 10.128.0.30$'\n'compute1\ 10.128.0.31$'\n'compute2\ 10.128.0.32$'\n'block\ 10.128.0.33$'\n'file\ 10.128.0.34$'\n'object1\ 10.128.0.35$'\n'object2\ 10.128.0.36$'\n'EOF$'\n'apt\ update$'\n'apt\ dist-upgrade$'\n'apt\ install\ bridge-utils\ debootstrap\ openssh-server\ tcpdump\ vlan\ python3\ -y --quiet

### 13 - Cria e para a instância openstack-object-storage2 com 2 vCPUs, 8 GB de memória  e 2 discos adicionais de 80GB cada 
gcloud compute instances create openstack-object-storage2 --zone us-central1-b --image=openstack-image-base --machine-type=e2-standard-2 --boot-disk-size=50GB \
 --disk=name=openstack-object-storage2-disk2 --disk=name=openstack-object-storage2-disk3 --private-network-ip=10.128.0.36 \
 --metadata=startup-script=cat\ \<\<\ EOF\ \>\>\ /etc/hosts$'\n'controller\ 10.128.0.30$'\n'compute1\ 10.128.0.31$'\n'compute2\ 10.128.0.32$'\n'block\ 10.128.0.33$'\n'file\ 10.128.0.34$'\n'object1\ 10.128.0.35$'\n'object2\ 10.128.0.36$'\n'EOF$'\n'apt\ update$'\n'apt\ dist-upgrade$'\n'apt\ install\ bridge-utils\ debootstrap\ openssh-server\ tcpdump\ vlan\ python3\ -y --quiet
