# CoreOS ELB Presence Service

[![Docker Repository on Quay.io](https://quay.io/repository/coreos/elb-presence/status "Docker Repository on Quay.io")](https://quay.io/repository/coreos/elb-presence)

This Docker container allows you to (de)register an EC2 instance with an Amazon Elastic Load Balancer (ELB).

## Usage

### As a Docker container

The `elb-presence` container takes all of its configuration from environment
variables.

``` sh
docker run --rm --name example-presence -e AWS_ACCESS_KEY=AKIAIBC5MW3ONCW6J2XQ -e AWS_SECRET_KEY=qxB5k7GhwZNweuRleclFGcvsqGnjVvObW5ZMKb2V -e AWS_REGION=us-east-1 -e ELB_NAME=ExampleLoadBalancer quay.io/coreos/elb-presence
```

* `AWS_ACCESS_KEY` ... Your AWS [access key](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html)
* `AWS_SECRET_KEY` ... Your AWS [secret key](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html)
* `AWS_REGION` ... The AWS region that your load balancer is located in
* `ELB_NAME` ... The exact name of your load balancer

### Via Fleet

Usually you'll want to manage the lifecycle of your presence service using
[fleet](https://github.com/coreos/fleet). To do so, you can create a service
file similar to this example:

**`my-service-presence@.service`**

``` ini
[Unit]
Description=Example Presence Service
BindsTo=my-service@%i.service

[Service]
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker kill %p-%i
ExecStartPre=-/usr/bin/docker rm %p-%i
ExecStartPre=/usr/bin/docker pull quay.io/coreos/elb-presence:latest
ExecStart=/usr/bin/docker run --rm --name %p-%i -e AWS_ACCESS_KEY=AKIAIBC5MW3ONCW6J2XQ -e AWS_SECRET_KEY=qxB5k7GhwZNweuRleclFGcvsqGnjVvObW5ZMKb2V -e AWS_REGION=us-east-1 -e ELB_NAME=ExampleLoadBalancer quay.io/coreos/elb-presence
ExecStop=/usr/bin/docker stop %p-%i

[X-Fleet]
MachineOf=my-service@%i.service
```

This service will deploy to the same machine as your service (`MachineOf`) and
automatically start and stop along with it (`BindsTo`).

### IAM Policy

If you want to create a minimum privilege IAM user for this presence service,
here is an example IAM Inline Policy for you to use.

Note that you will have to replace the `arn:...` URN with your loadbalancer's.

``` json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
    ],
    "Resource": "arn:aws:elasticloadbalancing:us-west-1:001340051967:loadbalancer/ExampleLoadBalancer"
  }]
}
```
