# Kubernetes stores a varity of data including cluster datate application configuration and secrets kubernets supports the abbility to encrypt cluster data at rest

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

echo ${ENCRYPTION_KEY}

# thsi is a k8s resource
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
