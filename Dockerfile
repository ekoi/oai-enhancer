FROM python:3.12.3-bookworm

ARG VERSION=0.1.4

RUN useradd -ms /bin/bash dans

USER dans
WORKDIR /home/dans
ENV PYTHONPATH=/home/dans/oai-enricher-service/src
ENV BASE_DIR=/home/dans/oai-enricher-service

COPY ./dist/*.* .

RUN mkdir -p ${BASE_DIR}  && mkdir -p ${BASE_DIR}/conf && mkdir -p ${BASE_DIR}/logs && mkdir -p ${BASE_DIR}/resources && \
    pip install --no-cache-dir *.whl && rm -rf *.whl && \
    tar xf oai_enricher_service-${VERSION}.tar.gz -C ${BASE_DIR} --strip-components 1 && \
    rm -f oai_enricher_service-${VERSION}.tar.gz

WORKDIR ${BASE_DIR}

CMD ["python", "src/main.py"]
#CMD ["tail", "-f", "/dev/null"]