FROM postgres:17

# Build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    wget \
    libssl-dev \
    postgresql-server-dev-17 \
    mongosh \
    mongodb-database-tools \
    && rm -rf /var/lib/apt/lists/*

# Copy source
COPY . /build/mongo_fdw
WORKDIR /build/mongo_fdw

# Build mongo-c-driver and json-c via autogen, then build the extension
ENV MONGOC_INSTALL_DIR=/usr/local
ENV JSONC_INSTALL_DIR=/usr/local
RUN ./autogen.sh \
    && export PKG_CONFIG_PATH=/build/mongo_fdw/mongo-c-driver/src/libmongoc/src:/build/mongo_fdw/mongo-c-driver/src/libbson/src \
    && make USE_PGXS=1 clean \
    && make USE_PGXS=1 \
    && make USE_PGXS=1 install

# Keep test assets available at runtime
WORKDIR /build/mongo_fdw
