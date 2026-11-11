#!/usr/bin/env bash
# Claude Code skills kit — installs the video + Meta-ads skill set in one go.
#
#   curl -fsSL https://raw.githubusercontent.com/shanebenjamindev/dylan-claude-skills-list/main/install.sh | bash
#
# Every skill is pulled from its ORIGINAL repo at a pinned commit (nothing third-party is
# re-hosted here), then copied into ~/.claude/skills so every Claude Code project can use it.
#
# Options (env vars):
#   SKILL_GROUPS="video marketing"   only install some groups (default: all)
#                              groups: remotion hyperframes video marketing custom
#   CLAUDE_SKILLS_DIR=...      install somewhere else (default: ~/.claude/skills)
#   KIT_REPO=owner/repo        where this kit lives (for the custom/ skills folder)
set -euo pipefail

KIT_REPO="${KIT_REPO:-shanebenjamindev/dylan-claude-skills-list}"
KIT_REF="${KIT_REF:-main}"
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
SKILL_GROUPS="${SKILL_GROUPS:-remotion hyperframes video marketing custom}"

# ---- pinned upstream sources (bump these to update) -----------------------------------
REMOTION_REPO="remotion-dev/remotion";            REMOTION_REF="9ef7bd9096b69af2a010ae9dbd9617f61f02ed78"
MOTION_REPO="haidrrrry/claude-remotion-skill";    MOTION_REF="1dcbe5e3fc6cf970bd10d3cc05f0a8a5d19d0383"
HF_REPO="heygen-com/hyperframes";                 HF_REF="9e346f9bb793fe53684d7437ac4bed79b11aaa54"   # v0.9.27
CV_REPO="AgriciDaniel/claude-video";              CV_REF="4253a2b7c6db74ac809429a4c69075b55e8a77ff"
MKT_REPO="coreyhaines31/marketingskills";         MKT_REF="3e729622e3de0c82abdb906190d91f9018045872"
META_REPO="kostja94/marketing-skills";            META_REF="ac823a127782355339f21aef6c87f1ccff751c84"

REMOTION_SKILLS="remotion-best-practices remotion-captions remotion-create remotion-docs remotion-interactivity remotion-license remotion-maps remotion-markup remotion-multimedia remotion-render remotion-saas remotion-studio remotion-upgrade"
HF_SKILLS="hyperframes hyperframes-cli hyperframes-registry media-use figma remotion-to-hyperframes reverse-any-video slideshow style-sampling"
MKT_SKILLS="ad-creative ads copywriting marketing-psychology"

# ---- helpers ---------------------------------------------------------------------------
c_ok="\033[32m"; c_dim="\033[2m"; c_warn="\033[33m"; c_off="\033[0m"
say()  { printf "  %b\n" "$*"; }
ok()   { printf "  ${c_ok}✓${c_off} %s\n" "$*"; }
warn() { printf "  ${c_warn}!${c_off} %s\n" "$*"; }
want() { case " $SKILL_GROUPS " in *" $1 "*) return 0;; *) return 1;; esac; }

