# Monster Roguelike — Product Requirements Document
**Version:** 1.0  
**Engine:** Flutter + Flame  
**Platform:** Android (Google Play Store) → iOS (Phase 2)  
**Genre:** Roguelike / Monster Collector / Puzzle RPG  
**Target Audience:** 13–35, fans of Pokémon, Slay the Spire, Hades  
**Monetisation Model:** Free-to-play with cosmetic IAP + optional battle pass

---

## Table of Contents

1. [Vision & Pillars](#1-vision--pillars)
2. [Core Game Loop](#2-core-game-loop)
3. [Creature System](#3-creature-system)
4. [Run Structure & World Map](#4-run-structure--world-map)
5. [Node Types](#5-node-types)
6. [Battle System](#6-battle-system)
7. [Puzzle System](#7-puzzle-system)
8. [Rarity & Progression System](#8-rarity--progression-system)
9. [Persistent Meta-Progression](#9-persistent-meta-progression)
10. [World Boss & Endgame](#10-world-boss--endgame)
11. [Biomes & Worlds](#11-biomes--worlds)
12. [UI/UX Specification](#12-uiux-specification)
13. [Audio Design](#13-audio-design)
14. [Monetisation & Economy](#14-monetisation--economy)
15. [Technical Architecture](#15-technical-architecture)
16. [Data & Analytics](#16-data--analytics)
17. [Development Phases](#17-development-phases)
18. [Google Play Store Launch Checklist](#18-google-play-store-launch-checklist)
19. [Post-Launch Roadmap](#19-post-launch-roadmap)
20. [Risks & Mitigations](#20-risks--mitigations)

---

## 1. Vision & Pillars

### Elevator Pitch
A roguelike monster-collection game where every run is a fresh adventure through procedurally generated world maps. Choose your creature, navigate branching paths, solve puzzles, battle wild monsters, and face a World Boss — all with permanent creature unlocks that carry across runs.

### Design Pillars

| Pillar | Description |
|--------|-------------|
| **Every Run Feels Different** | Procedural maps, randomised puzzles, varied node encounters ensure no two runs are identical |
| **Meaningful Choices** | Path decisions, move loadouts, and item picks have tangible consequences |
| **Creatures Are Trophies** | Defeating a World Boss permanently unlocks that run's creature — collection is the long-term hook |
| **Rarity Creates Excitement** | Shiny-tier creatures and legendary moves feel genuinely rare and powerful |
| **Accessible Depth** | Simple controls, 60 fps Flame rendering; deep synergies reward mastery |

---

## 2. Core Game Loop

```
┌─────────────────────────────────────────────────────────┐
│                    META (Persistent)                     │
│  Creature Roster → Pick Starter → Unlock Difficulty+    │
└────────────────────────┬────────────────────────────────┘
                         │ Start Run
┌────────────────────────▼────────────────────────────────┐
│                     RUN LOOP                            │
│                                                         │
│  World Map Screen                                       │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Node Path  →  Pick Node  →  Resolve Node        │  │
│  │  (repeat across 3–5 Acts per World)              │  │
│  └──────────────────────────────────────────────────┘  │
│         │                │               │              │
│      Battle           Puzzle          Event             │
│      Wild              Node           Node              │
│     Creature                                            │
│         └────────────► Loot / EXP / Move Upgrade        │
│                                 │                       │
│                        Act Boss Battle                  │
│                                 │                       │
│                        World Boss Battle                │
│                                 │                       │
│                   Victory → Creature Unlock             │
│                   Defeat  → Run End, partial rewards    │
└─────────────────────────────────────────────────────────┘
```

### Session Flow
1. **Home Screen** — tap Play, see roster/unlocks
2. **Creature Select** — pick from 3 random starters (+ any permanently unlocked creatures)
3. **World Map** — view full path graph, pick first node
4. **Node Sequence** — battle / puzzle / event / shop / rest
5. **Act Boss** — mid-world gatekeeper
6. **World Boss** — final encounter per world
7. **Run End Screen** — stats, rewards, creature unlock if applicable
8. **Meta Layer** — update roster, equip relics, see collection

---

## 3. Creature System

### 3.1 Creature Anatomy

Every creature has:

| Attribute | Description |
|-----------|-------------|
| **Name & Species** | Unique per creature, lore blurb |
| **Type** | Fire, Water, Earth, Wind, Shadow, Light, Storm, Void (8 types) |
| **Base Stats** | HP, Attack, Defence, Speed, Spirit (special resource) |
| **Move Set** | 4 active moves (can swap via nodes) |
| **Passive Ability** | 1 always-on passive per creature |
| **Rarity** | Determines stat scaling & visual effects (see §3.3) |
| **Evolution Stage** | 1–3; evolve mid-run via Evo Stones |

### 3.2 Starter Creatures (Launch Roster)
Minimum 30 unique creatures at launch across all rarities. Examples:

| Name | Type | Rarity | Passive |
|------|------|--------|---------|
| Embrix | Fire | Common | Deal +10% dmg when HP < 50% |
| Thalor | Water | Common | Heal 5 HP after each battle won |
| Grubolt | Earth | Uncommon | Reduce first hit each battle by 25% |
| Wispara | Light | Rare | First move each battle costs 0 Spirit |
| Duskfang | Shadow | Epic | Lifesteal 15% of damage dealt |
| Voltharx | Storm | Legendary | Double damage on paralysed enemies |
| Nullborn | Void | Mythic | Immune to status effects |
| Prismaray | Light | Shiny | All moves have 10% crit + rainbow VFX |

### 3.3 Rarity Tiers

| Rarity | Colour | Stat Multiplier | Move Power | Drop Chance | Visual Effect |
|--------|--------|----------------|------------|-------------|---------------|
| Common | Grey | 1.0× | Base | 50% | None |
| Uncommon | Green | 1.15× | +10% | 28% | Subtle shimmer |
| Rare | Blue | 1.3× | +20% | 14% | Glow outline |
| Epic | Purple | 1.5× | +35% | 5% | Particle aura |
| Legendary | Gold | 1.75× | +55% | 2.5% | Flame/lightning FX |
| Mythic | Red | 2.0× | +75% | 0.4% | Full screen reveal |
| Shiny | Rainbow | 2.2× | +80% | 0.1% | Prismatic sparkle + unique cry |

Shiny creatures are visual alternates of existing creatures (palette swap + enhanced VFX).

### 3.4 Moves

Each move has:
- **Type** (matches creature types)
- **Power** (base damage / heal amount)
- **Spirit Cost** (resource; regenerates each turn)
- **Effect** (burn, freeze, stun, lifesteal, shield, etc.)
- **Rarity** (moves themselves have Common→Legendary rarity, scaling power)
- **Cooldown** (turns before reuse, if any)

Move count at launch: 120+ moves across all types.

---

## 4. Run Structure & World Map

### 4.1 World Map Screen

The map is the centrepiece of the run. Displayed as a **top-down node graph** from bottom to top:

```
                    [WORLD BOSS]
                         │
           ┌─────────────┼─────────────┐
          [B]           [E]           [S]
           │             │             │
     ┌─────┴──┐    ┌─────┴──┐    ┌────┴───┐
    [W]      [P]  [P]      [W]  [E]      [W]
     │        │    │        │    │        │
    [E]──────[R]──[S]──────[W]──[P]──────[R]
                         START
```

**Legend:** W=Wild Battle, P=Puzzle, E=Event, B=Boss Battle, S=Shop, R=Rest Site

Map rules:
- 3–5 Acts per World, each Act has 6–9 rows of nodes
- Player sees the **full graph** from start to boss — informed decisions matter
- Each node is reachable only from the node(s) directly below it
- Player taps a node to travel — animated path draw
- **Fog of war option** (unlockable difficulty modifier): node types hidden until adjacent

### 4.2 Procedural Map Generation

- Seeded per run (seed visible — allows sharing)
- Guaranteed path always includes at least 1 shop, 1 rest, 1 puzzle, and 1 boss per Act
- Distribution weights configurable per biome (e.g. Shadow biome = more Elite nodes)
- Map seed can be stored for Daily Challenge mode (same seed for all players that day)

### 4.3 Worlds / Biomes

| World | Theme | Boss Type | Hazard |
|-------|-------|-----------|--------|
| Verdant Vale | Forest | Earth/Nature | Poison tiles |
| Ashpeak Crater | Volcano | Fire | Burn on miss |
| Frostmere | Ice Tundra | Ice/Water | Speed reduction |
| Stormspire | Sky | Storm/Wind | Random turn order |
| Shadow Abyss | Dark Dungeon | Shadow | Curse stacks |
| Celestial Rift | Sky Temple | Light/Void | Heal reduction |
| Temporal Void | End-game | Mythic Boss | All of the above |

---

## 5. Node Types

### 5.1 Wild Battle Node
- Fight 1–3 wild creatures (scaled to Act depth)
- Win → gain EXP, coin, chance to recruit creature as a **bench creature** (swap in at rest nodes)
- Lose → creature loses HP (no full death by default on Normal; optional Hardcore mode)

### 5.2 Elite Battle Node
- Stronger single enemy with a guaranteed relic/move reward
- Icon: skull overlay on battle node
- Appears from Act 2 onward

### 5.3 Boss Node (Act Boss)
- Unique named boss creature per Act per biome
- Has 2 phases (triggers at 50% HP)
- Guaranteed: 1 rare+ move, 1 relic on victory

### 5.4 World Boss Node
- Final node per World
- 3 phases
- Victory = world cleared; creature unlock flow triggered

### 5.5 Puzzle Node
- Player presented with a procedural puzzle (see §7)
- Solve = pick 1 of 3 rewards (move upgrade / relic / heal)
- Fail = no reward, minor stat debuff for next battle

### 5.6 Event Node
- Random narrative event with choices (30+ events at launch)
- Example: *"A wounded creature blocks your path. [Heal it] [Capture it] [Fight it]"*
- Each choice has probabilistic outcomes that can be positive, negative, or mixed
- Some events chain into mini-storylines across a run

### 5.7 Shop Node
- Spend coins earned in run
- Stock: moves, relics, consumables, stat boosts, evo stones
- Shopkeeper can be robbed (triggers Elite battle next node)
- Shop inventory procedurally seeded

### 5.8 Rest Site Node
- Choose one: **Heal 30% HP** or **Upgrade a Move** (increase rarity tier)
- If creature is below 25% HP, auto-shows heal option highlighted
- Bench swap available at rest sites

### 5.9 Mystery Node (?)
- Random: could be any node type, weighted toward positive
- Higher risk, higher reward — slightly better loot table

### 5.10 Campfire Node (Rare)
- Full heal + free move upgrade
- Only guaranteed once per World

---

## 6. Battle System

### 6.1 Turn-Based Combat

- **Speed stat** determines turn order; ties broken by coin flip
- Each turn: choose 1 of 4 moves
- Spirit regenerates +2 per turn; max 10 Spirit
- Status effects resolve at start of affected creature's turn

### 6.2 Status Effects

| Effect | Duration | Behaviour |
|--------|----------|-----------|
| Burn | 3 turns | Lose 5% max HP/turn |
| Freeze | 2 turns | Skip turn (thaw on hit) |
| Paralysis | 3 turns | 50% chance to skip turn |
| Poison | 5 turns | Lose 3% max HP/turn, stacks |
| Curse | Until healed | All healing reduced 50% |
| Stun | 1 turn | Skip next turn, guaranteed |
| Shield | X turns | Absorb flat damage amount |
| Enrage | 3 turns | +30% ATK, -30% DEF |

### 6.3 Type Chart (8×8)

Full effectiveness matrix: Strong / Neutral / Weak / Immune.  
Example strong matchups: Fire > Earth, Water > Fire, Shadow > Light, Void > everything (0.75×).

### 6.4 Combo System

Landing 3 moves of the same type in one battle triggers a **Type Surge**: the 4th move of that type in the same battle deals 2× damage and gains a bonus effect. Encourages mono-type strategy.

### 6.5 Crit System

Base crit rate: 5%. Moves and passives can raise this. Crits deal 1.75× damage and bypass shields.

### 6.6 Relic Interactions

Relics (passive items carried through the run) modify battle rules:  
Example: *"Shard of Fury — your first move each battle deals double damage."*

### 6.7 Battle UI

- Creature sprite (animated idle, attack, hurt, faint frames) — Flame SpriteAnimationComponent
- HP bar with animated fill
- Move buttons with Spirit cost shown
- Turn order indicator
- Status effect icons on creature
- Floating damage numbers
- Combo counter overlay

### 6.8 Enemy AI

- Enemies use a behaviour tree (Flame provides component system)
- Tiers: Passive (attacks only), Defensive (buffs/heals), Aggressive (targets weaknesses), Strategic (status + sweep)
- Boss AI adds phase-based logic (phase 2 = different move set + speed buff)

---

## 7. Puzzle System

### 7.1 Puzzle Types (Procedurally Generated)

**Type A — Element Sequencer**  
Grid of coloured tiles (matching creature types). Match sequences to fill a meter. Time-pressured. Complexity scales with Act depth.

**Type B — Move Chain**  
Given a set of 6 moves and an enemy with specific HP/shields, find the optimal sequence to defeat it in 3 turns. Logic puzzle. No time limit.

**Type C — Memory Grid**  
Flash a 4×4 grid of creature icons for 2 seconds, then replicate placement. Grid size scales.

**Type D — Creature Trivia**  
3 multiple-choice questions about game mechanics / creature lore. Rewards scale with correct answers.

**Type E — Rune Alignment**  
Sliding tile puzzle; align runes to complete a circuit. Procedural layout.

**Type F — Damage Calculator**  
Given creature stats and a move, calculate the exact damage dealt (with type multiplier). Tests mastery.

### 7.2 Procedural Parameters

Each puzzle has: `seed`, `difficulty_tier` (1–5), `type_override` (optional biome flavour).  
Puzzles are generated at map-seed time and pre-solved to guarantee solvability.

---

## 8. Rarity & Progression System

### 8.1 Rarity Discovery

Creatures are discovered through:
- Run starter selection (3 random starters; rarity roll on each)
- Capturing wild creatures mid-run (see §5.1)
- Event nodes offering creature rewards
- Shop purchases (using run coins or meta currency)
- Post-run Gacha pull (optional, see §14)

### 8.2 Move Upgrading

Moves start at the rarity of the creature holding them. At Rest Sites or via relics, moves can be upgraded:

`Common → Uncommon → Rare → Epic → Legendary`

Each upgrade: +15% power, may add or enhance the move's secondary effect.

### 8.3 Stat Scaling by Run Difficulty

Each "New Game+" style difficulty multiplies enemy base stats:

| Difficulty | Enemy Stat Mult | Reward Mult | Unlock Condition |
|------------|----------------|-------------|-----------------|
| Normal | 1.0× | 1.0× | Default |
| Veteran | 1.25× | 1.3× | Beat World 1 |
| Ruthless | 1.6× | 1.7× | Beat World 3 |
| Nightmare | 2.0× | 2.2× | Beat all worlds |
| Endless | Scales ∞ | ∞ | Beat Nightmare |

Persistent creatures played on harder difficulties retain their stat base but enemies scale up.

---

## 9. Persistent Meta-Progression

### 9.1 Creature Roster (Persistent Collection)

- Creatures defeated as World Bosses are permanently unlocked
- Unlocked creatures appear in the starter selection pool for future runs
- Each unlocked creature shows: rarity, times used, best run depth, move history

### 9.2 Creature Slots in Starter Select

```
[ Random A ] [ Random B ] [ Random C ]
[ Unlocked creature 1 ] [ Unlocked 2 ] [ Unlocked 3 ] ...scrollable
```

Unlocked creatures on harder difficulties may roll a **rarity upgrade** (e.g., a Common Embrix re-obtained on Ruthless might appear as Rare Embrix).

### 9.3 Relics — Run-Persistent Items

Relics are found in runs and persist until run end:
- 100+ relics at launch
- Divided into: Starter Relics (pick 1 before run), Found Relics (mid-run), Boss Relics (boss kills)
- Relic synergies: certain combos create emergent power spikes (documented in Codex)

### 9.4 Codex (Persistent Knowledge Base)

- Unlocks creature lore, move descriptions, relic effects as encountered
- Acts as a compendium — encourages exploration/completionism
- Tracks: Total runs, bosses defeated, creatures discovered, best win streak, fastest clear

### 9.5 Achievements

30+ achievements at launch. Tied to Google Play Games Services. Examples:
- *First Blood* — Win your first run
- *Shiny Hunter* — Encounter a Shiny creature
- *Speed Demon* — Clear a World in under 8 minutes
- *Completionist* — Fill the Codex 100%

### 9.6 Daily Challenge

- Same procedural seed for all players that day
- No meta relics or unlocked creatures (fair competition)
- Daily leaderboard (Google Play Games Services or Firebase)

---

## 10. World Boss & Endgame

### 10.1 World Boss Design

Each World Boss is a unique creature with:
- **3-phase fight** (phase triggers at 70% / 35% HP)
- **Signature Move** that is telegraphed 1 turn before use
- **Adaptive AI**: samples player's last 3 moves and counters them in phase 2
- **Arena Hazard**: biome-specific passive damage/effect during fight

### 10.2 Victory Flow

```
World Boss Defeated
→ "YOU WIN" cinematic (Flame animation + particle system)
→ Run Stats Screen (damage dealt, nodes visited, time, puzzle score)
→ Creature Unlock Screen:
    ┌─────────────────────────────────────────────────────┐
    │  ✨ [BOSS CREATURE NAME] has joined your roster! ✨  │
    │                                                      │
    │     [Rarity Roll Animation]                          │
    │     Rolled: EPIC Thalor                              │
    │                                                      │
    │     [Add to Roster]  [View in Collection]            │
    └─────────────────────────────────────────────────────┘
→ Return to Home
```

### 10.3 True Endgame — The Temporal Void

After clearing all 6 biome Worlds, **The Temporal Void** unlocks:
- Combines elements of all biomes
- 5 Acts, each borrowing mechanics from a previously cleared world
- Boss: **The Voidweaver** — randomises its type each phase
- Defeating The Voidweaver grants a **Mythic-tier creature** and unlocks Endless Mode

### 10.4 Endless Mode

- Infinite Acts; difficulty scales logarithmically
- Leaderboard: deepest floor cleared that week
- Exclusive cosmetic rewards at depth milestones

---

## 11. Biomes & Worlds

### Biome-Specific Mechanics

| Biome | Special Rule | Unique Node |
|-------|-------------|-------------|
| Verdant Vale | Poison stacks carry between battles | Herb Garden (+regen relic) |
| Ashpeak Crater | Burn bypasses shields | Forge Node (upgrade weapon relic) |
| Frostmere | First move each battle always hits | Glacier Trap (-speed) |
| Stormspire | Turn order re-rolls each round | Updraft (skip 1 node freely) |
| Shadow Abyss | Healing reduced by 50% | Shadow Market (cheap rare items) |
| Celestial Rift | All crits heal you 5% | Shrine (+Spirit max) |
| Temporal Void | All of the above, rotating | Echo Node (replay last node) |

---

## 12. UI/UX Specification

### 12.1 Screen Map

```
Splash / Loading
    └─ Home Screen
         ├─ Play → Creature Select → World Map → [Node flow] → Run End
         ├─ Collection (Codex / Roster)
         ├─ Daily Challenge
         ├─ Settings
         ├─ Shop (IAP cosmetics)
         └─ Profile (achievements, stats)
```

### 12.2 Key Screen Specs

**Home Screen**
- Animated creature idle in foreground
- Current biome background (cycles)
- Persistent: coins, run streak, battle pass progress bar
- Large "PLAY" CTA button, secondary buttons below

**Creature Select**
- Cards with creature sprite, name, type icon, rarity glow
- Stat preview on tap (radar chart)
- Swipe for unlocked creatures
- "Info" button opens Codex entry

**World Map**
- Full scrollable graph rendered via Flame or custom Canvas
- Current position highlighted
- Node icons: unique per type, colour-coded
- Path lines animate when new path is selected
- Top bar: HP, coins, relics held, Act indicator

**Battle Screen**
- Split: player creature bottom-centre, enemy top-centre
- Move grid: 2×2 button layout, each colour-coded by type
- HP bars animated; shake on hit (Flame camera shake)
- Status effect icons row under each creature
- Combo meter top-centre

**Puzzle Screen**
- Full-screen puzzle canvas
- Timer (if applicable) top bar
- "Give Up" option (lose reward, no penalty to HP)

**Run End Screen**
- Stats: nodes visited, battles won/lost, puzzles solved, damage dealt, total time
- EXP bar fill animation
- Creature unlock if applicable

### 12.3 Design Language

- **Style:** Dark fantasy with vivid creature colours; pixel art sprites + smooth UI chrome
- **Font:** Display — pixel/retro font for headers; clean sans-serif for body/stats
- **Colour Palette:** Deep navy/charcoal background; rarity colours as primary accents; white UI chrome
- **Animations:** Flame handles game sprites; Flutter handles UI transitions (Hero animations, fade/slide)
- **Accessibility:** Colour-blind mode (icon + pattern alongside colour); font size scaling; screen reader labels on interactive elements

---

## 13. Audio Design

| Category | Detail |
|----------|--------|
| **Music** | Per-biome adaptive OST (loops + intensity layers); battle music; boss theme |
| **SFX** | Hit, crit, miss, status apply, type-surge, relic pickup, puzzle solve, level up, shiny encounter |
| **Creature Cries** | Unique 1–2 second audio ID per creature (synth-generated for scope) |
| **UI Sounds** | Button tap, card flip, map node select, transition whoosh |
| **Shiny Encounter** | Distinct jingle + audio sting — high reward moment |

Tools: Flutter `audioplayers` or `flame_audio` package. Music in OGG/MP3 loops. Budget: license-free / commissioned.

---

## 14. Monetisation & Economy

### 14.1 In-Run Economy (Soft Currency)
- **Coins** — earned in battles, events, puzzles; spent at shops in-run only
- Coins do not persist between runs (prevents snowballing)

### 14.2 Meta Currency (Hard Currency)
- **Crystals** — earned slowly via achievements, dailies, first-time world clears
- Crystals spent on: cosmetic skins, Gacha pulls for creature shards, battle pass

### 14.3 IAP Tiers

| Product | Price (USD) | Contents |
|---------|-------------|----------|
| Starter Pack (one-time) | $1.99 | 200 Crystals + Rare creature skin |
| Crystal Pack S | $0.99 | 100 Crystals |
| Crystal Pack M | $4.99 | 550 Crystals |
| Crystal Pack L | $9.99 | 1,200 Crystals |
| Battle Pass (monthly) | $4.99 | 50-tier cosmetic track + exclusive skin |
| No Ads (permanent) | $2.99 | Remove all optional ads |

### 14.4 Ads (Optional / Rewarded Only)
- **Rewarded Ad:** Watch to revive creature once per run (Normal difficulty only)
- **Rewarded Ad:** Watch for a second Puzzle attempt
- **No intrusive interstitials**; respect user experience

### 14.5 Gacha (Cosmetic Only)
- Creature skins / shiny variants only — no gameplay advantage
- Pity system: guaranteed Rare at 10 pulls, Epic at 50, Legendary at 100
- No loot boxes for stats or moves — regulatory safety

### 14.6 Battle Pass
- Free track: coins, cosmetic icons
- Paid track: creature skins, animated backgrounds, exclusive shiny palette
- Season length: 8 weeks

---

## 15. Technical Architecture

### 15.1 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (stable channel) |
| Game Engine | Flame 1.x (latest stable) |
| State Management | Riverpod (app state); Flame component system (game state) |
| Local Storage | Hive (fast, NoSQL, Flutter-native) |
| Backend (optional) | Firebase (Auth, Firestore for leaderboards, Remote Config, Analytics) |
| IAP | `in_app_purchase` Flutter plugin |
| Ads | Google Mobile Ads SDK (`google_mobile_ads`) |
| Achievements | `games_services` plugin (Google Play Games Services) |
| Audio | `flame_audio` |
| Crash Reporting | Firebase Crashlytics |
| CI/CD | GitHub Actions → Fastlane → Google Play internal track |

### 15.2 Flame Architecture

```
FlameGame
  ├─ WorldMapComponent         # Map graph renderer
  ├─ BattleSceneComponent      # Full battle screen
  │    ├─ CreatureSpriteComponent (player)
  │    ├─ CreatureSpriteComponent (enemy)
  │    ├─ HUDComponent
  │    └─ EffectLayer (particles, VFX)
  ├─ PuzzleSceneComponent      # Puzzle renderer
  └─ UIOverlayBridge           # Flutter widget overlays on Flame canvas
```

Flame handles: sprite sheets, animations, collision (battles), particles (VFX), camera effects.  
Flutter handles: menus, settings, IAP, collection screens, all non-game UI.

### 15.3 Data Models

**Creature**
```dart
class Creature {
  String id;
  String name;
  CreatureType type;
  Rarity rarity;
  bool isShiny;
  BaseStats stats;          // hp, atk, def, spd, spirit
  List<Move> moves;         // max 4
  PassiveAbility passive;
  int evolutionStage;       // 1–3
  bool isUnlocked;          // persistent
  int runCount;             // meta stat
}
```

**Run State**
```dart
class RunState {
  String seed;
  Creature activeCreature;
  List<Creature> bench;     // max 2 bench creatures
  List<Relic> relics;
  int coins;
  int currentAct;
  int currentWorld;
  WorldMap map;
  RunStats stats;
  Difficulty difficulty;
}
```

**WorldMap**
```dart
class WorldMap {
  List<List<MapNode>> grid;  // rows of nodes
  MapNode currentNode;
  List<MapNode> visitedNodes;
  String seed;
}
```

### 15.4 Procedural Generation

- All randomness seeded via `Random(seed)` — reproducible
- Map: graph generation using modified Slay-the-Spire algorithm (guaranteed paths, min diversity)
- Puzzles: template + parametric fill, pre-verified solvable
- Enemy stats: base × depth_scalar × difficulty_multiplier × biome_modifier
- Loot tables: weighted random, pity timers to prevent long droughts of rare items

### 15.5 Save System

- Auto-save after every node resolution (Hive box write)
- Run state serialised to JSON snapshot
- If app killed mid-battle: restore to pre-battle state (battles are atomic)
- Cloud save: Firebase Firestore sync (authenticated users only)

### 15.6 Performance Targets

| Metric | Target |
|--------|--------|
| Frame Rate | 60 fps on mid-range Android (Snapdragon 665+) |
| Cold Start | < 3 seconds to Home Screen |
| APK Size | < 80 MB initial; assets delivered via deferred loading |
| RAM Usage | < 300 MB peak |
| Battery | < 5% drain per 30-minute session |

### 15.7 Offline Support
- Core game fully playable offline
- Leaderboards / daily challenge sync when online
- IAP requires connectivity

---

## 16. Data & Analytics

### 16.1 Events to Track (Firebase Analytics)

| Event | Properties |
|-------|-----------|
| `run_started` | creature_id, rarity, difficulty |
| `run_ended` | outcome, world_reached, act_reached, duration_s |
| `node_visited` | node_type, act, world |
| `battle_result` | outcome, enemy_id, moves_used, turns |
| `puzzle_result` | puzzle_type, solved, time_s, act |
| `boss_defeated` | boss_id, world, difficulty |
| `creature_unlocked` | creature_id, rarity, is_shiny |
| `iap_initiated` | product_id |
| `iap_completed` | product_id, value |
| `ad_watched` | placement, outcome |

### 16.2 KPIs

| KPI | Target (90 days post-launch) |
|-----|------------------------------|
| D1 Retention | ≥ 40% |
| D7 Retention | ≥ 20% |
| D30 Retention | ≥ 10% |
| Session Length | ≥ 12 minutes avg |
| Sessions/DAU | ≥ 2.5 |
| ARPU | ≥ $0.30 |
| Conversion (any IAP) | ≥ 3% |
| Crash-free sessions | ≥ 99.5% |

---

## 17. Development Phases

### Phase 0 — Pre-Production (4 weeks)
- [ ] Finalise GDD (this document + appendices)
- [ ] Art direction: style guide, palette, creature silhouettes (first 10)
- [ ] Prototype: single battle loop (Flutter + Flame, no polish)
- [ ] Tech spike: Flame performance on low-end Android
- [ ] Set up monorepo (GitHub), CI pipeline skeleton
- [ ] Define creature data schema, move database schema
- [ ] Sound direction: reference tracks, SFX approach

### Phase 1 — Core Loop MVP (8 weeks)
**Goal:** Playable vertical slice — one World, one biome, 5 creatures, basic map

- [ ] World map screen (procedural graph, tap navigation)
- [ ] Battle system: turn order, 4 moves, HP, status effects (5 effects)
- [ ] Battle UI: sprites, HP bars, move buttons, damage numbers
- [ ] 5 starter creatures with sprites (idle + attack + hurt + faint animations)
- [ ] 20 moves implemented
- [ ] 10 relics
- [ ] Wild battle node, boss node, rest node, shop node
- [ ] 1 puzzle type (Element Sequencer)
- [ ] Run end screen
- [ ] Hive local save/load
- [ ] Basic audio (placeholder SFX + 1 music track)

### Phase 2 — Content & Systems Expansion (10 weeks)
**Goal:** Full roguelike feel — 3 worlds, all node types, meta-progression

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

### Phase 3 — Polish & Monetisation (6 weeks)
**Goal:** Production-quality feel + monetisation plumbing

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

### Phase 4 — QA & Soft Launch (6 weeks)
**Goal:** Stable, balanced, launch-ready build

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

### Phase 5 — Global Launch (2 weeks)
**Goal:** Gradual rollout on Google Play Store

- [ ] Final APK / AAB signed and uploaded
- [ ] Content rating questionnaire completed (IARC)
- [ ] Store listing live (EN + translated)
- [ ] Staged rollout: 10% → 50% → 100% over 7 days
- [ ] Monitor Crashlytics in real-time
- [ ] Monitor reviews — respond within 24 hrs
- [ ] Hotfix pipeline ready (Fastlane expedited track)
- [ ] Press kit distributed (indie game press, Reddit, Discord)
- [ ] Launch social posts

---

## 18. Google Play Store Launch Checklist

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

---

## 19. Post-Launch Roadmap

### v1.1 (4 weeks post-launch)
- Hotfixes from launch feedback
- 5 new creatures
- 2 new event nodes
- Performance improvements for low-end devices
- First seasonal event (limited-time cosmetic skin)

### v1.2 (8 weeks post-launch)
- **iOS launch** (submit to App Store, Apple review)
- New puzzle type (Damage Calculator)
- 10 new relics
- Endless Mode leaderboard improvements

### v1.3 (3 months post-launch)
- **PvP mode** — asynchronous: your optimised run deck vs another player's ghost run
- New biome: Shadow Abyss
- New world boss
- Seasonal Battle Pass S2

### v2.0 (6 months post-launch)
- **Creature Fusion** — combine two creatures to create a hybrid (visual + stat blend)
- **Guild System** — co-op Daily Challenges
- **Raid Boss** — real-time limited boss event (Firebase Realtime DB)
- Expanded lore via Event chain storylines

---

## 20. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Flame performance on low-end Android | Medium | High | Benchmark early (Phase 0 spike); sprite atlas optimisation; disable particle FX on low-end toggle |
| Balancing — runs too hard/easy | High | Medium | Telemetry on run completion rate; rapid balance patches via Remote Config (enemy stat scalars) |
| Rarity system feels P2W | Low | High | Keep Gacha cosmetic-only; document clearly in store listing; community transparency |
| Scope creep delaying launch | High | High | Lock Phase 1–3 scope; backlog remaining features into post-launch roadmap |
| Play Store policy rejection | Low | High | Complete Data Safety / Content Rating forms before submitting; legal IP clearance on creature designs |
| Artist / audio contractor delays | Medium | Medium | Hire 2 contractors, stagger deliverables; use placeholder assets until finals |
| Firebase costs spike | Low | Medium | Firestore read limits + caching; leaderboards use aggregation instead of per-document reads |
| iOS launch complexity | Medium | Low | Treat as separate Phase 2; don't block Android launch on it |

---

## Appendix A — Creature Design Brief (First 30)

10 Common, 8 Uncommon, 5 Rare, 4 Epic, 2 Legendary, 1 Mythic, 1 Shiny (shiny variant of a Rare).  
Each creature needs: front sprite (96×96 px), idle animation (6 frames), attack (4 frames), hurt (3 frames), faint (6 frames).  
Style: chunky pixel art, strong silhouettes, readable at 96px.

---

## Appendix B — Move Database Format

```csv
id, name, type, power, spirit_cost, effect, effect_chance, cooldown, rarity
001, Embershot, Fire, 45, 2, Burn, 30%, 0, Common
002, Tidal Surge, Water, 55, 3, None, 0%, 0, Common
003, Glacial Spike, Water, 70, 4, Freeze, 25%, 0, Uncommon
...
```

---

## Appendix C — Relic Database Format

```csv
id, name, description, rarity, trigger, effect_value
001, Iron Shell, "Take 15% less damage from the first hit each battle", Common, on_first_hit, 0.15
002, Lucky Coin, "Gain +5 coins after every battle won", Common, on_battle_win, 5
003, Shard of Fury, "First move each battle deals double damage", Rare, on_first_move, 2.0
...
```

---

*Document Owner: Game Director*  
*Last Updated: 2026-05-11*  
*Status: APPROVED FOR DEVELOPMENT — Phase 0*
