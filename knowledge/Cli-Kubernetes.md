# **MicroK8s Frequently Asked Questions**

### ConfigMaps

To interact with a Kubernetes ComfigMap using kubectl from a Unix environment (such as Linux or macOS), you can use several variations of the kubectl get command depending on how much detail you need to extract.

A Kubernetes ConfigMap is an API object used to store non-confidential configuration data in key-value pairs. It allows you to decouple your environment-specific configuration from your container images, making your applications highly portable. By using ConfigMaps, you can run the exact same container image in development, staging, and production environments without needing to rebuild or alter your application code.

#### How Pods Consume ConfigMaps

Containers inside a Kubernetes Pod can read and ingest data from a ConfigMap in four main ways.

***Environment Variables:*** Injecting specific key-value pairs as environment variables into the container.

***Volume Mounts:*** Mounting the ConfigMap into the container's file system as a read-only volume. Each key in the ConfigMap automatically becomes an individual file, and its value becomes the file's content.

***Command-Line Arguments:*** Passing variables dynamically into a container’s startup command (command or args).

***Kubernetes API:*** Writing application code that queries the Kubernetes API directly to pull configuration parameters.

#### ConfigMaps vs. Secrets

While ConfigMaps and Secrets function very similarly, they have entirely different security expectations.
 
|Feature      |ConfigMap   |Secret   |
|-------------|------------|---------|
|Purpose      | Stores plain, non-sensitive configuration data. | Stores sensitive, confidential information.|
|Example Data | Database hostnames, log levels, port numbers, feature flags.| Passwords, API tokens, SSH keys, TLS certificates.| 
Security      | Stored in plain text within the cluster. | Obfuscated/Base64-encoded by default; can be encrypted at rest and locked down with RBAC.

#### Key Limitations & Behavior

+ ***Size Limit:*** A ConfigMap is restricted to a maximum size of 1 MiB. It is meant for light properties or configuration files, not large files or database dumps.

+ ***Namespace Scoped:*** A ConfigMap exists within a specific namespace. A Pod can only reference or consume ConfigMaps that live in that exact same namespace.

+ ***Updates and Restarts:*** If you update a ConfigMap, values mounted as a volume will update automatically inside the container after a short delay. However, values injected as environment variables will never update unless the Pod is restarted. Even with volume updates, your application code must actively watch for file modifications to read the new changes without a manual restart.

#### List all ConfigMaps

To see a basic list of what ConfigMaps exist in your current namespace, run.

`kubectl get configmaps`

View a specific ConfigMap in YAML format.

`kubectl get configmap <configmap-name> -o yaml`

Extract a single specific key's value using jsonpathUnix environments heavily rely on automation. If you need to grab just one specific configuration value and save it directly into a Unix environment variable, use a jsonpath expression.

`export MY_VALUE=$(kubectl get configmap <configmap-name> -o jsonpath='{.data.YOUR_KEY_NAME}')`
`echo "${MY_VALUE}"`

Export a ConfigMap's contents directly into a Unix .env file.

`kubectl get configmap <configmap-name> -o jsonpath='{.data}' | jq -r 'to_entries | .[] | "\(.key)=\(.value)"' > k8s.env`

If you don't need to pass the output to another file or script and just want a human-readable summary of the keys, you can use describe.

`kubectl describe configmap <configmap-name>`

### Checking and Modifying Limits

The overall capacity depends directly on how your cluster is configured across individual worker nodes. The official scalability guidelines set by the Kubernetes Project include the following thresholds:

+ 110 pods maximum per node (default limit)
+ 5,000 nodes maximum per cluster
+ 150,000 total pods maximum per cluster
+ 300,000 total containers maximum per cluster

#### Check current node capacity

`kubectl get nodes -o custom-columns=NODE:.metadata.name,MAX_PODS:.status.capacity.pods`

To increase the limit: The 110-pod default limit is a software setting rather than a hard physical restriction. You can increase it by modifying the maxPods value in the Kubelet configuration file on your worker nodes. 

**Note:** Managed cloud providers also support scaling this up; for instance, Google Kubernetes Engine (GKE) allows configuring up to 512 pods per node depending on your network layout.

***Important***: If you decide to bypass the defaults and run a higher density of pods, you must ensure your nodes have sufficient CPU, memory, and IP address allocation (CIDR blocks) to handle the network routing and resource overhead.

#### Check Kubernetes and Pod Details

Run a describe command on the stuck or creating pod to view the real-time event sequence, such as image pulling or mounting volumes.

`microk8s kubectl describe pod <pod-name> -n <namespace>`

To see cluster-wide recent events leading up to the creation state.

`microk8s kubectl get events --sort-by='.metadata.creationTimestamp'`

#### Inspect Underlying Containerd Runtime

MicroK8s uses containerd as its container runtime. You can query container states or use the bundled ctr tool.

`microk8s ctr -n k8s.io containers ls`


### Kubectl Memory/CPU Usage

View memory/CPU for all pods in the current namespace

`kubectl top pod`

 View all pods across ALL namespaces

`kubectl top pod -A`

View individual container metrics inside the pods

`kubectl top pod --containers`

Sort pods to find the highest memory consumers

`kubectl top pod --sort-by=memory`

### Kubectl Nodes

View aggregated memory and CPU usage for all physical/virtual nodes.

`kubectl top node`

### Kubectl Disk and Storage Usage

To mounted disk space.

`kubectl exec -it <pod-name> -- df -h`

Then execute on the mounted path directly.

`kubectl exec -it <pod-name> -- df -h /path/to/mount`

### Disk Pressure via Describe

If you suspect a cluster node is running out of local disk space, inspect the node conditions to see if a DiskPressure warning is triggered.

`kubectl describe node <node-name>`

### Check Metrics Server

`kubectl get deployment metrics-server -n kube-system`

### View Taints on a Node

To see if a node currently has any taints, you can inspect it using the describe command.

`kubectl describe node <node-name> | grep -A5 Taints`

Or, list all nodes with formatted output.

`kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints`
