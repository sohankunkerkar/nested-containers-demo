# Nested Containers with Kubernetes and CRI-O

This guide will help you set up **nested containers** using **CRI-O** as the container runtime in a Kubernetes cluster. We will walk through the prerequisites, configuration steps, and how to spin up a pod that runs nested containers.

## Pre-requisites

Ensure your environment meets the following requirements:

- **Kubernetes 1.30+**
- **CRI-O 1.30+**
- **container-selinux 2.234.2**
- **Kernel 5.12+** (with `UserNamespaces` support)
- **crun 1.16+**

## Setup Steps

### 1. Configure CRI-O

You need to configure **CRI-O** to enable the nested containers feature. Here’s an example configuration:

```ini
[crio.runtime]
default_runtime = "crun"
allowed_devices = [
  "/dev/fuse",
  "/dev/net/tun",
]

[crio.runtime.runtimes.crun]
allowed_annotations = [
    "io.kubernetes.cri-o.Devices",
]

```
Make sure to include this configuration in your CRI-O configuration file (crio-nested.conf) and set the path accordingly.

### 2. Start CRI-O

Run CRI-O with your configuration:

```bash
$ sudo ./bin/crio --config crio-nested.conf
```

### 3. Set Up Your Kubernetes Cluster

Use the provided `hack-test.sh` script to set up your Kubernetes cluster. This will start the Kubernetes cluster with necessary feature gates enabled. Feature gates such as `UserNamespacesSupport`, `ProcMountType`, and `UserNamespacesPodSecurityStandards` are enabled in the Kubernetes setup to ensure compatibility with nested containers.

### 4. Apply the Pod YAML
Once the cluster is set up, you can create a pod to run your nested container. Below is an example of a Pod YAML definition that runs nested containers:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: userns
  annotations:
    # /dev/fuse is required to use fuse-overlayfs, which is more performant than vfs.
    # /dev/net/tun is required to use networking with a masked proc
    io.kubernetes.cri-o.Devices: "/dev/fuse,/dev/net/tun"
spec:
  containers:
  - name: userns
    image: quay.io/cgruver0/che/ocp-4-17-userns-tp:latest
    args:
      - sleep
      - "1000000"
    securityContext:
      runAsUser: 1000
      procMount: Unmasked
      seLinuxOptions:
        type: container_engine_t
      allowPrivilegeEscalation: true
      capabilities:
        add:
          - SETUID
          - SETGID
  hostUsers: false

```

### 5. Deploy and access the Pod

```bash
$ kubectl apply -f nested-containers.yml

$ kubectl get po -w

$ kubectl exec -it userns -- sh
```

### 6. Run Nested Containers (Example with Podman)

```bash
$ podman run -d --rm --name webserver -p 8080:80 quay.io/libpod/banner

$ curl http://localhost:8080

   ___          __              
  / _ \___  ___/ /_ _  ___ ____ 
 / ___/ _ \/ _  /  ' \/ _ `/ _ \
/_/   \___/\_,_/_/_/_/\_,_/_//_

```

## Credits

This tutorial is based on the following resources:

- [OCP 4.17 Nested Container Tech Preview](https://github.com/cgruver/ocp-4-17-nested-container-tech-preview)
- Red Hat blogs on [Podman in Kubernetes](https://www.redhat.com/en/blog/podman-inside-kubernetes)
- Red Hat blogs on [Podman in Containers](https://www.redhat.com/en/blog/podman-inside-container)
