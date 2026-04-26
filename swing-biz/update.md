# Swing-BIZ Arena Update

## Current Focus

We are building the Arena workspace for Swing-BIZ. The current area is Arena Profile > Units.

## Product Decisions Made

- Business/profile level information should live on the profile selection/details page, not inside arena profile.
- Arena profile is arena-level only.
- A user can have multiple arenas.
- Add Arena flow should be progressive:
  - Arena type
  - Basic details
  - Location
  - Detailed setup continues later from arena profile.
- Unit setup is for Cricket first.
- User should choose one arena type before units.
- Unit name should be generated from unit type/label, not manually typed.
- If multiple same units exist, user should enter quantity and create all in one tap.
  - Example: quantity 2 with label `Net` creates `Net 1`, `Net 2`.
- For nets, user should capture net type like turf, cemented, or mat.
- Units support multiple prices:
  - per hour
  - 4 hours
  - 8 hours
  - full day
  - weekend multiplier
- Unit photos should support max 3 photos.
- Add-ons are per unit:
  - Bowling machine
  - Arm thrower
  - Scorer
  - Coaching
  - custom add-ons

## Backend Changes Done

Backend repo: `/Users/sangwanhq/dhandha/swing/swing-backend`

Changed files:

- `packages/db/prisma/schema.prisma`
- `packages/db/prisma/migrations/20260425_arena_unit_customization/migration.sql`
- `apps/api/src/modules/arenas/arena.routes.ts`
- `apps/api/src/modules/arenas/arena.service.ts`
- `apps/api/src/app.ts`
- `.env.example`

Backend now supports:

- Custom unit fields:
  - `unitTypeLabel`
  - `netType`
  - `photoUrls`
  - `price4HrPaise`
  - `price8HrPaise`
  - `priceFullDayPaise`
  - `weekendMultiplier`
  - `slotIncrementMins`
- Per-unit add-ons:
  - `unitId`
  - `addonType`
  - `name`
  - `description`
  - `pricePaise`
  - `unit`
  - `isAvailable`
- Unit APIs:
  - `POST /arenas/:id/units`
  - `PATCH /arenas/u/:unitId`
  - `DELETE /arenas/u/:unitId`
- Add-on APIs:
  - `GET /arenas/:id/addons?unitId=...`
  - `POST /arenas/:id/addons`
  - `PATCH /arenas/addons/:addonId`
  - `DELETE /arenas/addons/:addonId`
- Media upload:
  - `POST /media/upload`
  - `POST /admin/media/upload`
- Supabase storage envs added:
  - `SUPABASE_URL`
  - `SUPABASE_SERVICE_ROLE_KEY`
  - `SUPABASE_STORAGE_BUCKET`

Backend verification done:

- `npm run db:generate`
- `npm run build --workspace=@swing/db`
- `npm run build --workspace=@swing/api`

All passed after rebuilding workspace packages.

## Frontend Changes Done

Frontend repo: `/Users/sangwanhq/dhandha/swing/swing-biz`

Changed files:

- `lib/features/arena/screens/arena_profile_page.dart`
- `../packages/flutter_host_core/lib/src/contracts/host_path_config.dart`
- `../packages/flutter_host_core/lib/src/features/arena_booking/domain/arena_booking_models.dart`
- `../packages/flutter_host_core/lib/src/repositories/host_arena_repository.dart`

Arena Profile page:

- Removed business/owner/payment details from arena profile.
- Arena profile uses tabs:
  - Overview
  - Units
  - Rules
- Location and media are inside Overview.
- Facilities are inside Overview.
- Tabs were enlarged.

Units tab:

- Static helper text was removed.
- Empty state is now minimal with only an icon tile.
- Unit cards show:
  - photo
  - name
  - unit type/label
  - net type
  - slot duration range
  - pricing chips
  - weekend multiplier chip
  - add-on count
- Unit card menu supports:
  - Edit
  - Remove

Add/Edit Unit UI:

- Uses a progressive bottom-sheet flow.
- Steps:
  - Unit type
  - Unit details
  - Pricing and slots
  - Photos
  - Add-ons
- Unit name field was removed.
- Add flow supports quantity.
- Editing existing unit does not show quantity.
- Unit photos upload through `/media/upload`.
- Add-ons can be created/updated/deleted per unit.

Shared frontend model/repository:

- `ArenaUnitOption` now reads:
  - `unitTypeLabel`
  - `netType`
  - `sport`
  - `description`
  - `photoUrls`
  - all price slab fields
  - `weekendMultiplier`
  - slot duration fields
  - nested `addons`
- `ArenaAddon` now reads:
  - `unitId`
  - `addonType`
  - `description`
  - `isAvailable`
- Repository now supports:
  - create/update/delete unit
  - create/update/delete addon

Frontend verification done:

- `dart analyze lib/features/arena/screens/arena_profile_page.dart`
- Result: `No issues found!`

## Important Current Issue / Next Start Point

Start from this request:

> Show the calculated weekend price after weekend multiplier.

Needed change:

- In Add/Edit Unit > Pricing step:
  - After `Weekend multiplier`, show calculated weekend hourly price.
  - Formula:
    - `weekend hourly price = per hour price * weekend multiplier`
  - Example:
    - Per hour: `1000`
    - Weekend multiplier: `1.5`
    - Show: `Weekend price: Rs 1,500/hr`

Also update Unit card:

- Instead of only showing `Weekend x1.5`, show actual weekend price if multiplier is not `1`.
  - Example: `Weekend Rs 1,500/hr`

Implementation pointer:

- File: `lib/features/arena/screens/arena_profile_page.dart`
- Areas:
  - `_UnitCard` around `priceRows` and `_SmallPill('Weekend x...')`
  - `_UnitEditorSheetState._pricingStep()`
  - Add listener or use `ValueListenableBuilder` / local `setState` on price and multiplier fields.

## Notes

- Do not move business details back into arena profile.
- Keep Unit UI progressive and minimal.
- Keep quantity-based unit creation.
- For now, maps are not integrated. Pincode lookup exists in Add Arena.
- Media upload uses Supabase Storage SDK backend route, not direct S3 from Flutter.
