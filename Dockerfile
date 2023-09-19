FROM busybox AS homebuilder
ADD home /home
RUN sh -c 'for i in $(seq 1000 3000); do chown $i:$i /home/u$i; done'
FROM scratch
USER ${USER:-1234}
LABEL ok=ok
COPY --from=homebuilder /home /home
ADD machine-id /etc/machine-id
ADD passwd /etc/passwd
