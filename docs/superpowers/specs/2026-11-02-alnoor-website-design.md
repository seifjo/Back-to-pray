# AlNoor marketing landing page — design and build plan

Date: 2026-11-02
Status: awaiting approval
Scope: a two-language static landing page for the `back_to_prayer` Flutter app (published name **AlNoor | النور**), living in `site/` inside this repo.

---

## 1. Decisions already locked

| Question | Decision |
|---|---|
| Primary job | Marketing landing page — explain the app and drive install |
| Stack | Hand-built static HTML/CSS/JS, no framework, no build step |
| Home of files | `site/` inside this Flutter repo |
| Languages | Bilingual EN + AR, approach **A**: two mirrored HTML documents |
| App visuals | CSS phone mockups rebuilt from the real screen code |
| Download CTA | `https://github.com/seifjo/Back-to-pray/releases` (confirmed public) |

Approach A means: `index.html` is English/LTR, `ar.html` is Arabic/RTL, each with correct `lang` and `dir` on the `<html>` element, cross-linked with `hreflang`, sharing one stylesheet and one image set. The language toggle is a plain link, so the page works with JavaScript disabled.

## 2. File layout

```
site/
  index.html          English page
  ar.html             Arabic page (mirrored structure)
  styles.css          shared design system + layout, [dir=rtl] overrides
  site.js             progressive enhancement only (nav, reveal, FAQ)
  assets/
    logo.svg          rebuilt wordmark lockup from assets/images/app_icon.png
    og-en.png         1200x630 social card, English
    og-ar.png         1200x630 social card, Arabic
    favicon.svg
  robots.txt
  sitemap.xml
```

No bundler, no `node_modules`, no dependency install. `python -m http.server` or any static host serves it as-is. Nothing outside `site/` is created except this document.

## 3. Content, section by section

Both pages carry identical sections in identical order. English copy is written here; Arabic is authored to read naturally in Arabic, not machine-translated from the English sentences.

### 3.1 Header (sticky)

Logo lockup (النور with "AlNoor" beneath), language toggle `عربي`, and a `Get the app` button that anchors to section 9. On scroll past the hero it gains a backdrop and bottom border. Height 64px desktop, collapses to logo + toggle + icon-only download under 640px.

### 3.2 Hero

- Eyebrow: `Prayer · Qur'an · Adhkar · Qibla`
- Headline (EN): **Come back to your prayer — without leaving your phone.**
- Sub (EN): AlNoor puts accurate prayer times, the full Qur'an with recitation, adhkar, and a private worship tracker in one app that works offline and never asks you to sign up.
- Primary CTA: `Download for Android` → Releases page. Secondary: `See what's inside` → section 4.
- Supporting line: `Free · No account · No ads · Android 7.0+`
- Right: phone mockup #1 (prayer times, section 5.1), tilted 3°, with a soft radial glow behind it in the primary teal.

The `No account` claim is true in the sense that no sign-up exists — the app creates an anonymous Firebase ID on launch for Qur'an Race only. The hero states `No account` and section 7 explains that anonymous ID precisely. That is the one place where marketing brevity touches a technical fact, so it is called out rather than glossed.

### 3.3 Daily core band

Four tiles for the bottom-nav destinations, because these are what a user touches five times a day: Prayer times (`الصلاة`), Qur'an (`القرآن`), Adhkar (`الأذكار`), Qibla (`القبلة`). Each tile: icon, name in both scripts, one line of copy.

### 3.4 Feature groups — the app's own taxonomy

`lib/data/more_features_catalog.dart:70-74` already groups features as Worship / Knowledge / Tools. The site reuses those three groups and those fourteen display names, so a user moving from page to app sees the same labels.

**Worship** — Digital Tasbeeh, Dua Library, Worship Tracker, Islamic Journeys, Quran Race, Achievements.
**Knowledge** — Hadith Library, Names of Allah, Islamic Quiz.
**Tools** — Hijri Calendar, Saved Library, Nasheed Library, Qibla.

