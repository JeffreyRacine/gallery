#!/bin/sh

set -eu

ROOT=${1:-/Users/jracine/Development/Gallery_website}

failures=0

pass() {
  printf 'PASS: %s\n' "$1"
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  failures=$((failures + 1))
}

forbid_regex_in_tree() {
  pattern=$1
  label=$2
  shift 2

  if rg -n -e "$pattern" "$@" >/dev/null 2>&1; then
    fail "$label"
    rg -n -e "$pattern" "$@" >&2 || true
  else
    pass "$label"
  fi
}

expect_fixed() {
  path=$1
  needle=$2
  label=$3

  if rg -n -F -- "$needle" "$path" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label (missing: $needle)"
  fi
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'FAIL: required command not found: %s\n' "$1" >&2
    exit 1
  }
}

require_file() {
  path=$1
  label=$2

  if [ -f "$path" ]; then
    pass "$label"
  else
    fail "$label ($path missing)"
  fi
}

require_cmd rg

printf '== Gallery Hygiene Lint ==\n'
printf 'Gallery root: %s\n' "$ROOT"

require_file "$ROOT/quickstarts.qmd" "gallery quickstarts source present"
require_file "$ROOT/code_catalog.qmd" "gallery code catalog source present"
require_file "$ROOT/np_npRmpi.qmd" "gallery np/npRmpi source present"
require_file "$ROOT/www/np_npRmpi/nprmpi_session_quickstart.R" "gallery npRmpi session quickstart source present"

forbid_regex_in_tree \
  '^```\\{r([[:space:]]*,|[[:space:]]*})' \
  "gallery source has no unnamed R chunks" \
  "$ROOT" \
  -g '*.qmd' \
  -g '!docs/**'

CURRENT_NPRMPI_SURFACES="
$ROOT/faq.qmd
$ROOT/mpi_large_data.qmd
$ROOT/np_npRmpi.qmd
$ROOT/function_index.qmd
$ROOT/code_catalog.qmd
$ROOT/quickstarts.qmd
$ROOT/www/np_npRmpi/nprmpi_session_quickstart.R
$ROOT/www/np_npRmpi/nprmpi_attach_quickstart.R
$ROOT/www/np_npRmpi/nprmpi_profile_quickstart.R
"

# shellcheck disable=SC2086
forbid_regex_in_tree \
  'on\\.exit\\(npRmpi\\.quit|npRmpi\\.init\\(mode *= *"spawn"|npRmpi\\.autodispatch|autodispatch *= *TRUE|np\\.messages *= *FALSE' \
  "current npRmpi gallery surfaces avoid stale session teaching patterns" \
  $CURRENT_NPRMPI_SURFACES

expect_fixed \
  "$ROOT/www/np_npRmpi/nprmpi_session_quickstart.R" \
  'npRmpi.init(nslaves = 1)' \
  "npRmpi session quickstart uses explicit session init"

expect_fixed \
  "$ROOT/www/np_npRmpi/nprmpi_session_quickstart.R" \
  'npRmpi.quit()' \
  "npRmpi session quickstart uses explicit quit at end"

if [ "$failures" -eq 0 ]; then
  printf 'PASS: gallery hygiene lint completed without findings\n'
else
  printf 'FAIL: gallery hygiene lint found %s issue(s)\n' "$failures" >&2
  exit 1
fi
