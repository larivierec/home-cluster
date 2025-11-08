set -euo pipefail

export WORKDIR="/Users/christopher/personal-code/home-cluster/bitwarden/.certificate"; mkdir -p "$WORKDIR"

# CA OpenSSL config (v3_ca extensions)
cat > "$WORKDIR/openssl_ca.cnf" <<'EOF'
[req]
distinguished_name = req_distinguished_name
prompt = no

[req_distinguished_name]
CN = home-cluster CA

[v3_ca]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = critical, CA:TRUE
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
EOF

# Server (NAS) openssl config - single SAN bw.garb.dev
cat > "$WORKDIR/openssl_server.cnf" <<'EOF'
[req]
distinguished_name = req_distinguished_name
req_extensions = req_ext
prompt = no

[req_distinguished_name]
CN = bw.garb.dev

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = bw.garb.dev

[server_cert]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
EOF

# Pod (in-cluster) openssl config - SANs for cluster + external host
cat > "$WORKDIR/openssl_pod.cnf" <<'EOF'
[req]
distinguished_name = req_distinguished_name
req_extensions = req_ext
prompt = no

[req_distinguished_name]
CN = bitwarden-sdk-server

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = bw.garb.dev
DNS.2 = external-secrets.kube-system.svc.cluster.local
DNS.3 = localhost
IP.1 = 127.0.0.1
IP.2 = ::1

[server_cert]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
EOF

cd "$WORKDIR"

# Generate CA key/cert if missing
if [ ! -f ca.key ]; then
  openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out ca.key
fi
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt -subj "/CN=home-cluster CA" -config openssl_ca.cnf -extensions v3_ca

# Generate NAS/server key and cert (server.key/server.crt)
if [ ! -f server.key ]; then
  openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out server.key
fi
openssl req -new -key server.key -out server.csr -config openssl_server.cnf -reqexts req_ext
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650 -sha256 -extfile openssl_server.cnf -extensions server_cert

# Generate in-cluster pod key and cert (pod.key/pod.crt)
if [ ! -f pod.key ]; then
  openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out pod.key
fi
openssl req -new -key pod.key -out pod.csr -config openssl_pod.cnf -reqexts req_ext
openssl x509 -req -in pod.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out pod.crt -days 3650 -sha256 -extfile openssl_pod.cnf -extensions server_cert

# Prepare files for Kubernetes secret (tls.crt/tls.key) by copying pod cert/key
cp -f pod.crt tls.crt
cp -f pod.key tls.key

ls -l
