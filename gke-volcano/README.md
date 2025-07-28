# A3Mega Deepseek benchmar steps
## Setup Volcano in GKE
Install volcano Oeprator
```bash
kubectl apply -f https://raw.githubusercontent.com/volcano-sh/volcano/master/installer/volcano-development.yaml
```
Apply the resource quota:
```bash
Kubectl apply -f https://raw.githubusercontent.com/llm-on-gke/torchtitan/refs/heads/main/gke-vcl/resource-quota.yaml
```
Make sure the volcano pods running:

kubectl get po -n volcano-system
NAME                                       READY   STATUS      RESTARTS   AGE
pod/volcano-admission-5bd5756f79-p89tx     1/1     Running     0          6m10s
pod/volcano-admission-init-d4dns           0/1     Completed   0          6m10s
pod/volcano-controllers-687948d9c8-bd28m   1/1     Running     0          6m10s
pod/volcano-scheduler-94998fc64-9df5g      1/1     Running     0          6m10s

## Build torchtitan container image:
cloudbuild.yaml and Dockerfile in root directory:
```bash
git clone https://github.com/llm-on-gke/torchtitan.git
cd $HOME torch
gcloud builds submit . --region=us-east1
```bash

## Setup Volcano job task,
job file is under gke-volcano/a3mega-job.yaml

### Update the following, line 22 replicas=1 for master, line 128, adjust for number of workers. Altogether is total number of A3mega nodes, one for master
### The default training parameters files:
Deepseek v3 16b: torchtitan/models/deepseek_v3/train_configs/deepseek_v3_16b.toml

Deepseek v3 671b: torchtitan/models/deepseek_v3/train_configs/deepseek_v3_671b.toml
### Update a3mega-job.yaml file, 
Line 94, CONFIG_FILE="/gcs-dir/configs/deepseek_v3_16b.toml" ./run_train.sh
Line 202, CONFIG_FILE="/gcs-dir/configs/deepseek_v3_16b.toml" ./run_train.sh
replace both line with you own config file and path, default one is ./torchtitan/models/deepseek_v3/train_configs/
You can store your own config files on GCS fuse, since you may keep updating config file and run_train.sh file

## Run Volcano job task,
kubectl apply -f a3mega-job.yaml

The logs will provide MFU benchmark per 10 steps.




