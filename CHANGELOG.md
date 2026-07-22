# Changelog

All notable changes to this skill are documented here. This project follows [Semantic Versioning](https://semver.org/).

## [1.5.0] - 2026-07-22

### Added
- `scripts/make-times-block.sh` — the paste-ready block is now assembled by a bundled script. The opening line, the closing line, and the blank-line spacing are hardcoded in the script, so the frame can no longer be dropped or reworded. The model writes only the slot lines and passes them as arguments.

### Changed
- The opening line now reads "Holding these times for a chat. If one works, I'll send an invite." It said "for a call" through 1.4.1.
- Output format section rewritten around the script: generate the block, paste its output verbatim. Slot-line rules (M/D dates, timezone ordering, no bullets) are unchanged, and apart from the reworded opener the delivered block matches 1.4.1's. If the script's output ever lacks the frame, the skill stops and says so instead of patching the block by hand. In a session with no shell, the skill reads the frame lines out of the script file instead of reconstructing them from memory.

## [1.4.1] - 2026-07-21

### Added
- Color fallback in Config. Google Calendar's web UI has an expanded color palette (Birch and others) that the Calendar API cannot reach — the API accepts only the 11 classic event colors, Lavender through Tomato. When a request names a color outside those 11, the skill now substitutes Lavender (colorId 1) and says so. Before this rule the model improvised its own stand-in.

## [1.4.0] - 2026-07-09

### Added
- Booking flow. When the contact picks a time — "book [Name]", "lock in [Name]", "confirm [Name]", or a pasted reply with their pick — the skill converts the winning hold into a ready-to-send invite in one reply: retitles it to the Config confirmed-meeting title (no meeting medium), adds the contact as an attendee, drops in the Config invite note verbatim, recolors to the confirmed color, and keeps it Busy and private. The invite is never sent by the skill. Every calendar write uses `notificationLevel: NONE`, and the user reviews and sends.
- Config entries for the confirmed-meeting title and the invite note, so booking reads from Config like everything else.
- Guard against auto-attached conferencing: after the convert, the skill checks the returned event and strips any Google Meet link the calendar added on its own.
- The reply hands back the confirmed event's `htmlLink` and states plainly that no invite has gone out yet.

### Changed
- After a successful booking, the contact's leftover `📌 hold:` events are now deleted automatically and each deletion is listed in the reply. Before 1.4.0 the skill asked first. The auto-delete is tightly scoped: only that contact's own hold placeholders, never another person's holds, never any event with attendees, and nothing at all if the convert failed.
- The old "After the contact commits" section (rename, then ask before clearing) is replaced by the Booking section. One skill now covers the whole propose, book, and clear lifecycle.

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
