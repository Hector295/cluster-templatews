# rke2-baremetal-calico

![Version: 1.31.9-wcr.1-rc1](https://img.shields.io/badge/Version-1.31.9--wcr.1--rc1-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

Cluster templates for rke2 with rancher. Kubernetes version: 1.31.9

## Overview

This Helm chart deploys an RKE2 Kubernetes cluster on baremetal infrastructure with Calico CNI. It provides comprehensive configuration for:

- **Control Plane Nodes**: Highly available Kubernetes control plane
- **Worker Nodes**: Configurable worker nodes for workload scheduling 
- **Storage Options**: Longhorn, Ceph, OpenEBS storage providers
- **Add-ons**: Monitoring, logging, virtualization, and infrastructure add-ons
- **Network Configuration**: Calico CNI with optional Multus support

## Installation

```bash
# Download and install the cluster template
helm install rke2-baremetal-calico-1.31.9-wcr.1-rc1.tgz -f custom-values.yaml .

# Or via WhiteCruiser UI using the cluster template
```

## Configuration Examples

### Basic Cluster Configuration

```yaml
cluster:
  name: "production-cluster"
  etcd:
    exposeMetrics: true
    backup:
      disableAutomaticSnapshots: false

controlPlaneNodes:
  nodes:
    - hostname: cp-node-01
      bmc:
        address: 10.1.1.10
      network:
        primaryInterface:
          address: 10.1.2.10

workerNodes:
  nodes:
    - hostname: worker-01 
      bmc:
        address: 10.1.1.20
      network:
        primaryInterface:
          address: 10.1.2.20
```

### Storage Configuration

```yaml
storage:
  longhorn:
    enabled: true
    customValues:
      defaultSettings:
        replicaSoftAntiAffinity: true
       
  cephRBD:
    enabled: false
    clusterID: "your-ceph-cluster-id"
    monitorList:
      - "10.1.1.100:6789"
```

### Add-ons Configuration

```yaml
# Enable monitoring stack
monitoring:
  enabled: true
  customValues:
    prometheus:
      prometheusSpec:
        retention: "30d"

# Enable virtualization
kubevirt:
  enabled: true
  customValues:
    configuration:
      developerConfiguration:
        useEmulation: false
```

## Add-ons Inventory

This chart includes the following add-ons with their default versions:

### Storage Add-ons
| Name | Version | Default Enabled | Description |
|------|---------|----------------|-------------|
| longhorn | 106.2.0-up1.8.1 | ✅ | Longhorn storage |
| longhorn-crd | 106.2.0-up1.8.1 | ✅ | Longhorn custom resource definitions |
| ceph-csi-cephfs | 3.10.2 | ❌ | Ceph filesystem CSI driver |
| ceph-csi-rbd | 3.10.1 | ❌ | Ceph block device CSI driver |
| openebs | 3.10.0 | ❌ | OpenEBS storage |

### Infrastructure Add-ons
| Name | Version | Default Enabled | Description |
|------|---------|----------------|-------------|
| cert-manager | v1.17.1 | ❌ | X.509 certificate management |
| metallb | 0.14.5 | ❌ | Load balancer implementation |
| node-config-operator | 0.2.0 | ❌ | Node config operator |
| ntpd-rs | 1.1.2 | ❌ | Network time protocol daemon |
| sriov-network-operator | 1.5.2-up1.5.0 | ❌ | SR-IOV network device plugin |
| whitesdn-controller | 0.3.0 | ❌ | SDN controller for network management |
| x509-certificate-exporter | 3.18.1 | ❌ | X.509 certificate monitoring |
| kubernetes-power-manager-intel | 2.5.0 | ❌ | Intel CPU power management |
| kubernetes-power-manager-amd | 1.1.0 | ❌ | AMD CPU power management |

### Monitoring Add-ons 
| Name | Version | Default Enabled | Description |
|------|---------|----------------|-------------|
| rancher-monitoring | 106.1.1-up69.8.2-rancher.5 | ❌ | Prometheus monitoring stack |
| rancher-logging | 106.0.1-up4.10.0-rancher.4 | ❌ | Fluentd logging stack |

### Virtualization Add-ons
| Name | Version | Default Enabled | Description |
|------|---------|----------------|-------------|
| kubevirt | 0.5.0 | ❌ | Virtual machine management |
| cdi | 0.5.0 | ❌ | kubevirt crd |
| kubevirt-dashboard-extension | 1.3.1 | ❌ | Rancher UI extension for KubeVirt |

### Default Add-on Configuration

> ⚠️ **Warning**: When using `customValues`, they will completely override the default values shown below. Make sure to include any default settings you want to preserve.

```yaml
# Storage Add-ons
storage:
  longhorn:
    enabled: true  # Default: enabled
    # Default values (applied when customValues is empty):
    # persistence:
    #   defaultClass: false
    # defaultSettings:
    #   replicaSoftAntiAffinity: false
    #   autoDeletePodWhenVolumeDetachedUnexpectedly: true
    #   allowVolumeCreationWithDegradedAvailability: false
    #   replicaAutoBalance: least-effort
    #   storageMinimalAvailablePercentage: 25
    #   storageOverProvisioningPercentage: 200
    #   defaultDataPath: /var/lib/longhorn/
    #   nodeDownPodDeletionPolicy: delete-both-statefulset-and-deployment-pod
    customValues: {}
   
  cephFS:
    enabled: false
    clusterID: "aaaaaaaa-bbbb-1111-2222-33333ccccccc"
    monitorList: []
    pool: "volumes"
    userID: "admin"
    userKey: "AAAAAAAAAAAAAAAAAA/BBBBBBBBBBBBBBBBBBB=="
    provisionerReplicaCount: 3
    reclaimPolicy: "Retain"
    enabledHostNetwork: false
    fsName: ""
    customValues: {}

  cephRBD:
    enabled: false
    clusterID: "aaaaaaaa-bbbb-1111-2222-33333ccccccc"
    monitorList: []
    pool: "volumes"
    userID: "admin"
    userKey: "AAAAAAAAAAAAAAAAAA/BBBBBBBBBBBBBBBBBBB=="
    provisionerReplicaCount: 3
    reclaimPolicy: "Retain"
    enabledHostNetwork: false
    # Default values (applied when customValues is empty):
    # csiConfig:
    # - clusterID: `\{\{ clusterID \}\}`
    #   monitors: `\{\{ monitorList \}\}`
    #   readAffinity:
    #     enabled: true
    #     crushLocationLabels:
    #       - topology.kubernetes.io/region
    #       - topology.kubernetes.io/zone
    # storageClass:
    #   create: true
    #   name: default-ceph-rbd-sg
    #   clusterID: `\{\{ clusterID \}\}`
    #   pool: `\{\{ pool \}\}`
    #   reclaimPolicy: `\{\{ reclaimPolicy \}\}`
    #   encrypted: false
    # secret:
    #   create: true
    #   userID: `\{\{ userID \}\}`
    #   userKey: `\{\{ userKey \}\}`
    # readAffinity:
    #   enabled: true
    # provisioner:
    #   replicaCount: `\{\{ provisionerReplicaCount \}\}`
    #   enableHostNetwork: `\{\{ enabledHostNetwork \}\}`
    # logLevel: 5
    # sidecarLogLevel: 1
    customValues: {}

  openebs:
    enabled: false
    # Default values (applied when customValues is empty):
    # apiserver:
    #   enabled: false
    # localprovisioner:
    #   replicas: 2
    # ndm:
    #   enabled: false
    # ndmOperator:
    #   enabled: false
    # analytics:
    #   enabled: false
    # webhook:
    #   enabled: false
    # snapshotOperator:
    #   enabled: false
    # policies:
    #   monitoring:
    #     enabled: false
    # provisioner:
    #   enabled: false
    customValues: {}

# Infrastructure Add-ons (all disabled by default)

certManager: This addon has no default values
metallb: This addon has no default values
nodeConfigOperator: This addon has no default values
ntpd: This addon has no default values
sriovOperator: This addon has no default values
sdnController: This addon has no default values
x509CertExporter: This addon has no default values
kubernetsPowerManager: This addon has no default values

# Monitoring Add-ons (disabled by default)
monitoring:
  enabled: false
  # Default values (applied when customValues is empty):
  # alertmanager:
  #   enabled: false
  # prometheus:
  #   thanosService:
  #     enabled: true
  #   prometheusSpec:
  #     tolerations:
  #       - key: "node-role.kubernetes.io/control-plane"
  #         operator: "Exists"
  #         effect: "NoSchedule"
  #     externalLabels:
  #       k8s_cluster: cluster.name
  thanos:
    objectStorage:
      accessKey: ""
      bucket: ""
      endpoint: ""
      secretKey: ""
  thanosIngress:
    host: ""
  customValues: {}

logging:
  enabled: false
  # Default values (applied when customValues is empty):
  # rke2:
  #   enabled: true
  # logging:
  #   enableRecreateWorkloadOnImmutableFieldChange: true
  #   enabled: true
  #   clusterFlows:
  #     - name: all-logs
  #       spec:
  #         filters:
  #           - record_modifier:
  #               records:
  #                 - cluster-name: `\{\{ cluster.name \}\}`
  #         globalOutputRefs:
  #           - fluentd-forward
  #         match:
  #           - select: {}
  customValues: {}

# Virtualization Add-ons (disabled by default)
kubevirt:
  enabled: false
  # Default values (applied when customValues is empty):
  # configuration:
  #   developerConfiguration:
  #     useEmulation: true
  customValues: {}
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cluster | object | `{"annotations":{},"etcd":{"backup":{"disableAutomaticSnapshots":true},"exposeMetrics":false,"extraArgs":[]},"kubeComponents":{"kubeApiServer":{"extraArgs":[]},"kubeControllerManager":{"extraArgs":[]},"kubeProxy":{"extraArgs":[]},"kubeShceduler":{"extraArgs":[]},"kubelet":{"extraArgs":[]}},"labels":{},"name":"prod-cluster"}` | RKE2 cluster core configuration |
| cluster.name | string | `"prod-cluster"` | Cluster identifier used for naming resources and certificate generation |
| cluster.etcd | object | `{"backup":{"disableAutomaticSnapshots":true},"exposeMetrics":false,"extraArgs":[]}` | ETCD distributed key-value store configuration |
| cluster.etcd.exposeMetrics | bool | `false` | Enable Prometheus metrics endpoint for ETCD monitoring (port 2381) |
| cluster.etcd.backup | object | `{"disableAutomaticSnapshots":true}` | ETCD backup and snapshot configuration |
| cluster.etcd.backup.disableAutomaticSnapshots | bool | `true` | Disable automatic periodic snapshots (manual snapshots still available) |
| cluster.etcd.extraArgs | list | `[]` | Additional command-line arguments for ETCD server startup |
| cluster.kubeComponents | object | `{"kubeApiServer":{"extraArgs":[]},"kubeControllerManager":{"extraArgs":[]},"kubeProxy":{"extraArgs":[]},"kubeShceduler":{"extraArgs":[]},"kubelet":{"extraArgs":[]}}` | Kubernetes control plane components configuration |
| cluster.kubeComponents.kubeControllerManager | object | `{"extraArgs":[]}` | Controller Manager handles cluster-level functions like replication |
| cluster.kubeComponents.kubeControllerManager.extraArgs | list | `[]` | Additional arguments for controller manager (security, cloud provider, etc.) |
| cluster.kubeComponents.kubeApiServer | object | `{"extraArgs":[]}` | API Server provides the Kubernetes API and validates objects |
| cluster.kubeComponents.kubeApiServer.extraArgs | list | `[]` | Additional arguments for API server (authentication, authorization, etc.) |
| cluster.kubeComponents.kubeShceduler | object | `{"extraArgs":[]}` | Scheduler assigns pods to nodes based on resource requirements |
| cluster.kubeComponents.kubeShceduler.extraArgs | list | `[]` | Additional arguments for scheduler (policies, profiles, etc.) |
| cluster.kubeComponents.kubeProxy | object | `{"extraArgs":[]}` | Proxy handles network rules and load balancing on each node |
| cluster.kubeComponents.kubeProxy.extraArgs | list | `[]` | Additional arguments for kube-proxy (networking mode, IP tables, etc.) |
| cluster.kubeComponents.kubelet | object | `{"extraArgs":[]}` | Kubelet manages pods and containers on each node |
| cluster.kubeComponents.kubelet.extraArgs | list | `[]` | Additional arguments for kubelet (container runtime, logging, security) |
| cluster.labels | object | `{}` | Kubernetes labels applied to all cluster nodes for scheduling and selection |
| cluster.annotations | object | `{}` | Kubernetes annotations applied to all cluster nodes for metadata |
| infraConfig | object | `{"image":{"name":"ubuntu22","url":"http://10.100.100.2/ubuntu-22.iso"},"kernel":{"version":"6.5-generic"},"users":[{"authorized_keys":["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDyQwCd7gKxObBzDV357Nl+oQwMggFg0CseB4NtGvmusH3RLUXRuQqJQ5Keu+FKlRfG0QmBT+WEmr5rLN+LDbGKM54yAUDiJV9lWroOWaSbU8ynO9ZwXhPKgfnfvG/HmGTkfGpUQkfZYOSDetbfKJ7+mFOjDTvncgdErL14JbTXLFQ6vhqxk08a8sdCAxdiX+IJ4fy7jJW3TNqmH3dpE1OfKQe+CwKaksF0wjjXu4O+xj4BWv5a0V3ePOnGD9EVze3HZWkjUGmysGNjW6IayHydIDt1JB9Q6d+pMARQrZ6R4b6ySJ21vv7FwaIZ65kHxT/UMk9fbffhLxV0Dj3s5HKbwZoZU5HhAhj74zcptjer72YygdFs1uf8h5FIrmYAXgYuDfVN76nAUls2PC/jE79xtNxLxP045VerWZVg2fXZRKgqw++Wa5sd0IYmm++SVNV4I/VGSmLmTuxe5oWMPs4FtE78EQkkNYzch3cghxJjsgZiP/KMXlrtEfhInxU3YNc= hector@hector","ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCSIj+UglgxRvkwojlO4ZphGAgvhhrUm/Au165pE472VI5Wt5D5AGiCzt4Gw6J7P/LN+qY/XvP+T6hOf+OERg1AYNSNVX+3YszQBQjDP76PkjsNiNqk2mI1KoLhKzHUBP1mM349mwOQS40Wv+MdoF6YEYzgNVECxPExCo2pjRd6J65exiK5IfJamZVlyxwkDqiWjvhUdRKBc2PqyU7BEYltAmzzVsXiU+dgC4E5dce+OKmtoc0r137CI220TdkQMgeGHojgVQ7bfgovRajLoAcf3ntB2V7gU9gIY2rRKxqbHKyXWWIb/Rb2+w134avbxaFv8CTgTlE8N0h/vHL01Ta0dglQ16EyiC065NN+XctRPUXlaoiOBEN3OeArIjRsmLztleWtLG4/yzslG9V8TlTa0+pMArUeQICRl2OvqGUGmnE6ZIbhxJWhrWGRMbPTklKk2WwiXlc9pcN8mrwfdxYUzUYvn+SOHAXBqTL0N8MDVwcEyNLovpYW8skWWcPXQUH8HkmHlIzwiZd+qXSKOJAcuwcfGwk7MUWOP7NNpD3ltrnNClVIzL8BmaaCuABnNs+Y6rYhlNrscOIcrOH7a3Nbcz2/l2vPI9kvDM0BV8mDxwpOS/FS0BhqA8ry7hfbdLk02lVbXDbQJrAboSZzcR6iXLGAvoYmtNYVttc9t49ahw== luis@tt"],"name":"whitestack","password":"whitestack"}]}` | Baremetal infrastructure and node provisioning configuration |
| infraConfig.users | list | `[{"authorized_keys":["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDyQwCd7gKxObBzDV357Nl+oQwMggFg0CseB4NtGvmusH3RLUXRuQqJQ5Keu+FKlRfG0QmBT+WEmr5rLN+LDbGKM54yAUDiJV9lWroOWaSbU8ynO9ZwXhPKgfnfvG/HmGTkfGpUQkfZYOSDetbfKJ7+mFOjDTvncgdErL14JbTXLFQ6vhqxk08a8sdCAxdiX+IJ4fy7jJW3TNqmH3dpE1OfKQe+CwKaksF0wjjXu4O+xj4BWv5a0V3ePOnGD9EVze3HZWkjUGmysGNjW6IayHydIDt1JB9Q6d+pMARQrZ6R4b6ySJ21vv7FwaIZ65kHxT/UMk9fbffhLxV0Dj3s5HKbwZoZU5HhAhj74zcptjer72YygdFs1uf8h5FIrmYAXgYuDfVN76nAUls2PC/jE79xtNxLxP045VerWZVg2fXZRKgqw++Wa5sd0IYmm++SVNV4I/VGSmLmTuxe5oWMPs4FtE78EQkkNYzch3cghxJjsgZiP/KMXlrtEfhInxU3YNc= hector@hector","ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCSIj+UglgxRvkwojlO4ZphGAgvhhrUm/Au165pE472VI5Wt5D5AGiCzt4Gw6J7P/LN+qY/XvP+T6hOf+OERg1AYNSNVX+3YszQBQjDP76PkjsNiNqk2mI1KoLhKzHUBP1mM349mwOQS40Wv+MdoF6YEYzgNVECxPExCo2pjRd6J65exiK5IfJamZVlyxwkDqiWjvhUdRKBc2PqyU7BEYltAmzzVsXiU+dgC4E5dce+OKmtoc0r137CI220TdkQMgeGHojgVQ7bfgovRajLoAcf3ntB2V7gU9gIY2rRKxqbHKyXWWIb/Rb2+w134avbxaFv8CTgTlE8N0h/vHL01Ta0dglQ16EyiC065NN+XctRPUXlaoiOBEN3OeArIjRsmLztleWtLG4/yzslG9V8TlTa0+pMArUeQICRl2OvqGUGmnE6ZIbhxJWhrWGRMbPTklKk2WwiXlc9pcN8mrwfdxYUzUYvn+SOHAXBqTL0N8MDVwcEyNLovpYW8skWWcPXQUH8HkmHlIzwiZd+qXSKOJAcuwcfGwk7MUWOP7NNpD3ltrnNClVIzL8BmaaCuABnNs+Y6rYhlNrscOIcrOH7a3Nbcz2/l2vPI9kvDM0BV8mDxwpOS/FS0BhqA8ry7hfbdLk02lVbXDbQJrAboSZzcR6iXLGAvoYmtNYVttc9t49ahw== luis@tt"],"name":"whitestack","password":"whitestack"}]` | System users to create on all provisioned nodes (SSH access and administration) |
| infraConfig.users[0].authorized_keys | list | `["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDyQwCd7gKxObBzDV357Nl+oQwMggFg0CseB4NtGvmusH3RLUXRuQqJQ5Keu+FKlRfG0QmBT+WEmr5rLN+LDbGKM54yAUDiJV9lWroOWaSbU8ynO9ZwXhPKgfnfvG/HmGTkfGpUQkfZYOSDetbfKJ7+mFOjDTvncgdErL14JbTXLFQ6vhqxk08a8sdCAxdiX+IJ4fy7jJW3TNqmH3dpE1OfKQe+CwKaksF0wjjXu4O+xj4BWv5a0V3ePOnGD9EVze3HZWkjUGmysGNjW6IayHydIDt1JB9Q6d+pMARQrZ6R4b6ySJ21vv7FwaIZ65kHxT/UMk9fbffhLxV0Dj3s5HKbwZoZU5HhAhj74zcptjer72YygdFs1uf8h5FIrmYAXgYuDfVN76nAUls2PC/jE79xtNxLxP045VerWZVg2fXZRKgqw++Wa5sd0IYmm++SVNV4I/VGSmLmTuxe5oWMPs4FtE78EQkkNYzch3cghxJjsgZiP/KMXlrtEfhInxU3YNc= hector@hector","ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCSIj+UglgxRvkwojlO4ZphGAgvhhrUm/Au165pE472VI5Wt5D5AGiCzt4Gw6J7P/LN+qY/XvP+T6hOf+OERg1AYNSNVX+3YszQBQjDP76PkjsNiNqk2mI1KoLhKzHUBP1mM349mwOQS40Wv+MdoF6YEYzgNVECxPExCo2pjRd6J65exiK5IfJamZVlyxwkDqiWjvhUdRKBc2PqyU7BEYltAmzzVsXiU+dgC4E5dce+OKmtoc0r137CI220TdkQMgeGHojgVQ7bfgovRajLoAcf3ntB2V7gU9gIY2rRKxqbHKyXWWIb/Rb2+w134avbxaFv8CTgTlE8N0h/vHL01Ta0dglQ16EyiC065NN+XctRPUXlaoiOBEN3OeArIjRsmLztleWtLG4/yzslG9V8TlTa0+pMArUeQICRl2OvqGUGmnE6ZIbhxJWhrWGRMbPTklKk2WwiXlc9pcN8mrwfdxYUzUYvn+SOHAXBqTL0N8MDVwcEyNLovpYW8skWWcPXQUH8HkmHlIzwiZd+qXSKOJAcuwcfGwk7MUWOP7NNpD3ltrnNClVIzL8BmaaCuABnNs+Y6rYhlNrscOIcrOH7a3Nbcz2/l2vPI9kvDM0BV8mDxwpOS/FS0BhqA8ry7hfbdLk02lVbXDbQJrAboSZzcR6iXLGAvoYmtNYVttc9t49ahw== luis@tt"]` | SSH public keys for passwordless authentication (recommended for automation) |
| infraConfig.image | object | `{"name":"ubuntu22","url":"http://10.100.100.2/ubuntu-22.iso"}` | Operating system image configuration for node provisioning |
| infraConfig.image.url | string | `"http://10.100.100.2/ubuntu-22.iso"` | HTTP URL where the OS installation image is served (must be accessible by BMC) |
| infraConfig.image.name | string | `"ubuntu22"` | Image identifier used for node provisioning (ubuntu22 supports latest features) |
| infraConfig.kernel | object | `{"version":"6.5-generic"}` | Linux kernel configuration for provisioned nodes |
| infraConfig.kernel.version | string | `"6.5-generic"` | Specific kernel version to install (6.5-generic recommended for hardware compatibility) |
| controlPlaneNodes | object | `{"defaults":{"bmc":{"credentialsSecret":{"name":"baremetal-cluster","namespace":"default"},"provider":"ilo"},"labels":{"node-role.kubernetes.io/control-plane":""},"storage":[{"boot":"uefi","disks":["sda","sdb"],"lvs":[{"fs_type":"ext4","mount":"/","name":"lv-root","size":"80GB"},{"fs_type":"ext4","mount":"/var/log","name":"lv-logs","size":"20GB"},{"fs_type":"ext4","mount":"/var/tmp","name":"lv-tmp","size":"2GB"},{"fs_type":"ext4","mount":"/var/log/audit","name":"lv-audit","size":"5GB"}],"raid_type":1,"vg_name":"vg-root"}],"taints":[{"effect":"NoSchedule","key":"node-role.kubernetes.io/control-plane"}]},"nodes":[{"bmc":{"address":"10.40.12.10","credentialsSecret":{"name":"baremetal-cluster-1","namespace":"default"},"provider":"ilo"},"hostname":"node-01","network":{"netplan":{"network":{"ethernets":{"eno1":{"addresses":["10.100.2.150/24"],"routes":[{"to":"default","via":"10.100.2.1"}]}}}},"primaryInterface":{"address":"10.100.17.118"}}}]}` | controlPlane nodes configuration |
| controlPlaneNodes.defaults.labels | object | `{"node-role.kubernetes.io/control-plane":""}` | Kubernetes labels |
| controlPlaneNodes.defaults.storage[0].lvs[0].size | string | `"80GB"` | Storage size |
| controlPlaneNodes.defaults.storage[0].lvs[1].size | string | `"20GB"` | Storage size |
| controlPlaneNodes.defaults.storage[0].lvs[2].size | string | `"2GB"` | Storage size |
| controlPlaneNodes.defaults.storage[0].lvs[3].size | string | `"5GB"` | Storage size |
| controlPlaneNodes.defaults.bmc.credentialsSecret.name | string | `"baremetal-cluster"` | Name of the component |
| controlPlaneNodes.defaults.bmc.credentialsSecret.namespace | string | `"default"` | Kubernetes namespace |
| controlPlaneNodes.nodes[0].bmc.credentialsSecret.name | string | `"baremetal-cluster-1"` | Name of the component |
| controlPlaneNodes.nodes[0].bmc.credentialsSecret.namespace | string | `"default"` | Kubernetes namespace |
| workerNodes | object | `{"defaults":{"bmc":{"credentialsSecret":{"name":"baremetal-worker-cluster","namespace":"default"},"provider":"ilo"},"labels":{"node-role.kubernetes.io/worker":""},"storage":[{"boot":"uefi","disks":["sda","sdb"],"lvs":[{"fs_type":"ext4","mount":"/","name":"lv-root","size":"80GB"},{"fs_type":"ext4","mount":"/var/log","name":"lv-logs","size":"20GB"},{"fs_type":"ext4","mount":"/var/tmp","name":"lv-tmp","size":"2GB"},{"fs_type":"ext4","mount":"/var/log/audit","name":"lv-audit","size":"5GB"}],"raid_type":1,"vg_name":"vg-root"}],"taints":[{"effect":"NoSchedule","key":"node-role.kubernetes.io/worker"}]},"nodes":[{"bmc":{"address":"10.100.19.132"},"hostname":"worker-node-01","network":{"netplan":{"network":{"ethernets":{"eno2":{"addresses":["10.100.2.151/24"],"routes":[{"to":"default","via":"10.100.2.1"}]}}}},"primaryInterface":{"address":"10.100.20.198"}},"reservedSystemCPU":[]}]}` | worker nodes configuration |
| workerNodes.defaults.labels | object | `{"node-role.kubernetes.io/worker":""}` | Kubernetes labels |
| workerNodes.defaults.storage[0].lvs[0].size | string | `"80GB"` | Storage size |
| workerNodes.defaults.storage[0].lvs[1].size | string | `"20GB"` | Storage size |
| workerNodes.defaults.storage[0].lvs[2].size | string | `"2GB"` | Storage size |
| workerNodes.defaults.storage[0].lvs[3].size | string | `"5GB"` | Storage size |
| workerNodes.defaults.bmc.credentialsSecret.name | string | `"baremetal-worker-cluster"` | Name of the component |
| workerNodes.defaults.bmc.credentialsSecret.namespace | string | `"default"` | Kubernetes namespace |
| cniConfig | object | `{"additionalConfig":{},"bgp":false,"masquerade":true,"mtu":1440,"multusEnabled":true,"podCIDR":"10.42.0.0/16","serviceCIDR":"10.42.0.0/16","tunnelProtocol":"VXLAN"}` | cni configuration |
| cniConfig.additionalConfig | object | `{}` | additional configuration |
| storage.longhorn.enabled | bool | `true` | Enable or disable this component |
| storage.longhorn.customValues | object | `{}` | Custom values override |
| storage.openebs.enabled | bool | `false` | Enable or disable this component |
| storage.openebs.customValues | object | `{}` | Custom values override |
| storage.cephFS.enabled | bool | `false` | Enable or disable this component |
| storage.cephFS.clusterID | string | `"aaaaaaaa-bbbb-1111-2222-33333ccccccc"` |  |
| storage.cephFS.monitorList | list | `[]` |  |
| storage.cephFS.pool | string | `"volumes"` |  |
| storage.cephFS.userID | string | `"admin"` |  |
| storage.cephFS.userKey | string | `"AAAAAAAAAAAAAAAAAA/BBBBBBBBBBBBBBBBBBB=="` |  |
| storage.cephFS.provisionerReplicaCount | int | `3` |  |
| storage.cephFS.reclaimPolicy | string | `"Retain"` |  |
| storage.cephFS.enabledHostNetwork | bool | `false` |  |
| storage.cephFS.fsName | string | `""` |  |
| storage.cephFS.customValues | object | `{}` | Custom values override |
| storage.cephRBD.enabled | bool | `false` | Enable or disable this component |
| storage.cephRBD.clusterID | string | `"aaaaaaaa-bbbb-1111-2222-33333ccccccc"` |  |
| storage.cephRBD.monitorList | list | `[]` |  |
| storage.cephRBD.pool | string | `"volumes"` |  |
| storage.cephRBD.userID | string | `"admin"` |  |
| storage.cephRBD.userKey | string | `"AAAAAAAAAAAAAAAAAA/BBBBBBBBBBBBBBBBBBB=="` |  |
| storage.cephRBD.provisionerReplicaCount | int | `3` |  |
| storage.cephRBD.reclaimPolicy | string | `"Retain"` |  |
| storage.cephRBD.enabledHostNetwork | bool | `false` |  |
| storage.cephRBD.customValues | object | `{}` | Custom values override |
| logging | object | `{"clusterOutputs":{"server":{"host":"<changeme>","port":24224}},"customValues":{},"enabled":true}` | Logging configuration |
| logging.enabled | bool | `true` | Enable or disable this component |
| logging.customValues | object | `{}` | Custom values override |
| metallb.enabled | bool | `true` | Enable or disable this component |
| metallb.customValues | object | `{}` | Custom values override |
| monitoring | object | `{"customValues":{},"enabled":false,"thanos":{"objectStorage":{"accessKey":"<changeme>","bucket":"<changeme>","endpoint":"<changeme:changeme>","secretKey":"<changeme>"}},"thanosIngress":{"host":"<changeme>"}}` | Monitoring configuration |
| monitoring.enabled | bool | `false` | Enable or disable this component |
| monitoring.customValues | object | `{}` | Custom values override |
| ingressNginx.enabled | bool | `true` | Enable or disable this component |
| ingressNginx.customValues | object | `{}` | Custom values override |
| kubevirt.enabled | bool | `true` | Enable or disable this component |
| kubevirt.customValues | object | `{}` | Custom values override |
| sriovOperator.enabled | bool | `true` | Enable or disable this component |
| sriovOperator.customValues | object | `{}` | Custom values override |
| nodeConfigOperator.enabled | bool | `true` | Enable or disable this component |
| nodeConfigOperator.managerConfig | object | `{"aptEnabled":true,"hostfsEnabled":true}` | manager configuration |
| nodeConfigOperator.customValues | object | `{}` | Custom values override |
| certManager.enabled | bool | `false` | Enable or disable this component |
| certManager.customValues | object | `{}` | Custom values override |
| sdnController.enabled | bool | `true` | Enable or disable this component |
| sdnController.whitesdnSecrets.password | string | `"kcatsetiw"` |  |
| sdnController.customValues | object | `{}` | Custom values override |
| ntp.enabled | bool | `true` | Enable or disable this component |
| ntp.customValues | object | `{}` | Custom values override |
| x509CertExporter.enabled | bool | `true` | Enable or disable this component |
| x509CertExporter.customValues | object | `{}` | Custom values override |
| kubernetesPowerManager.enabled | bool | `false` | Enable or disable this component |
| kubernetesPowerManager.baremetalVendor | string | `"intel"` |  |
| kubernetesPowerManager.customValues | object | `{}` | Custom values override |
| registries.enabled | bool | `false` | Enable or disable this component |

## Troubleshooting

1. **BMC Connection Failures**
   - Verify BMC credentials and network connectivity
   - Check firewall rules for BMC ports

2. **Node Bootstrap Issues** 
   - Ensure base OS image is accessible
   - Verify network configuration in netplan

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)