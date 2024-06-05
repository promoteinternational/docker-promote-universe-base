FROM ruby:3.3.2-alpine3.20
RUN apk add --no-cache --update build-base nmap-ncat bash postgresql-dev tzdata shared-mime-info libxml2-dev libxslt-dev gcompat less zeromq zeromq-dev geckodriver
RUN mkdir -p /src
WORKDIR /src

# zeromq and libsodium alternatives

## alt 2, slow but correct versions
# RUN wget -q https://archive.promoteapp.net/zeromq-4.0.4.tar.gz -O /src/zeromq-4.0.4.tar.gz \
#   && wget -q https://archive.promoteapp.net/libsodium-1.0.0.tar.gz -O /src/libsodium-1.0.0.tar.gz \
#   && tar -xf /src/zeromq-4.0.4.tar.gz \
#   && tar -xf /src/libsodium-1.0.0.tar.gz \
#   && cd /src/libsodium-1.0.0 && ./configure && make -j 8 install \
#   && cd /src/zeromq-4.0.4 && ./configure && make -j 8 install \
#   && rm -rf /src/libsodium-1.0.0* /src/zeromq-4.0.4*

## alt 3, prebuilt debian, this doesn't work due to alpine musl issue
#RUN wget -q https://archive.promoteapp.net/libsodium-1.0.0-deb7-amd64.tar.gz -O /src/libsodium.tar.gz \
#  && tar -C /usr/local --strip-components=1 -xzf /src/libsodium.tar.gz \
#  && ldconfig /usr/local \
#  && wget -q https://archive.promoteapp.net/zeromq-4.0.4-deb7-amd64.tar.gz -O /src/zeromq.tar.gz \
#  && tar -C /usr/local --strip-components=1 -xzf /src/zeromq.tar.gz \
#  && ldconfig /usr/local \
#  && rm /src/zeromq.tar.gz /src/libsodium.tar.gz

# option 1: prebuilt, 0.34 available in alpine 3.20
# option 2: compile ourself
#RUN apk add --no-cache --update cargo git \
#  && wget -q https://github.com/mozilla/geckodriver/archive/refs/tags/v0.32.0.tar.gz -O /src/geckodriver-0.32.0.tar.gz \
#  && tar -xvf /src/geckodriver-0.32.0.tar.gz \
#  && ls /src \
#  && cd /src/geckodriver-0.32.0 \
#  && cargo install --path . --bin geckodriver --root /usr \
#  && rm -rf /src/geckodriver* /root/.cargo \
#  && apk del cargo

# Used for waiting on runtime dependencies
# For example db:migrate requires postgres server
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.9.0/wait /wait
RUN chmod +x /wait

RUN gem install bundler -v=2.5.11

COPY entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
