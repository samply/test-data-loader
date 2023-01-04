#!/usr/bin/env bash

#cd /app

echo Generating fake data
bbmri-fhir-gen /app/sample -n ${PATIENT_COUNT:-100}

echo Uploading data to Blaze Store
blazectl --server ${FHIR_STORE_URL:-http://store:8080/fhir} upload /app/sample/
blazectl --server ${FHIR_STORE_URL:-http://store:8080/fhir} count-resources

echo Done

