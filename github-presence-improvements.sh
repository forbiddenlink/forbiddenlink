#!/usr/bin/env bash
set -euo pipefail
ORG="forbiddenlink"
ERRORS=0

ok()  { echo "  ✓ $1"; }
err() { echo "  ✗ $1"; ERRORS=$((ERRORS+1)); }
run() {
  local label="$1"; shift
  if "$@" 2>/dev/null; then ok "$label"; else err "$label"; fi
}

# ============================================================
echo "=== 1/5  TOPICS ==="
# ============================================================

add_topics() {
  local repo=$1; shift
  local args=(); for t in "$@"; do args+=(--add-topic "$t"); done
  run "$repo" gh repo edit "$ORG/$repo" "${args[@]}"
}

add_topics hire-ready         nextjs job-search career ai saas
add_topics explainthiscode    ai code-explanation developer-tools nextjs saas
add_topics myaqualog          aquarium fish-keeping saas nextjs pet-care
add_topics dwello             real-estate home-management saas nextjs
add_topics testimoniq         testimonials social-proof saas nextjs
add_topics portfolio-pro      portfolio nextjs developer-tools saas
add_topics ucp-monitor        healthcare ucp patient-monitoring nextjs saas
add_topics kindred            relationships crm personal nextjs saas
add_topics runwayos           startup finance runway mrr saas nextjs
add_topics will-wise          estate-planning legal saas nextjs
add_topics automadocs         documentation automation ai nextjs saas
add_topics mistria-companion  gaming stardew-valley companion-app
add_topics finance-quest      personal-finance gamification nextjs saas
add_topics canvas-flow        design canvas tools nextjs
add_topics interview-ace      interview-prep career ai nextjs saas
add_topics tube-digest        youtube video ai summarization
add_topics storyvision        storytelling ai creative nextjs
add_topics stashcraft         productivity bookmarks saas nextjs
add_topics reprise            music audio tools nextjs

# ============================================================
echo ""
echo "=== 2/5  HOMEPAGE URLS ==="
# ============================================================

set_homepage() {
  local repo=$1 url=$2
  run "$repo → $url" gh repo edit "$ORG/$repo" --homepage "$url"
}

set_homepage hire-ready         "https://imhireready.com"
set_homepage explainthiscode    "https://explainthiscode.ai"
set_homepage myaqualog          "https://myaqualog.com"
set_homepage testimoniq         "https://testimoniq.io"
set_homepage portfolio-pro      "https://www.portfoliopro.dev"
set_homepage ucp-monitor        "https://ucpguard.com"
set_homepage runwayos           "https://runwayos-phi.vercel.app"
set_homepage will-wise          "https://willwise-app.vercel.app"
set_homepage automadocs         "https://automadocs.com"
set_homepage mistria-companion  "https://mistriacompanion.com"
set_homepage finance-quest      "https://financequest.fyi"
set_homepage elizabethannstein  "https://elizabethannstein.com"

# Dwello: read from package.json
echo -n "  dwello (checking package.json)... "
DWELLO_HOME=$(gh api "repos/$ORG/dwello/contents/package.json" --jq '.content' 2>/dev/null \
  | base64 --decode 2>/dev/null \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('homepage','').strip())" 2>/dev/null || echo "")
if [[ -n "$DWELLO_HOME" && "$DWELLO_HOME" != "None" ]]; then
  run "dwello → $DWELLO_HOME" gh repo edit "$ORG/dwello" --homepage "$DWELLO_HOME"
else
  echo "no homepage in package.json — skipped"
fi

# ============================================================
echo ""
echo "=== 3/5  DESCRIPTIONS ==="
# ============================================================

set_desc() {
  local repo=$1 desc=$2
  run "$repo" gh repo edit "$ORG/$repo" --description "$desc"
}