Each item shows the catalog's own icon and its existing subtitle string (e.g. Worship Tracker: "A private daily checklist for goals you choose yourself." — `app_localizations.dart:147`). Per-feature accent colors come from the catalog table so tiles read as the app's, not as generic marketing.

No feature is listed that isn't wired to a real screen: all 14 "More" routes and 4 nav tabs resolve to implemented widgets in `more_features_screen.dart:43-58`. Nothing on this page is aspirational.

### 3.5 Screens gallery

Four phone mockups in a horizontal scroll on narrow screens, a 4-up row on wide: prayer times (5.1), Qur'an reader (5.2), Qibla compass (5.3), Achievements streak + level ring (5.4). Caption under each, EN/AR.

### 3.6 Craft band

Four short columns on the details Muslim users actually notice: real RTL Arabic with Amiri Qur'anic type; six theme presets (Ocean, Sunset, Forest, Purple, Gold, Moonlight) plus light mode, shown as clickable-to-preview swatch chips using the exact background/surface/primary/secondary values from `getThemeById` (`app_theme.dart:133-174`); adjustable Arabic font size (default 26px, clamp 20–40); Hijri date adjustment for regions where the calendar runs a day off.

### 3.7 Privacy band — what actually leaves the device

A two-column table, computed from the code rather than from intent:

- **Stays on the device:** prayer times (calculated locally by the `adhan` package from your coordinates — `prayer_time_service.dart:1`), Qibla bearing and sensor readings (`qibla_service.dart:1` is pure `dart:math` plus `geolocator`), the entire Qur'an text (`assets/quran/uthmani.json`, 1.38 MB bundled), the sixteen nasheeds (`assets/Anashed/`, bundled — `nasheed_catalog.dart:3`), your adhkar progress, goals, streaks, badges and saved items (Hive/SharedPreferences), location (read locally, never sent to a server: no URL in `lib/` carries a coordinate).
- **Crosses the network:** Qur'an recitation audio from `cdn.mp3quran.net` and `cdn.islamic.network`, with the reciter catalogue from `mp3quran.net`; optional hadith collections beyond the bundled `assets/hadith/library_seed.json` from `cdn.jsdelivr.net` (fawazahmed0/hadith-api), cached to disk afterwards; Qur'an Race room state through Firebase Realtime Database under an **anonymous** auth ID created at launch (`main.dart:86`), which is the only identifier the app holds.
- **Absent by construction:** no advertising SDK, no analytics SDK, no crash reporter, no account, no email, no password. Verified: zero matches for `admob`, `analytics`, `crashlytics` in `pubspec.yaml` and `lib/`.
- One-line pointer to a full privacy policy, deferred (section 11 open question 3).

### 3.8 FAQ

