# Addon Version Updater

Scripts to automatically update addon versions in cluster templates based on inventory files.

## Files

- `update_addon_versions.py` - Script to update addon versions
- `addons-inventory.yaml` - Inventory files in each template directory

## Usage

### 1. Check what would be updated (Dry Run)

```bash
python3 update_addon_versions.py --dry-run
```

### 2. Apply the updates

```bash  
python3 update_addon_versions.py --apply
```

### 3. Process a specific directory

```bash
python3 update_addon_versions.py rke2-baremetal-calico/1.31.9-wcr.1-rc1 --dry-run
```

## Inventory Structure

Each template directory should have an `addons-inventory.yaml` file:

```yaml
charts:
  storage:
    - name: longhorn
      version: 106.2.0-up1.8.1
      path: storage/longhorn.yaml
    - name: ceph-csi-rbd
      version: 3.10.1
      path: storage/ceph-rbd.yaml

  infra:
    - name: metallb
      version: 0.14.5
      path: addons/infra/metallb.yaml
    - name: cert-manager
      version: v1.17.1
      path: addons/infra/cert-manager.yaml

  virtualization:
    - name: kubevirt
      version: 0.5.0
      path: addons/kubevirt.yaml
    - name: cdi
      version: 0.5.0
      path: addons/kubevirt.yaml

metadata:
  template_name: rke2-baremetal-calico
  template_version: 1.31.9-wcr.1-rc1
  total_addons: 22
```

## How It Works

1. **Inventory Search**: The script recursively searches for `addons-inventory.yaml` files

2. **Configuration Loading**: Loads the configuration from each inventory including:
   - Chart/addon name
   - Target version  
   - Template file path

3. **Template Updates**: For each addon:
   - Locates the corresponding template file
   - Searches for `version:` lines associated with the specific chart
   - Updates the version if it's different

4. **Support for Both Formats**:
   - **ManagedChart** (Rancher Fleet): `chart: name`
   - **HelmChartProxy** (CAPI): `chartName: name`

## Supported Patterns

The script can update versions in these formats:

```yaml
# ManagedChart format
apiVersion: management.cattle.io/v3
kind: ManagedChart
spec:
  chart: longhorn
  version: "106.2.0-up1.8.1"

# HelmChartProxy format  
apiVersion: addons.cluster.x-k8s.io/v1beta1
kind: HelmChartProxy
spec:
  chartName: longhorn
  version: "106.2.0-up1.8.1"
```

## Special Cases

- **"TBD" versions**: Automatically skipped
- **Multiple charts per file**: Supported (e.g. kubevirt.yaml with cdi + kubevirt)
- **Already updated versions**: Detected and skipped

## Example Output

```
Searching for inventory files in: .
Found 3 inventory files:
  - rke2-baremetal-calico/1.31.9-wcr.1-rc1/addons-inventory.yaml
  - rke2-openstack-calico/1.33.0-wcr.1-rc1/addons-inventory.yaml

Processing: rke2-baremetal-calico/1.31.9-wcr.1-rc1/addons-inventory.yaml
  infra:
    metallb: 0.14.3 -> 0.14.5
    cert-manager: v1.15.0 -> v1.17.1
  virtualization:
    kubevirt: 0.4.0 -> 0.5.0

Total updates: 3

[DRY RUN] No files were modified.
Use --apply to actually update the files.
```

## Recommended Workflow

1. **Update inventories**: Modify versions in the `addons-inventory.yaml` files
2. **Check changes**: `python3 update_addon_versions.py --dry-run`  
3. **Apply updates**: `python3 update_addon_versions.py --apply`
4. **Verify templates**: Review that the changes are correct
5. **Commit**: Commit the changes

## Troubleshooting

- **Files not found**: Verify that `addons-inventory.yaml` files exist
- **Versions not updating**: Verify that the chart name matches exactly
- **Permission errors**: Ensure write permissions on template files