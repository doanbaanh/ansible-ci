# Repository guide

## Purpose

This repository builds and publishes a small GHCR job image for running Ansible deployments.

## Change workflow

1. Keep the image based on the latest stable Ubuntu LTS and prefer Ubuntu packages over downloaded binaries.
2. Add packages only for a concrete deployment requirement; keep the image usable without a fixed entrypoint.
3. Build and smoke-test every tool changed in `Dockerfile`:

   ```sh
   docker build -t ansible-ci:test .
   docker run --rm ansible-ci:test sh -ec \
     'ansible --version; git --version; sops --version; age --version; python3 --version'
   ```

4. Validate workflow changes with `actionlint`.
5. When changing the Ubuntu version, verify required packages for both `amd64` and `arm64`.

## Security boundaries

- Pass SSH, SOPS, age, cloud, and registry credentials at runtime through the CI secret store.
- Keep decrypted secrets, private keys, tokens, and generated inventories out of the image and Git history.
- Keep GitHub Actions permissions least-privileged; pull requests build without publishing.

## Completion

A change is complete when the image builds, affected commands run successfully, workflow validation passes, and any untested architecture or external registry operation is reported.
