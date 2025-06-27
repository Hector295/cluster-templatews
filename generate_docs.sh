#!/bin/bash
# TODO: Organize the code into functions
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Helm-docs Documentation Generator ===${NC}"

# Check if helm-docs is installed
if ! command -v helm-docs &> /dev/null; then
    echo -e "${YELLOW}helm-docs not found. Installing...${NC}"
    
    # Detect OS and architecture
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        armv7l) ARCH="arm" ;;
    esac
    
    # Download and install helm-docs
    HELM_DOCS_VERSION="1.14.2"
    DOWNLOAD_URL="https://github.com/norwoodj/helm-docs/releases/download/v${HELM_DOCS_VERSION}/helm-docs_${HELM_DOCS_VERSION}_${OS}_${ARCH}.tar.gz"
    
    echo "Downloading helm-docs v${HELM_DOCS_VERSION} for ${OS}/${ARCH}..."
    curl -L -o /tmp/helm-docs.tar.gz "$DOWNLOAD_URL"
    
    # Extract and install
    tar -xzf /tmp/helm-docs.tar.gz -C /tmp
    sudo mv /tmp/helm-docs /usr/local/bin/
    sudo chmod +x /usr/local/bin/helm-docs
    
    # Cleanup
    rm -f /tmp/helm-docs.tar.gz
    
    echo -e "${GREEN}helm-docs installed successfully!${NC}"
else
    echo -e "${GREEN}helm-docs is already installed${NC}"
fi

# Verify installation
echo "helm-docs version: $(helm-docs --version)"

# Find all chart directories (containing Chart.yaml)
echo -e "\n${YELLOW}Finding Helm charts...${NC}"

CHART_DIRS=()
while IFS= read -r -d '' dir; do
    CHART_DIRS+=("$dir")
done < <(find . -name "Chart.yaml" -type f -printf '%h\0')

if [ ${#CHART_DIRS[@]} -eq 0 ]; then
    echo -e "${RED}No Helm charts found (no Chart.yaml files)${NC}"
    exit 1
fi

echo "Found ${#CHART_DIRS[@]} chart(s):"
for dir in "${CHART_DIRS[@]}"; do
    echo "  - $dir"
done

# Generate documentation for each chart
echo -e "\n${YELLOW}Generating documentation...${NC}"

for chart_dir in "${CHART_DIRS[@]}"; do
    echo -e "\n${GREEN}Processing chart: $chart_dir${NC}"
    
    cd "$chart_dir"
    
    # Check if README.md.gotmpl exists
    if [ ! -f "README.md.gotmpl" ]; then
        echo -e "${YELLOW}  No README.md.gotmpl found, creating basic template...${NC}"
        cat > README.md.gotmpl << 'EOF'
{{ template "chart.header" . }}
{{ template "chart.deprecationWarning" . }}

{{ template "chart.badgesSection" . }}

{{ template "chart.description" . }}

{{ template "chart.homepageLine" . }}

{{ template "chart.maintainersSection" . }}

{{ template "chart.sourcesSection" . }}

{{ template "chart.requirementsSection" . }}

## Installation

```bash
helm install {{ template "chart.name" . }} .
```

{{ template "chart.valuesSection" . }}

{{ template "helm-docs.versionFooter" . }}
EOF
    fi
    
    # Generate documentation
    if helm-docs --sort-values-order=file; then
        echo -e "${GREEN}  ✓ Documentation generated successfully${NC}"
        
        # Show generated file info
        if [ -f "README.md" ]; then
            lines=$(wc -l < README.md)
            size=$(du -h README.md | cut -f1)
            echo -e "    Generated README.md: ${lines} lines, ${size}"
        fi
    else
        echo -e "${RED}  ✗ Failed to generate documentation${NC}"
    fi
    
    # Return to base directory
    cd - > /dev/null
done

echo -e "\n${GREEN}=== Documentation generation complete! ===${NC}"

# Summary
echo -e "\n${YELLOW}Summary:${NC}"
echo "Charts processed: ${#CHART_DIRS[@]}"

for chart_dir in "${CHART_DIRS[@]}"; do
    if [ -f "$chart_dir/README.md" ]; then
        echo -e "  ✓ $chart_dir/README.md"
    else
        echo -e "  ✗ $chart_dir/README.md (failed)"
    fi
done

echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Review the generated README.md files"
echo "2. Customize the README.md.gotmpl templates as needed"
echo "3. Re-run this script after making changes to values.yaml"
echo "4. Commit the generated documentation to your repository"