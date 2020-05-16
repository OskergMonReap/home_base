FROM jetbrains/teamcity-agent

RUN apt-get update && \
    apt-get install -y python3-pip && \
    pip3 install --trusted-host pypi.python.org pytest tox

CMD ["/run-services.sh"]

EXPOSE 9090
