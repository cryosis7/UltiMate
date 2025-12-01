#!/bin/bash
set -e

# Ulti-Mate Release Script
# Usage: ./release.sh [version]
# Example: ./release.sh 1.0.0
# If no version provided, will prompt for version type (patch/minor/major)

DEVELOPER_KEY="../keys/developer_key.der"

# Function to get current version from latest tag
get_current_version() {
    local latest_tag=$(git describe --tags --match "v*" --abbrev=0 2>/dev/null || echo "")
    if [ -z "$latest_tag" ]; then
        echo "0.0.0"
    else
        echo "${latest_tag#v}"
    fi
}

# Function to parse version into components
parse_version() {
    local version="$1"
    IFS='.' read -r major minor patch <<< "$version"
    echo "$major $minor $patch"
}

# Function to calculate next version based on type
calculate_next_version() {
    local current_version="$1"
    local version_type="$2"
    
    local components=($(parse_version "$current_version"))
    local major="${components[0]}"
    local minor="${components[1]}"
    local patch="${components[2]}"
    
    case "$version_type" in
        patch)
            patch=$((patch + 1))
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
    esac
    
    echo "$major.$minor.$patch"
}

# Function to validate version increment
validate_version_increment() {
    local current_version="$1"
    local new_version="$2"
    
    local current_components=($(parse_version "$current_version"))
    local new_components=($(parse_version "$new_version"))
    
    local current_major="${current_components[0]}"
    local current_minor="${current_components[1]}"
    local current_patch="${current_components[2]}"
    
    local new_major="${new_components[0]}"
    local new_minor="${new_components[1]}"
    local new_patch="${new_components[2]}"
    
    # Check if exactly one component incremented by exactly one
    local major_diff=$((new_major - current_major))
    local minor_diff=$((new_minor - current_minor))
    local patch_diff=$((new_patch - current_patch))
    
    # Count how many components changed
    local changes=0
    [ $major_diff -ne 0 ] && changes=$((changes + 1))
    [ $minor_diff -ne 0 ] && changes=$((changes + 1))
    [ $patch_diff -ne 0 ] && changes=$((changes + 1))
    
    if [ $changes -eq 0 ]; then
        echo "Error: Version must be incremented"
        return 1
    fi
    
    if [ $changes -gt 1 ]; then
        echo "Error: Only one version component can be incremented at a time"
        echo "Current version: $current_version"
        echo "Provided version: $new_version"
        return 1
    fi
    
    # Validate the increment is exactly +1 and lower components reset appropriately
    if [ $major_diff -eq 1 ]; then
        if [ $new_minor -ne 0 ] || [ $new_patch -ne 0 ]; then
            echo "Error: Major version increment must reset minor and patch to 0"
            echo "Expected: $((current_major + 1)).0.0"
            echo "Got: $new_version"
            return 1
        fi
    elif [ $minor_diff -eq 1 ]; then
        if [ $new_patch -ne 0 ]; then
            echo "Error: Minor version increment must reset patch to 0"
            echo "Expected: $current_major.$((current_minor + 1)).0"
            echo "Got: $new_version"
            return 1
        fi
    elif [ $patch_diff -eq 1 ]; then
        # Patch increment is valid
        :
    else
        echo "Error: Version component must increment by exactly 1"
        echo "Current version: $current_version"
        echo "Provided version: $new_version"
        return 1
    fi
    
    return 0
}

# Validate developer key exists
if [ ! -f "$DEVELOPER_KEY" ]; then
    echo "Error: Developer key not found at $DEVELOPER_KEY"
    echo "Generate one with: openssl genrsa -out developer_key.der 4096"
    exit 1
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "Error: Working directory has uncommitted changes"
    echo "Please commit or stash changes before releasing"
    exit 1
fi

# Determine version
CURRENT_VERSION=$(get_current_version)

if [ -z "$1" ]; then
    # Interactive mode: prompt for version type
    echo "Current version: $CURRENT_VERSION"
    echo ""
    echo "Select version bump type:"
    echo "  1) patch ($(calculate_next_version "$CURRENT_VERSION" patch))"
    echo "  2) minor ($(calculate_next_version "$CURRENT_VERSION" minor))"
    echo "  3) major ($(calculate_next_version "$CURRENT_VERSION" major))"
    echo ""
    read -p "Enter choice [1-3]: " choice
    
    case "$choice" in
        1)
            VERSION_TYPE="patch"
            ;;
        2)
            VERSION_TYPE="minor"
            ;;
        3)
            VERSION_TYPE="major"
            ;;
        *)
            echo "Error: Invalid choice"
            exit 1
            ;;
    esac
    
    VERSION=$(calculate_next_version "$CURRENT_VERSION" "$VERSION_TYPE")
else
    # Version provided: validate increment
    VERSION="$1"
    
    if ! validate_version_increment "$CURRENT_VERSION" "$VERSION"; then
        exit 1
    fi
fi

TAG="v$VERSION"
RELEASE_DIR="release/$VERSION"
OUTPUT_FILE="$RELEASE_DIR/UltiMate.iq"

# Check if tag already exists
if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "Error: Tag $TAG already exists"
    exit 1
fi

echo "=== Releasing Ulti-Mate $VERSION ==="
echo "Previous version: $CURRENT_VERSION"
echo "New version: $VERSION"
echo "Tag: $TAG"
echo ""

# Create release directory
echo "Creating release directory..."
mkdir -p "$RELEASE_DIR"

# Build the release package
echo "Building release package..."
monkeyc --package-app --release \
    -o "$OUTPUT_FILE" \
    -f monkey.jungle \
    -y "$DEVELOPER_KEY" \
    -O 2pz

if [ ! -f "$OUTPUT_FILE" ]; then
    echo "Error: Build failed - output file not created"
    exit 1
fi

echo "Build successful: $OUTPUT_FILE"
echo ""

# Commit the artifact
echo "Committing release artifact..."
git add "$OUTPUT_FILE"
git commit -m "Add release artifact for $TAG"

# Create and push git tag
echo "Creating git tag $TAG..."
git tag -a "$TAG" -m "Release $TAG"

echo "Pushing commit and tag to origin..."
git push origin HEAD
git push origin "$TAG"

echo ""
echo "=== Release $VERSION complete! ==="
echo "Tag: $TAG"
echo "Artifact: $OUTPUT_FILE"
echo "GitHub Actions will create the release automatically"
