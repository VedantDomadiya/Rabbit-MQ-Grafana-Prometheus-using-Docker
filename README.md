Plan:

1. On an internet-connected machine, pull images and configs.
2. `docker save` the images to a single tar file (or multiple).
3. Copy tar file(s) to the offline VM (USB, scp over an internal network, etc).
4. On the offline VM `docker load` them, then `docker-compose up -d`.


* a `build-offline-bundle.sh` script to run on the internet machine (pulls images, saves to tar)
* a `install-offline.sh` script to run on the offline VM (loads images, runs compose)
* a `docker-compose.yml` for RabbitMQ 4.1, Prometheus, Grafana and a RabbitMQ exporter
* a minimal `prometheus.yml` target config

## 1) build-offline-bundle.sh (run on internet-connected machine)

Save this locally and run it where Docker can pull images.

**Notes**

* Replace the Grafana/Prometheus/exporter tags with the exact versions you want. I’ve included example tags; you should pin to exact tags you’ve tested.

## 2) docker-compose.yml (example)

Save next to the above scripts (this is what the offline `docker-compose` will start):


**Notes**

* `rabbitmq:4.1-management` is the tag for the 4.1 management image (official). I checked RabbitMQ Docker tags and the 4.1-management tag exists. ([Docker Hub][6])
* The exporter image is one of several choices. Change to an exporter you prefer and ensure it’s included in the `docker save` bundle.

## 3) prometheus.yml (basic)

Place this alongside compose:


## 4) install-offline.sh (run on the air-gapped VM)

This script assumes Docker and docker-compose are already installed on the target VM. If not, see "Installing container runtime offline" below.

**Important:** For Docker Compose, prefer the built-in `docker compose` (v2). If your target VM has older `docker-compose` binary, use that.

---

# C — Air-gapped gotchas & alternatives

1. **Container runtime must be present on the VM.**

   * If it’s not, either ship the Docker engine packages (OS-specific .deb/.rpm) with the bundle, or create a golden VM image that already has Docker installed. Installing Docker offline means collecting all OS-level package dependencies — easier to create a VM image if you control the VM template. Docker docs describe how to install but you’ll need the correct packages for your distro.

2. **Erlang dependency / binary RabbitMQ package complexity**

   * If you go native package route (non-container), RabbitMQ depends on Erlang/OTP and compatibility matters (see RabbitMQ Erlang compatibility guide). Shipping RabbitMQ + Erlang deb/rpm packages is possible but more fragile than containers. ([RabbitMQ][7])

3. **Large transfers**

   * Docker images and VM images can be large. Use compression `gzip` or split into parts if you must move via small media. `docker image save` + `gzip` reduces transfer size.

4. **Local private registry**

   * If you’re installing many VMs in the same air-gapped network, spin up a local registry (one-time), `docker load` + `docker tag` + `docker push` into the local registry, and have other VMs pull from it. This is convenient at scale.

5. **Testing**

   * Test the bundle on a local VM before shipping. Verify versions, exporter connectivity, and Grafana dashboards.

---
