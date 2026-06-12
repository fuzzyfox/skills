#!/usr/bin/env bash
# mailbox.sh — the agent-mailbox engine.
#
# A pure-filesystem inter-agent mailbox. Source this file, then call the mb_*
# functions. No daemon, no network, no harness-specific transport. Portable to
# any *nix with coreutils; `flock` and `fswatch` are optional accelerants.
#
#   . mailbox.sh
#   mb_ensure_inbox
#   name="$(mb_register)"      # claim a friendly name
#   mb_send "$target_id" reply.md
#
# All protocol logic lives here so the procedure skills stay thin.

# --- root resolution ---------------------------------------------------------
# AGENT_MAILBOX_DIR always wins and is the explicit parent->child contract.
# Default is the simple, documented /tmp/agent-mailbox (single-user laptop).
mb_root() {
	printf '%s' "${AGENT_MAILBOX_DIR:-/tmp/agent-mailbox}"
}

# Warn (once per process) when the resolved root does not exist on disk. A missing
# root and an empty inbox are otherwise indistinguishable on the read path: both
# make mb_list return empty/exit-0, so a wrong AGENT_MAILBOX_DIR silently looks
# like "no mail". This is the single signal that turns that silent trap into a
# diagnosable one. Idempotent so callers in a loop don't spam stderr.
_mb_warn_if_missing_root() {
	local root; root="$(mb_root)"
	[ -d "$root" ] && return 0
	[ -n "${_MB_WARNED_MISSING_ROOT:-}" ] && return 0
	_MB_WARNED_MISSING_ROOT=1
	printf 'mailbox: resolved root %s does not exist — AGENT_MAILBOX_DIR may be wrong or unset; "no mail" here is unreliable.\n' "$root" >&2
}

# Absolute path of an agent's inbox directory tree root.
mb_dir() { # <id>
	printf '%s/%s' "$(mb_root)" "$1"
}

# --- identity ----------------------------------------------------------------
# The agent owns its identity. mb_resolve_self returns AGENT_MAILBOX_ID when set
# — the explicit, stable contract — and otherwise mints a one-shot uuid. The
# agent establishes its id once at setup (its harness session id if it can read
# one, else a minted uuid), then passes AGENT_MAILBOX_ID on every later call so
# the address stays stable. `mb_lookup <my-name>` recovers it without recall.
_mb_mint_id() {
	if command -v uuidgen >/dev/null 2>&1; then uuidgen | tr 'A-Z' 'a-z'
	elif [ -r /proc/sys/kernel/random/uuid ]; then cat /proc/sys/kernel/random/uuid
	else printf '%s-%s' "$$" "${RANDOM:-0}${RANDOM:-0}"; fi
}

mb_resolve_self() {
	if [ -n "${AGENT_MAILBOX_ID:-}" ]; then printf '%s' "$AGENT_MAILBOX_ID"; return; fi
	_mb_mint_id
}

# --- inbox layout (Maildir discipline) ---------------------------------------
# tmp/ = write-then-rename staging; inbox/ = unread; archive/ = consumed.
# 0700 so contents stay private inside sticky, world-writable /tmp.
mb_ensure_inbox() { # [id]  (defaults to self)
	local id="${1:-$(mb_resolve_self)}" d
	d="$(mb_dir "$id")"
	mkdir -p -m 700 "$d/tmp" "$d/inbox" "$d/archive"
}

# --- envelope / filename -----------------------------------------------------
# Filename: <YYYYMMDDThhmmssZ>-<8hex>-<subject-slug>.md
#   lexical sort == chronological; 8 hex make it unique under parallel writers;
#   the slug often answers triage without even reading the frontmatter.
_mb_slug() { # <text>
	printf '%s' "$1" | tr 'A-Z' 'a-z' | tr -c 'a-z0-9' '-' \
		| sed -E 's/-+/-/g; s/^-//; s/-$//'
}

