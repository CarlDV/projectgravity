# UI Header Revamp — Two-Stage Collapse Animation

**Date:** 2026-08-06  
**Project:** Project Gravity 02 (Roblox)  
**Status:** Approved

## Overview

Replace the current single-stage height-collapse minimize with a **two-stage choreographed animation**: the panel first collapses vertically to header-only, then the header folds horizontally into a small draggable pill containing just the maximize button. The reverse sequence expands elegantly with a Back overshoot for liveliness.

## Current State

The existing minimize (`UI.lua:1478-1494`) has these characteristics:
- Boolean state `im` (closure local, not persisted)
- Height-only tween: 500→50px over 0.4s (Exponential Out)
- Content ScrollingFrame `c` snaps `Visible=false` instantly — visible pop
- Force-closes Advanced, mode selector, and target list
- **Gaps:** Keybinds and Tutorial stay floating; the button shows no state; width/height values are duplicated literals

Platform: Roblox Instance-based GUI, TweenService (`v6`), UIScale-based scaling system at `UI.lua:162-243`.

## Goals

1. **Smooth two-stage choreography** — height collapse, then horizontal fold
2. **Clean final state** — a 44×44 circular draggable pill with only the green maximize button visible
3. **Graceful expansion** — header unfolds first (with Back overshoot), then content rolls down
4. **Close all popups** — include Keybinds and Tutorial, which current code misses
5. **No duplication** — constants for panel dimensions

## Architecture

### Constants

Replace hardcoded literals with:
```lua
local PANEL_W = 320
local PANEL_H = 500
local HEADER_H = 50
local PILL_SIZE = 44
local CONTENT_GAP = 10   -- gap between header bottom and content top
```

Update `m.Size` at `UI.lua:284` and the tween targets at `UI.lua:1490-1492`.

`CONTENT_GAP` exists because the content frame `c` currently hardcodes `Position (0,0,0,60)` and `Size (1,0,1,-70)` (`UI.lua:311-312`) — a 60/70 pair derived from a 50px header plus a 10px gap, but written as raw literals. Both must become `HEADER_H + CONTENT_GAP` and `-(HEADER_H + CONTENT_GAP + CONTENT_GAP)` so changing `HEADER_H` cannot silently desync them.

### State

Reuse the existing `im` boolean. Add:
```lua
local anim_busy = false
```
Guard against mid-flight clicks that would desync the two stages.

### Animation Sequencing

Chain stages using `Completed` signals. Each tween `.Completed:Connect(function() ... end)` triggers the next stage only after the prior one finishes.

---

## Minimize — Two Stages

### Stage 1: Roll Up (0.35s, Quart Out)

**Before tweening:**
```lua
m.ClipsDescendants = true
```
This clips the content as it shrinks instead of the current snap-invisible.

**Close all popups:**
```lua
if am.Visible then toggle_window(am, false) end
if km.Visible then toggle_window(km, false) end
if tut_container.Visible then toggle_window(tut_container, false) end
if x6.dlst_container and x6.dlst_container.Visible then
    toggle_window(x6.dlst_container, false, true)
end
if m:FindFirstChild("TargetListContainer") and m.TargetListContainer.Visible then
    toggle_window(m.TargetListContainer, false, true)
end
```

**Height tween:**
```lua
v6:Create(m, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, PANEL_W, 0, HEADER_H)
}):Play()
```

On `Completed`, proceed to Stage 2.

### Stage 2: Fold Left (0.4s, Exponential Out)

**Fade out non-essential buttons and title:**
```lua
-- Title TextLabel `t`
v6:Create(t, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
    TextTransparency = 1
}):Play()

-- Discord button `dcb`
v6:Create(dcb, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
    BackgroundTransparency = 1,
    TextTransparency = 1
}):Play()

-- Tutorial button `tutb`
v6:Create(tutb, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
    BackgroundTransparency = 1,
    TextTransparency = 1
}):Play()

-- Close button `closeb`
v6:Create(closeb, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
    BackgroundTransparency = 1
}):Play()
```

**Recenter the minimize button:**  
Move `minb` from right-anchored `(1, -60, 0.5, -10)` to centered `(0.5, -10, 0.5, -10)`:
```lua
v6:Create(minb, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -10, 0.5, -10)
}):Play()
```
*Note:* Because both this tween and the panel width tween run simultaneously with identical timing, the button's actual path is not a straight line — `0.5` is evaluated against the live animating width. The endpoints are correct; the mid-flight drift is intentional.

**Shrink panel to pill:**  
Also resize the header `h` to match the pill height so elements anchor correctly inside it:
```lua
v6:Create(m, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, PILL_SIZE, 0, PILL_SIZE)
}):Play()
v6:Create(h, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
    Size = UDim2.new(1, 0, 0, PILL_SIZE)
}):Play()
```
`h.Size` currently has an absolute Y offset of 50 (`UI.lua:297`); tweening it to 44 keeps the minimize button's vertical centering correct within the pill.

**Round the corners:**
```lua
local corner = m:FindFirstChildOfClass("UICorner")
v6:Create(corner, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
    CornerRadius = UDim.new(0, PILL_SIZE / 2)  -- 22px for a 44px pill
}):Play()
```

On `Completed`, set `anim_busy = false`.

---

## Maximize — Two Stages (Inverse)

### Stage 1: Unfold (0.45s, Back Out)

