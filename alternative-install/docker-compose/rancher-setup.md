# Rancher 2.0 Installation and cluster setup

This documentation is focused on the use of Amazon Web Services(AWS) to setup and install Rancher 2.0, Cluster deployment, and Command Line tools.
1. Rancher 2.0 installation
    * Single node
    * High Availability(HA) cluster.
2. [Rancher Docs](https://rancher.com/docs/rancher/v2.x/en/installation/#installation-options).

### Installation Single Node

1. [Hardware requirements](https://rancher.com/docs/rancher/v2.x/en/installation/requirements/)
2. Provision Host - Rancher has created an AWS AMI RancherOS - HVM. EC2 under launch instance search for `rancher`. RancherOS comes with docker installed and ready to deploy rancher.
    * AWS Instance type (t2.xlarge depending on number of clusters. Please check the Hardware requirements link above)
    * Setup AWS ElasticIP
    * Associate Rancher EC2 Instance ID with ElasticIP
    * Add A-Record DNS entry for ElasticIP and FQDN
    * Certificate authority (CA)
        1. [Lets Encrypt](https://letsencrypt.org/)
            * Selected Let's Encrypt - Free to obtain certifications
        2. [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/faqs/)
            * Fee associated with obtaining certifications
        3. Other certificate authority (CA)
3. SSL Options - Many options:
   - Bring your own. This was the option that I used for deployment

         docker run -d --restart=unless-stopped \
          -p 80:80 -p 443:443 \
          -v << hostpath_to_certs >>/fullchain.pem:/etc/rancher/ssl/cert.pem \
          -v << hostpath_to_certs >>/privkey.pem:/etc/rancher/ssl/key.pem \
          -v /<< hostpath_local_volume >>:/var/lib/rancher \
          rancher/rancher:latest --no-cacerts

   - Please note: Local volume for etcd database. All settings stored with ectd database
   - Rancher can not verify external certifications. If you bring external certifications please remove `cacerts.pem` file volume mount.

### Rancher 2.0 Setup

1. Requires initial login. User must enter username and password
2. Rancher determines domain name in which user must confirm
3. Authentication: Many Options
   - Github integration setup up keypair
     1. Within github organization -> settings -> OAuth Apps
     2. Enter App name, url, callback url
     3. Copy ClientID and Client Secret
   - Rancher Setup
     1. Rancher Menu: Security -> Authentication
     2. Select Github
     3. copy ClientID and Client Secret
     4. Setup access permissions.
     5. Select Authorized Users and Organizations
     6. Specify organization or select specific team within organization.

### Rancher Kubernetes Cluster Setup with AWS EKS

1. Login into Rancher
    * Select Clusters on main Menu
    * Click `Add Cluster`
2. Setup Cluster AWS EKS service
    * Select `Amazon EKS`
    * Enter Cluster name (libapps)
    * Under `Member Roles` Add users that can control cluster
        1. This is associated with the Authentication above. In my case used Github Organization (CUlibraries) and team name (Rancher).
        2. Role - `Owner`
    * Account Access
        1. Select region - `us-west-2` (depending on your AWS region)
        2. AWS IAM user created with Programmatic access. Permission policies add to user.
        3. Enter AWS Key pair that has authentication to generate AWS EKS cluster and networking. Setup
        3. Session Token is optional and was not used for this setup.
    * Service Role
        1. Selected `Standard: Rancher generated service role`
    * VPC & Subnet
        1. Selected `Public` and `Standard: Rancher generated VPC and Subnet`
    * Nodes
        1. Instance type selected m5.large
        2. Optional 'Custom AMI Override' - not used
        3. Min and Max Auto Scaling Group (ASG) 1 , 3
            * [AutoSpotting reduce AWS cost with spot instances](https://rancher.com/reducing-aws-spend/)
        4. Click `Create`
        5. Cluster creation takes couple of minutes. Wait till Clusters page says that the cluster is `Active`

### New Rancher Cluster setup command line tools
The newly created cluster will become `active` on the Rancher Clusters Home Page. Click on the newly created Cluster Name(libapps). The dashboard will come up for the cluster.
1. Kubectl
    1. Click cluster name to bring up cluster dashboard
    2. Rancher `Launch kubectl` allows direct access to cluster command-line console through Rancher management console
    2. Setup local laptop to use kubectl on the new cluster
        * [Kubectl Installation](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
        * Click `KubeConfig File`
        * Click `Copy to Clipboard`
        * Put this into ~/.kube/config
        * Test kubectl ``
2. Rancher CLI
     1. Setup local laptop with Rancher CLI
        * [Rancher CLI Installation](https://rancher.com/docs/rancher/v2.x/en/cli/#download-rancher-cli)
            * Place rancher in system PATH environmental variable
        * Apple Mac - Homebrew install

                $ brew install rancher-cli
     2. Setup Rancher user API Token
        * Rancher management console
        * Drop down menu under username (Upper Right Corner)
            1. Select `API & Keys`
            2. Click `Add Key`
            3. Add description and click `Create`
            4. Copy URL Endpoint and Token
     2. Login to Rancher API

            $ rancher login < RANCHER URL ENDPOINT > --token < TOKEN >
3. Test Rancher and Kubectl Installation

        $ rancher kubectl get nodes

        NAME                                           STATUS   ROLES    AGE   VERSION
        ip-192-168-107-71.us-west-2.compute.internal   Ready    <none>   4h    v1.10.3
        ip-192-168-160-53.us-west-2.compute.internal   Ready    <none>   4h    v1.10.3
        ip-192-168-237-15.us-west-2.compute.internal   Ready    <none>   4h    v1.10.3
4.
### FOLIO Automation Tools
1. Addition tools needed for FOLIO automation script.
    1. Python pip
        * [Pip Install](https://pip.pypa.io/en/stable/installing/)
    2. virtualenv

            $ pip install virtualenv

2. Create virtualenv
    * Python 2.7

            $ virtualenv -p python2.7 virtpy

    * Python 3

            $ virtualenv -p python3.x virtpy
3. Activate Python virtual environment

            $ source virtpy/bin/activate
4. Install python libraries

        $ cd deployments/folio-backend
        $ pip install -r requirements.txt
