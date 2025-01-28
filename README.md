# V-Log-installation
shell script to automate the installation of Docker, Docker Compose, Fluentd, Elasticsearch, and Grafana on an Ubuntu machine
<h3> How to Use the Script: </h3>

Save the script to a file:
vim setup-devops-tools.sh

Paste the script into the file, save, and exit.

Make the script executable:
chmod +x setup-devops-tools.sh

Run the script with superuser privileges:
sudo ./setup-devops-tools.sh


Log Collection and Visualization Pipeline Setup

This guide provides step-by-step instructions to set up a log collection and visualization pipeline, including commands for easy copy-paste and a clear structure for implementation.

Step 1: System Architecture Block Diagram

Visualize the system architecture:

Log sources: Applications generating logs.

Log collector: A centralized system (e.g., Fluentd, Logstash).

Storage: Elasticsearch for storing logs.

Visualization: Grafana for dashboarding.

Example Diagram:

+----------------+     +-------------+     +------------------+
| Log Sources    | --> | Log Collector | --> | Storage (Elasticsearch) |
+----------------+     +-------------+     +------------------+
                                        |
                                        v
                                  +-------------+
                                  | Visualization |
                                  | (Grafana)     |
                                  +-------------+

Step 2: Log Collector Configuration

Configure the log collector (e.g., Fluentd or Logstash) to process and transform logs.

Commands:

Install Fluentd:

curl -fsSL https://toolbelt.treasuredata.com/sh/install-ubuntu-focal-td-agent4.sh | sh

Configure Fluentd to forward logs to Elasticsearch:

sudo nano /etc/td-agent/td-agent.conf

Example configuration:

<source>
  @type tail
  path /var/log/app.log
  pos_file /var/log/td-agent/app.pos
  tag app.log
  format json
</source>

<match app.log>
  @type elasticsearch
  host localhost
  port 9200
  logstash_format true
</match>

Restart Fluentd:

sudo systemctl restart td-agent

Step 3: Log Visualization Setup

Set up Grafana to visualize logs stored in Elasticsearch.

Commands:

Install Grafana:

sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update && sudo apt-get install -y grafana

Start Grafana:

sudo systemctl start grafana-server
sudo systemctl enable grafana-server

Access Grafana:

Open a browser and go to http://<your-server-ip>:3000.

Default credentials: admin / admin.

Add Elasticsearch as a data source:

Go to Settings > Data Sources > Add Data Source.

Select Elasticsearch and configure:

URL: http://<your-server-ip>:9200

Index Pattern: logstash-*.

Step 4: Dockerize the Setup

Package all components into Docker containers for portability.

Dockerfile Example:

Create a Dockerfile for Fluentd:

FROM fluent/fluentd:latest

COPY td-agent.conf /fluentd/etc/
RUN gem install fluent-plugin-elasticsearch

Create a docker-compose.yml file:

version: '3.7'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.5.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
    ports:
      - "9200:9200"

  fluentd:
    build: ./fluentd
    container_name: fluentd
    ports:
      - "24224:24224"
      - "24224:24224/udp"

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"

Start the containers:

docker-compose up -d

Step 5: CI/CD Pipeline

Automate the deployment of the Dockerized setup using a CI/CD pipeline.

Commands:

Install GitHub Actions Runner (or another CI/CD tool):

mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.310.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.310.0/actions-runner-linux-x64-2.310.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.310.0.tar.gz
./config.sh --url https://github.com/<your-repo> --token <your-token>

Example .github/workflows/deploy.yml file:

name: Deploy Log Pipeline

on:
  push:
    branches:
      - main

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Code
      uses: actions/checkout@v3

    - name: Build and Deploy
      run: |
        docker-compose down
        docker-compose up -d --build

Push to GitHub to trigger the pipeline:

git add .
git commit -m "Add CI/CD pipeline"
git push origin main

Follow these steps to set up and deploy the log collection and visualization pipeline successfully. Each section includes commands and configurations that can be directly copied and executed.

