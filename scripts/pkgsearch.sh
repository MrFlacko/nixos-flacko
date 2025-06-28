#!/usr/bin/env bash
# pkgsearch – nix-search wrapper
#   default : show packages whose *title* contains WORD (substring, case-insensitive)
#   -m      : also keep packages whose DESCRIPTION contains WORD
#   -m      : OR dump raw nix-search list if you prefer (see RAW=1 branch)

# ── flags ─────────────────────────────────────────────
if [[ $1 =~ ^(-m|--more)$ ]]; then FILTER_DESC=1; shift; else FILTER_DESC=0; fi
[[ -z $1 ]] && { echo "usage: $0 [-m] <word>" >&2; exit 1; }
WORD_LC=$(tr '[:upper:]' '[:lower:]' <<<"$1")

# ── nix search once ──────────────────────────────────
RAW=$(nix search nixpkgs "$1")
TOTAL=$(grep -c '^\* ' <<<"$RAW")

# ── raw mode (if you want it) ────────────────────────
if (( FILTER_DESC == 2 )); then     # set RAW=2 manually if ever needed
  printf '%s\n' "$RAW"
  printf '★ Showing all %d packages (unfiltered)\n' "$TOTAL" >&2
  exit
fi

# ── filter & pretty-print ────────────────────────────
TABLE=$(
printf '%s\n' "$RAW" | awk -v term="$WORD_LC" -v inc_desc="$FILTER_DESC" '
  BEGIN {
    wn = 48                                        # width for “name (ver)”
    dash = "------------------------------------------------------------"
    printf "%-*s  %s\n", wn, "PACKAGE (VERSION)", "DESCRIPTION"
    printf "%-*.*s  %s\n", wn, wn, dash, "-----------"
  }
  /^\*/ {
    sub(/^\* /,"")                                 # strip "* "
    split($0, p, " ")
    attr_full = p[1]
    version    = p[2]
    getline desc                                   # description line
    attr_lc = tolower(attr_full)
    desc_lc = tolower(desc)
    keep = (index(attr_lc, term) > 0)              # title match?
    if (!keep && inc_desc) keep = (index(desc_lc, term) > 0)

    if (keep && !seen[attr_full,version]++) {
      nice_attr = attr_full
      sub(/.*\./,"",nice_attr)                     # drop leading path
      gsub(/^[()]|[()]$/,"",version)
      printf "%-*s  %s\n", wn, nice_attr" ("version")", desc
      shown++
    }
  }
  END { print "###COUNT###", shown }
')

SHOWN=$(grep '^###COUNT###' <<<"$TABLE" | awk '{print $2}')
TABLE=${TABLE//$'\n###COUNT###'*}

printf '%s\n' "$TABLE"
printf '★ Showing %d / %d packages  (use -m for desc match / raw)\n' "$SHOWN" "$TOTAL" >&2
