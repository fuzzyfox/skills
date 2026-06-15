#!/usr/bin/env bash
# tests.sh — behavioral tests for mailbox.sh, sourced by run.sh.
#
# Each test_* function runs in an isolated subshell with the engine sourced and
# AGENT_MAILBOX_DIR pointed at a throwaway root. Assert through the public mb_*
# interface and observable filesystem state — never internal implementation.

# --- root resolution ---------------------------------------------------------

test_root_default() {
	unset AGENT_MAILBOX_DIR
	assert_eq "$(mb_root)" "/tmp/agent-mailbox" "default root is /tmp/agent-mailbox"
}

test_root_override() {
	assert_eq "$(mb_root)" "$AGENT_MAILBOX_DIR" "AGENT_MAILBOX_DIR overrides default"
}

# --- identity ----------------------------------------------------------------

test_resolve_self_env_wins() {
	export AGENT_MAILBOX_ID="bob-123"
	assert_eq "$(mb_resolve_self)" "bob-123" "AGENT_MAILBOX_ID is the return address"
}

test_resolve_self_mints_when_no_env() {
	unset AGENT_MAILBOX_ID
	# The agent owns its id: with no env contract, the engine mints a one-shot
	# uuid for the agent to capture and carry. (Not persisted by the engine.)
	assert_match "$(mb_resolve_self)" '^[0-9a-f-]{8,}$' "mints a uuid-shaped id without env"
}

test_resolve_self_stable_with_env() {
	export AGENT_MAILBOX_ID="zed"
	assert_eq "$(mb_resolve_self)" "zed" "AGENT_MAILBOX_ID is the stable address"
	assert_eq "$(mb_resolve_self)" "zed" "and is identical on every call"
}

# --- inbox layout ------------------------------------------------------------

test_ensure_inbox_creates_maildir() {
	export AGENT_MAILBOX_ID="alice"
	mb_ensure_inbox
	local d="$(mb_root)/alice"
	assert_file_dir "$d/tmp" "tmp/ staging dir exists"
	assert_file_dir "$d/inbox" "inbox/ exists"
	assert_file_dir "$d/archive" "archive/ exists"
}

# --- delivery (mb_send) ------------------------------------------------------

_mk_body() { # writes a tiny handoff body, prints its path
	local f="$(mb_root)/body.md"
	mkdir -p "$(mb_root)"
	printf '# Findings\n\nThe auth flow is sound.\n' >"$f"
	printf '%s' "$f"
}

test_send_is_atomic() {
	export AGENT_MAILBOX_ID="bob"
	local body="$(_mk_body)"
	mb_send "alice" "$body" "auth flow findings" >/dev/null
	assert_nfiles "$(mb_dir alice)/inbox" 1 "exactly one message delivered to inbox"
	assert_nfiles "$(mb_dir alice)/tmp" 0 "tmp/ staging is empty after delivery"
}

test_send_reads_body_from_stdin() {
	export AGENT_MAILBOX_ID="bob"
	local name body
	name="$(mb_send alice - "streamed findings" <<'__MB__'
# Findings

The `auth` flow is sound. No $vars expand.
__MB__
)"
	assert_nfiles "$(mb_dir alice)/inbox" 1 "stdin body delivered as one message"
	assert_nfiles "$(mb_dir alice)/tmp" 0 "tmp/ staging empty after stdin delivery"
	body="$(cat "$(mb_dir alice)/inbox/$name")"
	assert_match "$body" 'The `auth` flow is sound\. No \$vars expand\.' \
		"stdin body lands verbatim (backticks and \$ preserved)"
}

test_send_filename_is_chronological_and_slugged() {
	export AGENT_MAILBOX_ID="bob"
	local body="$(_mk_body)" name
	name="$(mb_send alice "$body" "auth flow findings")"
	assert_match "$name" '^[0-9]{8}T[0-9]{6}Z-[0-9a-f]{8}-auth-flow-findings\.md$' \
		"filename = <UTC ts>-<8hex>-<slug>.md"
}

test_send_stamps_return_address_in_frontmatter() {
	export AGENT_MAILBOX_ID="bob"
	local body="$(_mk_body)" name fm
	name="$(mb_send alice "$body" "auth flow findings")"
	# Triage by reading only the frontmatter (head), never the body.
	fm="$(head -8 "$(mb_dir alice)/inbox/$name")"
	assert_match "$fm" 'from: bob' "from = sender id (the return address)"
	assert_match "$fm" 'subject: auth flow findings' "subject enables body-free triage"
	assert_match "$fm" 'msg_id: .+' "msg_id present for dedup/threading"
}

