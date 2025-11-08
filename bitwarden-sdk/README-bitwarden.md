# out of cluster bitwarden sdk

1. ./generate.sh
2.
```bash
kubectl -n kube-system create secret generic bitwarden-css-certs \
  --from-file=tls.crt=.certificate/pod.crt \
  --from-file=tls.key=.certificate/pod.key \
  --from-file=ca.crt=.certificate/ca.crt
```
3. terminate the ingress with the bitwarden-css-certs

Run the Bitwarden SDK server locally for testing

Prereqs:
- Docker & docker-compose installed
- You have generated certs at `.certificate/bitwarden-tls/`:
  - `server.crt` (server certificate)
  - `server.key` (server private key)
  - `ca.crt` (CA certificate)

Start the server (from repo root):

```bash
cd .certificate
docker compose -f bitwarden-docker-compose.yml up -d
```

The server will be listening on https://localhost:9998 and expects certs mounted at `/certs` (container path).

Notes:
- The compose file maps the local files `bitwarden-tls/server.crt`, `server.key`, and `ca.crt` into the container. If your files are elsewhere, edit the compose file accordingly.
- The container expects TLS files named `cert.pem`, `key.pem`, and `ca.pem` under `/certs`. The compose maps the filenames appropriately.
- For production you'd typically run this behind a dedicated proxy or service, and handle OS-level CA trust for `ca.crt` where needed.
