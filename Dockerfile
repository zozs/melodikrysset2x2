# PDF generator part
FROM ubuntu:22.04 AS pdf

WORKDIR /usr/local
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.27/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=7dadd4ac827e7bd60b386414dfefc898ae5b6c63

# Install pdflatex and supercronic for cronjobs
RUN apt-get update && apt-get install -y perl wget libfontconfig1 libdatetime-perl curl && \
    wget -qO- "https://yihui.name/gh/tinytex/tools/install-unx.sh" | sh  && \
    apt-get clean && \
    curl -fsSLO "$SUPERCRONIC_URL" \
        && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
        && chmod +x "$SUPERCRONIC" \
        && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
        && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic
ENV PATH="${PATH}:/root/bin"
RUN tlmgr install pdfpages pdflscape
RUN fmtutil-sys --all

COPY crontab /usr/local/etc/crontab
USER www-data
WORKDIR /var/www/pdf
COPY create4.pl /var/www/create4.pl

CMD /var/www/create4.pl && supercronic /usr/local/etc/crontab

# Web server part
FROM docker.io/nginxinc/nginx-unprivileged:alpine AS web

COPY index.html /usr/share/nginx/html/index.html
