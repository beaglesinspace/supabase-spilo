# Spilo-base image with Supabase extensions and migrations

## Build

1. Build the base image

    ```bash
    docker build -t ghcr.io/beaglesinspace/pg_friisbi/focal-python3.10:0 -f Dockerfile.focal-python-3-10 .
    ```

2. Build spilo
  
    ```bash
    docker buildx build \
      --tag ghcr.io/beaglesinspace/pg_friisbi/spilo-focal:0 \
      --build-arg BASE_IMAGE=ghcr.io/beaglesinspace/pg_friisbi/focal-python3.10:0 \
      --build-arg DEB_PG_SUPPORTED_VERSIONS="15" \
      --build-arg TIMESCALEDB=2.11.0 \
      -f ./spilo/postgres-appliance/Dockerfile ./spilo/postgres-appliance/
    ```

3. Build supabase-extensions

    ```bash
    docker buildx build \
      --tag ghcr.io/beaglesinspace/pg_friisbi/supabase-extensions:0 \
      --target=extensions postgres/
    ```

4. Build postgres

    ```bash
    docker buildx build \
      --tag ghcr.io/beaglesinspace/pg_friisbi/spilo-supabase:0 \
      --build-arg spilo_image=ghcr.io/beaglesinspace/pg_friisbi/spilo-focal:0 \
      --build-arg supabase_extensions_image=ghcr.io/beaglesinspace/pg_friisbi/supabase-extensions:0 \
      --target=spilo .
    ```
