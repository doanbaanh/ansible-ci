# ansible-ci

A Docker image based on Ubuntu 26.04 LTS for running Ansible playbooks in CI/CD pipelines and deploying servers.

## Included tools

- Ansible and Python 3
- Git
- OpenSSH client and rsync
- SOPS and age
- Bash, curl, jq, yq, and unzip
- Pinned Ansible collections from [`requirements.yml`](requirements.yml)

The image has no fixed `ENTRYPOINT`, so it can run both `ansible-playbook` and supporting CI commands.

## Local build

```sh
docker build -t ansible-ci .
docker run --rm ansible-ci ansible --version
```

Run a playbook from the current directory:

```sh
docker run --rm \
  -v "$PWD:/workspace" \
  -w /workspace \
  ansible-ci \
  ansible-playbook -i inventory.yml playbook.yml
```

Pass SSH keys, age keys, and other credentials at runtime through your CI secret store or a read-only volume. Never add them to the image.

## Publishing to GHCR

The `.github/workflows/container.yml` workflow builds and publishes the image only when a Git tag matching `v*` is pushed. The container image uses the exact Git tag, for example:

```text
Git tag:   v1.0.0
Image tag: ghcr.io/<owner>/<repository>:v1.0.0
```

The image is published to:

```text
ghcr.io/<owner>/<repository>
```

Pull the published image with:

```sh
docker pull ghcr.io/<owner>/<repository>:v1.0.0
```

## Ansible collections

The deployment collections and their exact versions are installed system-wide from [`requirements.yml`](requirements.yml). They remain available when GitHub Actions overrides `HOME` with `/github/home`, and a matching project-level `ansible-galaxy collection install -r requirements.yml` skips downloading them again.

List all installed collections:

```sh
docker run --rm ansible-ci ansible-galaxy collection list
```

When a deployment changes a collection version, update this file and publish a new image tag. Some collections also require Python libraries or external command-line tools; check the `Requirements` section of the modules you use.

## License

[MIT](LICENSE)
