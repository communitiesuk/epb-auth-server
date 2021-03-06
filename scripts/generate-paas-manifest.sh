#!/usr/bin/env bash

#define parameters which are passed in.
APPLICATION_NAME=$1  # e.g. mhclg-epb-something-api-integration
STAGE=$2 # i.e. [integration, staging, production]

cat << EOF
---
applications:
  - name: $APPLICATION_NAME
    memory: 1G
    buildpacks:
      - ruby_buildpack
    health-check-type: http
    health-check-http-endpoint: /auth/healthcheck
    services:
      - mhclg-epb-auth-db-${STAGE}
EOF