# --- delivery (mb_send) ------------------------------------------------------
# Compose the envelope (from = self return address, fresh msg_id, subject), then
# deliver: write to <root>/<target>/tmp, then atomic mv into inbox/ — a triaging
# reader never head's a half-written file because mv within a filesystem is atomic.
#
#   mb_send <target-id> <body-file> [subject] [reply_to]   -> prints filename
mb_send() {
	local target="$1" body="$2" subject="${3:-message}" reply_to="${4:-}"
	local from msg_id ts hex8 slug name d tmpf
	from="$(mb_resolve_self)"
	msg_id="$(_mb_mint_id)"
	ts="$(date -u +%Y%m%dT%H%M%SZ)"
	hex8="$(printf '%s' "$msg_id" | tr -cd '0-9a-fA-F' | tr 'A-Z' 'a-z' | cut -c1-8)"
	slug="$(_mb_slug "$subject")"
	name="${ts}-${hex8}-${slug}.md"

	d="$(mb_dir "$target")"
	mkdir -p -m 700 "$d/tmp" "$d/inbox"
	tmpf="$d/tmp/$name"
	{
		printf -- '---\n'
		printf 'from: %s\n' "$from"
		printf 'msg_id: %s\n' "$msg_id"
		printf 'subject: %s\n' "$subject"
		[ -n "$reply_to" ] && printf 'reply_to: %s\n' "$reply_to"
		printf 'to: %s\n' "$target"
		printf -- '---\n\n'
		cat "$body"
	} >"$tmpf"
	mv -f "$tmpf" "$d/inbox/$name"
	printf '%s' "$name"
}

# --- read-state transitions --------------------------------------------------
# Read-state is location, not a flag: unread == in inbox/, consumed == in archive/.
mb_list() { # [id]  -> pending inbox paths, chronological (lexical == chrono)
	local id="${1:-$(mb_resolve_self)}" inbox
	_mb_warn_if_missing_root
	inbox="$(mb_dir "$id")/inbox"
	[ -d "$inbox" ] || return 0
	find "$inbox" -maxdepth 1 -type f -name '*.md' 2>/dev/null | sort
}

mb_archive() { # <inbox-path-or-name> [id]  -> mv inbox -> archive (idempotent)
	local arg="$1" id="${2:-$(mb_resolve_self)}" d base
	d="$(mb_dir "$id")"
	base="$(basename "$arg")"
	mkdir -p -m 700 "$d/archive"
	if [ -f "$d/inbox/$base" ]; then
		mv -f "$d/inbox/$base" "$d/archive/$base"
	fi
	# Already moved (or never existed in inbox): no-op, not an error.
	return 0
}

# --- wake leg (mb_wait) ------------------------------------------------------
# Block until mail arrives, bounded by a timeout. Uses fswatch when installed
# (wakes on the first inbox change), else a bounded sleep-poll. Returns 0 when
# mail is present, non-zero on timeout. The harness's own turn-blocking capability
# (e.g. Claude Code's Monitor) is a layer above this and lives in the skill prose.
# Set MB_NO_FSWATCH=1 to force the poll fallback; MB_POLL_INTERVAL tunes the poll.
_mb_has_mail() { [ -n "$(mb_list "$1")" ]; } # <id>

_mb_fswatch_once() { # <inbox-dir> <max-seconds>  — block until a change or timeout
	fswatch -1 "$1" >/dev/null 2>&1 &
	local fpid=$!
	( sleep "$2"; kill "$fpid" 2>/dev/null ) &
	local kpid=$!
	wait "$fpid" 2>/dev/null
	kill "$kpid" 2>/dev/null
	wait "$kpid" 2>/dev/null
	return 0
}

mb_wait() { # [timeout-seconds] [id]
	local timeout="${1:-540}" id="${2:-$(mb_resolve_self)}"
	local inbox interval elapsed step use_fswatch
	inbox="$(mb_dir "$id")/inbox"
	mkdir -p -m 700 "$inbox"
	_mb_has_mail "$id" && return 0

	interval="${MB_POLL_INTERVAL:-5}"
	[ -z "${MB_NO_FSWATCH:-}" ] && command -v fswatch >/dev/null 2>&1 && use_fswatch=1
	elapsed=0
	while [ "$elapsed" -lt "$timeout" ]; do
		step="$interval"
		[ $((timeout - elapsed)) -lt "$step" ] && step=$((timeout - elapsed))
		if [ -n "${use_fswatch:-}" ]; then _mb_fswatch_once "$inbox" "$step"; else sleep "$step"; fi
		_mb_has_mail "$id" && return 0
		elapsed=$((elapsed + step))
	done
	return 1
}

