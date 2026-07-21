<div align="center">

# hold-times

### A Claude skill that turns "let's find time to talk" into a booked call

**From "we should talk" to a confirmed date and time, fast.**

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.4.1-brightgreen.svg)](../../releases/latest)
[![Claude](https://img.shields.io/badge/Claude-skill-blueviolet.svg)](https://claude.ai)
[![Google Calendar](https://img.shields.io/badge/Google_Calendar-required-4285F4.svg)](https://calendar.google.com)

</div>

It reads your Google Calendar. It places tentative holds around your real commitments. Then it hands back a clean list of times to paste into an email.

When they pick one, tell Claude. That hold becomes a ready-to-send invite with the contact on it and your note in the description, the rest of the holds clear off your calendar, and you get the event link back. Claude never sends the invite. You review it, add the medium (Meet, phone, or a place), and send it yourself.

## What it does

- Reads your calendar and finds open slots around real commitments
- Places each proposed time as a private, Busy hold, so no slot gets offered twice
- Returns a paste-ready list in the other person's timezone
- Books the pick: turns that hold into a ready-to-send invite, clears the other holds, and hands back the event link. It never sends the invite and never emails the contact — every calendar write is silent
- Flags holidays in the window, respecting whatever holiday calendar you subscribe to (if any), and skips scheduling on weekends unless you ask

## What success looks like

Success is speed. The goal is to go from "we should talk about it" to a confirmed date and time, fast. Every default serves that goal. Offer few enough options to decide at a glance. Show each time in the contact's own timezone, so there is no mental math. Make the whole thing answerable in one reply.

## Why it exists

Proposing times by hand is slow. You scan the week. You dodge conflicts. You convert time zones. You format a clean list. You do it every time.

Automating the typing is easy. The judgment is the part worth building:

**Busy means busy.** A calendar is full of soft reminders that look like commitments. A lunch block. A "water the plants" nudge. A birthday. The skill reads each event's availability field and blocks time around Busy events only. Free events stay open. Titles never get a vote, so a reminder can't eat an afternoon and a real meeting can't slip through under a bland name.

**Holds block time.** Each proposed slot goes on the calendar as a Busy event. The next scan treats it like any other meeting, so you never offer the same time to two people.

The rest serves the same goal. The 30-minute buffers. The holiday flags. The timezone-first format. All of it gives the other person something they can say yes to in one reply.

## Why not just send a scheduling link?

Scheduling-link utilities are common and fine. Some even require paid subscriptions to use. You send a URL. The other person picks a slot. But a link hands the work to the invitee. Now they have to open a page, scan your calendar, and commit. When you are the one asking for time, that work should sit with you.

Offering five specific times is just as fast for them. It keeps the effort on your side. And the list always ends with an escape hatch: "Or propose a time that works better for you." No one hits a dead end if none of the options fit.

## Example

Input:

> hold times for Dale Cooper

Output:

```
Holding these times for a call. If one works, I'll send an invite.

Fri, 7/3 at 11:00 AM ET
Mon, 7/6 at 10:00 AM ET
Mon, 7/6 at 2:30 PM ET
Tue, 7/7 at 11:30 AM ET
Tue, 7/7 at 3:00 PM ET

Or propose a time that works better for you.
```

Behind the scenes it created five Busy `📌 hold: Dale Cooper` events. Each one sits 30 minutes clear of existing commitments, in his daytime hours. When Dale picks one — say "book Dale" or paste his reply — the skill turns that hold into the confirmed meeting with Dale as an attendee and your invite note in the description, deletes the other four holds (listing each one), and returns the event link. Nothing gets emailed. You open the event, add Meet or a phone number, and hit send.

When the contact is in another timezone, the skill lists their zone first and yours in parentheses. No mental math for either of you.

Input:

> hold times for Audrey Horne, she's on PT

Output:

```
Holding these times for a call. If one works, I'll send an invite.

Mon, 6/8 at 10:30 AM PT (1:30 PM ET)
Mon, 6/8 at 12:30 PM PT (3:30 PM ET)
Tue, 6/9 at 9:00 AM PT (12:00 PM ET)
Tue, 6/9 at 1:00 PM PT (4:00 PM ET)
Wed, 6/10 at 10:00 AM PT (1:00 PM ET)

Or propose a time that works better for you.
```

And when the contact picks a slot, booking is one line. Say "book Dale" or paste his reply:

> book Dale, he picked Monday at 10

Output:

```
Booked: Mon, 7/6 at 10:00 AM ET — Your Name <> Dale Cooper
Dale is on the invite with your note in the description. No email has gone out.

Cleared the other holds:
Fri, 7/3 at 11:00 AM ET
Mon, 7/6 at 2:30 PM ET
Tue, 7/7 at 11:30 AM ET
Tue, 7/7 at 3:00 PM ET

Open the event, add Meet, phone, or a place, and send: [event link]
```

Behind the scenes that was one event update and four silent deletions. The hold became the real meeting with Dale as an attendee, the leftovers cleared, and nobody got emailed. The send stays yours.

## Requirements

Claude with a connected Google Calendar. It needs read and write access: list, create, update, and delete events. No calendar, no times. The skill stops and says so. It will not guess.

## Install

This is a Claude skill: a folder with a `SKILL.md` inside. Install it wherever your Claude reads skills.

- **Claude Code:** copy the `hold-times` folder into your skills directory, for example `~/.claude/skills/hold-times/` (user-level) or `.claude/skills/hold-times/` inside a project.
- **Claude desktop app:** download `hold-times.skill` from the [latest release](https://github.com/bluem0nday/hold-times/releases/latest), then add it under Settings > Capabilities.

Use the `hold-times.skill` file itself. The green Code button and the "Source code" links give you a folder named after the branch (like `hold-times-main`), not an installable skill.

Exact paths and menus vary by Claude version, so check your app's skills documentation if either location looks different.

## Setup

The Config block at the top of `SKILL.md` is the only part you change, and most of it is optional. Home timezone and holidays come from your Google Calendar automatically. Set your working hours, buffer, slot count, and colors to taste, or leave the defaults. Holds stay private unless you say otherwise.

Two values do need your own words before your first booking: the confirmed-meeting title (your name goes in it) and the invite note that lands in the event description. Both sit in Config as bracketed placeholders until you fill them in.

## Region

No region setup needed. The skill reads your home timezone from your primary Google Calendar and flags holidays from whatever holiday calendar you subscribe to (US, UK, anywhere). If you don't subscribe to one, the skill says so and skips holiday flagging. Subscribing in Google Calendar turns it on. It adapts to wherever you are. On first run it confirms the detected zone with you. If that zone is ever wrong, set it in the Config block to override.

## Privacy

Holds and confirmed events are created private. The skill sets visibility on every event it makes and checks that it took. Anyone who shares your calendar sees only "Busy," not the contact's name. Everything defaults to private, unless you ask to make it public.

The skill also never sends email. Booking adds your contact as an attendee, but every calendar write is silent — you review the finished invite and send it yourself.

And your personal details stay yours. The published skill ships bracketed placeholders; your name, phone number, and invite note exist only in the Config of your own copy.

## Edge cases handled

- Weekends skipped, unless you ask for one.
- Holidays flagged in the window. The other person may have the day off.
- All-day OOO or travel: the skill asks before it books that day.
- Stale holds flagged for cleanup. A stale hold is older than 5 business days with no pick.
- Existing holds count as Busy, so two people's options never collide.
- A pick with no matching hold never gets guessed at. The skill says what it found and offers to create a fresh confirmed event at the picked time.
- If Google Calendar auto-attaches a Meet link when the attendee is added, the skill strips it. You choose the medium when you send.
- Booking cleanup only ever deletes that one contact's own `📌 hold:` events, only after the convert succeeds, and every deletion is listed.

## Limitations

- Google Calendar only. No Outlook or Apple Calendar support.

## Version

v1.4.1 — full history, including what got removed and why, in the [changelog](CHANGELOG.md).

## License

MIT License — see [LICENSE](LICENSE) for details.

## Author

**Matt MacQueen** — Product Design Leader, NYC
[GitHub](https://github.com/bluem0nday) · [LinkedIn](https://www.linkedin.com/in/mattmacqueen/)
