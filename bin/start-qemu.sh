#!/bin/sh

IMAGE=${IMAGE_DIR}/${IMAGE_NAME}
RUN_IMAGE=${RUN_DIR}/${IMAGE_NAME}

# remove old image if it exist
rm -f ${RUN_IMAGE}
# create new image in volume to bypass the 10GB limit
qemu-img create -f qcow2 -b $IMAGE $RUN_IMAGE
# start image with port forwarding
qemu-system-x86_64 -smp 1 -m 3072M -vnc :0 -device virtio-net,netdev=user.0 -netdev user,id=user.0,hostfwd=tcp::22-:22 -machine type=pc,accel=kvm, -drive file=${RUN_DIR}/${IMAGE_NAME},if=virtio,cache=writeback
