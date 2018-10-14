#!/bin/bash

CONFIG=/etc/rabbitmq/advanced.config
TEMPLATE=/etc/rabbitmq/custom.config.template

# create our custom config file while substituting the placeholders with env vars
sed \
    -e 's@\${RABBITMQ_AUTH_ENDPOINT}@'"$RABBITMQ_AUTH_ENDPOINT"'@' \
    $TEMPLATE > $CONFIG

# execute the original entrypoint
exec docker-entrypoint.sh rabbitmq-server