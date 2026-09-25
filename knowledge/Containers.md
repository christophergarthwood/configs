# **Containers Frequently Asked Questions (FAQ)**

[TOC]

## Containers

### Overview

+ OSA builds containers using OpenShift and Tekton with OCI-compliant, rootless builders.

+ Docker and Podman produce standard, engine-agnostic container images.

+ Dockerfiles define how images are built and are portable across tools.

+ Compose files describe how containers are run together and are optional. The same configuration can be provided directly via a container run command.

+ Docker CE cannot be made FIPS-compliant internally we would have to create a distict new product. (super nuanced and complicated issue for me at least.)

### How OSA Builds Containers (OpenShift + Tekton)

OSA builds container images using OpenShift pipelines powered by Tekton. These pipelines use OCI-compliant image builders such as Buildah, not Docker. The resulting images are portable and behave the same regardless of the tool used to build them or the tool to run them.

### OCI

The Open Container Initiative is an open governance structure for the express purpose of creating open industry standards around container formats and runtimes.

Established in June 2015 by Docker and other leaders in the container industry, the OCI currently contains three specifications: the Runtime Specification (runtime-spec), the Image Specification (image-spec) and the Distribution Specification (distribution-spec). The Runtime Specification outlines how to run a “filesystem bundle” that is unpacked on disk. At a high-level an OCI implementation would download an OCI Image then unpack that image into an OCI Runtime filesystem bundle. At this point the OCI Runtime Bundle would be run by an OCI Runtime.

CRI-O is a lightweight, Open Container Initiative (OCI) compliant, container runtime for Kubernetes.  CRI-O is meant to provide an integration path between OCI conformant runtimes and the Kubelet. Specifically, it implements the Kubelet Container Runtime Interface (CRI) using OCI conformant runtimes.  It is designed to run any OCI-based container, it is optimized for Kubernetes and committed to being stable and conformant with the Kubernetes container runtime interface with each Kubernetes release.  CRI-O is also now fully supported in OpenShift, Red Hat’s enterprise Kubernetes container platform.

### Docker vs Podman: What They Are and Why It Doesn’t Matter for Containers

Docker and Podman are tools used to build and run containers, they do not define what a container is. Containers are Linux processes isolated by namespaces and constrained by cgroups, using a packaged filesystem an "image". The Linux kernel enforces the isolation.

Docker is a full container platform built around a daemon-based architecture, bundling image building, container runtime, networking, and ecosystem tooling.

Podman is a daemonless container engine focused on tighter OS integration and rootless execution. Despite architectural differences, both tools build and run OCI-compliant images and support the same Dockerfile syntax. A Dockerfile is not Docker-specific; it is a portable build recipe. The same Dockerfile can be built by Docker, Podman, Buildah (used by OpenShift), BuildKit (used by web.git.mil shared runners), or other OCI-compliant builders to produce functionally equivalent images. Containers do not retain any knowledge of which tool built them. As long as an approved, compliant builder is used, the resulting container behaves the same.

### Where Compose Fits (compose.yml)

A Compose file does not build or change containers. It is a declarative configuration that describes how multiple containers should be run together like Images, environment variables, ports, volumes, networks, and startup order. Compose does not change the container image or its contents. It translates configuration into runtime commands for the underlying container engine. Docker Compose, Podman Compose, and similar tools all consume the same Compose specification and produce equivalent runtime behavior. Compose is optional. Anything expressed in a Compose file can also be executed directly using a single container run command by specifying the same environment variables, volume mounts, port mappings, and network options on the command line. Compose exists primarily for ease and to improve readability, reuse, and operational consistency not because it introduces new functionality.

###  Why "Docker CE" Still Cannot Be Made FIPS-Compliant Internally

Docker Community Edition (CE) cannot be made FIPS-compliant without substantial software modification. FIPS compliance requires either a CMVP-validated cryptographic module or a vendor-supported FIPS mode built around such a module.

Docker Enterprise, and now Mirantis Container Runtime (MCR), achieved FIPS support by changing the software and productizing a FIPS-mode variant. Mirantis maintains a CMVP-validated cryptographic module (“Mirantis Cryptographic Module NG,” FIPS 140-2 Level 1) Certificates (NIST): #3993, #3304, which is used by FIPS-mode builds of MCR distributed through a dedicated update channel. These builds enforce FIPS behavior at runtime and operate only in supported configurations.

 Docker CE does not include a validated cryptographic module, does not come with FIPS 140-2 Validation. As a result, Docker CE cannot be considered FIPS-compliant in its current form.  Achieving a comparable posture internally would require creating and maintaining a Docker-derived product with a dedicated FIPS-mode build, integration with a validated cryptographic module, defined cryptographic boundaries, and sustained vendor compliance ownership. At that point, it would no longer be Docker CE but a distinct product.

### References:

+ [Docker](https://www.docker.com/)
+ [Podman](https://podman.io/)
+ [Docker Compose](https://docs.docker.com/compose/)
+ [Open Containers Initiative (OCI)](https://opencontainers.org/)
+ [RedHat Blog: Crictl Vs Podman](https://www.redhat.com/en/blog/crictl-vs-podman)
+ [CRI-O](https://github.com/cri-o/cri-o)
