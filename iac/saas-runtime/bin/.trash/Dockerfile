FROM alpine:latest
ARG ENGINE_TYPE
ARG ENGINE_VERSION
LABEL dev.cloud.saas.engine.type=${ENGINE_TYPE}
LABEL dev.cloud.saas.engine.version=${ENGINE_VERSION}
WORKDIR /app
COPY . .
