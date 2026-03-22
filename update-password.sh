#!/usr/bin/env bash

set -euo pipefail

FILE="Pod.yml"

echo "🔐 Generating secure passwords..."

# Generate passwords
MARIADB_ROOT_PASSWORD=$(pwgen -s 32 1)
MARIADB_PASSWORD=$(pwgen -s 32 1)
DCS_PASSWORD=$(pwgen -s 32 1)
ADMIN_MASTER_PASSWORD=$(pwgen -s 24 1)
CONTEXT_ADMIN_PASSWORD=$(pwgen -s 24 1)

# IMPORTANT
export MARIADB_ROOT_PASSWORD
export MARIADB_PASSWORD
export DCS_PASSWORD
export ADMIN_MASTER_PASSWORD
export CONTEXT_ADMIN_PASSWORD

echo "📄 Updating $FILE ..."

# MariaDB
yq e -i '
(.spec.containers[] | select(.name=="mariadb").env[] | select(.name=="MARIADB_ROOT_PASSWORD").value) = strenv(MARIADB_ROOT_PASSWORD)
' "$FILE"

yq e -i '
(.spec.containers[] | select(.name=="mariadb").env[] | select(.name=="MARIADB_PASSWORD").value) = strenv(MARIADB_PASSWORD)
' "$FILE"

# DCS
yq e -i '
(.spec.containers[] | select(.name=="dcs").env[] | select(.name=="OX_DCSDB_DB_PASSWORD").value) = strenv(DCS_PASSWORD)
' "$FILE"

yq e -i '
(.spec.containers[] | select(.name=="dcs").env[] | select(.name=="OX_CONFIG_DATABASE_ROOT_PASSWORD").value) = strenv(MARIADB_ROOT_PASSWORD)
' "$FILE"

# Appsuite DB
yq e -i '
(.spec.containers[] | select(.name=="appsuite").env[] | select(.name=="OX_CONFIG_DATABASE_PASSWORD").value) = strenv(MARIADB_PASSWORD)
' "$FILE"

yq e -i '
(.spec.containers[] | select(.name=="appsuite").env[] | select(.name=="OX_CONFIG_DATABASE_ROOT_PASSWORD").value) = strenv(MARIADB_ROOT_PASSWORD)
' "$FILE"

# Appsuite DCS
yq e -i '
(.spec.containers[] | select(.name=="appsuite").env[] | select(.name=="OX_DCSDB_DB_PASSWORD").value) = strenv(DCS_PASSWORD)
' "$FILE"

# Admin passwords
yq e -i '
(.spec.containers[] | select(.name=="appsuite").env[] | select(.name=="OX_ADMIN_MASTER_PASSWORD").value) = strenv(ADMIN_MASTER_PASSWORD)
' "$FILE"

yq e -i '
(.spec.containers[] | select(.name=="appsuite").env[] | select(.name=="OX_CONTEXT_ADMIN_PASSWORD").value) = strenv(CONTEXT_ADMIN_PASSWORD)
' "$FILE"

echo "✅ Done."

echo ""
echo "🔑 Generated passwords (SAVE THEM!):"
echo "-----------------------------------"
echo "MARIADB_ROOT_PASSWORD=$MARIADB_ROOT_PASSWORD"
echo "MARIADB_PASSWORD=$MARIADB_PASSWORD"
echo "DCS_PASSWORD=$DCS_PASSWORD"
echo "ADMIN_MASTER_PASSWORD=$ADMIN_MASTER_PASSWORD"
echo "CONTEXT_ADMIN_PASSWORD=$CONTEXT_ADMIN_PASSWORD"
