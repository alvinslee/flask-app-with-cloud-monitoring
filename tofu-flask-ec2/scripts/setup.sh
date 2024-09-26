#!/bin/bash
# Update the instance and install necessary packages
sudo apt update
sudo apt install -y python3 python3-pip git

# Install Flask
sudo pip3 install Flask

# Set up the Flask application
cat <<EOF > /home/ubuntu/app.py
import json
import logging

from flask import Flask

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

@app.route('/')
def hello_world():
    logger.info("This is a log message.")
    return {'message': 'Hello, World!'}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
EOF

# Set up systemd service for Flask app
cat <<EOF | sudo tee /etc/systemd/system/flask-app.service
[Unit]
Description=Flask Application

[Service]
ExecStart=/usr/bin/python3 /home/ubuntu/app.py
WorkingDirectory=/home/ubuntu
User=root
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable flask-app
sudo systemctl start flask-app

# Install and configure CloudWatch agent
sudo wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
cat <<EOF | sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "agent": {
    "metrics_collection_interval": 60,
    "logfile": "/var/log/amazon-cloudwatch-agent.log"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/flask-app",
            "log_stream_name": "{instance_id}/messages",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/cloud-init.log",
            "log_group_name": "/aws/ec2/flask-app",
            "log_stream_name": "{instance_id}/cloud-init",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
EOF

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start
