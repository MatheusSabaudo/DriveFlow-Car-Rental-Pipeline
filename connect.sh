# connect.sh — load PG* env vars for the Class A RDS so you can just run `psql`.
#
# USAGE (must be SOURCED, not executed, so the exports stay in your shell):
#   export AWS_PROFILE=lab
#   source connect.sh
# then:
#   psql                                    # interactive
#   psql -f include/sql/ddl_ops.sql         # run DDL
#   psql -c '\dt ops.*'                     # verify
#
# Requires: an applied `envs/class-a` with enable_rds=true, plus awscli, jq, psql.

# --- guard: must be sourced ---------------------------------------------------
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo "ERROR: source this file, don't run it:  source connect.sh" >&2
  exit 1
fi

# --- locate the env root relative to this script ------------------------------
_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_ENV_DIR="${_REPO_ROOT}/envs/class-a"

# --- checks -------------------------------------------------------------------
for _cmd in terraform aws jq psql; do
  command -v "$_cmd" >/dev/null 2>&1 || { echo "ERROR: '$_cmd' not found on PATH" >&2; return 1; }
done
: "${AWS_PROFILE:?Set AWS_PROFILE first, e.g. export AWS_PROFILE=lab}"

# --- pull connection info from terraform outputs (-chdir avoids cd'ing you) ---
_tf() { terraform -chdir="${_ENV_DIR}" output -raw "$1" 2>/dev/null; }

_HOST="$(_tf rds_address)"
_DB="$(_tf rds_db_name)"
_SECRET_ARN="$(_tf rds_master_user_secret_arn)"

if [ -z "${_HOST}" ] || [ "${_HOST}" = "null" ] || [ -z "${_SECRET_ARN}" ] || [ "${_SECRET_ARN}" = "null" ]; then
  echo "ERROR: RDS outputs are empty. Did you 'terraform apply -var enable_rds=true' in envs/class-a?" >&2
  return 1
fi

# --- fetch the managed master credentials from Secrets Manager ----------------
_SECRET="$(aws secretsmanager get-secret-value --secret-id "${_SECRET_ARN}" \
  --query SecretString --output text)" || { echo "ERROR: could not read the RDS secret" >&2; return 1; }

# --- export the standard PG* vars psql reads automatically --------------------
export PGHOST="${_HOST}"
export PGPORT=5432
export PGDATABASE="${_DB}"
export PGSSLMODE=require
export PGUSER="$(echo "${_SECRET}" | jq -r .username)"
export PGPASSWORD="$(echo "${_SECRET}" | jq -r .password)"

# --- cleanup locals -----------------------------------------------------------
unset _SECRET _SECRET_ARN _HOST _DB _REPO_ROOT _ENV_DIR _cmd

echo "Connected profile: ${PGUSER}@${PGHOST}:${PGPORT}/${PGDATABASE} (sslmode=${PGSSLMODE})"
echo "Now run:  psql   |   psql -f include/sql/ddl_ops.sql   |   psql -c '\\dt ops.*'"
