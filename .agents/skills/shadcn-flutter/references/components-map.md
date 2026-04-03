# Shadcn Flutter Component Map (package: shadcn_flutter 0.0.52)

Source of truth: `~/.pub-cache/hosted/pub.dev/shadcn_flutter-0.0.52/lib/shadcn_flutter.dart` export list.
Use this file to map Material widgets to their Shadcn Flutter counterparts and to see the available
component families.

## Quick Rules

- Prefer `import 'package:shadcn_flutter/shadcn_flutter.dart';` and avoid `material.dart` to prevent
  conflicts with patched widgets (Form, Table, TextField, Scaffold, etc.).
- If a Material widget is absolutely needed, import it as `import 'package:flutter/material.dart' as m;`
  and use the `m.` prefix.

## Component Catalog (by export path)

App + Theme
- `ShadcnApp`, `ShadcnUI`, `ShadcnAnimatedTheme`, `Theme`, `ThemeData`, `ComponentThemeData`

Layout
- `Scaffold`, `Accordion`, `Alert`, `Breadcrumb`, `Card`, `CardImage`, `Collapsible`, `OutlinedContainer`
- `Table`, `Timeline`, `Tree`, `Window`, `Stepper`, `Steps`, `Resizable`, `StageContainer`
- Patched flex: `Row`, `Column`, `Flex`, `Expanded`, `Flexible`, `Stack`, `Positioned`

Controls
- Buttons: `Button`, `PrimaryButton`, `SecondaryButton`, `OutlineButton`, `GhostButton`, `LinkButton`,
  `TextButton`, `DestructiveButton`, `IconButton`, `ButtonGroup`
- Other: `Clickable`, `Command`, `Scrollbar`, `ScrollView`

Forms
- Inputs: `TextField`, `TextArea`, `Input`, `FormattedInput`, `InputOTP`, `PhoneInput`, `ImageInput`
- Selectors: `Select`, `Autocomplete`, `Radio`, `RadioGroup`, `Checkbox`, `Switch`, `Slider`
- Pickers: `DatePicker`, `TimePicker`, `ItemPicker`, `MultipleChoice`, `ColorPicker`
- Form infra: `Form`, `FormField`, `Validated`, `StarRating`, `ChipInput`, `ObjectInput`, `Sortable`

Display
- `Avatar`, `Badge`, `Chip`, `Calendar`, `Carousel`, `CodeSnippet`, `Divider`, `DotIndicator`
- `CircularProgressIndicator`, `LinearProgressIndicator`, `Progress`, `Skeleton`
- `KeyboardShortcut`, `NumberTicker`, `Chat`

Navigation
- `NavigationBar`, `NavigationRail`, `NavigationSidebar`, `NavigationItem`, `NavigationButton`
- `Tabs`, `TabList`, `TabContainer`, `TabPane`
- `Pagination`, `Breadcrumb`, `Subfocus`, `Switcher`

Overlay + Menus
- `Dialog`, `AlertDialog`, `Drawer`, `Popover`, `HoverCard`, `Tooltip`, `Toast`, `Overlay`
- `ContextMenu`, `DropdownMenu`, `Menu`, `MenuBar`, `NavigationMenu`, `Popup`

Icons
- `LucideIcons`, `BootstrapIcons`, `RadixIcons`, plus `Icons` re-exported from Material

## Material -> Shadcn Flutter Mapping (common replacements)

App + Theme
- `MaterialApp` -> `ShadcnApp`
- `ThemeData` -> `ThemeData` (from shadcn_flutter)
- `Theme.of(context)` -> `Theme.of(context)` (shadcn Flutter Theme)

Scaffold + App Bar
- `Scaffold` -> `Scaffold`
- `AppBar` -> use `Scaffold(headers: [...])` (build a custom header row), or `ScaffoldBarData`

Buttons
- `ElevatedButton` -> `PrimaryButton`
- `OutlinedButton` -> `OutlineButton`
- `TextButton` -> `TextButton`
- `IconButton` -> `IconButton`
- `FloatingActionButton` -> `PrimaryButton` or `Button` with icon (no direct FAB)

Inputs + Forms
- `TextField` -> `TextField`
- `TextFormField` -> `TextField` + `Form`/`FormField`
- `DropdownButton` / `DropdownButtonFormField` -> `Select`
- `Checkbox` -> `Checkbox`
- `Switch` -> `Switch`
- `Radio` -> `Radio` / `RadioGroup`
- `Slider` -> `Slider`
- `DatePicker` -> `DatePicker`
- `TimePicker` -> `TimePicker`
- `Autocomplete` -> `Autocomplete`

Dialogs + Overlays
- `showDialog` + `AlertDialog` -> `Dialog` / `AlertDialog`
- `BottomSheet` -> `Drawer` or `Overlay`
- `Tooltip` -> `Tooltip`
- `SnackBar` -> `Toast`

Navigation
- `BottomNavigationBar` -> `NavigationBar`
- `NavigationRail` -> `NavigationRail`
- `TabBar` + `TabBarView` -> `Tabs`, `TabList`, `TabPane`
- `Breadcrumbs` -> `Breadcrumb`
- `Pagination` -> `Pagination`

Display
- `Card` -> `Card`
- `Chip` -> `Chip`
- `Divider` -> `Divider`
- `CircularProgressIndicator` -> `CircularProgressIndicator`
- `LinearProgressIndicator` -> `LinearProgressIndicator`
- `DataTable` -> `Table`

## Notes

- Many class names match Material but are redefined by Shadcn Flutter. Avoid importing `material.dart` to
  prevent collisions.
- For anything missing above, look for a component with the same name under the export list in
  `lib/shadcn_flutter.dart` and verify the widget class in the referenced file.
