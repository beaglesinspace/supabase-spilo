ARG supabase_extensions_image
ARG spilo_image

FROM ${supabase_extensions_image} as extensions
FROM ${spilo_image} as spilo

ARG allowed_extensions="jwt net sodium graphql jsonschema vault wrappers stat_monitor vector"
ARG postgresql_major=15
ARG supabase_src_dir=./postgres
ARG supabase_custom=${supabase_src_dir}/ansible/files

COPY --from=extensions /tmp /tmp/pg-extensions

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    extensions=$(find /tmp/pg-extensions -name "*.deb" | grep -E "$(echo $allowed_extensions | sed 's/ /|/g')") && \
    apt-get install -y --no-install-recommends $extensions ca-certificates && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ADD --chown=postgres:postgres \
    --chmod=0755 \
    https://github.com/amacneil/dbmate/releases/latest/download/dbmate-linux-amd64 \
    /usr/local/bin/dbmate  

COPY --chown=postgres:postgres ${supabase_custom}/postgresql_extension_custom_scripts/postgres_fdw /scripts/postgres_fdw
COPY --chown=postgres:postgres ${supabase_custom}/postgresql_extension_custom_scripts/pgsodium /scripts/pgsodium
COPY --chown=postgres:postgres ${supabase_custom}/pgsodium_getkey_urandom.sh.j2 /usr/lib/postgresql/${postgresql_major}/bin/pgsodium_getkey.sh
COPY --chown=postgres:postgres ${supabase_src_dir}/migrations /scripts/supabase

# DO not demote postgres user at the moment
# TODO: 
# - check if we can use supabase_admin for our dba
# - check if it won't break patroni/spilo ops
RUN rm /scripts/supabase/db/migrations/10000000000000_demote-postgres.sql
