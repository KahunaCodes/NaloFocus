#!/bin/bash
#
# One-time: create a self-signed code-signing certificate so Reminders (TCC) grants survive rebuilds.
#
# An ad-hoc signature's designated requirement is the binary's cdhash, which changes on every build,
# so macOS treats each rebuild as a new app and prompts for Reminders access again. Signing with a
# certificate gives a designated requirement of "identifier + certificate", stable across builds.
#
# Usage:  scripts/make-signing-cert.sh ["NaloFocus Dev"]
# Then:   export NALOFOCUS_SIGN_IDENTITY="NaloFocus Dev"   (persist it in ~/.zshrc or ~/.env)
#
# Expect one or two GUI prompts: keychain authorization when the trust setting is written, and
# "codesign wants to use key" on the first signature (choose Always Allow).
# Remove later with: security delete-identity -c "NaloFocus Dev" ~/Library/Keychains/login.keychain-db

set -euo pipefail

NAME="${1:-NaloFocus Dev}"
KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"
OPENSSL=/usr/bin/openssl   # Apple's LibreSSL writes PKCS#12 that `security import` still understands

if security find-identity -v -p codesigning 2>/dev/null | grep -q "\"$NAME\""; then
    echo "identity '$NAME' already exists and is valid for code signing"
    exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/cert.cnf" <<EOF
[req]
distinguished_name = dn
x509_extensions = ext
prompt = no
[dn]
CN = $NAME
[ext]
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, codeSigning
basicConstraints = critical, CA:false
subjectKeyIdentifier = hash
EOF

"$OPENSSL" req -x509 -newkey rsa:2048 -nodes -sha256 -days 3650 \
    -keyout "$TMP/key.pem" -out "$TMP/cert.pem" -config "$TMP/cert.cnf" 2>/dev/null
"$OPENSSL" pkcs12 -export -inkey "$TMP/key.pem" -in "$TMP/cert.pem" \
    -out "$TMP/identity.p12" -passout pass:nalofocus -name "$NAME"

security import "$TMP/identity.p12" -k "$KEYCHAIN" -P nalofocus \
    -T /usr/bin/codesign -T /usr/bin/security
security add-trusted-cert -p codeSign -k "$KEYCHAIN" "$TMP/cert.pem"

if security find-identity -v -p codesigning | grep -q "\"$NAME\""; then
    echo "created identity '$NAME'. Now: export NALOFOCUS_SIGN_IDENTITY=\"$NAME\""
else
    echo "certificate imported but not yet valid for code signing." >&2
    echo "Open Keychain Access, find '$NAME', Get Info, Trust, set Code Signing to Always Trust." >&2
    exit 1
fi
