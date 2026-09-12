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
  '`0.80-1` are available on CRAN' \
  "gallery overview identifies 0.80-1 as the current np release"

expect_fixed \
  "$ROOT/index.qmd" \
  'September 11, 2026' \
  "gallery overview records the 0.80-1 package date"

expect_fixed \
  "$ROOT/index.qmd" \
  '`crs` `0.15-46`' \
  "gallery overview identifies 0.15-46 as the current crs release"

forbid_regex_in_tree \
  'release[- ]candidate|public CRAN releases remain `0\.70-[45]`' \
  "gallery sources contain no stale pre-release status" \
  "$ROOT" \
  -g '*.qmd' \
  -g '!docs/**'

CURRENT_GUIDANCE_SURFACES="
$ROOT/index.qmd
$ROOT/primer.qmd
$ROOT/plotting_and_intervals.qmd
$ROOT/semiparametric_models.qmd
$ROOT/runtime_and_scaling.qmd
$ROOT/npksum_custom.qmd
"

# Exact older versions remain valid in migration and reproducibility records.
# shellcheck disable=SC2086
forbid_regex_in_tree \
  '0\.70-[1-5]|0\.15-45' \
  "current guidance avoids superseded release-history framing" \
  $CURRENT_GUIDANCE_SURFACES

forbid_regex_in_tree \
  'boot\.num[[:space:]]*=' \
  "current gallery examples avoid the retired boot.num argument" \
  "$ROOT" \
  -g '*.qmd' \
  -g '*.R' \
  -g '!faq.qmd' \
  -g '!docs/**'

forbid_regex_in_tree \
  'errors[[:space:]]*=[[:space:]]*(TRUE|FALSE)' \
  "current gallery examples avoid retired Boolean estimator errors" \
  "$ROOT" \
  -g '*.qmd' \
  -g '*.R' \
  -g '!docs/**'

forbid_regex_in_tree \
  'gradient_order[[:space:]]*=' \
  "current gallery pages avoid the retired gradient_order argument" \
  "$ROOT" \
  -g '*.qmd' \
  -g '!docs/**'

RETIRED_NP_PLOT_ARGUMENTS='(data_rug|data_overlay|factor_boxplot|boxplot_outliers|coef_index|common_scale|proper_method|proper_control|boot_control|grid_control|render_control|bar_num|y_vars|y_dat|pair_list)[[:space:]]*='

forbid_regex_in_tree \
  "$RETIRED_NP_PLOT_ARGUMENTS" \
  "current np/npRmpi pages avoid retired underscore plot arguments" \
  "$ROOT" \
  -g '*.qmd' \
  -g '!crs.qmd' \
  -g '!docs/**'

forbid_regex_in_tree \
  "$RETIRED_NP_PLOT_ARGUMENTS" \
  "current np/npRmpi scripts avoid retired underscore plot arguments" \
  "$ROOT/www/np_npRmpi" \
  "$ROOT/www/Regression"

expect_fixed \
  "$ROOT/faq.qmd" \
  '`se = TRUE, se.type = "asymptotic"`' \
  "0.80-1 migration guidance records the npindex uncertainty exception"

forbid_regex_in_tree \
  'nptgauss[[:space:]]*\(' \
  "current gallery examples avoid the retired nptgauss interface" \
  "$ROOT" \
  -g '*.qmd' \
  -g '*.R' \
  -g '!faq.qmd' \
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
  'R CMD INSTALL npRmpi_0.80-1.tar.gz' \
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
