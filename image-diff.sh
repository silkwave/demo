#!/bin/bash
set -e

podman inspect 192.168.139.179:5000/spring-server:latest       | jq '.[0].RootFS.Layers'
podman inspect 192.168.139.179:5000/spring-server:containerd   | jq '.[0].RootFS.Layers'