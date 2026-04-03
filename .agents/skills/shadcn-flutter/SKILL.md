---
name: shadcn-flutter
description: Map and replace Flutter Material widgets with shadcn_flutter components. Use when building UI with shadcn_flutter, migrating Material-based screens to shadcn_flutter, or avoiding Material widgets in this repo.
---

# Shadcn Flutter

## Overview

Use `package:shadcn_flutter/shadcn_flutter.dart` as the primary UI toolkit. Replace Material widgets
with Shadcn Flutter components and keep imports clean to avoid class name collisions.

## Workflow

1. Ensure imports
- Prefer `import 'package:shadcn_flutter/shadcn_flutter.dart';`
- Remove `import 'package:flutter/material.dart';` when possible.
- If a Material widget is still needed, import as `import 'package:flutter/material.dart' as m;`
  and use the `m.` prefix.

2. Map components
- Use `references/components-map.md` to map Material widgets to Shadcn Flutter equivalents.
- For widgets not listed, look up the export list in `~/.pub-cache/hosted/pub.dev/shadcn_flutter-0.0.52/lib/shadcn_flutter.dart`.

3. Replace with Shadcn widgets
- Swap Material components for their Shadcn counterparts.
- Prefer Shadcn button variants (`PrimaryButton`, `OutlineButton`, `GhostButton`, etc.) over generic
  Material buttons.
- Use Shadcn form controls (`TextField`, `Select`, `RadioGroup`, `Switch`, etc.).

4. App shell and theme
- Use `ShadcnApp` instead of `MaterialApp`.
- Use Shadcn `Theme` / `ThemeData` and component themes.
- If needed, use `ShadcnScrollBehavior` for consistent scroll feel.

5. Verify behavior
- Check layout, focus states, hover/press states, and accessibility.
- Validate that no Material widgets are reintroduced accidentally via indirect imports.

## Resources

- `references/components-map.md`: Catalog and Material-to-Shadcn mapping table (based on shadcn_flutter 0.0.52).