set_desc hire-ready         "AI-powered job search assistant to help developers land their next role faster"
set_desc explainthiscode    "AI tool that explains any code snippet in plain English — powered by LLMs"
set_desc myaqualog          "Track and manage your aquarium parameters, livestock, and maintenance logs"
set_desc dwello             "Smart home management platform for tracking tasks, maintenance, and costs"
set_desc testimoniq         "Beautiful testimonial collection and display widgets for SaaS products"
set_desc portfolio-pro      "Showcase your developer portfolio with a sleek, customizable Next.js site"
set_desc ucp-monitor        "Patient monitoring dashboard for urea cycle disorders (UCP) — UCPGuard"
set_desc kindred             "Personal CRM for nurturing relationships that matter"
set_desc runwayos           "Track your startup runway, MRR, and burn rate in one dashboard"
set_desc will-wise          "Guided estate planning and will creation made simple"
set_desc automadocs         "AI-powered documentation generator — write code, get docs automatically"
set_desc mistria-companion  "Companion app for Fields of Mistria with guides, crop calendars, and more"
set_desc finance-quest      "Gamified personal finance tracker to make saving and budgeting fun"
set_desc canvas-flow        "Design tool for creating and organizing visual content on an infinite canvas"
set_desc interview-ace      "AI-powered interview prep with practice questions, mock interviews, and feedback"
set_desc tube-digest        "Summarize YouTube videos instantly with AI — skip the filler, get the insights"
set_desc storyvision        "AI-assisted storytelling platform for writers and creative teams"
set_desc stashcraft         "Bookmark manager with tagging, search, and team sharing"
set_desc reprise            "Music tools for musicians — loop, practice, and annotate audio tracks"

# ============================================================
echo ""
echo "=== 4/5  ORG PROFILE README ==="
# ============================================================

GITHUB_REPO_EXISTS=$(gh repo view "$ORG/.github" --json name --jq '.name' 2>/dev/null || echo "")

if [[ -z "$GITHUB_REPO_EXISTS" ]]; then
  echo "  Creating .github repo..."
  gh repo create "$ORG/.github" --public --description "GitHub organization profile" 2>/dev/null && ok "Created .github repo" || err "Failed to create .github repo"
  # Initialize with a README
  gh api "repos/$ORG/.github/contents/profile/README.md" \
    --method PUT \
    --field message="Initial org profile README" \
    --field content="$(cat ~/.copilot/session-state/org-profile-readme.md 2>/dev/null | base64)" \
    2>/dev/null && ok "Created profile/README.md" || err "Failed to create profile/README.md"
else
  echo "  .github repo exists — updating profile/README.md..."
  # Get current SHA
  SHA=$(gh api "repos/$ORG/.github/contents/profile/README.md" --jq '.sha' 2>/dev/null || echo "")
  if [[ -n "$SHA" ]]; then
    gh api "repos/$ORG/.github/contents/profile/README.md" \
      --method PUT \
      --field message="Update org profile README" \
      --field content="$(cat ~/.copilot/session-state/org-profile-readme.md | base64)" \
      --field sha="$SHA" \
      2>/dev/null && ok "Updated profile/README.md" || err "Failed to update profile/README.md"
  else
    gh api "repos/$ORG/.github/contents/profile/README.md" \
      --method PUT \
      --field message="Create org profile README" \
      --field content="$(cat ~/.copilot/session-state/org-profile-readme.md | base64)" \
      2>/dev/null && ok "Created profile/README.md" || err "Failed to create profile/README.md"
  fi
fi

# ============================================================
echo ""
echo "=== 5/5  PUBLIC REPO READMES ==="
# ============================================================

PUBLIC_REPOS=(elizabethannstein apoc-bnb constellation-events time-slip-search rootwrecker guts-and-glory studio-furniture codememory codecraft-dev contradict-me aichatbot caipo-new security-trainer mythos)

for repo in "${PUBLIC_REPOS[@]}"; do
  VIS=$(gh repo view "$ORG/$repo" --json visibility --jq '.visibility' 2>/dev/null || echo "not_found")
  if [[ "$VIS" == "public" ]]; then
    README_FILE="$HOME/.copilot/session-state/readmes/$repo.md"
    if [[ -f "$README_FILE" ]]; then
      SHA=$(gh api "repos/$ORG/$repo/contents/README.md" --jq '.sha' 2>/dev/null || echo "")
      if [[ -n "$SHA" ]]; then
        gh api "repos/$ORG/$repo/contents/README.md" \
          --method PUT \
          --field message="Improve README with badges, demo link, and getting started guide" \
          --field content="$(cat "$README_FILE" | base64)" \
          --field sha="$SHA" \
          2>/dev/null && ok "$repo README updated" || err "$repo README update failed"
      else
        gh api "repos/$ORG/$repo/contents/README.md" \
          --method PUT \
          --field message="Add README with badges, demo link, and getting started guide" \
          --field content="$(cat "$README_FILE" | base64)" \
          2>/dev/null && ok "$repo README created" || err "$repo README creation failed"
      fi
    else
      echo "  $repo — README file not found at $README_FILE, skipping"
    fi
  else
    echo "  $repo — $VIS (skipped)"
  fi
done

echo ""
echo "=== DONE — Errors: $ERRORS ==="