# --- read-state transitions (mb_list / mb_archive) ---------------------------

test_list_and_archive_move_read_state() {
	export AGENT_MAILBOX_ID="alice"
	mb_ensure_inbox
	# bob sends to alice
	( export AGENT_MAILBOX_ID="bob"; mb_send alice "$(_mk_body)" "hello" >/dev/null )
	local listed
	listed="$(mb_list | wc -l | tr -d ' ')"
	assert_eq "$listed" "1" "mb_list shows one pending message"
	local f="$(mb_list)"
	mb_archive "$f"
	assert_nfiles "$(mb_dir alice)/inbox" 0 "inbox empty after archive"
	assert_nfiles "$(mb_dir alice)/archive" 1 "message moved into archive/"
}

test_wait_returns_when_mail_present() {
	export AGENT_MAILBOX_ID="alice"; export MB_NO_FSWATCH=1
	mb_ensure_inbox
	( export AGENT_MAILBOX_ID="bob"; mb_send alice "$(_mk_body)" "ping" >/dev/null )
	if mb_wait 2; then assert_eq ok ok "mb_wait returns 0 immediately when inbox already has mail"
	else assert_eq err ok "mb_wait must return on existing mail"; fi
}

test_wait_times_out_when_empty() {
	export AGENT_MAILBOX_ID="alice"; export MB_NO_FSWATCH=1; export MB_POLL_INTERVAL=1
	mb_ensure_inbox
	if mb_wait 1; then assert_eq err ok "mb_wait must time out on an empty inbox"
	else assert_eq ok ok "mb_wait returns non-zero on timeout"; fi
}

test_wait_wakes_on_arrival() {
	export AGENT_MAILBOX_ID="alice"; export MB_NO_FSWATCH=1; export MB_POLL_INTERVAL=1
	mb_ensure_inbox
	( sleep 1; export AGENT_MAILBOX_ID="bob"; mb_send alice "$(_mk_body)" "ping" >/dev/null ) &
	if mb_wait 6; then assert_eq ok ok "mb_wait wakes (sleep-poll fallback) when mail arrives mid-wait"
	else assert_eq err ok "mb_wait must wake on arrival"; fi
	wait
}

test_archive_is_idempotent() {
	export AGENT_MAILBOX_ID="alice"
	mb_ensure_inbox
	( export AGENT_MAILBOX_ID="bob"; mb_send alice "$(_mk_body)" "hi" >/dev/null )
	local f="$(mb_list)"
	mb_archive "$f"
	if mb_archive "$f"; then assert_eq "ok" "ok" "re-archiving a moved file is a no-op"
	else assert_eq "err" "ok" "re-archiving must not error"; fi
}

# --- registry & naming -------------------------------------------------------

_valid_json() { jq -e . "$1" >/dev/null 2>&1; }

test_register_claims_name() {
	export AGENT_MAILBOX_ID="id-bob"
	assert_eq "$(mb_register bob)" "bob" "mb_register returns the claimed name"
	assert_file "$(mb_root)/registry.json" "registry.json is created"
	if _valid_json "$(mb_root)/registry.json"; then assert_eq ok ok "registry is valid JSON"
	else assert_eq err ok "registry must be valid JSON"; fi
}

test_register_collision_is_rejected() {
	( export AGENT_MAILBOX_ID="id-bob"; mb_register bob >/dev/null )
	local second
	second="$( export AGENT_MAILBOX_ID="id-other"; mb_register bob )"
	assert_eq "$second" "collision" "second claim of a taken name returns collision"
	# bob recorded exactly once
	local n
	n="$(jq -r 'keys | map(select(. == "bob")) | length' "$(mb_root)/registry.json")"
	assert_eq "$n" "1" "taken name appears exactly once"
}