Seven items, `<details>` elements so they work without JS: why an APK rather than the Play Store; is it really free; what works offline; minimum Android version (7.0 / API 24 — `android/app/build.gradle.kts:30` sets `minSdk = flutter.minSdkVersion`, which is 24 in the local Flutter SDK; `flutter_launcher_icons.min_sdk_android: 21` is only the icon generator's own setting and does not ship); how updates arrive (Releases page); is my location stored or uploaded; is there an iOS version.

### 3.9 Download CTA and footer

Repeat of the Releases button with version `1.0.1+5` and a one-line install note (allow unknown sources on Android). Footer: app name in both scripts, links to GitHub repo, Releases, FAQ, language toggle, and the contact route from open question 2.

## 4. Visual system

Taken directly from `lib/core/theme/app_theme.dart` so the page is the app's brand, not an interpretation of it.

| Token | Value | Use |
|---|---|---|
| primary | `#0D7377` | buttons, links, active state |
| accent cyan | `#14FFEC` | values on dark, selected labels |
| accent gold | `#D4AF37` | Qur'an pill, Names of Allah, XP |
| background | `#1A1A2E` | page base (dark-first) |
| surface | `#16213E` | cards, mockup chrome |
| light bg / surface | `#F6F3EE` / `#FFF8F8` | light-mode theme swatches in the craft band |
| ink (light) | `#1C2430` | body text on light |
| text secondary | `#B0B0B0` | captions on dark |
| error | `#B42318` | warnings only |
| prayer Fajr/Dhuhr/Asr/Maghrib/Isha | `#6B5B95` / `#88B04B` / `#FF6F61` / `#5B5A56` / `#45B8AC` | mockup 1 rows |

Fonts: `Amiri` (Google Fonts) for Arabic and Qur'anic display — the app's only custom font (`app_theme.dart:31-36`); Latin uses the system stack (`system-ui, -apple-system, Segoe UI, Roboto`) exactly as the app does. Latin text is never set in Amiri. Loading Amiri over the network is an accepted cost of brand fidelity; `font-display: swap` keeps text visible meanwhile.

Shapes and spacing mirror the app: cards radius 16, hero card radius 20, buttons radius 12 at 48px min height, 16px gutters. Radii are the app's, so mockups and page share one geometry language.

RTL: `ar.html` sets `dir="rtl"` and the stylesheet uses logical properties (`margin-inline-start`, `padding-inline-end`, `inset-inline-start`) throughout, so the Arabic page is a true mirror rather than a set of `float: right` patches. One `[dir="rtl"]` block exists only for the mockup tilt and compass rotation, which must invert. The Qibla mockup additionally has a real reason to invert: in the app the XP bar grows from the right in Arabic (`level_badge_widget.dart:105-135`), so the achievements mockup mirrors its progress direction.

## 5. Mockup specifications

Each mockup is a 300×620 device frame: `#16213E` surface, radius 36, 2px bezel, 44px notch strip, `#1A1A2E` screen. Markup is semantic `div`/`span`, no images — text stays selectable and crisp on any display, and it renders in both languages without regenerating assets.

**5.1 Prayer times** — centered `Prayer times` bar with three trailing icons (settings, calculator, refresh); hero card tinted with a `#5B5A56` → 70% Maghrib gradient, radius 20: `Next prayer` label at 70% white, `Maghrib` at 36px bold, `02 : 14 : 36` countdown with `Hours/Min/Sec` under each value, target time `6:42 PM` at 20px; `12-hour / 24-hour` segmented control; six rows — Fajr `5:12 AM`, Sunrise `6:38 AM`, Dhuhr `12:20 PM`, Asr `3:45 PM`, Maghrib `6:42 PM` (upcoming: 2px border in its own color, elevation, plus `Next`/`القادمة` label), Isha `8:05 PM`. Each row carries a 60×60 chip at 20% of the prayer color with the app's own icon (`wb_twilight`, `wb_sunny`, `light_mode`, `wb_cloudy`, `nightlight`, `nights_stay`). Bottom nav with five labeled destinations.

Deliberately omitted from the mockup because the real screen does not have them: a location line and a Hijri date row.

**5.2 Qur'an reader** — app bar with Arabic surah name `سورة الملك` and a 44px strip at `#0D7377` 15% holding `headphones`, `يُشغَّل: سورة الملك`, play and red stop icons; three ayah cards, each with bookmark and play icons on the left and a gold pill `الآية 3` (radius 20, gold text on gold 10% fill, 1px gold 30% border) on the right; ayah text in Amiri 26px, line-height 1.9, RTL and right-aligned; the bookmarked ayah filled `#0D7377` 10% with a 1px `#0D7377` 30% border.

Deliberately omitted: translation or tafsir. The reader renders Arabic only (`quran_screen.dart:675-750`), so the mockup shows Arabic only. Showing an English translation would advertise a feature the reader does not have.

**5.3 Qibla** — 280px dial on `#121A2B`, 3px `#0D7377` ring with a 12px blur glow, rotated so the gold `#D4AF37` triangle needle points at the gold `mosque` glyph pinned near the top; 8px gold center hub; status line `You are facing the Qibla` at 22px bold green; four stat rows — `Qibla bearing 118.4°`, `Heading 116.9°`, `Difference 1.5°`, `Accuracy ±4.0°`, values 18px bold right-aligned.

Deliberately omitted: a city name. The screen works in raw coordinates and never renders a place name.

**5.4 Achievements** — streak card, diagonal `#FF6B6B` → `#FF8E53` gradient, radius 20: `🔥 سلسلة الالتزام`, `64` at 64px bold, `أيام متتالية`, milestone track at 30% white with white fill and `64%`, footer `أطول سلسلة: 81 يوم`; level ring card: 80px ring, 6px stroke `#03A9F4` on `white10` track, 64px inner circle with radial gradient and glow holding `⚔️`, `مقاتل` in the level color at 20px bold, `المستوى 4`, 8px XP bar `cur 1 240 / next 2 000`; two badge tiles with rarity glow (`rare` `#2196F3`, `legendary` `#FFD700`), 64px emoji circle at 20% rarity fill, `+120 XP` pill; behind the whole screen, the app's eight-point-star pattern tile at 3% opacity (`islamic_motif.dart:11-43`).

Tab labels stay Arabic in the English mockup (`الإنجازات` / `إحصائيات`) because that is what the screen actually renders today (`achievements_screen.dart:51-52`) — a known app bug, not a site bug. Rendering it faithfully also gives the mockup value as a QA artifact.

## 6. Behavior and JavaScript

`site.js` is enhancement only; every section, both CTAs, and the language toggle exist in the HTML and work with JS off.

- IntersectionObserver adds a 240ms fade-and-rise to feature tiles and mockups; disabled entirely under `prefers-reduced-motion: reduce`.
- Sticky header gains its backdrop class on scroll.
- FAQ uses native `<details>`; JS only closes siblings.
- Screens gallery gets arrow-key and wheel horizontal paging on narrow viewports.
- No framework, no analytics, no cookies, no consent banner — consistent with the app's own no-tracking stance. If analytics is added later it needs a decision, not a default.

## 7. SEO, metadata, sharing

Per page: unique `<title>` under 60 characters, one `<h1>`, `description`, `canonical`, `og:` and `twitter:` tags pointing at the language-matched `og-*.png` card, `hreflang` pair (`en` → `index.html`, `ar` → `ar.html`, `x-default` → English), `lang` and `dir` correct on `<html>`, theme-color `#1A1A2E`. JSON-LD `SoftwareApplication`: name, operating system `Android`, application category `Lifestyle`, `offers.price` 0, `softwareVersion` 1.0.1. `robots.txt` allows all and names `sitemap.xml`.

The two `og-*.png` cards are the only raster assets. Both must carry the same lockup and a distinct headline per language; the Arabic one is laid out RTL, not the English one with Arabic pasted on.

## 8. Performance and accessibility budget

- Two requests for the critical path (HTML + `styles.css`), `site.js` and Amiri non-blocking.
- Page weight target under 300 KB per page excluding fonts, since mockups are markup rather than images.
- WCAG 2.1 AA contrast for all text; the app's own accent cyan `#14FFEC` fails on `#F6F3EE`, so cyan appears only on dark surfaces, and `#D4AF37` gold is never used for body text on light backgrounds.
- Full keyboard operability with a visible focus ring, skip-to-content link, one `h1` per page with no skipped heading levels, `alt`-free decorative mockups marked `aria-hidden` because they are illustrative chrome, and a real text description next to each gallery item so screen-reader users get the same information the mockup conveys visually.
- 320px to 1920px, no horizontal scroll at any width; Arabic type scales with the viewport because Amiri needs more x-height headroom than Latin.

## 9. Error and edge cases

- Broken or moved Releases link: the CTA is a plain anchor with `rel="noopener"`, so there is no JS layer that could mask a dead link, and the Phase 6 check curls the Releases URL and fails loudly if it returns anything but 200. A dead download button gets caught in verification rather than shipped.
- Amiri fails to load: the font stack falls back to `serif`, so Arabic stays legible in the system Arabic face.
- JS disabled: navigation, both CTAs, FAQ, and the language toggle all work.
- No iOS build: the footer and FAQ answer "is there an iOS version" honestly instead of shipping a dead App Store badge. This depends on open question 1.
- Old Android: the build floor is stated as "Android 7.0 or newer" (API 24, from `flutter.minSdkVersion`) rather than left implied.
- Licensing: the repo has no `LICENSE` file, so the site says the source is "published on GitHub" and never claims "open source", which would need a licence.
- Search engine crawler of the Arabic page: gets real `lang="ar"` `dir="rtl"` markup, never a translated-by-JS shell.

## 10. Verification plan

Nothing is "done" until these pass, and each result gets reported with its evidence rather than asserted:

1. Serve `site/` locally and open both pages in the browser.
2. Screenshot each page at 1440, 768 and 375 wide; confirm no overflow, no clipped mockup, header behaves.
3. Toggle EN ↔ AR from both directions and confirm the mirror: `dir`, alignment, tilt, and XP-bar direction all flip together.
4. Verify every claim on the page against a code location — the privacy band line by line, since it is the section most likely to be wrong.
5. Check contrast ratios for all text pairs and both og cards against their backgrounds.
6. Validate HTML, `sitemap.xml`, and `robots.txt`; curl the Releases URL and both canonicals for 200.
7. Load with JavaScript disabled and confirm full function, then again under `prefers-reduced-motion`.
8. Read the rendered Arabic page as Arabic — native phrasing, no translation smell — and fix anything that reads mechanically.

I cannot verify the page on a real device farm or confirm production SEO after deploy; I'll state those limits rather than imply coverage I don't have.

## 11. Open questions — answer or accept defaults

Defaults let the build start immediately; edits to this file before approval are the cheapest place to change any of them.

1. **Is there an iOS/TestFlight build?** Default: no — Android only, and the FAQ says so plainly.
2. **What contact route for feedback?** Default: a `mailto:` needs an address; otherwise GitHub Issues on the repo. I will not invent an email.
3. **Want a full standalone privacy policy page** (`site/privacy.html`, plus `ar`)? Recommended yes if this ever goes into a store listing; section 7 currently carries the substance.
4. **Domain.** Default: none assumed; canonical URLs are relative until a host is chosen, then one find-and-replace.
5. **Real screenshots later?** Default: ship mockups now, and swap in captured PNGs into the same frames whenever they exist.

## 12. Build order

Each phase leaves the site in a state that opens and renders; partial work is never broken work.

- **Phase 1 — skeleton and system (1 edit set).** Create `site/`, `styles.css` with the token table from section 4 as custom properties, the device-frame component, and `index.html` with all nine sections as empty landmarks. Verify: page renders, tokens applied, dark base correct.
- **Phase 2 — English content.** Hero, core band, feature groups from the catalog, craft band, privacy band, FAQ, footer copy. Verify: content matches `more_features_catalog.dart` names and the claims table has a code citation behind each line.
- **Phase 3 — mockups.** Build 5.1–5.4 against the screen code, iterating with the browser open, comparing each against the spec in section 5 rather than against my memory of the code. Verify: four frames render at all widths.
- **Phase 4 — Arabic page.** Write `ar.html` as native Arabic with `dir="rtl"`, add logical-property and `[dir=rtl]` rules, author `og-ar.png` and `og-en.png`. Verify: mirror check in section 10 step 3.
- **Phase 5 — enhancement and metadata.** `site.js` (reveal, sticky header, FAQ, gallery paging), `hreflang`/canonical/OG/JSON-LD, `robots.txt`, `sitemap.xml`. Verify: JS-off path still complete.
- **Phase 6 — audit and handoff.** Run the full section 10 list, fix what it finds, then report results with evidence and the deployment note (any static host, or `flutter`-free `python -m http.server` for local review).

Estimated scope: roughly 1 page per language at 400–500 lines of markup, one 800–1000 line stylesheet, one small JS file, two social cards. This is a focused landing page, not a multi-page site — and that is deliberate; a second page appears only if open question 3 says yes.

## 13. Out of scope

No Flutter app changes of any kind, including the Arabic-only achievements tab labels noticed in 5.4 — noted, not touched, unless you ask separately. No backend, no CMS, no analytics, no store listings, no domain purchase, no CI/CD. No design-system documentation site. This document is the only file written outside `site/`.

## 14. Phase 6 audit — what ran, what it found

Checks executed against `site/` on 2026-11-02, each with its evidence:

- **Markup integrity.** Tag-balance pass over both documents: zero unclosed tags, zero stray closers, zero implicit closes.
- **Responsive.** Real 375 and 768 CSS-px viewports (rendered inside same-origin iframes, because headless Chrome on this machine clamps the layout viewport to 485 px minimum): `scrollWidth - clientWidth = 0` for both languages at both widths. The only off-screen elements are gallery slides past the scroller edge, which is intended.
- **Progressive enhancement.** `class="no-js"` had been left on `<body>` while the inline head script removed it from `<html>`, so the reveal animation never ran and the `.no-js` fallback was permanently active. Fixed by moving the class to `<html>`. With scripts stripped from copies of both pages, the renders are byte-identical to the JS-enabled ones (0 differing pixels at 1440×9000), so no content depends on JS.
- **Reduced motion.** `--force-prefers-reduced-motion` renders are byte-identical to normal renders for both languages.
- **Contrast.** Every text/background pair on the page measured against WCAG 2.1 now clears 4.5:1. Six pairs failed on the first pass and were fixed: the Isha hero card (white on `#45b8ac` = 2.41 → `#2b7f78` = 4.76), the streak card gradient (2.27–2.78 → `#b03a2c`/`#c14e2a` = 6.02/4.78), the recitation strip's teal text (2.69 → `#2bb6bc` = 6.14, and the separate `[dir=rtl]` colour override deleted), the stop icon and strike-through red (`--error` `#b42318` → `#ff7a6e`, 5.95–6.71), and the rare-badge XP pill (`#2196f3` → `#64b5f6` = 5.32).
- **Arabic bidi.** `<bdi>` isolation plus `unicode-bidi: isolate` on the LTR islands (version tags, XP numbers, hostnames, `+500 XP` pills); the XP bar fill rule that mirrored to the wrong side was deleted. Zoomed captures confirm each.
- **Claims re-read against the code.** Three were wrong and are corrected on both pages: nasheeds are **bundled** (`assets/Anashed/`, 16 files, no CDN), not streamed; the hadith **seed** is bundled (`assets/hadith/library_seed.json`) and only extra collections come from `cdn.jsdelivr.net`; and the build floor is **Android 7.0 / API 24**, not 5.0 — `flutter_launcher_icons.min_sdk_android: 21` is the icon generator's setting, while `android/app/build.gradle.kts:30` uses `flutter.minSdkVersion`, which is 24 in the installed SDK. The footer also stopped saying "open source": there is no `LICENSE` file in the repo, so it now says the source is published on GitHub.
- **Download CTA.** `https://github.com/seifjo/Back-to-pray/releases` returns 200 and the repository is public. The Releases page currently lists **zero published releases**, so the button lands on an empty page until you publish the APK.
- **Metadata.** Both JSON-LD blocks parse; every in-page anchor resolves; `og:image` files exist; hreflang pairs are reciprocal (`en` ↔ `ar` ↔ `x-default`).

### Publish checklist (the five things that need a host)

1. Put the deployed origin in `canonical`, `hreflang`, `og:url` and `og:image` on both pages — they are root-relative today and Open Graph requires absolute URLs for previews to render.
2. Replace `REPLACE_WITH_YOUR_DOMAIN` in `robots.txt` and in every `<loc>`/`xhtml:link` in `sitemap.xml`.
3. Publish the APK as a GitHub Release so the download button resolves to a file; the site needs no edit afterwards.
4. Add a `LICENSE` file if you want to claim open source, then restore that wording in the footer.
5. Re-shoot the two social cards only if the headline changes: `site/tools/og-en.html` and `og-ar.html` are the sources, rendered at 1200×630.
