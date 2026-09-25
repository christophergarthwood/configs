# **Certificate chains Frequenty Asked Questions**

## CSRs (Certificate Signing Requests)

### File Types

A PEM file is plain text, enclosed between markers like:

```
-----BEGIN CERTIFICATE-----
(Base64 data)
-----END CERTIFICATE-----
```

Extensions can vary: .pem, .crt, .cer, .key — the extension alone does not define the content; the header/footer does.

**CRT** (.crt) is typically a certificate file, often in PEM format, containing the public certificate issued by a Certificate Authority (CA) or self-signed. It may also be in DER (binary) format. .crt is just a naming convention to indicate “certificate”.

**SSL** (Secure Sockets Layer) is the predecessor to TLS (Transport Layer Security). In practice, when people say “SSL certificate,” they mean an X.509 certificate used in TLS/SSL protocols to secure communications. The certificate can be stored in PEM, DER, PKCS#7, or PKCS#12 formats.

Key Differences:

**PEM** → Encoding format (Base64 + headers) that can hold certificates, keys, or both.

**CRT** → Usually a PEM-encoded certificate file (public key only), but could be DER.

**SSL** → The protocol that uses these certificates for encryption and authentication.

### Examples

Example: Converting Between Formats with OpenSSL

#### PEM to CRT (just renaming if already PEM-encoded)
```
cp cert.pem cert.crt
```

#### PEM to DER
```
openssl x509 -outform der -in cert.pem -out cert.crt
```

#### Combine certificate and key into one PEM
```
cat cert.crt private.key > combined.pem
```


***Tip***: Always inspect the file content:

```
openssl x509 -in file.pem -text -noout
```

If it shows certificate details, it’s a cert; if it says “BEGIN PRIVATE KEY,” it’s a private key.

In short: PEM and CRT are about how the certificate is stored, while SSL/TLS is how it’s used in secure communication. The same certificate can be saved as .pem or .crt without changing its cryptographic function.
