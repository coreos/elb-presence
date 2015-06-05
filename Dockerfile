FROM ubuntu:14.04
ADD elb-presence /bin/elb-presence
ADD requirements.txt /requirements.txt

RUN apt-get update
RUN apt-get install -y python-pip
RUN pip install -r /requirements.txt


CMD ["/bin/elb-presence"]
