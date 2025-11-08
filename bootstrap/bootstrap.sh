#!/usr/bin/env bash
set -euo pipefail

# One-shot bootstrap helper
# - runs the Bitwarden cert generator
# - creates/updates the kubernetes secret used by the ingress
# - decrypts & applies the Flux/GitHub sops secrets in order

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
GEN_SCRIPT="$REPO_ROOT/bootstrap/bitwarden-sdk/generate.sh"
CERT_DIR="$REPO_ROOT/bootstrap/bitwarden-sdk/.certificate"

command -v openssl >/dev/null 2>&1 || { echo "openssl not found in PATH" >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl not found in PATH" >&2; exit 1; }
command -v sops >/dev/null 2>&1 || { echo "sops not found in PATH" >&2; exit 1; }

echo "Repository root: $REPO_ROOT"
echo "Certificate directory: $CERT_DIR"

if [ ! -f "$GEN_SCRIPT" ]; then
  echo "generate script not found: $GEN_SCRIPT" >&2
  exit 1
fi

echo "Running certificate generator: $GEN_SCRIPT"
bash "$GEN_SCRIPT"

if [ ! -d "$CERT_DIR" ]; then
  echo "Expected cert directory missing: $CERT_DIR" >&2
  exit 1
fi

for f in pod.crt pod.key ca.crt; do
  if [ ! -f "$CERT_DIR/$f" ]; then
    echo "Missing expected cert file: $CERT_DIR/$f" >&2
    exit 1
  fi
done

echo "Creating/updating kubernetes secret 'bitwarden-css-certs' in namespace kube-system"
kubectl -n kube-system create secret generic bitwarden-css-certs \
  --from-file=tls.crt="$CERT_DIR/pod.crt" \
  --from-file=tls.key="$CERT_DIR/pod.key" \
  --from-file=ca.crt="$CERT_DIR/ca.crt" -o yaml | kubectl apply -f -

echo "Applying encrypted Flux secrets (sops -> kubectl)"
for name in age-key github-deploy-key github-app; do
  src="$REPO_ROOT/bootstrap/flux/${name}.yaml"
  if [ ! -f "$src" ]; then
    echo "Skipping missing file: $src"
    continue
  fi
  echo "Applying $src"
  sops --decrypt "$src" | kubectl apply -f -
done

echo "Bootstrap one-shot complete."
