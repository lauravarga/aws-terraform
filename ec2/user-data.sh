#!/bin/bash
yum -y install postgresql-server
wget https://dl.grafana.com/oss/release/grafana-9.3.6-1.x86_64.rpm
yum -y install grafana-9.3.6-1.x86_64.rpm

