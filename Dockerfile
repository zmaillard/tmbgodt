FROM erlang:25.3-alpine

# Install Gleam
RUN apk add curl \
    && curl -LO https://github.com/gleam-lang/gleam/releases/download/v1.2.1/gleam-v1.2.1-x86_64-unknown-linux-musl.tar.gz \
    && tar -xzf gleam-v1.2.1-x86_64-unknown-linux-musl.tar.gz \
    && mv gleam /usr/local/bin/gleam


# Add LiteFS binary, to replicate SQLite database
#COPY --from=flyio/litefs:0.5 /usr/local/bin/litefs /usr/local/bin/litefs

#COPY --from=ghcr.io/amacneil/dbmate:2.14 /usr/local/bin/dbmate /usr/local/bin/dbmate

# Add project code
COPY . /build/

RUN cd /build \
    && apk add fuse3 ca-certificates sqlite gcc build-base \
    && gleam export erlang-shipment \
    && mv build/erlang-shipment /app \
    && rm -r /build \
    && apk del gcc build-base

# Add database migrations
#COPY ./db /app/db


#COPY litefs.yml /etc/litefs.yml

# Run the application
WORKDIR /app
#ENTRYPOINT litefs mount

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
