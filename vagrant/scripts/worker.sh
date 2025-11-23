#!/bin/bash
set -euxo pipefail

# Wait for join command to be available
while [ ! -f /vagrant/join-command.sh ]; do
  echo "Waiting for join command from control plane..."
  sleep 5
done

# Join the cluster
sudo bash /vagrant/join-command.sh

echo "Worker node joined the cluster successfully!"
