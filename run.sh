#!/usr/bin/env bash
# Exit on error
set -e

# To run this bash script, you need to have the following tools installed:
# php, composer, git

# Set the path to the composer executable (if not in PATH)
# This script fails with Composer >= 2.7
COMPOSER=composer

rm -rf vendor composer.lock composer.json
cp composer.json.orig composer.json
cp composer.lock.orig composer.lock

export COMPOSER_CACHE_DIR=/dev/null
export COMPOSER_MINIMAL_CHANGES=1
export COMPOSER_DISABLE_NETWORK=0

echo "Using composer version..."
$COMPOSER --version

echo "Validating composer.json and composer.lock files..."
$COMPOSER validate --no-ansi --no-interaction

echo "Prevent the use of packagist.org"
$COMPOSER config repo.packagist false
echo "Modifying composer.json to use the local composer repository..."
$COMPOSER config repo.composer composer file://$(pwd)/local-repo/packages.json

echo "Disabling network access..."
export COMPOSER_DISABLE_NETWORK=1
export COMPOSER_MIRROR_PATH_REPOS=1

echo "Updating composer.lock file since we modified the composer.json file..."
$COMPOSER \
    --lock \
    --no-ansi \
    --no-install \
    update

echo "Validating composer.json and composer.lock files..."
$COMPOSER validate --no-ansi --no-interaction

echo "Installing the dependencies..."
$COMPOSER \
    --no-ansi \
    --no-interaction \
    install
