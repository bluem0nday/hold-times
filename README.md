# hold-times

A Claude skill that turns "let's find time to talk" into a booked call. It reads your Google Calendar. It places tentative holds around your real commitments. Then it hands back a clean list of times to paste into an email.

When they pick one, tell Claude. That hold becomes the real meeting, and the rest clear off your calendar.

## What success looks like

Success is speed. The goal is to go from "we should talk about it" to a confirmed date and time, fast. Every default serves that goal. Offer few enough options to decide at a glance. Show each time in the contact's own timezone, so there is no mental math. Make the whole thing answerable in one reply.

## Why it exists

Proposing times by hand is slow. You scan the week. You dodge conflicts. You convert time zones. You format a clean list. You do it every time.

The hard part is not the typing. It is the judgment. Two decisions carry the skill.

**Free vs. Busy, not title-guessing.** A calendar is full of soft reminders that look like commitments. A lunch block. A "water the plants" nudge. A birthday. The skill blocks only around events marked Busy. It treats Free events as open time. This one rule prevents double-booking and phantom conflicts alike. Read the availability field. Never guess from the title.

**Holds are real blocks, not notes.** Each proposed time goes on the calendar as a Busy hold. A later scan sees those holds. It will not offer a slot that is already on the table for someone else.

The rest serves the same goal. The 30-minute buffers. The holiday flags. The timezone-first format. All of it gives the other person something they can say yes to in one reply.

## Why not just send a scheduling link?

Scheduling-link utilities are common and fine. Some even cost money to use. You send a URL. The other person picks a slot. But a link hands the work to the invitee. Now they have to open a page, scan your calendar, and commit. When you are the one asking for time, that work should sit with you.

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

Behind the scenes it created five Busy `📌 hold: Dale Cooper` events. Each one sits 30 minutes clear of existing commitments, in his daytime hours. When Dale picks one, the skill renames that event to the real meeting, recolors it, and offers to clear the rest.

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

## Requirements

Claude with a connected Google Calendar. It needs read and write access: list, create, update, and delete events. No calendar, no times. The skill stops and says so. It will not guess.

## Install

This is a Claude skill: a folder with a `SKILL.md` inside. Install it wherever your Claude reads skills.

- **Claude Code:** copy the `hold-times` folder into your skills directory, for example `~/.claude/skills/hold-times/` (user-level) or `.claude/skills/hold-times/` inside a project.
- **Claude desktop app:** download `hold-times.skill` from the [latest release](https://github.com/bluem0nday/hold-times/releases/latest), then add it under Settings > Capabilities.

Exact paths and menus vary by Claude version, so check your app's skills documentation if either location looks different.

## Setup

The Config block at the top of `SKILL.md` is the only part you change, and most of it is optional. Home timezone and holidays come from your Google Calendar automatically. Set your working hours, buffer, slot count, colors, and visibility to taste, or leave the defaults.

## Region

No region setup needed. The skill reads your home timezone from your primary Google Calendar and flags holidays from whatever holiday calendar you subscribe to. It adapts to wherever you are. On first run it confirms the detected zone with you. If that zone is ever wrong, set it in the Config block to override.

## Privacy

Holds and confirmed events are created private by default. Anyone who shares your calendar sees only "Busy," not the contact's name. Ask to make one public if you want the title visible. Private is the safe default; public is the exception.

## Edge cases handled

- Weekends skipped, unless you ask for one.
- Federal holidays flagged in the window. The contact may be off.
- All-day OOO or travel: the skill asks before it books that day.
- Stale holds flagged for cleanup. A stale hold is older than 5 business days with no pick.
- Existing holds count as Busy, so two people's options never collide.

## Version

v1.2.0

## License

MIT
