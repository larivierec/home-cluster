# Bootstrap

## Flux

### Using Github for Auth

1. [Go to Developer Settings -> Github Apps](https://github.com/settings/apps)
2. Create a new Github App for Flux
  1. Give it a name
  2. Give it a fake url, or a real one, it doesn't matter really
  3. Select the following [permissions](https://fluxcd.io/flux/installation/bootstrap/github/#github-organization):
    - Repository
      - Actions: Read
      - Contents: Read and Write
      - Metadata: Read (will be selected by default)
    - Organisation. None
    - Account. None.
3. Uncheck webhook and create the application.

####

In `bootstrap` folder, create: 

- flux/unencrypted/age-key.yaml
- flux/unencrypted/github-app.yaml
  - edit the app id, installation id and private key. [Configure Secret Example](https://fluxcd.io/flux/components/source/gitrepositories/#configure-github-app-secret)
- flux/unencrypted/github-deploy-key.yaml

Encrypt them:

```bash
sops --encrypt bootstrap/flux/unencrypted/age-key.yaml > bootstrap/flux/age-key.yaml
sops --encrypt bootstrap/flux/unencrypted/github-app.yaml > bootstrap/flux/github-app.yaml
sops --encrypt bootstrap/flux/unencrypted/github-deploy-key.yaml > bootstrap/flux/github-deploy-key.yaml
```

### Apply Cluster Configuration

_These cannot be applied with `kubectl` in the regular fashion due to be encrypted with sops_

```sh
sops --decrypt bootstrap/flux/age-key.yaml | kubectl apply -f -
sops --decrypt bootstrap/flux/github-deploy-key.yaml | kubectl apply -f -
sops --decrypt bootstrap/flux/github-app.yaml | kubectl apply -f -
```