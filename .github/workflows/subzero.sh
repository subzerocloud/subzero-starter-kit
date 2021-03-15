#!/bin/bash

# This is a helper script that implements some actions used in CI/CD configuration scripts

IFS=
check_configuration() {
    local CHECKS_FAILED=false
    echo "checking configuration"
    # check all needed variables are set
    for ENV_VAR in APP_NAME APP_DOMAIN APP_DB_MASTER_USER APP_DB_MASTER_PASSWORD APP_DB_HOST APP_DB_PORT APP_DB_NAME APP_DB_AUTHENTICATOR_USER APP_DB_AUTHENTICATOR_PASS APP_JWT_SECRET APP_DB_SCHEMA APP_DB_ANON_ROLE
    do
    if [ -z ${!ENV_VAR} ]; then echo "${ENV_VAR} is unset"; CHECKS_FAILED=true; fi
    done

    if [ "$UPLOAD_STATIC_FILES" = true ]; then
    for ENV_VAR in SFTP_USER SFTP_HOST SFTP_PORT SFTP_USER SFTP_PASSWORD
    do
        if [ -z ${!ENV_VAR} ]; then echo "${ENV_VAR} is unset"; CHECKS_FAILED=true; fi
    done
    fi

    if [ "$DEPLOY_TARGET" = "subzerocloud" ]; then
    for ENV_VAR in SUBZERO_EMAIL SUBZERO_PASSWORD
    do
        if [ -z ${!ENV_VAR} ]; then echo "${ENV_VAR} is unset"; CHECKS_FAILED=true; fi
    done
    fi

    # check migrations folder present
    if [ ! -f ./db/migrations/sqitch.plan ]; then
        echo "Migrations folder missing, please run 'subzero migrations init --with-roles'"
        CHECKS_FAILED=true
    fi
    
    if [ "$CHECKS_FAILED" = true ]; then exit 1; fi
}

check_database_connection() {
    echo "checking database connection"
    psql -c '\q' "$1"
}

store_jwt_secret_in_settings() {
    local ROLE=$1
    local JWT_SECRET=$2
    local CONNECTION_STRING=$3
    echo "storing jwt secret in settings table";
    psql -qc "select settings.set('jwt_secret', '$JWT_SECRET')" "$CONNECTION_STRING"
}

store_jwt_secret_as_guc() {
    local ROLE=$1
    local JWT_SECRET=$2
    local CONNECTION_STRING=$3
    echo "storing jwt secret as GUC for authenticator role";
    psql -qc "alter role $ROLE set pgrst.jwt_secret = '$JWT_SECRET'" "$CONNECTION_STRING"
}

setup_authenticator_role() {
    local ROLE=$1
    local PASS=$2
    local CONNECTION_STRING=$3
    local ROLE_EXISTS=$(
        psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$ROLE'" "$CONNECTION_STRING"
    )
    if [ $ROLE_EXISTS ]; then
        echo "autheticator role exists, skipping creation";
    else
        echo "authenticator role does not exist, creating ...";
        psql -qc "CREATE ROLE $ROLE WITH LOGIN PASSWORD '$PASS' NOINHERIT" "$CONNECTION_STRING"
    fi
}

update_authenticator_role_password() {
    local ROLE=$1
    local PASS=$2
    local CONNECTION_STRING=$3
    echo "update authenticator role password";
    psql -qc "ALTER ROLE $ROLE WITH PASSWORD '$PASS'" "$CONNECTION_STRING"
}

login() {
 
    local RESPONSE=$(
        curl -s -w '\n%{response_code}' -X POST \
        --cookie-jar session.txt \
        -H 'Content-Type: application/json' \
        -d "{\"email\":\"$1\",\"password\":\"$2\"}" \
        "$SUBZERO_API_ENDPOINT/rest/rpc/login?select=id"
    )
    local HTTP_STATUS=$(echo $RESPONSE | sed -n 2p)
    if [ "$HTTP_STATUS" != "200" ]; then
        echo $RESPONSE | sed -n 1p
        exit 1; 
    fi
}

reload_db_schema() {
    curl -s -X GET \
    --cookie session.txt \
    "${SUBZERO_API_ENDPOINT}/rest/rpc/reload_db_schema?id=eq.$" > /dev/null
}

