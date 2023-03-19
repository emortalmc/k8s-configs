# Minecraft Configs

## gamemodes.yaml

### Gamemode Definition

```yaml
id: string
enabled: bool
fleetName: string
protocolVersion: int32

friendlyName: string
activityNoun: string

minPlayers: int32
maxPlayers: int32

displayItem: Item
displayNpc: NPC

partyRestrictions:
  allowParties: bool
  minSize: int32
  maxSize: int32 # Optional

teamInfo: # Optional
  teamSize: int32
  teamCount: int32
  
maps: [string]Map # A map of map IDs to Map objects

matchmakerInfo:
  matchMethod: string # enum: INSTANT, COUNTDOWN
  selectMethod: string # enum: PLAYER_COUNT, AVAILABLE
  rate: Duration # duration: nanoseconds
  
  backfill: bool
```

### Duration

A duration must use nanoseconds and be a positive integer.

### Item

```yaml
material: string
slot: int32
name: string
lore: []string # Optional
```

### Map

```yaml
id: string
enabled: bool

friendlyName: string

displayItem: Item

matchmakerInfo:
  chance: float32
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
  