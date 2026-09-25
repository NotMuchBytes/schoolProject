# Arabic voice recording manifest

Place final recordings at the exact paths below. OGG is the default format. A
line can use WAV or MP3 by setting its `audio_path` metadata explicitly.

Missing recordings are intentional and safe: subtitles, missions, animation,
camera behavior, and input continue normally.

## Speaker IDs and folders

| Speaker ID | Role | Folder |
|---|---|---|
| `player` | Young messenger | `res://audio/dialogue/player/` |
| `teacher` | Village teacher | `res://audio/dialogue/teacher/` |
| `temple_recipient` | Temple recipient | `res://audio/dialogue/temple_recipient/` |
| `athens` | Important Athenian speakers | `res://audio/dialogue/athens/` |
| `sparta` | Important Spartan speakers | `res://audio/dialogue/sparta/` |
| `alexander` | Alexander | `res://audio/dialogue/alexander/` |
| `macedonian_officer` | Macedonian officer | `res://audio/dialogue/macedonian_officer/` |
| `macedonian_messenger` | Messenger reporting from Babylon | `res://audio/dialogue/narrator/` |
| `narrator` | Historical narrator | `res://audio/dialogue/narrator/` |

## Required story recordings

### Player

- `teacher_message_002.ogg`
- `temple_record_002.ogg`
- `athens_citizen_002.ogg`
- `sparta_trainer_001.ogg`
- `sparta_trainer_004.ogg`
- `alexander_briefing_002.ogg`

### Teacher

- `teacher_message_001.ogg`
- `teacher_message_003.ogg` through `teacher_message_005.ogg`

### Temple recipient

- `temple_record_001.ogg`
- `temple_record_003.ogg`
- `temple_record_004.ogg`

### Athens

- `athens_arrival_001.ogg` belongs to the narrator folder, not Athens.
- `athens_debate_001.ogg` through `athens_debate_003.ogg`
- `athens_citizen_001.ogg`, `athens_citizen_003.ogg`, `athens_citizen_004.ogg`

### Sparta

- `sparta_training_001.ogg`, `sparta_training_002.ogg`
- `sparta_trainer_002.ogg`, `sparta_trainer_003.ogg`, `sparta_trainer_005.ogg`

### Macedonian officer

- `macedon_officer_001.ogg` through `macedon_officer_003.ogg`

### Alexander

- `alexander_briefing_001.ogg`, `alexander_briefing_003.ogg`, `alexander_briefing_004.ogg`

### Narrator and historical transitions

- `village_opening_001.ogg` through `village_opening_004.ogg`
- `athens_arrival_001.ogg`
- `city_state_conflict_001.ogg` through `city_state_conflict_003.ogg`
- `macedon_arrival_001.ogg`
- `campaign_narration_001.ogg` through `campaign_narration_005.ogg`
- `campaign_narration_006.ogg` uses the Macedonian messenger voice
- `campaign_narration_007.ogg`
- `division_narration_001.ogg` through `division_narration_005.ogg`
- `hellenistic_narration_001.ogg` through `hellenistic_narration_004.ogg`

## Ambient positional recordings

Ambient recordings go directly in `res://audio/ambient/`. Existing categories:

- `ambient_village_harbor_001.ogg`, `ambient_village_harbor_002.ogg`
- `ambient_village_market_001.ogg`, `ambient_village_market_002.ogg`
- `ambient_village_square_001.ogg`, `ambient_village_square_002.ogg`
- `ambient_village_upper_path_001.ogg`
- `ambient_athens_debater_west_001.ogg`
- `ambient_athens_debater_east_001.ogg`
- `ambient_athens_civic_001.ogg`
- `ambient_sparta_trainee_west_001.ogg`
- `ambient_sparta_trainee_center_001.ogg`
- `ambient_sparta_trainer_call_001.ogg`
- `ambient_macedon_patrol_west_001.ogg`
- `ambient_macedon_patrol_east_001.ogg`
- `ambient_macedon_supply_001.ogg`

Ambient lines use `AudioStreamPlayer3D`, a global one-speaker-at-a-time slot,
distance attenuation, cooldowns, a small Label3D subtitle, and suppression while
major dialogue or narration is active.
