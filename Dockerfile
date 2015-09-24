FROM registry.camunda.com/ubuntu:14.04.2

ENV IMAGE_NAME=windows-2012.qcow2 \
    IMAGE_DIR=/qemu/ \
    RUN_DIR=/qemu/run

# create directories
RUN mkdir -p $IMAGE_DIR $RUN_DIR

# set run dir to be a volume (to remove 10GB limit)
VOLUME $RUN_DIR

# add helper script
ADD bin/* /usr/local/bin/

# install qemu
RUN yum -y -q update && \
    yum -y -q install curl qemu-system-x86 qemu-img && \
    yum -q clean all && \
    rm -rf /var/cache/* /var/lib/yum/lists* /tmp/* /var/tmp/*

# add qemu image
RUN curl https://nginx.service.consul/ci/binaries/microsoft/${IMAGE_NAME} > ${IMAGE_DIR}/${IMAGE_NAME}

EXPOSE 22 5900

CMD ["/usr/local/bin/start-qemu.sh"]
