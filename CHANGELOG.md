# Changelog

All notable changes to this skill are documented here. This project follows [Semantic Versioning](https://semver.org/).

## [1.3.1] - 2026-07-04

### Removed
- The parallel-create instruction from 1.3.0. It shipped without a way to verify it helped, and it could not be proven in practice. Hold creation is back to the plain one-call-per-slot wording.

### Changed
- Install section now warns off the "Source code" downloads, which unpack to a branch-named folder instead of an installable skill.
- Cleaned up instruction wording inside the skill. No behavior change.

## [1.3.0] - 2026-07-03

### Added
- When no holiday calendar is subscribed, the skill now says so once and moves on, instead of silently skipping holiday flagging. It never fills the gap by guessing holidays from memory.

### Changed
- Holds are created in one parallel batch instead of one at a time, to cut wall-clock time on the slowest step. Speed gain depends on the client; behavior is unchanged.
- README rewritten in a plainer voice. Holiday wording is region-neutral, the Region section covers users without a holiday calendar, and the Privacy section closes on a single clear rule.
- Trigger description example renamed from Jane to Dale Cooper to match the README examples.

## [1.2.1] - 2026-07-03

### Fixed
- Holds could be created with the calendar's default visibility instead of private, exposing the contact's name to anyone who shares the calendar. Every create call now sets visibility explicitly, and the skill verifies the created event came back private, repairing it if not. Found in fresh-install testing; confirmed against a live calendar.

### Changed
- README Setup and Privacy sections updated to match: private is enforced and verified, not just a default.

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
