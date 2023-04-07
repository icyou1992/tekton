MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
sudo /etc/eks/bootstrap.sh ${cluster-name} --apiserver-endpoint ${apiserver-endpoint} --b64-cluster-ca ${b64-cluster-ca} --container-runtime containerd

sudo yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent

--==MYBOUNDARY==--