# --- registry & naming -------------------------------------------------------
# Single registry.json at the root, an object keyed by name:
#   { "bob": {"id":...,"harness":...,"inbox":...,"pid":...,"created":...}, ... }
# Agents touch it ONLY through these utilities — never by hand-editing — so a
# weaker model cannot corrupt it. The engine writes valid JSON with pure bash
# (no jq dependency); all values are constrained or escaped below.
_mb_registry() { printf '%s/registry.json' "$(mb_root)"; }

_mb_json_escape() { # minimal: backslash and double-quote
	printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

# Run a mutating block under an exclusive lock when flock is available; the lock
# is agent-transparent and silently skipped when flock is absent (low contention).
_mb_with_lock() { # <fn> [args...]
	local lock
	lock="$(mb_root)/.registry.lock"
	mkdir -p -m 700 "$(mb_root)" 2>/dev/null || true
	if [ -z "${MB_NO_FLOCK:-}" ] && command -v flock >/dev/null 2>&1; then
		( flock 9; "$@" ) 9>"$lock"
	else
		"$@"
	fi
}

# Print every "name<TAB>id<TAB>inbox" line by reading our own canonical layout
# (one entry per line: `  "name": {"id":"..","inbox":"..",...}` ).
_mb_entries() {
	local reg; reg="$(_mb_registry)"
	[ -f "$reg" ] || return 0
	# Parse line-oriented entries with sed; fields we wrote are unescaped-safe.
	sed -nE 's/^[[:space:]]*"(.*)": \{.*"id":"([^"]*)".*"inbox":"([^"]*)".*/\1\t\2\t\3/p' "$reg"
}

mb_names() { _mb_entries | cut -f1; }

mb_lookup() { # <name>  -> "<id>\t<inbox>"
	_mb_entries | awk -F'\t' -v n="$1" '$1==n {print $2"\t"$3; found=1} END{exit !found}'
}

mb_whois() { # <id>  -> friendly name
	_mb_entries | awk -F'\t' -v i="$1" '$2==i {print $1; found=1} END{exit !found}'
}

_mb_register_impl() { # <name> <id>
	local name="$1" id="$2" reg harness inbox created tmp
	reg="$(_mb_registry)"
	[ -f "$reg" ] || printf '{}\n' >"$reg"
	# Collision: name already a key.
	if mb_names | grep -Fxq "$name"; then
		printf 'collision'; return 0
	fi
	harness="${AGENT_HARNESS:-${CLAUDE_CODE:+claude}}"; harness="${harness:-unknown}"
	inbox="$(mb_dir "$id")/inbox"
	created="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
	# Rebuild the object: existing entry lines + the new one, comma-joined.
	tmp="$(mb_root)/.registry.tmp.$$"
	{
		printf '{\n'
		# Re-emit existing entries verbatim.
		local first=1 line
		while IFS= read -r line; do
			line="${line#"${line%%[![:space:]]*}"}" # trim leading whitespace
			line="${line%,}"                        # drop any trailing comma
			[ "$first" = 1 ] && first=0 || printf ',\n'
			printf '  %s' "$line"
		done < <(grep -E '^[[:space:]]*".*": \{' "$reg")
		[ "$first" = 1 ] || printf ',\n'
		printf '  "%s": {"id":"%s","harness":"%s","inbox":"%s","pid":%s,"created":"%s"}\n' \
			"$(_mb_json_escape "$name")" "$(_mb_json_escape "$id")" \
			"$(_mb_json_escape "$harness")" "$(_mb_json_escape "$inbox")" \
			"$$" "$created"
		printf '}\n'
	} >"$tmp"
	mv -f "$tmp" "$reg"
	printf '%s' "$name"
}

# Claim a non-colliding friendly name; prints the name, or 'collision'.
# The agent generates the name (a common given name in the operator's current
# conversation language) and retries on collision with a different one.
#
# Names self by default. Pass an explicit <id> to name *another* agent you just
# created — a parent naming the child whose inbox it provisioned — so a freshly
# spawned inbox is never nameless: its registry entry exists the instant the inbox
# does, before the child even boots. (The stamped pid is the registrant's, a
# passive hint either way — see takeover's caveats.)
mb_register() { # [name] [id]
	local name="${1:-}" id="${2:-$(mb_resolve_self)}"
	[ -n "$name" ] || name="agent-$(_mb_mint_id | tr -cd '0-9a-f' | cut -c1-4)"
	_mb_with_lock _mb_register_impl "$name" "$id"
}
