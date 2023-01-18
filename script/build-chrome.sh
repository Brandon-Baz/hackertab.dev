echo 'building extension for Chrome...'

# install jq if not installed
if ! command -v jq &> /dev/null
then
    echo "jq command not found. attempting to download jq binary"
    pth=$(pwd)
    export PATH=$PATH:$pth
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o jq
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64 -o jq
    else
        echo "Unsupported OS type. Exiting..."
        exit 1
    fi
    chmod +x jq
fi

# Merge base and chrome jsons
if [ -n "$version" ]; then
    echo "Change manifest version to ${version}"
    jq ".version = \"$version\"" ./public/base.manifest.json > base.manifest.temp.json
    echo 'Generate Chrome manifest'
    jq -s '.[0] * .[1]' base.manifest.temp.json ./public/chrome.manifest.json > ./public/manifest.json
    rm -f base.manifest.temp.json
else
    echo 'Generate Chrome manifest'
    jq -s '.[0] * .[1]' ./public/base.manifest.json ./public/chrome.manifest.json > ./public/manifest.json
fi

# Remove previous artifacts
echo 'Remove previous zipped extension'
rm -f chrome_extension.zip

# Install dependencies
echo 'Install dependencies'
yarn build

# Copy generated build to distrubution folder
echo 'Copy generated build to distrubution folder'
mkdir -p dist
cp -r build/* dist

# Zip the distribution folder
echo 'Zip the extension'
cd dist/ && zip -r ../chrome_extension.zip * -x "*.DS_Store" && cd ..