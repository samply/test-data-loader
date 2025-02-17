FROM debian:stable

RUN apt-get -y update && apt-get -y install curl

WORKDIR /app

# Get bbmri-fhir-gen, for generating test data
RUN curl -LO https://github.com/samply/bbmri-fhir-gen/releases/download/v0.4.0/bbmri-fhir-gen-0.4.0-linux-amd64.tar.gz
RUN tar xzf bbmri-fhir-gen-*-linux-amd64.tar.gz
RUN mv ./bbmri-fhir-gen /usr/local/bin/bbmri-fhir-gen
RUN bbmri-fhir-gen --version

# Get blazectl, for uploading data to a FHIR store
RUN curl -LO https://github.com/samply/blazectl/releases/download/v0.15.1/blazectl-0.15.1-linux-amd64.tar.gz
RUN tar xzf blazectl-*-linux-amd64.tar.gz
RUN mv ./blazectl /usr/local/bin/blazectl
RUN blazectl --version

RUN mkdir -p /app/sample
COPY run.sh /app/run.sh
RUN chmod a+rx /app/run.sh

CMD ["/app/run.sh"]

