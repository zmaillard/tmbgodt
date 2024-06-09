FROM erlang:25.3-alpine

# Install Gleam
RUN apk add curl \
    && curl -LO https://github.com/gleam-lang/gleam/releases/download/v1.2.1/gleam-v1.2.1-x86_64-unknown-linux-musl.tar.gz \
    && tar -xzf gleam-v1.2.1-x86_64-unknown-linux-musl.tar.gz \
    && mv gleam /usr/local/bin/gleam

# Add project code
COPY . /build/

RUN cd /build \
    && apk add ca-certificates gcc build-base \
    && gleam export erlang-shipment \
    && mv build/erlang-shipment /app \
    && rm -r /build \
    && apk del gcc build-base curl

# Add database migrations
#COPY ./db /app/db


#COPY litefs.yml /etc/litefs.yml

# Run the application
WORKDIR /app
#ENTRYPOINT litefs mount

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