The Back easing creates a slight overshoot that makes the expansion feel alive rather than mechanical.

**Expand pill to header and restore header height:**
```lua
v6:Create(m, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, PANEL_W, 0, HEADER_H)
}):Play()
v6:Create(h, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(1, 0, 0, HEADER_H)
}):Play()
```

**Restore corner radius:**
```lua
local corner = m:FindFirstChildOfClass("UICorner")
v6:Create(corner, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    CornerRadius = UDim.new(0, 10)
}):Play()
```

**Slide button back to the right:**
```lua
v6:Create(minb, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(1, -60, 0.5, -10)
}):Play()
```

**Fade in title and buttons:**
```lua
v6:Create(t, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    TextTransparency = 0
}):Play()

v6:Create(dcb, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0,
    TextTransparency = 0
}):Play()

v6:Create(tutb, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0,
    TextTransparency = 0
}):Play()

v6:Create(closeb, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0
}):Play()
```

On `Completed`, proceed to Stage 2.

### Stage 2: Roll Down (0.4s, Quart Out)

**Height expansion:**
```lua
v6:Create(m, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
}):Play()
```

On `Completed`:
```lua
-- ClipsDescendants stays true until the panel is fully expanded,
-- because content must remain hidden during height animation.
m.ClipsDescendants = false
anim_busy = false
```

---

## Edge Cases

### Overflow on Expand

If the collapsed pill was dragged near screen edges, expanding to 320×500 would overflow. On maximize Stage 1 start, clamp both axes:

```lua
local vps = workspace.CurrentCamera.ViewportSize
local clamp_x = math.max(10, math.min(m.Position.X.Offset, vps.X - PANEL_W - 10))
local clamp_y = math.max(10, math.min(m.Position.Y.Offset, vps.Y - PANEL_H - 10))
m.Position = UDim2.new(0, clamp_x, 0, clamp_y)
```

The Y clamp is critical — a pill dragged to the bottom expands 500px downward.

### Button Click Guard

Wrap the `minb.MouseButton1Click` handler:
```lua
minb.MouseButton1Click:Connect(function()
    if anim_busy then return end
    anim_busy = true
    im = not im
    if im then
        minimize_stage_1()
    else
        maximize_stage_1()
    end
end)
```

### Nested Window Sizing

`dlst_container` and `tdlst` are children of `m` with `Size = UDim2.new(0, 220, 1, 0)` — full height of Main. During the collapse tween they'd squash to 50px tall unless force-closed first. The current code already does this; we keep that behavior and extend it to include `km` and `tut_container`.

### `f1()` Rebuilds

The `f1()` function (`UI.lua:734-1239`) destroys and recreates the content area, including `tdlst`. The `im` and `anim_busy` closure locals live outside `f1`, so they survive. New elements created by `f1` must respect the current `im` state — if `im == true`, the recreated `tdlst` should start with `Visible = false`.

---

## Component Reference

| Element | Variable | Initial Position | Collapsed Position | Final State |
|---------|----------|------------------|-------------------|-------------|
| Main panel | `m` | `(0,30, 0.5,-250)` 320×500 | `(any, any)` 44×44 | draggable pill |
| Header | `h` | 50px tall | 44px tall | tweened to match pill |
| Title | `t` | `(0,20, 0,0)` | n/a | TextTransparency=1 |
| Min button | `minb` | `(1,-60, 0.5,-10)` | `(0.5,-10, 0.5,-10)` | visible, centered |
| Discord | `dcb` | `(1,-120, 0.5,-10)` | n/a | transparency=1 |
| Tutorial | `tutb` | `(1,-90, 0.5,-10)` | n/a | transparency=1 |
| Close | `closeb` | `(1,-30, 0.5,-10)` | n/a | transparency=1 |
| Content | `c` | `(0,0, 0,60)` full-height-70 | n/a | clipped away |
| Corner | `UICorner` | radius 10 | radius 22 | circular |
| Stroke | `UIStroke` | thickness 1 | thickness 1 | unchanged |

---

## Testing Checklist

- [ ] Minimize animates smoothly through both stages
- [ ] Maximize animates smoothly through both stages, header before content
- [ ] Final collapsed state is a 44×44 circle with only green button visible
- [ ] Pill is draggable
- [ ] Expanding from the right edge clamps on-screen
- [ ] Double-click during animation is ignored (guard works)
- [ ] Advanced, Keybinds, Tutorial, mode selector, and target list all close on minimize
- [ ] `f1()` rebuild respects `im` state for newly created elements
- [ ] UI Scale slider in Advanced still works (no conflict with the scale/pop system)
- [ ] Mobile variant at `mobilever/UI.lua` is updated to match (or explicitly noted as deferred)

---

## Implementation Notes

- The existing `toggle_window` function already handles the Advanced/mode-selector/target-list open/close animations. We're only replacing the minimize/maximize handler at `UI.lua:1478-1494`.
- The scale/pop system (`UI.lua:162-243`) must not be touched. Main is registered at `register_window(m, 1)` (`UI.lua:293`) and any `UIScale`-based animation must go through `set_pop`, but our size/corner/position tweens don't touch `UIScale.Scale`, so there's no conflict.
- Duration choices: 0.35s for roll-up (quick), 0.4s for fold (deliberate), 0.45s for unfold (Back overshoot needs time), 0.4s for roll-down (matches collapse feel).

---

## Open Questions

None — design approved.
