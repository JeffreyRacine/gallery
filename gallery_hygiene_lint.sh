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

forbid_multiline_regex_in_tree() {
  pattern=$1
  label=$2
  shift 2

  if rg -U -n -e "$pattern" "$@" >/dev/null 2>&1; then
    fail "$label"
    rg -U -n -e "$pattern" "$@" >&2 || true
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

expect_fixed \
  "$ROOT/index.qmd" \
  '`npRmpi`' \
  "gallery overview names npRmpi"

expect_fixed \
  "$ROOT/index.qmd" \
  '`0.70-5` are release candidates' \
  "gallery overview identifies 0.70-5 as release candidates"

forbid_multiline_regex_in_tree \
  '(?s)(`npRmpi`|`np`)[[:space:]]+`0\.70-5`.{0,160}available on CRAN' \
  "gallery sources do not claim pre-release 0.70-5 is available on CRAN" \
  "$ROOT" \
  -g '*.qmd' \
  -g '!docs/**'

CURRENT_REGRESSION_SCRIPTS="
$ROOT/www/Regression/regression_intro_a.R
$ROOT/www/Regression/regression_intro_b.R
$ROOT/www/Regression/regression_intro_c.R
$ROOT/www/Regression/regression_multivar_a.R
"

# shellcheck disable=SC2086
forbid_regex_in_tree \
  'attach[[:space:]]*\(' \
  "featured regression scripts use explicit data arguments" \
  $CURRENT_REGRESSION_SCRIPTS

expect_fixed \
  "$ROOT/mpi_large_data.qmd" \
  'R CMD INSTALL npRmpi_0.70-5.tar.gz' \
  "npRmpi source-install example uses the current release tarball"

expect_fixed \
  "$ROOT/www/np_npRmpi/np_copula_quickstart.R" \
  'summary(copula_fit$bws)' \
  "copula quickstart uses the public bandwidth component"

forbid_regex_in_tree \
  "attr\\([^)]*,[[:space:]]*['\"]bws['\"]\\)" \
  "gallery sources avoid retired attribute-based bandwidth storage" \
  "$ROOT" \
  -g '*.qmd' \
  -g '*.R' \
  -g '!docs/**'

if [ "$failures" -eq 0 ]; then
  printf 'PASS: gallery hygiene lint completed without findings\n'
else
  printf 'FAIL: gallery hygiene lint found %s issue(s)\n' "$failures" >&2
  exit 1
fi
