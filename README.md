# Spilo-base image with Supabase extensions and migrations

Warning: WIP

## Build

1. Build the base image

    ```bash
    docker build -t ghcr.io/beaglesinspace/supabase-spilo/focal-python3-10:edge -f Dockerfile.focal-python3-10 .
    ```

2. Build spilo
  
    ```bash
    docker buildx build \
      --tag ghcr.io/beaglesinspace/supabase-spilo/spilo-focal:0 \
      --build-arg BASE_IMAGE=ghcr.io/beaglesinspace/supabase-spilo/focal-python3-10:edge \
      --build-arg DEB_PG_SUPPORTED_VERSIONS="15" \
      --build-arg TIMESCALEDB=2.11.0 \
      -f ./spilo/postgres-appliance/Dockerfile ./spilo/postgres-appliance/
    ```

3. Build supabase-extensions

    ```bash
    docker buildx build \
      --tag ghcr.io/beaglesinspace/supabase-spilo/extensions:edge \
      --target=extensions postgres/
    ```

4. Build postgres

    ```bash
    docker buildx build \
      --tag ghcr.io/beaglesinspace/supabase-spilo/spilo-supabase:edge \
      --build-arg spilo_image=ghcr.io/beaglesinspace/supabase-spilo/spilo-focal:edge \
      --build-arg supabase_extensions_image=ghcr.io/beaglesinspace/supabase-spilo/extensions:edge \
      --target=spilo .
    ```
