!#/bin/bash

if [ ! -f ".ran" ]; then
  distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
        && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
        && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
              sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
              sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
  sudo apt-get update
  sudo apt-get install -yq docker.io nvidia-container-toolkit nvidia-driver-520
  sudo usermod -aG docker ubuntu
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker
  sudo systemctl enable docker

  # Create .ran file to so that the script doesn't run again on next boot
  touch > /.ran
fi
