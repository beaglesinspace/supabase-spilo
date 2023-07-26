ARG supabase_extensions_image
ARG spilo_image

FROM ${supabase_extensions_image} as extensions
FROM ${spilo_image} as spilo

ARG allowed_extensions="pgjwt pg_cron pg_net pgsodium pg_graphql pg_jsonschema safeupdate vault wrappers"
ARG postgresql_major=15
ARG supabase_src_dir=./postgres
ARG supabase_custom=${supabase_src_dir}/ansible/files

COPY --from=extensions /tmp /tmp

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    for ext in $allowed_extensions; do \
        apt-get install -y --no-install-recommends /tmp/${ext}*.deb; \
    done && \
    # Needed for anything using libcurl
    # https://github.com/supabase/postgres/issues/573
    apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/* /tmp/*

COPY --chown=postgres:postgres ${supabase_custom}/postgresql_extension_custom_scripts/postgres_fdw /scripts/postgres_fdw
COPY --chown=postgres:postgres ${supabase_custom}/postgresql_extension_custom_scripts/pgsodium /scripts/pgsodium
COPY --chown=postgres:postgres ${supabase_custom}/pgsodium_getkey_urandom.sh.j2 /usr/lib/postgresql/${postgresql_major}/bin/pgsodium_getkey.sh
COPY --chown=postgres:postgres ${supabase_src_dir}/migrations /scripts/migrations
