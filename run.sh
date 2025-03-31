#!/usr/bin/env bash

if [ -n "$START_DELAY" ]; then
    echo "Waiting for $START_DELAY seconds..."
    sleep "$START_DELAY"
fi

if [ -n "$WAIT_FOR_BLAZE" ] && [ "$WAIT_FOR_BLAZE" = true ]; then
    echo "Waiting for blaze..."
    while ! curl -s ${FHIR_STORE_URL:-http://store:8080/fhir} > /dev/null; do
        sleep 2
    done
fi

if [ -n "$DATA_GENERATION_SEED" ]; then
    echo "Using seed \"$DATA_GENERATION_SEED\" for fake data generation..."
    SEED_STR="--seed $DATA_GENERATION_SEED"
else
    echo "Generating random fake data..."
    SEED_STR=""
fi

bbmri-fhir-gen /app/sample -n ${PATIENT_COUNT:-100} "$SEED_STR"

AUTH=""
if [ -n "$USE_BRIDGEHEAD_AUTH" ] && [ "$USE_BRIDGEHEAD_AUTH" = true ]; then
    FILE="/etc/bridgehead/ccp.local.conf"
    if [ ! -e "$FILE" ]; then
        FILE="/etc/bridgehead/bbmri.local.conf"
    fi
    if [ ! -e "$FILE" ]; then
        # Use a glob pattern to find any matching file
        FILE=$(ls /etc/bridgehead/*.local.conf 2>/dev/null | head -n 1)
    fi
    if [ -e "$FILE" ]; then
        USER=$(grep -m 1 User "$FILE" | sed 's/# User: //')
        PASSWORD=$(grep -m 1 Password "$FILE" | sed 's/# Password: //')
    fi
    if [ -n "$USER" ] && [ -n "$PASSWORD" ]; then
        AUTH="--user $USER --password $PASSWORD"
    fi
fi

echo Uploading data to Blaze Store
blazectl $AUTH --server ${FHIR_STORE_URL:-http://store:8080/fhir} upload /app/sample/
blazectl $AUTH --server ${FHIR_STORE_URL:-http://store:8080/fhir} count-resources

echo Done

if [ -n "$KEEP_ALIVE" ] && [ "$KEEP_ALIVE" = true ]; then
    tail -f /dev/null
fi

