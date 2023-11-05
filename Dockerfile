# PDF generator part
FROM ubuntu:22.04 AS pdf

WORKDIR /usr/local
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.27/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=7dadd4ac827e7bd60b386414dfefc898ae5b6c63

# Install pdflatex and supercronic for cronjobs
RUN apt-get update && apt-get install -y perl wget libfontconfig1 libdatetime-perl curl && apt-get clean && \
    curl -fsSLO "$SUPERCRONIC_URL" \
        && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
        && chmod +x "$SUPERCRONIC" \
        && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
        && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

USER www-data
WORKDIR /var/www
RUN wget -qO- "https://yihui.name/gh/tinytex/tools/install-unx.sh" | sh
ENV PATH="${PATH}:/var/www/bin"
RUN tlmgr install pdfpages pdflscape
RUN fmtutil-sys --all

COPY create4.pl /var/www/create4.pl
COPY crontab /var/www/crontab

WORKDIR /var/www/pdf
CMD /var/www/create4.pl && supercronic /var/www/crontab

# Web server part
FROM docker.io/nginxinc/nginx-unprivileged:alpine AS web

COPY index.html /usr/share/nginx/html/index.html
