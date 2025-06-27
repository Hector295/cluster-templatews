#!/usr/bin/env python3
"""
Updatees addon versions in YAML template files.
"""

import yaml
import re
from pathlib import Path
import argparse
import sys


def update_version_in_template(template_path: Path, chart_name: str, new_version: str, dry_run: bool = True) -> bool:
    """Update version for a specific chart in a template file using line-by-line processing."""
    
    if not template_path.exists():
        return False
    
    try:
        with open(template_path, 'r') as f:
            lines = f.readlines()
        
        updated = False
        in_chart_section = False
        chart_matched = False
        
        for i, line in enumerate(lines):
            # Check if we found the chart we're looking for
            if (f'chart: {chart_name}' in line or f'chartName: {chart_name}' in line):
                in_chart_section = True
                chart_matched = True
                continue
            
            # If we're in the right chart section and find a version line
            if in_chart_section and 'version:' in line:
                # Extract current version
                version_match = re.search(r'version:\s*"?([^"\n\s]+)"?', line)
                if version_match:
                    current_version = version_match.group(1)
                    if current_version != new_version:
                        # Update the version
                        new_line = re.sub(r'version:\s*"?[^"\n\s]+"?', f'version: "{new_version}"', line)
                        lines[i] = new_line
                        updated = True
                        print(f"    {chart_name}: {current_version} -> {new_version}")
                
                # Reset section flag after processing version
                in_chart_section = False
                continue
            
            # Reset if we hit another chart/chartName line
            if ('chart:' in line or 'chartName:' in line) and not chart_matched:
                in_chart_section = False
            
            # Reset chart_matched flag for next iteration
            if 'chart:' in line or 'chartName:' in line:
                chart_matched = False
        
        # Write back if updated and not dry run
        if updated and not dry_run:
            with open(template_path, 'w') as f:
                f.writelines(lines)
        
        return updated
        
    except Exception as e:
        print(f"    Error processing {template_path}: {e}")
        return False


def process_inventory_file(inventory_path: Path, dry_run: bool = True) -> int:
    """Process a single inventory file and update corresponding templates."""
    
    print(f"\nProcessing: {inventory_path}")
    
    try:
        with open(inventory_path, 'r') as f:
            inventory = yaml.safe_load(f)
    except Exception as e:
        print(f"  Error loading inventory: {e}")
        return 0
    
    # Get template directory
    template_dir = inventory_path.parent / "templates"
    if not template_dir.exists():
        print(f"  Templates directory not found: {template_dir}")
        return 0
    
    charts = inventory.get('charts', {})
    total_updates = 0
    
    # Process each category
    for category, addons in charts.items():
        print(f"  {category}:")
        
        for addon in addons:
            chart_name = addon.get('name')
            version = addon.get('version')
            path = addon.get('path')
            
            # Skip if missing required fields or version is placeholder
            if not all([chart_name, version, path]):
                continue
            if version in ['TBD', 'version not specified']:
                print(f"    Skipping {chart_name}: {version}")
                continue
            
            # Build template path
            template_path = template_dir / path
            
            # Update version in template
            if update_version_in_template(template_path, chart_name, version, dry_run):
                total_updates += 1
    
    return total_updates


def main():
    parser = argparse.ArgumentParser(description='Update addon versions in cluster templates')
    parser.add_argument('path', nargs='?', default='.', help='Base path to search for inventory files')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be updated without making changes')
    parser.add_argument('--apply', action='store_true', help='Actually apply the changes')
    
    args = parser.parse_args()
    
    # Default to dry run unless --apply is specified
    dry_run = not args.apply
    
    base_path = Path(args.path)
    print(f"Searching for inventory files in: {base_path}")
    
    # Find all inventory files
    inventory_files = list(base_path.rglob("addons-inventory.yaml"))
    
    if not inventory_files:
        print("No inventory files found!")
        return 1
    
    print(f"Found {len(inventory_files)} inventory files:")
    for inv_file in inventory_files:
        print(f"  - {inv_file}")
    
    # Process each inventory file
    total_updates = 0
    for inventory_file in inventory_files:
        updates = process_inventory_file(inventory_file, dry_run)
        total_updates += updates
    
    print(f"\nTotal updates: {total_updates}")
    
    if dry_run:
        print("\n[DRY RUN] No files were modified.")
        print("Use --apply to actually update the files.")
    else:
        print("\nFiles have been updated!")
    
    return 0


if __name__ == "__main__":
    sys.exit(main())