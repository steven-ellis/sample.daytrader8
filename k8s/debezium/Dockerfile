FROM docker.io/ansible/ansible-runner as plugins

COPY playbook.yml /runner/project/playbook.yml

# dowload connect plugins
RUN ansible-runner -p /runner/project/playbook.yml run /runner

FROM docker.io/strimzi/kafka:latest-kafka-2.5.0

COPY --from=plugins /tmp/debezium-connectors/plugins/ /opt/kafka/plugins/debezium/

USER 1001