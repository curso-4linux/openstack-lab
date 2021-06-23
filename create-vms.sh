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

### 05 - Reserva endereços estáticos para as instâncias controller, compute1 e compute2
gcloud compute addresses create controller compute1 compute2 --region=us-central1 --quiet

### 06 - Cria discos adicionais para as instâncias block1, object1 e openstack-object-storage2
gcloud compute disks create block1-disk2 block1-disk3 \
 object1-disk2 object1-disk3 \
 object2-disk2 object2-disk3 \
 --type=pd-balanced --size=80GB --zone=us-central1-b --quiet

### 07 - Cria a instância controller com 4 vCPUs e 15 GB de memória e ip estático 
IP_CONTROLLER=$(gcloud compute addresses list --filter="name= ( 'controller' )" | awk -F" " '{print $2}' | tail -1)
gcloud compute instances create controller --zone us-central1-b --image=openstack-image-base --machine-type=n1-standard-4 --boot-disk-size=100GB --private-network-ip=10.128.0.30 --address $IP_CONTROLLER

### 08 - Cria a instância compute1 com 4 vCPUs e 15 GB de memória e ip estático 
IP_COMPUTE1=$(gcloud compute addresses list --filter="name= ( 'compute1' )" | awk -F" " '{print $2}' | tail -1)
gcloud compute instances create compute1 --zone us-central1-b --image=openstack-image-base --machine-type=n1-standard-4 --boot-disk-size=100GB --private-network-ip=10.128.0.31 --address $IP_COMPUTE1

### 09 - Cria a instância compute2 com 4 vCPUs e 15 GB de memória e ip estático 
IP_COMPUTE2=$(gcloud compute addresses list --filter="name= ( 'compute2' )" | awk -F" " '{print $2}' | tail -1)
gcloud compute instances create compute2 --zone us-central1-b --image=openstack-image-base --machine-type=n1-standard-4 --boot-disk-size=100GB --private-network-ip=10.128.0.32 --address $IP_COMPUTE2

### 10 - Cria a instância block1 com 2 vCPUs, 8 GB de memória, ip estático e 2 discos adicionais de 80GB cada  
gcloud compute instances create block1 --zone us-central1-b --image=openstack-image-base --machine-type=e2-standard-2 --boot-disk-size=50GB --disk=name=openstack-block1-disk2 --disk=name=block1-disk3 --private-network-ip=10.128.0.33

### 11 - Cria a instância file com 2 vCPUs, 7.5 GB de memóriae ip estático  
gcloud compute instances create file --zone us-central1-b --image=openstack-image-base --machine-type=n1-standard-2 --boot-disk-size=50GB --private-network-ip=10.128.0.34

### 12 - Cria a instância object1 com 2 vCPUs, 8 GB de memória, ip estático e 2 discos adicionais de 80GB cada 
gcloud compute instances create object1 --zone us-central1-b --image=openstack-image-base --machine-type=e2-standard-2 --boot-disk-size=50GB \
 --disk=name=object1-disk2 --disk=name=object1-disk3 --private-network-ip=10.128.0.35
 
### 13 - Cria a instância object2 com 2 vCPUs, 8 GB de memória, ip estático e 2 discos adicionais de 80GB cada 
gcloud compute instances create object2 --zone us-central1-b --image=openstack-image-base --machine-type=e2-standard-2 --boot-disk-size=50GB \
 --disk=name=object2-disk2 --disk=name=object2-disk3 --private-network-ip=10.128.0.36
