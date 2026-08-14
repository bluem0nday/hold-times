<div align="center">

# hold-times

### A Claude skill that changes "let's find time to talk" into a booked call

**The skill changes "we should talk" into a confirmed date and time.**

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.5.1-brightgreen.svg)](../../releases/latest)
[![Claude](https://img.shields.io/badge/Claude-skill-blueviolet.svg)](https://claude.ai)
[![Google Calendar](https://img.shields.io/badge/Google_Calendar-required-4285F4.svg)](https://calendar.google.com)

</div>

The skill reads your Google Calendar. It creates tentative hold events around your commitments. It then gives you a clean list of times, which you can paste into an email.

When the contact selects a time, tell Claude. The skill changes that hold into an invite that includes the contact and your note. It deletes the other holds and gives you the event link. Claude does not send the invite. You examine the invite, add Meet, a phone number, or a place, and then send it.

## What it does

- The skill reads your calendar and finds the open slots around your commitments.
- It creates each proposed time as a private Busy hold, so it does not offer the same time to two contacts.
- It gives you a paste-ready list of times in the timezone of the contact.
- When the contact selects a time, it changes that hold into an invite, deletes the other holds, and gives you the event link.
- It does not send the invite, and it does not send email to the contact. Each calendar write is silent.
- It flags the holidays in the window, and it does not schedule the weekends, unless you ask.

## What success looks like

The goal is speed. The skill changes "we should talk" into a confirmed date and time quickly. It offers a small number of times, so the contact can decide quickly. It shows each time in the timezone of the contact. The contact does not convert times, and can answer with one short reply.

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
Holding these times for a chat. If one works, I'll send an invite.

Fri, 7/3 at 11:00 AM ET
Mon, 7/6 at 10:00 AM ET
Mon, 7/6 at 2:30 PM ET
Tue, 7/7 at 11:30 AM ET
Tue, 7/7 at 3:00 PM ET

Or propose a time that works better for you.
```

The skill creates five Busy `📌 hold: Dale Cooper` events. Each event is 30 minutes away from your other commitments, and is in the daytime hours of the contact.

When Dale selects a time, say "book Dale" or paste his reply. The skill changes that hold into the confirmed meeting, with Dale as an attendee and your note in the description. It deletes the other four holds and lists each deletion. It then gives you the event link. The skill does not send email. You open the event, add Meet or a phone number, and send the invite.

When the contact is in a different timezone, the skill shows the timezone of the contact first, and your timezone in parentheses. You and the contact do not convert times.

Input:

> hold times for Audrey Horne, she's on PT

Output:

```
Holding these times for a chat. If one works, I'll send an invite.

Mon, 6/8 at 10:30 AM PT (1:30 PM ET)
Mon, 6/8 at 12:30 PM PT (3:30 PM ET)
Tue, 6/9 at 9:00 AM PT (12:00 PM ET)
Tue, 6/9 at 1:00 PM PT (4:00 PM ET)
Wed, 6/10 at 10:00 AM PT (1:00 PM ET)

Or propose a time that works better for you.
```

When the contact selects a time, the booking is one line. Say "book Dale" or paste his reply:

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

The booking is one event update and four deletions. The hold became the meeting, and the skill did not send email. You send the invite.

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

## Region

You do not need region setup. The skill reads your home timezone from your primary Google Calendar. It flags the holidays from the holiday calendar that you subscribe to, for the US, the UK, or a different country. If you do not subscribe to a holiday calendar, the skill tells you, and it does not flag the holidays. To turn on the holiday flags, subscribe to a holiday calendar in Google Calendar.

On the first run, the skill shows the timezone that it found, and asks you to make sure that the timezone is correct. If the timezone is wrong, set the correct timezone in the Config block.

## Privacy

The skill creates the holds and the confirmed events as private events. It sets the visibility on each event, and then makes sure that the setting is applied. A person who shares your calendar sees only "Busy", and does not see the name of the contact. All events are private, unless you ask for public events.

The skill does not send email. A booking adds your contact as an attendee, but each calendar write is silent. You examine the finished invite and send it.

Your personal data stays with you. The published skill has placeholders in brackets. Your name, your phone number, and your invite note are only in the Config block of your copy.

## Edge cases handled

- The skill does not schedule the weekends, unless you ask.
- It flags the holidays in the window, because the contact can be out of the office.
- If a day has an all-day out-of-office event or a travel event, the skill asks before it books that day.
- It flags the stale holds for cleanup. A stale hold is more than 5 business days old, with no selected time.
- Holds on the calendar are Busy events, so the times for two contacts do not collide.
- If a selected time has no hold, the skill does not guess. It tells you what it found, and it offers to create a confirmed event at the selected time.
- If Google Calendar attaches a Meet link when the skill adds the attendee, the skill removes the link. You select the medium when you send the invite.
- The cleanup deletes only the `📌 hold:` events of that one contact. The skill deletes them only after it changes the selected hold into the meeting, and it lists each deletion.

## Limitations

- The skill works with Google Calendar only. It does not work with Outlook or Apple Calendar.

## Version

The current version is v1.5.1. The [changelog](CHANGELOG.md) has the full history. It includes each feature that we removed, and the reason.

## License

MIT License. See the [LICENSE](LICENSE) file for details.

## Author

**Matt MacQueen** — Product Design Leader, NYC
[GitHub](https://github.com/bluem0nday) · [LinkedIn](https://www.linkedin.com/in/mattmacqueen/)
