<div align="center">

# hold-times

### A Claude skill that turns "let's find time to talk" into a booked call

**From "we should talk" to a confirmed date and time, fast.**

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.8.0-brightgreen.svg)](../../releases/latest)
[![Claude](https://img.shields.io/badge/Claude-skill-blueviolet.svg)](https://claude.ai)
[![Google Calendar](https://img.shields.io/badge/Google_Calendar-required-4285F4.svg)](https://calendar.google.com)

</div>

It reads your Google Calendar. It places tentative holds around your real commitments. Then it hands back a clean list of times to paste into an email.

When they pick one, tell Claude. That hold becomes a ready-to-send invite with the contact on it and your note in the description, the rest of the holds clear off your calendar, and you get the event link back. Claude never sends the invite. You review it, add the medium (Meet, phone, or a place), and send it yourself.

## What it does

- Reads your calendar and finds open slots around real commitments
- Places each proposed time as a private, Busy hold, so no slot gets offered twice
- Returns a paste-ready list in the other person's timezone, grouped by day
- Books the pick: turns that hold into a ready-to-send invite, clears the other holds, and hands back the event link. It never sends the invite and never emails the contact — every calendar write is silent
- Flags holidays in the window, respecting whatever holiday calendar you subscribe to (if any), and skips scheduling on weekends unless you ask

## What success looks like

Success is speed. The goal is to go from "we should talk about it" to a confirmed date and time, fast. Every default serves that goal. Offer few enough options to decide at a glance. Show each time in the contact's own timezone, so there is no mental math. Make the whole thing answerable in one reply.

## Why it exists

Proposing times by hand is slow. You scan the week. You dodge conflicts. You convert time zones. You format a clean list. You do it every time.

Automating the typing is easy. The judgment is the part worth building:

**Busy means busy.** A calendar is full of soft reminders that look like commitments. A lunch block. A "water the plants" nudge. A birthday. The skill reads each event's availability field and blocks time around Busy events only. Free events stay open. Titles never get a vote, so a reminder can't eat an afternoon and a real meeting can't slip through under a bland name.

**Holds block time.** Each proposed slot goes on the calendar as a Busy event. The next scan sees it, so you never offer the same time to two people.

**Holds can sit back to back. Booked meetings get room.** Most proposed times never get picked, so one hold may start the minute another ends. Once a meeting is booked, it keeps 30 minutes clear on each side. When the skill cannot keep that buffer, it asks you what to do. It does not squeeze a time in on its own.

The rest serves the same goal. The 30-minute buffers around booked meetings. The holiday flags. The timezone-first format. All of it gives the other person something they can say yes to in one reply.

## Why not just send a scheduling link?

Scheduling-link utilities are common and fine. Some even require paid subscriptions to use. You send a URL. The other person picks a slot. But a link hands the work to the invitee. Now they have to open a page, scan your calendar, and commit. When you are the one asking for time, that work should sit with you.

Offering five specific times is just as fast for them. It keeps the effort on your side. And the list always ends with an escape hatch: "Or propose a time that works better for you." No one hits a dead end if none of the options fit.

## Example

Input:

> hold times for Dale Cooper

Output:

```
Holding these times for a chat. If one works, I'll send an invite.

Fri, 7/3 at 11:00 AM ET

Mon, 7/6
10:00 AM ET
2:30 PM ET

Tue, 7/7
11:30 AM ET
3:00 PM ET

Or propose a time that works better for you.
```

The times run in date order. A day with two or more times gets a label with its times under it. A day with one time stays on one line: `Fri, 7/3 at 11:00 AM ET`.

Behind the scenes it created five Busy `📌 hold: Dale Cooper` events. Each one sits 30 minutes clear of existing commitments, in his daytime hours. When Dale picks one — say "book Dale" or paste his reply — the skill turns that hold into the confirmed meeting with Dale as an attendee and your invite note in the description, deletes the other four holds (listing each one), and returns the event link. Nothing gets emailed. You open the event, add Meet or a phone number, and hit send.

When the contact is in another timezone, the skill lists their zone first and yours in parentheses. No mental math for either of you.

Input:

> hold times for Audrey Horne, she's on PT

Output:

```
Holding these times for a chat. If one works, I'll send an invite.

Mon, 6/8
10:30 AM PT (1:30 PM ET)
12:30 PM PT (3:30 PM ET)

Tue, 6/9
9:00 AM PT (12:00 PM ET)
1:00 PM PT (4:00 PM ET)

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

You need Claude with a connected Google Calendar. The skill needs read and write access: it must list, create, update, and delete events. If no calendar is connected, the skill stops and tells you. It does not guess.

## Install

This skill is a folder with a `SKILL.md` file and a small script. Install it where your Claude reads skills.

- **Claude Code:** Copy the `hold-times` folder into your skills directory, for example `~/.claude/skills/hold-times/` at the user level, or `.claude/skills/hold-times/` in a project.
- **Claude desktop app:** Download `hold-times.skill` from the [latest release](https://github.com/bluem0nday/hold-times/releases/latest). Then add it in Settings > Capabilities.

Use the `hold-times.skill` file. The green Code button and the "Source code" links give you a folder with the name of the branch, for example `hold-times-main`. That folder is not an installable skill.

The exact paths and menus change with the Claude version. If a location looks different, read the skills documentation for your app.

## Setup

The Config block at the top of `SKILL.md` is the only part that you change, and most of the block is optional. The skill gets your home timezone and your holidays from your Google Calendar. Set your work hours, buffer, slot count, and colors, or keep the defaults. Holds stay private, unless you change the setting.

Two values need your words before your first booking: the title of the confirmed meeting, and the invite note in the event description. The two values are placeholders in brackets in the Config block until you replace them. Write the note as HTML, because Google Calendar shows a description as HTML. Then the line breaks and a link to your site stay correct.

To keep your name and note out of a copy that you share, put them in a file named `config.local.md` next to `SKILL.md`. Its values replace the matching Config lines. Git ignores this file. If a value still has brackets when you book, the skill asks you for the words. It never puts brackets into an invite.

## Region

You do not need region setup. The skill reads your home timezone from your primary Google Calendar. It flags the holidays from the holiday calendar that you subscribe to, for the US, the UK, or a different country. If you do not subscribe to a holiday calendar, the skill tells you, and it does not flag the holidays. To turn on the holiday flags, subscribe to a holiday calendar in Google Calendar.

On the first run, the skill shows the timezone that it found, and asks you to make sure that the timezone is correct. If the timezone is wrong, set the correct timezone in the Config block.

## Privacy

Holds and confirmed events are created private. The skill sets visibility on every event it makes and checks that it took. Anyone who shares your calendar sees only "Busy," not the contact's name. Everything defaults to private, unless you ask to make it public.

The skill also never sends email. Booking adds your contact as an attendee, but every calendar write is silent — you review the finished invite and send it yourself.

And your personal details stay yours. The published skill ships bracketed placeholders; your name, phone number, and invite note exist only in your own copy, in the Config or in `config.local.md`.

## Edge cases handled

- The skill does not schedule the weekends, unless you ask.
- It flags the holidays in the window, because the contact can be out of the office.
- If a day has an all-day out-of-office event or a travel event, the skill asks before it books that day.
- It flags the stale holds for cleanup. A stale hold is more than 5 business days old, with no selected time.
- Holds on the calendar are Busy events, so the times for two contacts never overlap. Holds can touch each other. A booked meeting keeps 30 minutes clear on each side.
- If the window cannot fit the times without cutting into a booked meeting's buffer, the skill asks you what to do: extend the window, offer fewer times, or use the buffer. It does not decide for you.
- If a booking leaves another contact's hold inside the new meeting's buffer, the skill tells you and asks what to do. It does not move or delete that hold.
- If a selected time has no hold, the skill does not guess. It tells you what it found, and it offers to create a confirmed event at the selected time.
- If Google Calendar attaches a Meet link when the skill adds the attendee, the skill removes the link. You select the medium when you send the invite.
- The cleanup deletes only the `📌 hold:` events of that one contact. The skill deletes them only after it changes the selected hold into the meeting, and it lists each deletion.

## Limitations

- The skill works with Google Calendar only. It does not work with Outlook or Apple Calendar.

## Version

v1.8.0 — full history, including what got removed and why, in the [changelog](CHANGELOG.md).

## License

MIT License — see [LICENSE](LICENSE) for details.

## Author

**Matt MacQueen** — Product Design Leader, NYC
[GitHub](https://github.com/bluem0nday) · [LinkedIn](https://www.linkedin.com/in/mattmacqueen/)
