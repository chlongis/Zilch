#!/usr/bin/env bash
# Zilch — point this fork at your own Supabase project.
#
#   ./setup.sh https://yourproject.supabase.co your-anon-key
#
# Rewrites the Supabase URL and anon key across every page.
# The anon key is public by design and safe in client code — row level
# security is what protects the data. Never put a service_role key here.

set -euo pipefail

if [ $# -ne 2 ]; then
  echo "usage: ./setup.sh <supabase-url> <anon-key>"
  echo "example: ./setup.sh https://abcd1234.supabase.co eyJhbGciOi..."
  exit 1
fi

NEW_URL="${1%/}"
NEW_KEY="$2"

if [[ ! "$NEW_URL" =~ ^https://.*\.supabase\.co$ ]]; then
  echo "error: URL should look like https://yourproject.supabase.co"
  exit 1
fi

if [[ "$NEW_KEY" != eyJ* ]]; then
  echo "error: that doesn't look like a Supabase anon key (should start with eyJ)"
  exit 1
fi

if [[ "$NEW_KEY" == *"service_role"* ]]; then
  echo "error: that looks like a service_role key. Use the anon key instead."
  exit 1
fi

OLD_URL="https://zlvvtaydmaphdnhvmppj.supabase.co"
OLD_KEY_PREFIX="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"

# BSD sed (macOS) and GNU sed disagree about -i
if sed --version >/dev/null 2>&1; then
  SED_INPLACE=(-i)
else
  SED_INPLACE=(-i '')
fi

COUNT=0
for f in *.html; do
  [ -e "$f" ] || continue
  if grep -q "createClient" "$f"; then
    sed "${SED_INPLACE[@]}" \
      -e "s|${OLD_URL}|${NEW_URL}|g" \
      -e "s|\"${OLD_KEY_PREFIX}[A-Za-z0-9._-]*\"|\"${NEW_KEY}\"|g" \
      "$f"
    echo "  updated $f"
    COUNT=$((COUNT + 1))
  fi
done

echo ""
echo "Done — $COUNT files now point at $NEW_URL"
echo ""
echo "Next:"
echo "  1. Paste schema.sql into the Supabase SQL Editor and run it"
echo "  2. Create storage buckets 'proof' and 'insurance' (private, 5 MB)"
echo "  3. Edit the AREAS list in pledge.html, claim.html and find.html"
echo "     to match your own city"
echo "  4. Commit, push, enable GitHub Pages on main / root"