update_configuration(){
    PAYLOAD=$(
        jq -n \
            --arg domain "$APP_DOMAIN" \
            --arg name "$APP_NAME" \
            --arg db_host "$APP_DB_HOST" \
            --arg db_port "$APP_DB_PORT" \
            --arg db_name "$APP_DB_NAME" \
            --arg db_authenticator "$APP_DB_AUTHENTICATOR_USER" \
            --arg db_authenticator_pass "$APP_DB_AUTHENTICATOR_PASS" \
            --arg db_schema "$APP_DB_SCHEMA" \
            --arg db_anon_role "$APP_DB_ANON_ROLE" \
            --arg jwt_secret "$APP_JWT_SECRET" \
            '{domain: $domain, name: $name, db_host: $db_host, db_port: $db_port, db_name: $db_name, db_authenticator: $db_authenticator, db_authenticator_pass: $db_authenticator_pass, db_schema: $db_schema, db_anon_role: $db_anon_role, jwt_secret: $jwt_secret}'
    )

    echo $PAYLOAD > payload.json
    local RESPONSE=$(
        curl -s -w '\n%{response_code}' -X PATCH \
        --cookie session.txt \
        -H 'Content-Type: application/json' \
        -H 'Prefer: return=representation' \
        --data-binary "@payload.json" \
        "${SUBZERO_API_ENDPOINT}/rest/applications?select=id&id=eq.${APP_ID}"
    )

    rm payload.json
    local HTTP_STATUS=$(echo $RESPONSE | sed -n 2p)
    if [ "$HTTP_STATUS" != "200" ]; then
        echo HTTP_STATUS
        echo $RESPONSE | sed -n 1p
        exit 1; 
    fi

}

create_application(){
    local HTTP_STATUS=$(
        curl -so /dev/null -w '%{response_code}' \
        --cookie session.txt \
        -H "Accept: application/vnd.pgrst.object+json" \
        "${SUBZERO_API_ENDPOINT}/rest/applications?select=id,domain&domain=eq.${APP_DOMAIN}"
    )
    if [ "$HTTP_STATUS" == "200" ]; then
        # this sets the global env var which will be used by the rest of the script
        APP_ID=$(
            curl -s \
            --cookie session.txt \
            -H "Accept: text/csv" \
            "${SUBZERO_API_ENDPOINT}/rest/applications?select=id&domain=eq.${APP_DOMAIN}" \
            | sed -n 2p
        )
        echo "app with domain=${APP_DOMAIN} already exists ($APP_ID), skipping creation"
    else
        echo "creating app with domain=${APP_DOMAIN}"
        PAYLOAD=$(
            jq -n \
                --arg domain "$APP_DOMAIN" \
                --arg name "$APP_NAME" \
                --arg db_host "$APP_DB_HOST" \
                --arg db_port "$APP_DB_PORT" \
                --arg db_name "$APP_DB_NAME" \
                --arg db_authenticator "$APP_DB_AUTHENTICATOR_USER" \
                --arg db_authenticator_pass "$APP_DB_AUTHENTICATOR_PASS" \
                --arg db_schema "$APP_DB_SCHEMA" \
                --arg db_anon_role "$APP_DB_ANON_ROLE" \
                --arg jwt_secret "$APP_JWT_SECRET" \
                '{domain: $domain, name: $name, db_host: $db_host, db_port: $db_port, db_name: $db_name, db_authenticator: $db_authenticator, db_authenticator_pass: $db_authenticator_pass, db_schema: $db_schema, db_anon_role: $db_anon_role, jwt_secret: $jwt_secret}'
        )

        echo $PAYLOAD > payload.json
        APP_ID=$(
            curl -s -X POST \
            --cookie session.txt \
            -H "Accept: text/csv" \
            -H 'Content-Type: application/json' \
            -H 'Prefer: return=representation' \
            --data-binary "@payload.json" \
            "${SUBZERO_API_ENDPOINT}/rest/applications?select=id" \
            | sed -n 2p
        )
        rm payload.json
        echo "app with domain=${APP_DOMAIN} created ($APP_ID)"
    fi
    export APP_ID=$APP_ID
    echo "APP_ID=$APP_ID" >> $GITHUB_ENV
}

case "$1" in
    "") ;;
    check_configuration) "$@"; exit;;
    check_database_connection) "$@"; exit;;
    login) "$@"; exit;;
    reload_db_schema) "$@"; exit;;
    update_configuration) "$@"; exit;;
    create_application) "$@"; exit;;
    setup_authenticator_role) "$@"; exit;;
    update_authenticator_role_password) "$@"; exit;;
    store_jwt_secret_as_guc) "$@"; exit;;
    store_jwt_secret_in_settings) "$@"; exit;;
    *) log_error "Unkown function: $1()"; exit 2;;
esac