command -v git >/dev/null || { echo "git is required (macOS: xcode-select --install)"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$DEST/.backup-$STAMP"
mkdir -p "$DEST"
INSTALLED=()

# fetch <owner/repo> <commit-or-branch> <path>...   -> checkout in $TMP/<repo>
fetch() {
  local repo="$1" ref="$2"; shift 2
  local dir="$TMP/${repo//\//_}"
  rm -rf "$dir"; mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" remote add origin "https://github.com/$repo.git"
  git -C "$dir" config core.sparseCheckout true
  git -C "$dir" sparse-checkout set --no-cone "$@" >/dev/null 2>&1
  git -C "$dir" fetch -q --depth 1 --filter=blob:none origin "$ref"
  git -C "$dir" checkout -q FETCH_HEAD
  echo "$dir"
}

# place <source dir> <skill name> : back up any existing copy, then install
place() {
  local src="$1" name="$2"
  [ -f "$src/SKILL.md" ] || { warn "skipped $name (no SKILL.md upstream)"; return; }
  if [ -e "$DEST/$name" ]; then mkdir -p "$BACKUP"; mv "$DEST/$name" "$BACKUP/$name"; fi
  cp -R "$src" "$DEST/$name"
  INSTALLED+=("$name")
}

echo
echo "  Claude skills kit  →  $DEST"
echo "  groups: $SKILL_GROUPS"
echo

# ---- Remotion ----------------------------------------------------------------------------
if want remotion; then
  say "${c_dim}Remotion skills (remotion-dev/remotion)…${c_off}"
  d=$(fetch "$REMOTION_REPO" "$REMOTION_REF" "/packages/skills/skills/")
  for s in $REMOTION_SKILLS; do place "$d/packages/skills/skills/$s" "$s"; done
  d=$(fetch "$MOTION_REPO" "$MOTION_REF" "/remotion-motion-graphics/" "/LICENSE")
  place "$d/remotion-motion-graphics" "remotion-motion-graphics"
  cp "$d/LICENSE" "$DEST/remotion-motion-graphics/LICENSE" 2>/dev/null || true
  ok "Remotion"
fi

# ---- HyperFrames ---------------------------------------------------------------------------
if want hyperframes; then
  say "${c_dim}HyperFrames skills (heygen-com/hyperframes v0.9.27)…${c_off}"
  d=$(fetch "$HF_REPO" "$HF_REF" "/skills/" "/LICENSE")
  for s in $HF_SKILLS; do place "$d/skills/$s" "$s"; cp "$d/LICENSE" "$DEST/$s/LICENSE" 2>/dev/null || true; done
  ok "HyperFrames"
fi

# ---- claude-video (FFmpeg suite) — same layout as its own installer -------------------------
if want video; then
  say "${c_dim}claude-video suite (AgriciDaniel/claude-video)…${c_off}"
  d=$(fetch "$CV_REPO" "$CV_REF" "/skills/" "/scripts/" "/references/" "/promo-pipeline/scripts/" "/promo-pipeline/references/" "/requirements.txt" "/LICENSE")
  main="$TMP/claude-video"; mkdir -p "$main/scripts" "$main/references"
  cp "$d/skills/video/SKILL.md" "$main/"
  cp "$d"/scripts/*.py "$d"/scripts/*.sh "$main/scripts/" 2>/dev/null || true
  cp "$d"/promo-pipeline/scripts/*.py "$main/scripts/" 2>/dev/null || true
  cp "$d"/references/*.md "$main/references/" 2>/dev/null || true
  cp "$d"/promo-pipeline/references/*.md "$main/references/" 2>/dev/null || true
  cp "$d/requirements.txt" "$d/LICENSE" "$main/" 2>/dev/null || true
  place "$main" "claude-video"
  for sd in "$d"/skills/video-*/; do
    n="claude-$(basename "$sd")"; mkdir -p "$TMP/$n"; cp "$sd/SKILL.md" "$TMP/$n/"
    place "$TMP/$n" "$n"
  done
  ok "claude-video (16 skills)"
fi

# ---- Marketing / Meta ads ------------------------------------------------------------------
if want marketing; then
  say "${c_dim}Marketing skills (coreyhaines31/marketingskills, kostja94/marketing-skills)…${c_off}"
  d=$(fetch "$MKT_REPO" "$MKT_REF" "/skills/ad-creative/" "/skills/ads/" "/skills/copywriting/" "/skills/marketing-psychology/" "/skills/video/" "/LICENSE")
  for s in $MKT_SKILLS; do place "$d/skills/$s" "$s"; cp "$d/LICENSE" "$DEST/$s/LICENSE" 2>/dev/null || true; done
  # upstream "video" is renamed so it doesn't clash with claude-video's /video command
  sed 's/^name: video$/name: marketing-video/' "$d/skills/video/SKILL.md" > "$d/skills/video/SKILL.md.tmp" && mv "$d/skills/video/SKILL.md.tmp" "$d/skills/video/SKILL.md"
  place "$d/skills/video" "marketing-video"; cp "$d/LICENSE" "$DEST/marketing-video/LICENSE" 2>/dev/null || true
  d=$(fetch "$META_REPO" "$META_REF" "/skills/paid-ads/platforms/meta-ads/")
  place "$d/skills/paid-ads/platforms/meta-ads" "meta-ads"
  ok "Marketing + Meta ads"
fi

# ---- Your own skills (custom/ folder of this kit) ----------------------------------------
if want custom; then
  if d=$(fetch "$KIT_REPO" "$KIT_REF" "/custom/" 2>/dev/null) && [ -d "$d/custom" ]; then
    for sd in "$d"/custom/*/; do [ -d "$sd" ] && place "$sd" "$(basename "$sd")"; done
    ok "custom skills from $KIT_REPO"
  fi
fi

# ---- summary + dependency hints -----------------------------------------------------------
echo
ok "${#INSTALLED[@]} skills installed into $DEST"
[ -d "$BACKUP" ] && say "${c_dim}previous copies backed up to $BACKUP${c_off}"
echo
command -v ffmpeg >/dev/null || warn "ffmpeg not found — video skills need it (macOS: brew install ffmpeg)"
command -v node   >/dev/null || warn "node not found — Remotion/HyperFrames need it (https://nodejs.org)"
command -v python3.12 >/dev/null || command -v python3.11 >/dev/null || command -v python3.10 >/dev/null \
  || warn "python 3.10+ not found — some claude-video scripts need it (brew install python@3.12)"
say "Open a NEW Claude Code session to load the skills."
echo
