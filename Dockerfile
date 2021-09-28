FROM ruby:3.0.2-alpine
RUN apk add --no-cache --update build-base nmap-ncat bash postgresql-dev tzdata shared-mime-info
RUN mkdir -p /src
WORKDIR /src

# zeromq and libsodium
## alt 1, fast but different versions (1.0.18, 4.3.4), doesn't seem to work
#RUN apk add --no-cache libsodium zeromq

## alt 2, slow but correct versions
RUN wget -q https://archive.promoteapp.net/zeromq-4.0.4.tar.gz -O /src/zeromq-4.0.4.tar.gz \
  && wget -q https://archive.promoteapp.net/libsodium-1.0.0.tar.gz -O /src/libsodium-1.0.0.tar.gz \
  && tar -xf /src/zeromq-4.0.4.tar.gz \
  && tar -xf /src/libsodium-1.0.0.tar.gz \
  && cd /src/libsodium-1.0.0 && ./configure && make install \ 
  && cd /src/zeromq-4.0.4 && ./configure && make install \
  && rm -rf /src/libsodium-1.0.0* /src/zeromq-4.0.4*

## alt 3, prebuilt debian, this doesn't work due to alpine musl issue
#RUN wget -q https://archive.promoteapp.net/libsodium-1.0.0-deb7-amd64.tar.gz -O /src/libsodium.tar.gz \
#  && tar -C /usr/local --strip-components=1 -xzf /src/libsodium.tar.gz \
#  && ldconfig /usr/local \
#  && wget -q https://archive.promoteapp.net/zeromq-4.0.4-deb7-amd64.tar.gz -O /src/zeromq.tar.gz \
#  && tar -C /usr/local --strip-components=1 -xzf /src/zeromq.tar.gz \
#  && ldconfig /usr/local \
#  && rm /src/zeromq.tar.gz /src/libsodium.tar.gz

# Used for waiting on runtime dependencies
# For example db:migrate requires postgres server
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.8.0/wait /wait
RUN chmod +x /wait

RUN gem install bundler -v=2.2.28

COPY entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
