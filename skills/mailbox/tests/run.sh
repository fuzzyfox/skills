#!/usr/bin/env bash
# run.sh — plain-bash test runner for mailbox.sh.
#
# Zero dependencies beyond a POSIX-ish shell + coreutils. Runs on any *nix.
# Each test runs in a subshell against a throwaway mailbox root, so nothing
# touches real /tmp state and a test's env changes never leak.
#
#   ./run.sh            # run all tests
#
# Exit status is non-zero if any assertion fails.
set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE="$HERE/../scripts/mailbox.sh"

# --- assertion helpers (run inside the per-test subshell) --------------------
# Each prints one TAP-ish line to stdout; the driver tallies "not ok" lines.

assert_eq() { # <actual> <expected> <msg>
	if [ "$1" = "$2" ]; then printf 'ok - %s\n' "$3"
	else printf 'not ok - %s: expected [%s] got [%s]\n' "$3" "$2" "$1"; fi
}

assert_match() { # <actual> <regex> <msg>
	if printf '%s' "$1" | grep -Eq "$2"; then printf 'ok - %s\n' "$3"
	else printf 'not ok - %s: [%s] !~ /%s/\n' "$3" "$1" "$2"; fi
}

assert_file() { # <path> <msg>
	if [ -f "$1" ]; then printf 'ok - %s\n' "$2"
	else printf 'not ok - %s: no file at %s\n' "$2" "$1"; fi
}

assert_file_dir() { # <path> <msg>
	if [ -d "$1" ]; then printf 'ok - %s\n' "$2"
	else printf 'not ok - %s: no dir at %s\n' "$2" "$1"; fi
}

assert_nfiles() { # <dir> <n> <msg>
	local n
	n="$(find "$1" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')"
	if [ "$n" = "$2" ]; then printf 'ok - %s\n' "$3"
	else printf 'not ok - %s: expected %s files in %s, found %s\n' "$3" "$2" "$1" "$n"; fi
}

# --- driver ------------------------------------------------------------------

PASS=0
FAIL=0

run_test() { # <fn-name>
	local root out rc
	root="$(mktemp -d "${TMPDIR:-/tmp}/mbtest.XXXXXX")"
	out="$(
		export AGENT_MAILBOX_DIR="$root/agent-mailbox"
		# shellcheck disable=SC1090
		. "$ENGINE" 2>&1 || { echo "not ok - could not source engine"; exit 1; }
		"$1" 2>&1
	)"
	rm -rf "$root"
	printf '• %s\n' "$1"
	while IFS= read -r line; do
		[ -z "$line" ] && continue
		printf '  %s\n' "$line"
		case "$line" in
		"not ok"*) FAIL=$((FAIL + 1)) ;;
		"ok "*) PASS=$((PASS + 1)) ;;
		esac
	done <<EOF
$out
EOF
}

TESTS="$(grep -oE '^test_[a-zA-Z0-9_]+' "$HERE/tests.sh" | sort -u)"
# shellcheck disable=SC1090
. "$ENGINE" 2>/dev/null   # make functions visible to editors; re-sourced per test
# shellcheck disable=SC1091
. "$HERE/tests.sh"

for t in $TESTS; do
	run_test "$t"
done

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
