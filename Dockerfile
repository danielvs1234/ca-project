FROM ubuntu:latest

RUN apt-get update \
&& apt-get install python3 -y \
&& apt-get install python3-pip -y \
&& apt-get install git -y

COPY ./ /ca-project/

RUN pip3 install -r /ca-project/requirements.txt

ENTRYPOINT ["python3", "/ca-project/run.py"]




