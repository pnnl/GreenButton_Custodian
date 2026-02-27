#!/usr/bin/env bash
set -euo pipefail

DC_PORT=${DC_PORT:-8080}
RC_ID=${1:-1}

XML_FILE=${2:-}

TAGGED_DIR="/GBA/OpenESPI-DataCustodian-java/src/User 1 XML Files/xmlFilesTagged"
DEFAULT_XML_OLD="/GBA/OpenESPI-DataCustodian-java/user1.xml"

normalize_urn_uuid_tokens_to_stdout() {
  local in_file="$1"

  # The tagged privacy variant files include IDs like urn:uuid:<uuid>-low which are not RFC-4122 UUIDs.
  # DataCustodian expects UUIDType, so we rewrite any non-UUID urn:uuid:* tokens into deterministic UUIDs.
  # Output is written to stdout so we don't create temp files.
  python3 - "$in_file" <<'PY'
import re
import sys
import uuid

in_path = sys.argv[1]

with open(in_path, 'r', encoding='utf-8', errors='strict') as f:
  text = f.read()

pattern = re.compile(r"urn:uuid:([A-Za-z0-9\-]+)")
cache: dict[str, str] = {}

def to_uuid(token: str) -> str:
  if token in cache:
    return cache[token]
  try:
    u = uuid.UUID(token)
    cache[token] = str(u).upper()
  except Exception:
    # Stable mapping from arbitrary token -> UUID.
    # Use a fixed namespace so values are stable across runs.
    u = uuid.uuid5(uuid.NAMESPACE_URL, token)
    cache[token] = str(u).upper()
  return cache[token]

def repl(match: re.Match) -> str:
  token = match.group(1)
  return "urn:uuid:" + to_uuid(token)

new_text = pattern.sub(repl, text)
sys.stdout.write(new_text)
PY
}

import_file() {
  local file="$1"
  local generate_variants="$2" # true|false

  if [[ ! -f "$file" ]]; then
    echo "XML file not found: $file" >&2
    return 1
  fi

  echo "Uploading $file to retailCustomerId=$RC_ID (generatePrivacyVariants=${generate_variants}) ..."
  local url="http://localhost:${DC_PORT}/DataCustodian/api/data/import?retailCustomerId=${RC_ID}&generatePrivacyVariants=${generate_variants}"
  local resp http body

  if [[ "$generate_variants" == "false" ]]; then
    # Normalize variant IDs before uploading so DC import doesn't fail.
    # Stream directly to curl; do not write temporary files.
    resp=$(curl -sS -X POST \
      -F "file=@-;filename=$(basename "$file");type=application/xml" \
      -w $'\n%{http_code}' \
      "$url" \
      < <(normalize_urn_uuid_tokens_to_stdout "$file") \
    )
  else
    resp=$(curl -sS -X POST \
      -F "file=@${file};type=application/xml" \
      -w $'\n%{http_code}' \
      "$url" \
    )
  fi

  http="${resp##*$'\n'}"
  body="${resp%$'\n'*}"

  echo "HTTP: $http"
  if [[ "$http" != 204* && "$http" != 200* ]]; then
    echo "--- Response body (truncated) ---"
    printf '%s\n' "$body" | head -n 80 || true
    return 1
  fi

  echo "Upload complete."
  return 0
}

# If an explicit XML file is provided, keep legacy behavior:
# import that one file and also ask DC to generate privacy variants.
if [[ -n "${XML_FILE}" ]]; then
  import_file "$XML_FILE" true
  exit $?
fi

# Preferred behavior: import only the up-to-date tagged privacy feeds.
# This avoids uploading any non-privacy-scoped “base” feeds.
if [[ -d "$TAGGED_DIR" ]]; then
  shopt -s nullglob
  variant_files=(
    "$TAGGED_DIR"/*-low.xml "$TAGGED_DIR"/*-medium.xml "$TAGGED_DIR"/*-high.xml "$TAGGED_DIR"/*-full.xml
    "$TAGGED_DIR"/*_low.xml "$TAGGED_DIR"/*_medium.xml "$TAGGED_DIR"/*_high.xml "$TAGGED_DIR"/*_full.xml
  )
  shopt -u nullglob

  if [[ ${#variant_files[@]} -eq 0 ]]; then
    echo "No tagged privacy feeds found in: $TAGGED_DIR" >&2
    exit 1
  fi

  for variant in "${variant_files[@]}"; do
    import_file "$variant" false
  done

  exit 0
fi

# Fallback: old single file.
import_file "$DEFAULT_XML_OLD" true
