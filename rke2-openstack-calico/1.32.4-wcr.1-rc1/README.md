# rke2-openstack-calico

![Version: 1.32.4-wcr.1-rc1](https://img.shields.io/badge/Version-1.32.4--wcr.1--rc1-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

Cluster templates for rke2 with CAPI. Kubernetes version: 1.32.4

## Overview

This Helm chart deploys an RKE2 Kubernetes cluster on OpenStack infrastructure using Cluster API (CAPI) with Calico CNI. It provides:

- **CAPI Integration**: Full Cluster API support for OpenStack deployments
- **Auto-scaling**: Machine deployments with configurable scaling
- **Cloud Integration**: OpenStack Cloud Controller Manager and CSI drivers
- **Storage Options**: Longhorn, Ceph, OpenEBS, and OpenStack Cinder
- **Add-ons**: Comprehensive monitoring, logging, and infrastructure add-ons
- **Network Configuration**: Calico CNI with Multus support

## Prerequisites

- Kubernetes cluster with Cluster API controllers installed
- OpenStack cloud credentials and network configuration
- Cluster API OpenStack provider (CAPO) deployed
- Container registry access for RKE2 images

## Installation

```bash
# Download and install the cluster template
helm install rke2-openstack-calico-1.32.4-wcr.1-rc1.tgz -f custom-values.yaml .

# Or via WhiteCruiser UI using the cluster template
```

## Configuration Examples

### Basic Cluster Configuration

```yaml
cluster:
  name: "production-cluster"
  apiServerVIP: "10.1.1.100"

infraConfig:
  authUrl: "https://openstack.example.com:5000/v3"
  availabilityZones:
    - "zone1"
  domainName: "Default"
  region: "RegionOne"
  tenantName: "my-project"
  username: "cluster-admin"
```

### Machine Deployment Configuration

```yaml
machineDeployment:
  controlPlane:
    replicas: 3
    flavor: "m1.large"
    image: "ubuntu-22.04"

  workers:
    replicas: 3
    flavor: "m1.xlarge"
    image: "ubuntu-22.04"

networking:
  podCIDR: "10.42.0.0/16"
  serviceCIDR: "10.43.0.0/16"
```

### OpenStack Integration

```yaml
# Cloud Controller Manager
openStackCCM:
  enabled: true
  customValues:
    cloudConfig:
      global:
        auth-url: "https://openstack.example.com:5000/v3"

# Cinder CSI Driver
storage:
  cinder:
    enabled: true
    storageClass:
      name: "cinder-csi"
      parameters:
        type: "ssd"
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
| openstack-cinder-csi | 2.1.1 | ❌ | OpenStack Cinder CSI driver |

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

### Networking Add-ons
| Name | Version | Default Enabled | Description |
|------|---------|----------------|-------------|
| rke2-ingress-nginx | 4.12.103 | ❌ | NGINX ingress controller |

### Cloud Add-ons
| Name | Version | Default Enabled | Description |
|------|---------|----------------|-------------|
| openstack-cloud-controller-manager | 2.32.0 | ❌ | OpenStack cloud controller |

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
| kubevirt-dashboard-extension | TBD | ❌ | Rancher UI extension for KubeVirt |

### Default Add-on Configuration

> ⚠️ **Warning**: When using `customValues`, they will completely override the default values shown below. Make sure to include any default settings you want to preserve.

```yaml
# Storage Add-ons
storage:
  longhorn:
    enabled: true
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

  cinder:
    enabled: false  # OpenStack Cinder CSI
    # Default values (applied when customValues is empty):
    # secret:
    #   enabled: true
    #   name: cloud-config
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

  openebs:
    enabled: false

# Infrastructure Add-ons (all disabled by default)
certManager:
  enabled: false

metallb:
  enabled: false

# Networking Add-ons
ingressNginx:
  enabled: false

# Cloud integration
openStackCCM:
  enabled: false

# Monitoring Add-ons (disabled by default)
monitoring:
  enabled: false
  thanos:
    objectStorage:
      accessKey: ""
      bucket: ""
      endpoint: ""
      secretKey: ""
  thanosIngress:
    host: ""
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
  #       k8s_cluster: `\{\{ cluster.name \}\}`
  #     thanos:
  #       objstoreConfig:
  #         config:
  #           access_key: `\{\{ thanos.objectStorage.accessKey \}\}`
  #           bucket: `\{\{ thanos.objectStorage.bucket \}\}`
  #           endpoint: `\{\{ thanos.objectStorage.endpoint \}\}`
  #           insecure: true
  #           secret_key: `\{\{ thanos.objectStorage.secretKey \}\}`
  #         type: S3
  customValues: {}

logging:
  enabled: false

# Virtualization Add-ons (disabled by default)
kubevirt:
  enabled: false
  # Default values (applied when customValues is empty):
  # kubevirt:
  #   configuration:
  #     developerConfiguration:
  #       useEmulation: true
  customValues: {}
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cluster.apiServerVIP | string | `"<changeme>"` |  |
| cluster.name | string | `"prod-cluster"` | Name of the component |
| cluster.etcd.exposeMetrics | bool | `false` |  |
| cluster.etcd.backup | object | `{"disableAutomaticSnapshots":true}` | Backup configuration |
| cluster.etcd.extraArgs | list | `[]` | Additional command line arguments |
| cluster.kubeComponents.kubeControllerManager.extraArgs | list | `[]` | Additional command line arguments |
| cluster.kubeComponents.kubeApiServer.extraArgs | list | `[]` | Additional command line arguments |
| cluster.kubeComponents.kubeShceduler.extraArgs | list | `[]` | Additional command line arguments |
| cluster.kubeComponents.kubeProxy.extraArgs | list | `[]` | Additional command line arguments |
| cluster.kubeComponents.kubelet.extraArgs | list | `[]` | Additional command line arguments |
| cluster.labels | object | `{}` | Kubernetes labels |
| cluster.annotations | object | `{}` | Kubernetes annotations |
| infraConfig | object | `{"authUrl":"https://whitecloud.intra.whitestack.com:5000/v3","availabilityZones":["HAL1"],"caCerts":{"configMap":{"name":"","namespace":""}},"domainName":"Default","keypairName":"Hector","password":{"secret":{"name":"passopenstack","namespace":"default"}},"principalNetwork":{"netName":"intra-net-products","subnetName":"net-products"},"region":"RegionOne","sshUser":"ubuntu","tenantName":"team-products","username":"hventura"}` | infra configuration |
| infraConfig.password.secret.name | string | `"passopenstack"` | Name of the component |
| infraConfig.password.secret.namespace | string | `"default"` | Kubernetes namespace |
| infraConfig.caCerts.configMap.name | string | `""` | Name of the component |
| infraConfig.caCerts.configMap.namespace | string | `""` | Kubernetes namespace |
| controlPlaneNodes | object | `{"additionalPorts":[{"netName":"red_whitecruiser_hector","subnetName":"subred_whitecruiser_hector"}],"annotations":{},"flavorName":"m1.large","hypervisorHostname":"hal1","imageName":"Ubuntu 22.04 LTS","labels":["node-role.kubernetes.io/control-plane=true"],"quantity":1,"rootVolume":{"availabilityZone":"nova","sizeGiB":"40"},"securityGroups":["whitecicd-whitemist-deployment_sg"],"taints":[{"effect":"NoSchedule","key":"node-role.kubernetes.io/control-plane","value":true}]}` | controlPlane nodes configuration |
| controlPlaneNodes.labels | list | `["node-role.kubernetes.io/control-plane=true"]` | Kubernetes labels |
| controlPlaneNodes.annotations | object | `{}` | Kubernetes annotations |
| workerNodes | object | `{"defaults":{"additionalPorts":[{"netName":"red_whitecruiser_hector","subnetName":"subred_whitecruiser_hector"}],"flavorName":"m1.large","hypervisorHostname":"hal1","labels":["node-role.kubernetes.io/worker=true"],"quantity":2,"rootVolume":{"availabilityZone":"nova","sizeGiB":"50"},"securityGroups":["whitecicd-whitemist-deployment_sg"],"taints":[{"effect":"NoSchedule","key":"node-role.kubernetes.io/worker"}]},"imageName":"Ubuntu 22.04 LTS","nodes":[{"hypervisorHostname":"hal2","labels":["node-role.kubernetes.io/worker=true","node-role.kubernetes.io/worker-diff=true"],"name":"worker-node-sin-flavor","quantity":1,"rootVolume":{"availabilityZone":"nova","sizeGiB":"60"}},{"additionalPorts":[{"netName":"red_whitecruiser_hector","subnetName":"subred_whitecruiser_hector"},{"netName":"red_whitecruiser_ventura","subnetName":"subred_whitecruiser_ventura"}],"flavorName":"m1.medium","name":"worker-node-medium"}]}` | worker nodes configuration |
| workerNodes.defaults.labels | list | `["node-role.kubernetes.io/worker=true"]` | Kubernetes labels |
| workerNodes.nodes[0].labels | list | `["node-role.kubernetes.io/worker=true","node-role.kubernetes.io/worker-diff=true"]` | Kubernetes labels |
| cniConfig | object | `{"additionalConfig":{},"bgp":false,"masquerade":true,"mtu":1440,"multusEnabled":false,"podCIDR":"10.42.0.0/16","serviceCIDR":"10.42.0.0/16","tunnelProtocol":"VXLAN"}` | cni configuration |
| cniConfig.additionalConfig | object | `{}` | additional configuration |
| storage.longhorn.enabled | bool | `false` | Enable or disable this component |
| storage.longhorn.customValues | object | `{}` | Custom values override |
| storage.openebs.enabled | bool | `true` | Enable or disable this component |
| storage.openebs.customValues | object | `{}` | Custom values override |
| storage.cinder.enabled | bool | `false` | Enable or disable this component |
| storage.cinder.customValues | object | `{}` | Custom values override |
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
| registries.enabled | bool | `false` | Enable or disable this component |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)