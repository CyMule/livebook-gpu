# Livebook GPU

This repo lets you launch [Livebook](https://github.com/livebook-dev/livebook) in under 10 minutes on Google Cloud with a GPU.

# Prerequisites

1. [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

2. [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)
   - `gcloud auth login`
   - `glcoud config set project $YOUR_PROJECT`

# Running

1. Clone the repo.
    ```bash
    git clone https://github.com/CyMule/livebook-gpu.git
    cd livebook-gpu
    ```

2. Initialize the Terraform configuration.
    ```bash
    terraform init
    ```

3. Edit [variables.tf](/variables.tf) to set the desired values for the following variables:
    - project_id- The id of your GCP project. Find it [here](https://console.cloud.google.com/cloud-resource-manager) or your can [create a new one](https://console.cloud.google.com/projectcreate)
    - region- Where your node will be created. You may need to change this depending on availability.
    - zone- Deployment area within a region. You may need to change this depending on availability.
    - ssh_key- Path to the ssh private key you want to use to ssh into the node.
    - machine_type- The machine type to use for the VM.
    - gpu_type- The type of GPU to use for the VM.
    - num_gpus- The number of GPUs to use for the VM.
    - disk_size- The size of the disk in GB.


4. Preview what will be created from the configuration.
    ```bash
    terraform plan
    ```

5. Apply the Terraform configuration to start the GPU instance.
    ```bash
    terraform apply
    ```

6. Copy and run the connection string that is output from the previous step.
This will forward traffic your host's port 8080 and 8081 through the ssh tunnel on port 22 to the GPU node's port 8080 and 8081.

    **You will need to wait about 7 minutes for the GPU drivers to install. You will be able to connect in the meantime, but you will need to run `newgrp` after waiting 7 minutes.**
        
    It will look like this:
    ```bash
    ssh -i /path/to/private/key -L 8080:localhost:8080 ubuntu@1.2.3.4
    ```

7. Run the following command and wait for it to stop.
    ```bash
    timeout 10m bash -c 'while [ ! -f "/.ran" ]; do echo "Waiting for installation for $SECONDS seconds" && sleep 5; done; echo Done && newgrp docker'
    ```

8. After waiting, start livebook, and click the livebook url.
    ```bash
    docker run --gpus all -p 8080:8080 -p 8081:8081 --pull always -u $(id -u):$(id -g) -v $(pwd):/data livebook/livebook:latest-cuda11.8
    ```

8. Sling some code at your GPU.

# Troubleshooting

There is a decent chance you get the error:
```
Error: Error waiting for instance to create: The zone 'projects/your-project-id/zones/us-east1-c' does not have enough resources available to fulfill the request.  Try a different zone, or try again later.
```

First I recommend cycling through the available zones for a region, (i.e trying `us-east1-c`, then `us-east1-d` etc.). Then try a different region from the [list of GPU regions/zones](https://cloud.google.com/compute/docs/gpus/gpu-regions-zones).

Maybe some day I will find a better way. These commands show resources that COULD BE available not that actual resources that are at the moment.

`gcloud compute machine-types list --filter="zone:us-central1-a"`

`gcloud compute accelerator-types list --filter="name=nvidia-tesla-t4 AND zone:us-central1-*" --format="value(name,zone,acceleratorCount)"`

