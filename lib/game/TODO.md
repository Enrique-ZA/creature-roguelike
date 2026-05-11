# Monster Roguelike - Development TODO List

## Project Sanity Commands
- dart fix
- dart format
- tests: test/widget_test.dart
- flutter analyze
- git repository: creature-roguelike

## Project Structure
```
lib/
├── main.dart                         # App entry, routes (/login, /menu, /game)
├── game/
│   ├── TODO.md                       # This file
│   ├── Monster-Roguelike-PRD.md      # Game design document
│   ├── types.dart                    # CreatureType enum (8 types), Rarity enum
│   ├── creatures.dart                # Creature, Stats, PassiveAbility models + CreatureDataLoader
│   ├── creature_sprite.dart          # Creature sprite rendering logic
│   ├── moves.dart                    # Move model + loader
│   ├── status_effects.dart           # Status effect logic (Burn, Poison, etc.)
│   ├── battle_system.dart            # Turn-based battle logic, damage calculation
│   ├── battle_ui.dart                # Flame components for battle (HP bars, buttons)
│   ├── world_map.dart                # Procedural map generation and navigation
│   ├── nodes.dart                    # Node types for map
│   ├── puzzle_sequencer.dart         # Puzzle logic
│   ├── relics.dart                   # Relic system logic
│   ├── contrast-checker.js           # WCAG colour contrast checker
│   └── roguelike_game.dart           # FlameGame: Orchestrates map/battle states
└── screens/
    ├── login_screen.dart             # Placeholder login → /menu
    ├── main_menu_screen.dart         # Placeholder menu → creature select → game
    ├── creature_select_screen.dart   # Creature cards, stat bars, rarity glow, start run
    ├── game_screen.dart              # Wraps Flame GameWidget (accepts selected creature)
    ├── puzzle_screen.dart            # Puzzle interface
    ├── rest_screen.dart              # Rest node screen
    ├── run_end_screen.dart           # Run summary/end screen
    └── shop_screen.dart              # Shop interface
assets/
├── creatures.json                    # Expanded creature data
├── moves.json                        # Expanded move data
└── relics.json                       # Relic data
```

## Coding Conventions
- **Keep files small** — target ≤300 lines per file. Split concerns into separate files early.
- Flame components, UI widgets, and data models each get their own file.
- JSON data files live in `assets/` and are loaded via `rootBundle`.
- **Contrast:** Verify colours using `node lib/game/contrast-checker.js <fg> <bg>` before assigning text-on-surface colours.

Skip *ANY* audio related tasks for now

## Phase 0 — Pre-Production (4 weeks)
- [ ] Finalise GDD (this document + appendices)
- [ ] Art direction: style guide, palette, creature silhouettes (first 10)
- [x] Prototype: single battle loop (Flutter + Flame, no polish)
- [ ] Tech spike: Flame performance on low-end Android
- [ ] Set up monorepo (GitHub), CI pipeline skeleton [User: I believe we set up a repository]
- [x] Define creature data schema, move database schema
- [ ] Sound direction: reference tracks, SFX approach

## Phase 1 — Core Loop MVP (8 weeks)
- [x] Creature select screen (cards, stats, rarity glow, start run)
- [x] World map screen (procedural graph, tap navigation)
- [x] Battle system: turn order, 4 moves, HP, status effects (5 effects)
- [x] Battle UI: sprites, HP bars, move buttons, damage numbers
- [ ] 5 starter creatures with sprites (idle + attack + hurt + faint animations)
- [ ] 20 moves implemented
- [ ] 10 relics
- [ ] Wild battle node, boss node, rest node, shop node
- [ ] 1 puzzle type (Element Sequencer)
- [ ] Run end screen
- [ ] Hive local save/load
- [ ] Basic audio (placeholder SFX + 1 music track)

## Phase 2 — Content & Systems Expansion (10 weeks)
- [ ] 3 biomes fully implemented (Verdant Vale, Ashpeak Crater, Frostmere)
- [ ] 20 creatures (sprites + data)
- [ ] 60 moves
- [ ] 40 relics
- [ ] All 6 puzzle types
- [ ] Event node system (15 events)
- [ ] Meta-progression: roster screen, creature unlock flow
- [ ] Rarity system: visual effects per tier (glow, particles)
- [ ] Shiny encounter system
- [ ] Codex / collection screen
- [ ] Difficulty system (Normal + Veteran)
- [ ] Full type chart (8×8)
- [ ] Combo / Type Surge system
- [ ] Creature evolution (Evo Stones)
- [ ] Bench system (swap at rest)
- [ ] Daily challenge (Firebase seed)

## Phase 3 — Polish & Monetisation (6 weeks)
- [ ] 30 creatures, 120 moves, 100 relics
- [ ] All 7 worlds + Temporal Void
- [ ] 30+ event nodes
- [ ] Full OST (7 biome tracks + battle/boss variants)
- [ ] All SFX
- [ ] Creature cry audio
- [ ] IAP integration (`in_app_purchase`)
- [ ] Google Mobile Ads (rewarded only)
- [ ] Battle pass UI + backend (Firebase)
- [ ] Creature skin system
- [ ] Settings screen (sound, haptics, colour-blind mode, font size)
- [ ] Accessibility pass
- [ ] Tutorial (first run guided, skippable on subsequent runs)
- [ ] Onboarding FTUE (first-time user experience)
- [ ] Haptic feedback (Flutter HapticFeedback API)
- [ ] Achievements (30) — Google Play Games Services integration
- [ ] Leaderboards (Endless mode, Daily Challenge)
- [ ] Firebase Crashlytics integration
- [ ] Firebase Analytics — all events firing