test_register_distinct_names_coexist() {
	( export AGENT_MAILBOX_ID="id-bob"; mb_register bob >/dev/null )
	( export AGENT_MAILBOX_ID="id-alice"; mb_register alice >/dev/null )
	local names
	names="$(mb_names | sort | tr '\n' ' ')"
	assert_eq "$names" "alice bob " "mb_names lists every registered name"
	if _valid_json "$(mb_root)/registry.json"; then assert_eq ok ok "registry valid after multiple writes"
	else assert_eq err ok "registry must stay valid JSON"; fi
}

test_lookup_resolves_name_to_id() {
	( export AGENT_MAILBOX_ID="id-bob"; mb_ensure_inbox; mb_register bob >/dev/null )
	local id
	id="$(mb_lookup bob | cut -f1)"
	assert_eq "$id" "id-bob" "mb_lookup name -> wire id"
}

test_whois_reverses_id_to_name() {
	( export AGENT_MAILBOX_ID="id-bob"; mb_register bob >/dev/null )
	assert_eq "$(mb_whois id-bob)" "bob" "mb_whois id -> friendly name"
}

test_register_concurrent_stays_valid_json() {
	# flock path: fire several registrations in parallel; all must land and the
	# registry must remain valid JSON (no interleaved half-writes).
	local i
	for i in 1 2 3 4 5; do
		( export AGENT_MAILBOX_ID="id-$i"; mb_register "name$i" >/dev/null ) &
	done
	wait
	if _valid_json "$(mb_root)/registry.json"; then assert_eq ok ok "registry valid JSON after concurrent writes"
	else assert_eq err ok "registry must stay valid JSON under contention"; fi
	assert_eq "$(mb_names | wc -l | tr -d ' ')" "5" "all concurrent names recorded"
}

test_register_no_flock_fallback() {
	export MB_NO_FLOCK=1
	( export AGENT_MAILBOX_ID="id-bob"; mb_register bob >/dev/null )
	( export AGENT_MAILBOX_ID="id-alice"; mb_register alice >/dev/null )
	if _valid_json "$(mb_root)/registry.json"; then assert_eq ok ok "no-flock fallback writes valid JSON"
	else assert_eq err ok "no-flock fallback must write valid JSON"; fi
	assert_eq "$(mb_names | sort | tr '\n' ' ')" "alice bob " "fallback records all names"
}

test_register_names_explicit_child_id() {
	# A parent provisions a child inbox and registers the child's name against the
	# child's id — not its own — so the inbox is named the instant it exists.
	export AGENT_MAILBOX_ID="id-parent"
	mb_ensure_inbox "id-child"
	assert_eq "$(mb_register alice id-child)" "alice" "mb_register claims a name for an explicit child id"
	assert_eq "$(mb_lookup alice | cut -f1)" "id-child" "the name resolves to the child id, not the registrant"
	assert_eq "$(mb_whois id-child)" "alice" "the child can recover its assigned name via mb_whois (adoption)"
	assert_eq "$(mb_whois id-parent)" "" "the registrant's own id is left unnamed"
}

# --- missing-root warning (the silent 'no mail' trap) ------------------------

test_list_warns_when_root_missing() {
	# A wrong/unset AGENT_MAILBOX_DIR and a genuinely empty inbox both make mb_list
	# return empty; the warning is the one signal that distinguishes them.
	export AGENT_MAILBOX_ID="alice"   # note: no mb_ensure_inbox, so the root is absent
	local err; err="$(mb_list 2>&1 >/dev/null)"
	assert_match "$err" "does not exist" "mb_list warns on stderr when the resolved root is missing"
}

test_list_silent_when_root_exists() {
	export AGENT_MAILBOX_ID="alice"
	mb_ensure_inbox                   # creates the root + maildir
	local err; err="$(mb_list 2>&1 >/dev/null)"
	assert_eq "$err" "" "mb_list stays silent when the root exists (no false warning)"
}

test_list_warns_once_per_process() {
	# The guard is per-process; call twice in the SAME shell (no command-subst around
	# the call, which would fork and lose the flag) and capture stderr to files.
	export AGENT_MAILBOX_ID="alice"   # root absent
	local e1 e2; e1="$(mktemp)"; e2="$(mktemp)"
	mb_list 2>"$e1" >/dev/null
	mb_list 2>"$e2" >/dev/null
	assert_match "$(cat "$e1")" "does not exist" "first mb_list warns about the missing root"
	assert_eq "$(cat "$e2")" "" "second mb_list stays silent (warn-once-per-process)"
	rm -f "$e1" "$e2"
}
