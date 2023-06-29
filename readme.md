# How to run

## pre-requisites

### windows
If you are on windows, you need to install [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) and [Docker Desktop](https://www.docker.com/products/docker-desktop) to run this project.


### linux
If you are on linux, you need to install [Docker](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/) to run this project.

To set this up on your machine, you need to run the following commands:

DISCLAIMER: The following commands have been tested on debian 11, running on a hetzner dedicated server. If you are running a different distro, you might need to adapt the commands to your needs.

```bash
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt update
sudo apt-get install ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $(whoami)

```


## running the project in linux

### one liner
Fast and easy to run, optionally in a screen or tmux session.
```bash
mkdir x1
docker run -v x1:/home/opera bok11/x1-validator
```

### systemd service
Running the validator as a systemd service will make sure it is always running in the background uless stopped, even after a reboot.

```bash
DATADIR=/x1
USER=$(whoami)
sudo tee /etc/systemd/system//x1-validator.service << EOF
[Unit]
Description=x1-validator

[Service]
TimeoutStartSec=0
User=$USER
Restart=always
ExecStartPre=-/usr/bin/docker exec %n stop
ExecStartPre=-/usr/bin/docker rm %n
ExecStartPre=/usr/bin/docker pull bok11/x1-validator:latest
ExecStart=/usr/bin/docker run --rm --name %n \
    -v $DATADIR:/home/opera \
    bok11/x1-validator:latest

[Install]
WantedBy=default.target
EOF

sudo systemctl enable x1-validator.service
sudo systemctl start x1-validator.service
```

You can check the status of the service with `sudo systemctl status x1-validator.service` and stop it with `sudo systemctl stop x1-validator.service`.
To see the logs, run `sudo journalctl -u x1-validator.service -f`.