## Phase 4 — QA & Soft Launch (6 weeks)
- [ ] Internal QA: all nodes, all puzzles, all battles, all relics
- [ ] Balance pass: run completion rate target 20–35% Normal, 10–15% Veteran
- [ ] Performance profiling: 60 fps on Snapdragon 665
- [ ] Memory leak audit
- [ ] Soft launch: limited regions (e.g. Philippines, South Africa) via Play internal track → open testing
- [ ] Analyse soft-launch retention & economy data
- [ ] Monetisation tuning (Crystal earn rate vs spend)
- [ ] Bug bash: address all P0/P1 issues
- [ ] Store listing assets: icon, feature graphic, 8 screenshots, promo video (30 sec)
- [ ] Privacy policy & Terms of Service page (hosted URL)
- [ ] GDPR / COPPA compliance review (age gate if needed)
- [ ] Legal: IP clearance on creature names/designs
- [ ] Localisation: English + at least 3 additional languages (strings externalised via `intl`)

## Phase 5 — Global Launch (2 weeks)
- [ ] Final APK / AAB signed and uploaded
- [ ] Content rating questionnaire completed (IARC)
- [ ] Store listing live (EN + translated)
- [ ] Staged rollout: 10% → 50% → 100% over 7 days
- [ ] Monitor Crashlytics in real-time
- [ ] Monitor reviews — respond within 24 hrs
- [ ] Hotfix pipeline ready (Fastlane expedited track)
- [ ] Press kit distributed (indie game press, Reddit, Discord)
- [ ] Launch social posts

## Google Play Store Launch Checklist
### App Configuration
- [ ] App signing: enrolled in Google Play App Signing
- [ ] Target SDK: latest stable Android API (API 35 at time of writing)
- [ ] Min SDK: API 24 (Android 7.0) — covers ~97% of active devices
- [ ] 64-bit compliance (Flutter builds 64-bit by default — confirm)
- [ ] Android App Bundle (.aab) format (required by Play)
- [ ] ProGuard / R8 obfuscation configured
- [ ] Asset delivery: on-demand modules for large asset packs

### Play Console Setup
- [ ] Developer account in good standing
- [ ] App created in Play Console
- [ ] Content rating (IARC questionnaire complete)
- [ ] Target audience declared
- [ ] Data safety form completed (explain data collected: analytics, IAP, no personal data sold)
- [ ] App category: Games > Role Playing
- [ ] In-app products configured (all SKUs)
- [ ] Subscriptions configured (battle pass)

### Store Listing Assets
- [ ] App icon: 512×512 PNG (no alpha)
- [ ] Feature graphic: 1024×500 PNG
- [ ] Screenshots: minimum 2, up to 8 (phone + 7-inch tablet + 10-inch tablet)
- [ ] Promo video: YouTube URL, 30–2 min, shows real gameplay
- [ ] Short description: ≤80 characters (include keywords: roguelike, monster, puzzle, RPG)
- [ ] Full description: ≤4000 characters, keyword-optimised, store-policy compliant (no misleading claims)
- [ ] Privacy policy URL live (required)
- [ ] Support email configured

### Pre-Launch Testing
- [ ] Pre-launch report reviewed (Google automated test)
- [ ] Android Vitals baseline established (crash rate, ANR rate)
- [ ] Tested on: low-end (2GB RAM), mid-range (4GB), high-end (8GB+) devices
- [ ] Tested on Android 7, 10, 13, 14
- [ ] Edge cases: airplane mode, incoming call mid-battle, low storage

## Post-Launch Roadmap
### v1.1 (4 weeks post-launch)
- [ ] Hotfixes from launch feedback
- [ ] 5 new creatures
- [ ] 2 new event nodes
- [ ] Performance improvements for low-end devices
- [ ] First seasonal event (limited-time cosmetic skin)

### v1.2 (8 weeks post-launch)
- [ ] **iOS launch** (submit to App Store, Apple review)
- [ ] New puzzle type (Damage Calculator)
- [ ] 10 new relics
- [ ] Endless Mode leaderboard improvements

### v1.3 (3 months post-launch)
- [ ] **PvP mode** — asynchronous: your optimised run deck vs another player's ghost run
- [ ] New biome: Shadow Abyss
- [ ] New world boss
- [ ] Seasonal Battle Pass S2

### v2.0 (6 months post-launch)
- [ ] **Creature Fusion** — combine two creatures to create a hybrid (visual + stat blend)
- [ ] **Guild System** — co-op Daily Challenges
- [ ] **Raid Boss** — real-time limited boss event (Firebase Realtime DB)
- [ ] Expanded lore via Event chain storylines
