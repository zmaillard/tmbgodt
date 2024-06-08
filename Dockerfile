FROM erlang:25.3-alpine

# Install Gleam
RUN apk add curl \
    && curl -LO https://github.com/gleam-lang/gleam/releases/download/v1.2.1/gleam-v1.2.1-x86_64-unknown-linux-musl.tar.gz \
    && tar -xzf gleam-v1.2.1-x86_64-unknown-linux-musl.tar.gz \
    && mv gleam /usr/local/bin/gleam

# Add project code
COPY . /build/

RUN cd /build \
    && gleam export erlang-shipment \
    && mv build/erlang-shipment /app \
    && rm -r /build \
    && apk del curl

# Run the application
WORKDIR /app

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
