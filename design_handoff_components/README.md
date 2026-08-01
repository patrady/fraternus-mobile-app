# Handoff: Fraternus Onboarding — Shared Components

## Overview
Reusable UI pieces built while prototyping the Fraternus app's first-launch/onboarding flow (splash, sign in/up, role selection, guardian wizard, summary). This package extracts the components that recur across those screens so they can become permanent entries in the Fraternus Design System and be rebuilt as real Flutter widgets, organized into a **Widget Book** (Flutter's component-catalog tool, analogous to Storybook).

## About the Design Files
The files in this bundle are **design references written in HTML/JSX** (a web prototyping tool), not production code to copy directly. `components-source.jsx` is a flattened, annotated extraction of the shared components — not runnable Flutter. The task is to **recreate each component as a Flutter widget** in the target codebase, matching the visual spec below exactly, then register each in the Widget Book with its states/variants as separate stories.

## Fidelity
**High-fidelity.** Colors, type, spacing, radii, and states below are exact values pulled from the live design tokens (`tokens/colors.css`, `tokens/typography.css`, `tokens/spacing.css` in the Fraternus Design System). Build pixel-accurate widgets, not approximations.

## Relationship to the base Design System
Four components used throughout (`Button`, `Input`, `Select`, `Checkbox`) already exist in the Fraternus Design System bundle — implement/confirm those first if the Flutter package doesn't have them yet, since every component below is composed on top of them. Everything else listed here is **new**, invented during onboarding and not yet formalized in the design system.

---

## Components

