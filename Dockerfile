FROM ubuntu:24.10

RUN apt update && apt install -y wget gnupg xz-utils

WORKDIR /tmp
RUN wget https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh && \
    chmod +x guix-install.sh

RUN cat <<EOM >> /etc/services
ftp-data        20/tcp
ftp             21/tcp
ssh             22/tcp                          # SSH Remote Login Protocol
domain          53/tcp                          # Domain Name Server
domain          53/udp
http            80/tcp          www             # WorldWideWeb HTTP
https           443/tcp                         # http protocol over TLS/SSL
ftps-data       989/tcp                         # FTP over SSL (data)
ftps            990/tcp
http-alt        8080/tcp        webcache        # WWW caching service
http-alt        8080/udp
EOM

# auto accepts install
RUN echo -e "\n" | ./guix-install.sh

# Copy SysV init script for Guix daemon
COPY guix-daemon.init /etc/init.d/guix-daemon
RUN chmod +x /etc/init.d/guix-daemon \
    && update-rc.d guix-daemon defaults

RUN rm /tmp/guix-install.sh

ENV GUIX_PROFILE=/root/.guix-profile
ENV PATH=$GUIX_PROFILE/bin:$PATH

WORKDIR /

COPY guix-runner.sh /guix-runner.sh
RUN chmod +x /guix-runner.sh

# RUN --security=insecure sh -c '/guix-runner.sh guix pull && guix package --fallback -i nss-certs' \
#         && sh -c '/guix-runner.sh guix gc && guix gc --optimize'

RUN ./guix-runner.sh guix pull

ENTRYPOINT ["/guix-runner.sh"]

CMD ["guix --version"]