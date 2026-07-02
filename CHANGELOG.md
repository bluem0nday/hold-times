# Changelog

All notable changes to this skill are documented here. This project follows [Semantic Versioning](https://semver.org/).

## [1.2.0] - 2026-07-02

### Changed
- Home timezone is now auto-detected from the primary Google Calendar and confirmed with the user on first run, instead of being hardcoded. A Config value overrides detection.
- Holidays are read from the user's subscribed holiday calendar instead of a hardcoded US list, so flagging is region-correct anywhere.
- Contact-day hours are generalized. Slots stay inside the overlap of the user's working hours and the contact's working hours in each zone, which handles any pair of timezones instead of only Eastern and Pacific.

### Removed
- US-specific assumptions from the shipped defaults. The skill no longer needs hand-editing to work outside the US.

## [1.1.0] - 2026-07-02

### Added
- Cleanup step is now mandatory and proactive. When a time is confirmed, the skill finds the contact's remaining holds, lists them, and always offers to clear them, including the count in the prompt. The permission guardrail stays: nothing is deleted without explicit approval.
- Explicit per-request override for slot count. Slots per request stays 5 by default, and the user can ask for more or fewer in the moment ("give me 3 times").
- Private-by-default visibility for holds and confirmed events, so calendar-share viewers see only "Busy" and not the contact name. Users can make an event public per request.
- README now covers install steps, region configuration, and a privacy note.

### Notes
- Ships configured for US timezones (Eastern home, Pacific second zone) and US federal holidays. The Config block documents how to adapt it to other regions.

## [1.0.0] - 2026-07-02

First public release.

### Added
- Config block as the single source of truth for all scheduling preferences.
- Requirements note: a connected Google Calendar with read and write access.
- Default scheduling window of the next 3 business days, with auto-extend to day 4 then day 5.
- Weekends off unless explicitly asked.
- 5 slots per request, max 3 per day, 30-minute length, :00 or :30 start times.
- 30-minute buffer rule keyed off event availability (Busy blocks, Free does not).
- Hold events titled `📌 hold: [Full Name]`, colored Banana, marked Busy.
- Confirm flow: drop the 📌, recolor to Grape, keep Busy, then offer to remove unused holds.
- Timezone discipline with ET and PT contact-day hours as documented examples.
- Paste-ready output format with numeric M/D dates and title-case weekday abbreviations.