### 1. PrimaryButton
**Purpose:** main call-to-action on every screen footer (Continue, Sign In, Send Reset Link, Let's Get Started).
**Why not the DS `Button`:** the base `Button` has no full-width/centering override, so onboarding reimplements its primary style directly at 100% width.
**Variants:** `size`: `lg` (default) | `sm`. `iconRight`: appends a trailing arrow (→). `disabled` state.
**Spec:**
- Full width, `box-sizing: border-box`, min-height 44px (`--tap-target-min`)
- Background `--accent-primary` (`#c66737`), text `#fff`
- Label: Oswald 600, uppercase, letter-spacing `--tracking-button` (0.03em); 16px at `lg`, 15px at `sm`
- Padding: `18px 32px` at `lg`, `15px 26px` at `sm`
- Border radius `--radius-sm` (6px), no border
- Disabled: opacity 0.5, `cursor: not-allowed`
- No hover-lift/shadow — per brand, only a color darken on press (`--accent-primary-hover` / `#a8542a`)

### 2. SecondaryButton
**Purpose:** lower-emphasis full-width actions — "Cancel", "Add Child", "I don't have any kids".
**Spec:**
- Full width, white background (`#fff`), 1px solid `--border-subtle` (`#e2d6c3`)
- Label: Oswald 600 13px, uppercase, letter-spacing 0.03em, color `--color-forest-green` (`#0b2b25`)
- Padding `14px`, radius `--radius-sm` (6px), min-height 44px
- Optional leading icon (e.g. `plus`), gap 8px
- Disabled: opacity 0.5

### 3. LinkButton
**Purpose:** tertiary text actions — "Forgot Password?", "Resend Code", "Don't have an account? Create an account".
**Spec:**
- No background/border, padding `10px 0`
- Oswald 600 13px, uppercase, letter-spacing 0.03em, underline (offset 3px)
- `tone` variant controls color: `muted` → `--text-on-light-muted` (`#4a5651`), `brand` → `--color-forest-green`, `white` → `#fff` (for dark screens)
- `align`: left or center depending on context

### 4. FieldLabel
**Purpose:** label above every form input (Email, Password, First Name, Chapter, etc).
**Spec:** Oswald 700 12px, uppercase, letter-spacing 0.05em, color `--text-on-light-muted`, `margin-bottom: 6px`.

### 5. ScreenHeader
**Purpose:** top bar on every stacked screen — back chevron + uppercase screen title ("Create Account", "Sign In", "Reset Password").
**Spec:**
- Row, gap 4px, padding `18px 16px 6px`
- Back button: 22px chevron-left icon, no background, min tap target 44×32
- Title: Oswald 700 20px, uppercase, color `--color-forest-green`

### 6. ScreenShell
**Purpose:** the per-screen layout wrapper — full-height column with a 56px top safe-area inset, a scrollable body, and an optional pinned footer (for the primary/secondary button stack).
**Spec:**
- `dark` variant: background `--surface-dark` (`#0b2b25`) for splash/welcome; default is `--surface-card-dim` (`#f6f0e6`)
- Footer padding `14px 16px calc(14px + 16px)`; footer background matches body except transparent on dark screens
- Body scrolls independently (`overflow: auto`) so the footer stays pinned

### 7. StepProgress
**Purpose:** segmented progress bar at the top of each guardian sign-up wizard step (email → verify → password → name → attendance → kids → summary = 7 total).
**Spec:**
- Row of equal-width segments, gap 6px, height 4px, radius 2px
- Filled segments (`i < step`): `--accent-primary`; unfilled: `--border-subtle`
- Horizontal padding 16px

### 8. IconBadgeCircle
**Purpose:** centered circular icon badge used for confirmation/status moments — "Check Your Email" (circle-check), "We Love The Enthusiasm" (circle-exclaim), "You're All Set" (party-popper).
**Spec:**
- Default size 56×56, border-radius 50%
- `dark` (default true): fill `--surface-dark`, icon tone white, 28px icon
- Light variant: fill `--surface-card-dim`, icon tone default (ink), used for the "locked" state at larger 56px icon size

### 9. SelectableCard
**Purpose:** role-selection cards on the "Which best describes you?" screen (Parent or Volunteer / Brother).
**Spec:**
- White card, 2px border: `--accent-primary` when selected, `--border-subtle` otherwise; radius `--radius-lg` (12px); padding `18px 16px`; margin-bottom 14px
- Leading 44px circular icon chip: filled `--accent-primary` + white icon when selected, else `--surface-card-dim` + default-tone icon
- Title: Oswald 700 16px uppercase, `--color-forest-green`; description: `--text-small` (Nunito Sans 14px), `--text-on-light-muted`
- `muted` variant (used for the locked "Brother" option): no card background/border, same content — signals reduced emphasis/disabled without fully hiding the option

### 10. InfoCard
**Purpose:** summary/list row for a person — used for added children in the wizard and for "You" / "Your Children" in the final summary screen.
**Spec:**
- White card, 1px `--border-subtle` border, radius `--radius-lg`, padding `14px 16px`, margin-bottom 12px
- Optional 40px circular initials avatar: `--color-forest-green` fill, white Oswald 700 15px initials
- Title: Nunito Sans 600 16px, `--color-ink`; subtitle: `--text-small`, `--text-on-light-muted`
- Optional role badge (e.g. "Captain"): small pill, `--accent-primary` fill, white Oswald 700 11px uppercase label, radius `--radius-sm`, padding `4px 10px`
- Optional trailing remove (×) button, 44px tap target

### 11. FormCard
**Purpose:** inline "add child" form panel — wraps a set of labeled fields with a Cancel/Save button row.
**Spec:**
- White card, 1px `--border-subtle` border, radius `--radius-lg`, padding 16px, margin-bottom 16px
- Footer row: `SecondaryButton` ("Cancel") + primary-filled Save button, each `flex: 1`, gap 10px
- Save button disabled (opacity 0.5) until required fields are filled

---

### 12. DangerButton
**Purpose:** destructive full-width outline action — "Remove Child", "Log Out".
**Spec:** same shape as SecondaryButton (white bg, 1px `--border-subtle`, radius `--radius-sm`, padding 14px) but label color `--color-error` (`#a8402c`).

### 13. Avatar
**Purpose:** circular initials avatar — profile row, kid rows, "others attending" list.
**Spec:** circle, fill `--color-forest-green`, white Oswald 700 text sized at ~36% of the circle diameter. Sizes observed: 34px (attendee list), 40px (default/list rows), 72px (profile header).

### 14. BottomTabBar
**Purpose:** primary 4-item app navigation (Today / Guide / Challenge / Events), pinned to the bottom of every authenticated screen.
**Spec:**
- Dark bar, `--surface-dark` background, 1px top hairline `rgba(255,255,255,0.08)`, padding-top 10px, padding-bottom 30px (safe area)
- Each item: icon (24px) + Oswald 600 11px uppercase label, gap 5px, min-height 44px, flex:1
- Active: icon tone terracotta, label `--accent-primary`, opacity 1; inactive: white icon at 62% opacity, label `rgba(205,218,213,0.62)`
- No pill/background behind the active icon — color/opacity is the only active signal

### 15. PersonTabs
**Purpose:** segmented text-tab switcher for the household member in view (You / Jack / Thomas) — appears on Today, Guide, and Challenges. **Distinct from BottomTabBar**: underline indicator instead of icon+color, plus a per-person completion status icon.
**Spec:**
- Row, gap 22px, bottom border `--border-subtle` under the whole row
- Label: Oswald 600 14px uppercase, letter-spacing `--tracking-button`; active `--color-forest-green` with a 3px `--accent-primary` underline; inactive `--text-on-light-muted` with transparent underline
- Trailing status icon per tab: `circle-check` (success tone) when done, `circle-dashed` (terracotta tone) when in progress, nothing when not started
- Padding `12px 2px`, min-height 44px

### 16. ListRow
**Purpose:** generic row shape underlying ProfileRow, TodoRow, and the "Others Attending" rows — leading icon/avatar, label + optional sublabel, trailing chevron or control.
**Variants:**
- `bordered` (default true): white card, 1px `--border-subtle`, radius `--radius-lg`, padding `14px 16px`, margin-bottom 12px — used in Profile/Kids lists
- `bordered=false`: no card, just a `11px 0` padded row — used for TodoRow inside a card and for plain in-list rows (bottom border between rows handled by the parent list)
- `trailing`: swaps the default chevron for a custom control (e.g. status icon, Edit button, remove ×)

### 17. RsvpToggle
**Purpose:** two-option pill toggle for event RSVPs (Going / Can't), tri-state color.
**Spec:** two pill buttons, gap 8px, each `8px 14px` padding, radius `--radius-sm`, min-height 36. Selected "Going": `--color-success` fill; selected "Can't": `--color-error` fill; unselected: white with `--border-subtle` border, muted text.

### 18. Pill (badge/tag)
**Purpose:** small filled label for role/category/status — "Captain", "Entire Chapter", "New", relative-time ("In 2 hours"), "Cancelled".
**Spec:** pill radius (`--radius-pill`), Oswald 700 11px uppercase, letter-spacing 0.04em, padding `5px 12px`, white text. `tone`: `dark` (forest green fill — role/scope badges), `primary` (terracotta fill — "New" w/ sparkle icon), `tan` (tan-dim fill). A text-only variant (no fill, just colored uppercase label) is used for "Cancelled" (error-colored) and countdown labels.

### 19. StreakBanner
**Purpose:** "N Day Streak" — dark rounded bar with flame icon, sits above the daily reading content on the Guide tab.
**Spec:** `--surface-dark` background, radius `--radius-md`, padding 14px, centered row, Oswald 700 13px uppercase white text, flame icon in terracotta tone.

### 20. RepDots
**Purpose:** small circular indicators showing which reps of a weekly challenge are complete (used compactly inside Past Challenge cards).
**Spec:** 9px filled/unfilled dots (view-only) or 20px tappable circles (`editable` mode, used to retroactively mark a rep done) — filled circle `--color-forest-green`, unfilled white/`--border-subtle` outline.

### 21. ContentCard
**Purpose:** general-purpose bordered card for eyebrow+title+body content — powers SectionCard, QuoteCard, and EventCard's text pattern.
**Spec:** white card, 1px `--border-subtle`, radius `--radius-lg`, padding `18px 18px 20px`, margin-bottom 16px. Optional eyebrow (Oswald 700 13px uppercase, `--accent-primary`), optional title (Oswald 600 18px, forest green), optional italic subtitle/quote line, and an optional heart-icon like toggle (outline default-tone / filled error-tone) in the top-right.

### 22. DarkFeatureCard
**Purpose:** dark celebratory/result card — "Challenge Complete!", "Your Temperament". Centered icon, eyebrow, big value line, optional body copy, optional outlined CTA.
**Spec:** `--surface-dark` background, radius `--radius-lg`, padding `26px 20px 22px`, all content centered. CTA: transparent bg, `1px solid rgba(255,255,255,0.4)` border, white uppercase Oswald 600 12px text.

### 23. ContinuousProgressBar
**Purpose:** single animated fill bar for the temperament quiz (as opposed to StepProgress's discrete segments).
**Spec:** 6px track, `--border-subtle` background, `--radius-pill`; filled portion `--accent-primary`, width transitions 350ms ease.

### 24. JournalTextarea
**Purpose:** freeform multi-line entry — the "My Spade" daily reflection field. **Not yet a Design System component** — should be formalized as a DS `Textarea` alongside the existing `Input`.
**Spec:** same visual language as `Input` — 1px `--border-subtle` border, radius `--radius-sm`, `14px 16px` padding, Nunito Sans 15px, no resize handle, 4 rows default.

## Existing Design System components confirmed in use
`Radio` (temperament quiz, "My Sword" prompt), `Select` (chapter dropdowns), `Checkbox` (attendance step), `Switch` (reminder toggles), `Tag` (Primary/Secondary temperament tags), `Toast` (reading-complete confirmation), `Dialog` (remove-child / log-out confirmations) — all used as-is from the DS bundle; no restyling needed. `Textarea` is the one gap (see JournalTextarea above).

## Design Tokens
Pull these directly from the design system rather than hardcoding new values in Flutter (map to `ThemeData`/a `FraternusTokens` class):

**Colors**
- Forest green `#0b2b25` (surfaces, headline text) / deep `#071f1a` / mid `#123a32`
- Terracotta `#c66737` (primary accent/CTA) / dark `#a8542a` (hover/press)
- Tan `#c9a876` (secondary accent, eyebrow emphasis)
- Parchment `#ece3d9` / parchment-dim `#f6f0e6` (light surfaces)
- Ink `#16231f` (body text) / muted `#4a5651`
- Border `#e2d6c3` / border-on-dark `rgba(255,255,255,0.16)`
- Semantic: success `#4f7a52`, error `#a8402c`, warning `#c9a876`

**Typography**
- Display font: Oswald (500/600/700) — all headlines, eyebrows, buttons, uppercase
- Body font: Nunito Sans (400/600/700) — body copy, field values
- Scale: h1 700/76px, h2 700/34px, h3 600/22px, h4 600/18px, eyebrow 600/13px (letter-spacing 0.1em), button 600/15px (letter-spacing 0.03em), body-lg 400/19px, body 400/16px, small 400/14px, caption 400/13px

**Spacing / radius**
- Space scale: 4, 8, 16, 24, 32, 44, 60, 90, 100px
- Radius: xs 4px, sm 6px (buttons/inputs), md 10px (nested cards), lg 12px (outer cards), pill 999px
- Shadows: card `0 12px 28px rgba(11,43,37,0.14)`, popover `0 16px 40px rgba(11,43,37,0.28)` — reserved for dialogs/toasts only, never everyday cards
- Minimum tap target: 44px

## States & Motion
- Disabled: 50% opacity, no pointer, everywhere (no separate disabled color)
- Hover/press: terracotta darkens to `--accent-primary-hover`; outline/link buttons dim to 75% opacity — no lift, scale, or shadow growth
- No bounce/spring easing; the only observed motion is the splash screen's fade+translateY-up entrance (700ms ease, text at 0ms, logo at +300ms)
- No border/shadow on dark-surface cards; hairline border instead of shadow on light-surface cards

## Assets
- `assets/fraternus-logo-hz.svg` — horizontal Fraternus wordmark (cream fill), used on the welcome screen
- `icons.jsx` — inline SVG icon set (Lucide-derived stroke icons) used across every component above: `chevron-left`, `circle-check`, `circle-exclaim`, `party-popper`, `x`, `plus`, `compass`, `circle-user`. Flutter should source equivalent icons from `lucide_icons` (or commission real Fraternus iconography) rather than re-embedding raw SVG paths.

## Screenshots
Real rendered states from the prototype, in `screenshots/`, for visual reference alongside the specs above:
- `01-today-home.png` — Today tab: greeting, virtue focus card, PersonTabs, PersonTodoCard (ListRow), StreakBanner-adjacent divider
- `02-guide-reading.png` — Guide tab: PersonTabs w/ status icons, StreakBanner, ContentCard (Identity/Wisdom sections)
- `03-challenges.png` — Challenges tab: ChallengeIntroCard, PersonTabs, ChallengeCard (accept/rep state)
- `04-events-list.png` — Events tab: EventCard list w/ Pill badges (soon/cancelled)
- `05-event-detail-rsvp.png` — Event detail: scope Pill, RsvpToggle rows, "Others Attending" ListRow/Avatar
- `07-profile.png` — Profile tab: ListRow (avatar/icon leading), DarkFeatureCard (temperament), DangerButton
- `08-guide-quiz-question.png` — Temperament quiz: ContinuousProgressBar, Radio options
- `09-guide-quiz-result.png` — Temperament quiz result screen
- `10-auth-welcome.png` — Welcome screen: PrimaryButton, LinkButton
- `11-auth-role-select-empty.png` — Role screen, no selection
- `12-auth-role-selected.png` — Role screen: SelectableCard selected/muted states
- `13-auth-email-step.png` — Guardian wizard: ScreenHeader, StepProgress, FieldLabel + Input

## Files
- `components-source.jsx` — flattened reference source for all 24 components above, extracted from the app screens
- `icons.jsx` — the icon helper referenced by every component
- `assets/fraternus-logo-hz.svg` — logo asset
- `tokens/colors.css`, `tokens/typography.css`, `tokens/spacing.css` — the actual Fraternus Design System token source files (raw CSS custom properties, not just the prose summary above)
- `tokens/styles.css` — root stylesheet that imports/composes the token files

## Suggested Widget Book structure
One story group per component above (24 total), with a story per variant/state called out in its spec. Use the token values above to seed a shared Flutter theme so every story pulls from one source of truth instead of one-off hex/style values per widget.
