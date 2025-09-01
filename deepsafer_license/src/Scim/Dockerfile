###############################################
#                 Build stage                 #
###############################################
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Docker buildx supplies the value for this arg
ARG TARGETPLATFORM

# Determine proper runtime value for .NET
# We put the value in a file to be read by later layers.
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
    RID=linux-x64 ; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
    RID=linux-arm64 ; \
    elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then \
    RID=linux-arm ; \
    fi \
    && echo "RID=$RID" > /tmp/rid.txt

# Copy required project files
WORKDIR /source
COPY . ./

# Restore project dependencies and tools
WORKDIR /source/deepsafer_license/src/Scim
RUN . /tmp/rid.txt && dotnet restore -r $RID

# Build project
RUN . /tmp/rid.txt && dotnet publish \
    -c release \
    --no-restore \
    --self-contained \
    /p:PublishSingleFile=true \
    -r $RID \
    -o out

###############################################
#                  App stage                  #
###############################################
FROM mcr.microsoft.com/dotnet/aspnet:8.0

ARG TARGETPLATFORM
LABEL ye.vault.deepsafer.product="deepsafer"
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:5000
ENV SSL_CERT_DIR=/etc/deepsafer/ca-certificates
EXPOSE 5000

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    gosu \
    curl \
    krb5-user \
    && rm -rf /var/lib/apt/lists/*

# Copy app from the build stage
WORKDIR /app
COPY --from=build /source/deepsafer_license/src/Scim/out /app
COPY ./deepsafer_license/src/Scim/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

HEALTHCHECK CMD curl -f https://localhost:5000/alive || exit 1

ENTRYPOINT ["/entrypoint.sh"]
