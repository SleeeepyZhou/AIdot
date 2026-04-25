---
name: GameInput
description: Simulate keyboard input in the game
tool_names: game_key_input
---

Use `game_key_input` to control the game by simulating key presses.

The `key` parameter must match an action name defined in **Project Settings → Input Map**.

Always release a key after pressing it — send a second call with `pressed: false`.

Example sequence to move right briefly:
1. `game_key_input(key: "move_right", pressed: true)`
2. `game_key_input(key: "move_right", pressed: false)`
