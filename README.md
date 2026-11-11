# Claude skills kit — video + Meta ads

One command installs the full skill set used to produce 9:16 Meta video ads with Claude Code
(Remotion, HyperFrames, FFmpeg editing, ad creative, Meta Ads) into `~/.claude/skills`,
so every project on the machine can use it.

```bash
curl -fsSL https://raw.githubusercontent.com/shanebenjamindev/dylan-claude-skills-list/main/install.sh | bash
```

Then open a **new** Claude Code session.

## What gets installed (45 skills)

| Group | Skills | Source (pinned commit) | License |
|---|---|---|---|
| `remotion` | remotion-best-practices, -captions, -create, -docs, -interactivity, -license, -maps, -markup, -multimedia, -render, -saas, -studio, -upgrade | [remotion-dev/remotion](https://github.com/remotion-dev/remotion) `packages/skills` | Remotion License |
| | remotion-motion-graphics | [haidrrrry/claude-remotion-skill](https://github.com/haidrrrry/claude-remotion-skill) | MIT |
| `hyperframes` | hyperframes, hyperframes-cli, hyperframes-registry, media-use, figma, remotion-to-hyperframes, reverse-any-video, slideshow, style-sampling | [heygen-com/hyperframes](https://github.com/heygen-com/hyperframes) v0.9.27 | Apache-2.0 |
| `video` | claude-video + 15 sub-skills (edit, caption, export, shorts, promo, audio, transcode, analyze…) | [AgriciDaniel/claude-video](https://github.com/AgriciDaniel/claude-video) | MIT |
| `marketing` | ad-creative, ads, copywriting, marketing-psychology, marketing-video* | [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) | MIT |
| | meta-ads | [kostja94/marketing-skills](https://github.com/kostja94/marketing-skills) | — |
| `custom` | anything you put in `custom/<skill-name>/SKILL.md` in this repo | this repo | yours |

\* upstream `video` is installed as `marketing-video` so it doesn't clash with claude-video's `/video`.

Nothing third-party is stored in this repo: the script downloads each skill from its original
repo at the commit pinned at the top of `install.sh`. Bump a `*_REF` line to update.

## Options

```bash
# only some groups
curl -fsSL https://raw.githubusercontent.com/shanebenjamindev/dylan-claude-skills-list/main/install.sh | SKILL_GROUPS="video marketing" bash

# install somewhere else
curl -fsSL …/install.sh | CLAUDE_SKILLS_DIR=./.claude/skills bash
```

Existing skills with the same name are moved to `~/.claude/skills/.backup-<date>/` first, never deleted.

## Tools the skills expect (installer only checks, never installs)

- **ffmpeg** — `brew install ffmpeg` (note: Homebrew's build has no `drawtext`/`libass`; put text in Remotion)
- **node** 18+ — for Remotion / HyperFrames
- **python 3.10+** — `brew install python@3.12` (some claude-video scripts)
- Remotion on macOS: if its downloaded headless shell hangs, point it at installed Chrome in
  `remotion.config.ts`: `Config.setBrowserExecutable("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"); Config.setChromeMode("chrome-for-testing");`

## Adding your own skills

Put each one in `custom/<name>/SKILL.md` (+ any files it uses), commit, push. Everyone who re-runs
the one-liner gets it. Set `KIT_REPO` at the top of `install.sh` to this repo's `owner/name`.
