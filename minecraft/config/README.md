# Minecraft Configs

## gamemodes.yaml

### Gamemode Definition

```yaml
id: string
enabled: bool
fleetName: string

priority: int32 # Lower is higher priority

friendlyName: string
activityNoun: string

minPlayers: int32
maxPlayers: int32

# Optional
displayItem: Item
# Optional
displayNpc: NPC

partyRestrictions:
  minSize: int32
  maxSize: int32 # Optional

teamInfo: # Optional
  teamSize: int32
  teamCount: int32
  
# Optional
maps: [string]Map # A map of map IDs to Map objects

matchmakerInfo:
  matchMethod: string # enum: INSTANT, COUNTDOWN
  selectMethod: string # enum: PLAYER_COUNT, AVAILABLE
  rate: Duration # duration: nanoseconds
  
  backfill: bool # default: false
```

### Duration

A duration must use nanoseconds and be a positive integer.

### Item

```yaml
material: string
name: string
lore: []string # Optional
```

### Map

```yaml
id: string
enabled: bool

friendlyName: string
priority: int32 # Lower is higher priority

displayItem: Item
```

### NPC

```yaml
entityType: string # enum: Minestom EntityType values
titles: []string
skin: Skin
```

### Skin

```yaml
texture: string
signature: string
```
  