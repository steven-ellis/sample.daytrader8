FROM docker.io/openliberty/open-liberty-s2i

ARG MAVEN_MIRROR_URL='https://repo1.maven.org/maven2'

USER 0
ADD . /tmp/src
RUN chown -R 1001:0 /tmp/src

USER 1001

RUN /usr/local/s2i/assemble

CMD /usr/local/s2i/run