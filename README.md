# Godville Prana Bot (Playwright)

Lightweight Playwright bot for Godville that logs in, clicks “Do good” or “Do bad” based on a chosen strategy, and goes
to “sleep” when buttons are no longer available. Optimized for low CPU/memory usage and Docker-friendly. Session can be
persisted across restarts.

## Features

- Reliable login with optional persisted session (state.json)
- Action modes: random | good | bad (+ optional fallback)
- Resource-friendly: minimal reloads, blocks trackers and media
- Auto-sleep once buttons are missing for several checks in a row
- Ready-to-run Docker setup with CPU/RAM limits and auto-restart

## Project Structure

```
.
├─ app.py               # the bot (your final code)
├─ Dockerfile           # Playwright-based image
├─ docker-compose.yml   # resource limits, auto-restart, volume for state
├─ requirements.txt     # local-only deps (python-dotenv)
├─ .env                 # config and secrets (not committed)
├─ .dockerignore
└─ data/                # persistent state (state.json)
```

## Quick Start

### A) Docker (recommended)

1) Prepare files: app.py, Dockerfile, docker-compose.yml, .env, and a data/ folder.
2) Build and run:

```bash
docker compose up -d --build
```

3) Tail logs:

```bash
docker compose logs -f
```

Stop:

```bash
docker compose down
```

### B) Local (without Docker)

Requires Python 3.10+ and Playwright browsers installed.

```bash
python -m venv .venv
. .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install playwright python-dotenv
playwright install chromium
python app.py
```

## Configuration (.env)

Example:

```env
# Account
GODVILLE_LOGIN=your_login
GODVILLE_PASSWORD=your_password

# Action behavior
ACTION_MODE=bad           # random | good | bad
ACTION_FALLBACK=0         # 1 to click the alternative if preferred button is missing

# Intervals and behavior
MIN_ACTION_INTERVAL_SEC=5
MAX_ACTION_INTERVAL_SEC=20
NO_BUTTONS_GRACE_CHECKS=3
SHORT_RETRY_DELAY_SEC=1.5
RELOAD_ON_MISS=2
NAVIGATE_ON_MISS=4

# Sleep window (when buttons are repeatedly missing)
SLEEP_MIN_SEC=3600
SLEEP_MAX_SEC=7200

# Resource saving
HEADLESS=1
BLOCK_MEDIA=1
BLOCK_TRACKERS=1
SAVE_STATE=1
STATE_PATH=./data/state.json

# Misc
LOG_LEVEL=INFO
LOCALE=ru-RU
```

### Environment variables reference

| Variable                                          |           Default | Description                                                  |
|---------------------------------------------------|------------------:|--------------------------------------------------------------|
| GODVILLE_LOGIN / GODVILLE_PASSWORD                |                 — | Credentials for login                                        |
| ACTION_MODE                                       |            random | Action strategy: random, good, bad                           |
| ACTION_FALLBACK                                   |                 0 | If preferred button is missing, allow clicking the other one |
| MIN_ACTION_INTERVAL_SEC / MAX_ACTION_INTERVAL_SEC |            5 / 20 | Delay between action attempts                                |
| NO_BUTTONS_GRACE_CHECKS                           |                 3 | How many consecutive “no buttons” before sleeping            |
| SHORT_RETRY_DELAY_SEC                             |               1.5 | Short retry delay before counting a “miss”                   |
| RELOAD_ON_MISS / NAVIGATE_ON_MISS                 |             2 / 4 | When to do page.reload / goto(HERO_URL) after misses         |
| SLEEP_MIN_SEC / SLEEP_MAX_SEC                     |       3600 / 7200 | Sleep duration range (seconds)                               |
| HEADLESS                                          |                 1 | Run Chromium headless                                        |
| BLOCK_MEDIA / BLOCK_TRACKERS                      |             1 / 1 | Block images/fonts/media and trackers to save bandwidth/CPU  |
| SAVE_STATE                                        |                 1 | Save session to state.json for auto-login on restart         |
| STATE_PATH                                        | ./data/state.json | Path to session state file                                   |
| DETECT_TIMEOUT_MS                                 |              7000 | Max time to wait for action buttons to appear                |
| CLICK_TIMEOUT_MS                                  |              1500 | Click timeout per button attempt                             |
| LOG_LEVEL                                         |              INFO | Logging level (DEBUG/INFO/WARN/ERROR)                        |
| LOCALE                                            |             ru-RU | Locale and Accept-Language header                            |
| USER_AGENT                                        |         Chrome UA | Custom user agent string                                     |
| VIEWPORT_W / VIEWPORT_H                           |         960 / 600 | Viewport size for the page                                   |

## Docker Notes

- The provided docker-compose.yml uses:
    - restart: unless-stopped
    - cpus: 0.30 and mem_limit: 256m
    - shm_size: 256m for Chromium stability
    - Mounted volume ./data -> /app/data to persist state.json
- The Dockerfile uses the official Playwright image for maximum compatibility.

## Logs and Diagnostics

- The bot saves debug artifacts on failures (e.g., timeout_debug.png/html, login_failed.png/html) in the container’s
  working directory.
    - To persist them across runs, either mount the project root as a volume or adjust the save path to /app/data.
- For interactive debugging locally, set HEADLESS=0 in .env.
- If buttons “exist” but the bot can’t see them:
    - Increase DETECT_TIMEOUT_MS (e.g., 10000)
    - Temporarily set BLOCK_MEDIA=0 and BLOCK_TRACKERS=0
    - Verify button texts/DOM didn’t change

## Updating

- With Docker:

```bash
docker compose up -d --build
```

- Locally:

```bash
pip install -U playwright
playwright install chromium
```

## Resource Tips

- Keep HEADLESS=1, BLOCK_MEDIA=1, BLOCK_TRACKERS=1 for low CPU/memory and less network noise.
- Increase action intervals (e.g., 10–30s) if your host is tight on resources.
- If you see Chromium shared memory issues, raise shm_size to 512m in docker-compose.

## Security

- Never commit .env to your repo.
- Restrict access to logs and the data directory in production.
- Rotate your password if you suspect exposure.

## Important

- Follow the game’s rules and ToS. This bot does not bypass captchas or simulate human behavior beyond simple button
  clicks.
