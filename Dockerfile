FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y python-boto

ADD elb-presence /bin/elb-presence

CMD /bin/elb-presence
