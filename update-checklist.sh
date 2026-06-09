#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  🚀 Comms Checklist — One-Click GitHub Pages Updater
#  Double-click this file in Finder, or run: bash update-checklist.sh
# ─────────────────────────────────────────────────────────────

set -e  # Stop on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/AdHoc_Comms_Checklist.html"
DEST="$SCRIPT_DIR/index.html"
TIMESTAMP=$(date "+%d %b %Y at %H:%M")

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   📧 Comms Checklist — GitHub Pages Updater      ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# ── 1. Check source file exists ───────────────────────────────
if [ ! -f "$SOURCE" ]; then
  echo "❌  Error: AdHoc_Comms_Checklist.html not found."
  echo "    Expected at: $SOURCE"
  echo ""
  read -p "Press Enter to close..."
  exit 1
fi

# ── 2. Copy → index.html ──────────────────────────────────────
echo "📄  Copying checklist → index.html..."
cp "$SOURCE" "$DEST"
echo "    ✓ Done"

# Also stage the PWA support files if present
for f in manifest.json sw.js; do
  if [ -f "$SCRIPT_DIR/$f" ]; then
    echo "    ✓ Staging $f"
  fi
done
echo ""

# ── 3. Check we're inside a git repo ──────────────────────────
cd "$SCRIPT_DIR"
if [ ! -d ".git" ]; then
  echo "❌  Error: No git repo found in:"
  echo "    $SCRIPT_DIR"
  echo ""
  echo "    Run the setup steps first (see the guide from Enchanté)."
  echo ""
  read -p "Press Enter to close..."
  exit 1
fi

# ── 4. Stage & commit ─────────────────────────────────────────
echo "📦  Staging changes..."
git add index.html manifest.json sw.js 2>/dev/null || git add index.html

# Only commit if there's something new
if git diff --cached --quiet; then
  echo "    ℹ️  No changes detected — index.html is already up to date."
else
  git commit -m "Update checklist — $TIMESTAMP"
  echo "    ✓ Committed: \"Update checklist — $TIMESTAMP\""
fi
echo ""

# ── 5. Push to GitHub ─────────────────────────────────────────
echo "☁️   Pushing to GitHub..."
git push origin main
echo "    ✓ Pushed successfully"
echo ""

# ── 6. Print the live URL ─────────────────────────────────────
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [ -n "$REMOTE_URL" ]; then
  # Extract owner/repo from HTTPS or SSH remote URL
  REPO_PATH=$(echo "$REMOTE_URL" \
    | sed 's|https://github.com/||' \
    | sed 's|git@github.com:||' \
    | sed 's|\.git$||')
  OWNER=$(echo "$REPO_PATH" | cut -d'/' -f1)
  REPO=$(echo "$REPO_PATH" | cut -d'/' -f2)
  LIVE_URL="https://${OWNER}.github.io/${REPO}"
  echo "╔══════════════════════════════════════════════════╗"
  echo "║  🌐 Live at:                                     ║"
  echo "║  $LIVE_URL"
  echo "╚══════════════════════════════════════════════════╝"
  echo ""
  # Open the URL in the browser
  echo "🔗  Opening in browser..."
  open "$LIVE_URL"
fi

echo ""
echo "✅  All done! Your team's link is up to date."
echo ""
read -p "Press Enter to close..."
