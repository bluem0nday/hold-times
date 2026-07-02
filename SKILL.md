---
name: hold-times
description: Finds open calendar slots, creates hold events, and returns paste-ready meeting times in the user's email format. Use whenever the user says "hold times", "hold time for [person]", "find time", "find times", "put holds on my calendar", "give me times for [person]", "send [person] some options", or any request to propose meeting times to a contact. Also trigger when the user says a person picked a slot and unused holds need to be released, or asks to check whether proposed times conflict with their calendar. Trigger even if the request is loose ("hold times next week for Jane") — the skill carries all of the user's scheduling preferences so they never have to re-explain them.
---

# Hold Times

Find open calendar slots, place hold events, and hand back paste-ready times for an email. All of the user's scheduling preferences live here — never make them re-explain them.

## Requirements

This skill needs a connected Google Calendar with read and write access. It calls `list_events`, `create_event`, `update_event`, and `delete_event`, so the calendar connector must be set up before the skill runs. If no calendar is connected, stop and tell the user to connect one. Do not guess at times.

## Config

Edit these to fit your setup. The rest of the skill reads from them. Do not hardcode values in the body.

- **Home timezone:** auto-detected from your primary Google Calendar. Set a value here only to override (for example `America/New_York`).
- **Your working hours (home zone):** earliest start 9:00 AM, latest slot ends 5:30 PM. This is when you are available.
- **Contact working hours (contact's zone):** 8:30 AM to 5:00 PM. Keep every slot inside the overlap of your hours and the contact's hours. A contact west of you gets your late-morning-to-evening; a contact east gets your earlier slots.
- **Holiday calendar:** whichever holiday calendar you subscribe to in Google Calendar (for example "Holidays in United States"). The skill flags any holiday that lands in the window.
- **Window:** next 3 business days (auto-extend to day 4, then 5 if needed)
- **Weekends:** off unless explicitly asked
- **Slots per request:** 5 by default (max 3 per day). The user can ask for more or fewer per request.
- **Slot length:** 30 min
- **Start times:** :00 or :30 only
- **Buffer from Busy events:** 30 min
- **Lead time:** nothing sooner than 4 hours after the request
- **Hold title:** `📌 hold: [Full Name]`
- **Hold color:** Banana (colorId 5)
- **Confirmed-meeting color:** Grape (colorId 3)
- **Hold visibility:** private (calendar-share viewers see only "Busy," not the title). The user can override to public per request.

**Region note:** home timezone and holidays are read from your Google Calendar, so the skill adapts to your region on its own. Nothing is hardcoded to the US. Override the home timezone in Config only if the calendar's zone is wrong for you.

**The goal:** give the contact something they can say yes to without a lot of back-and-forth. Every choice below serves that: enough options, sane hours in their timezone, and a paste-ready block that asks for a simple pick.

## Defaults (apply unless the user says otherwise)

- **Window:** the next 3 business days. Never Saturday or Sunday unless the user asks for a weekend. If the buffer rule leaves too few clean slots, auto-extend to day 4, then day 5. Keep options within 3–4 days out when possible. Speed to a booked call is the point.
- **Count:** use the Config slots-per-request and per-day max. The user can override per request ("give me 3 times" means 3 slots). Honor the per-day max unless the user overrides that too.
- **Lead time:** use the Config lead time.
- **Length:** use the Config slot length.
- **Start times:** :00 or :30 only.
- **Same-day pairs:** when placing more than one slot on a day, put one before noon and one after noon.
- **Day boundaries:** keep each slot inside the overlap of your working hours and the contact's working hours (both from Config), expressed in each zone. A contact west of you naturally gets later slots; a contact east gets earlier ones.
- **No attendees, no invites.** Holds go on the user's primary calendar only. The user sends the real invite themselves after the contact picks.

## Hold event settings

- **Title:** the Config hold title. Full name, no acronyms or nicknames the user hasn't used themselves.
- **Availability:** Busy. Holds must block the time so later scans don't double-book against them.
- **Color:** the Config hold color, so holds are easy to spot and sweep.
- **Visibility:** the Config hold visibility. Private by default, so anyone who shares the user's calendar sees only "Busy," not who the hold is for.

## After the contact commits

When the user reports a confirmed time, always run both steps in the same reply. Do not stop after step 1.

1. Rename that hold to whatever the user calls the meeting (they decide the title). Drop the 📌 from the title. Change the color to the Config confirmed-meeting color. Keep it Busy and keep the Config visibility (private).
2. Find every other `📌 hold: [Full Name]` event still on the calendar for that contact. List them by date and time. Then ask: "Want me to clear the other [N] holds for [Name]?" where [N] is the real count. Always offer this, even if the user did not bring up the leftovers. Never delete anything without explicit permission in the current conversation.

## The buffer rule (this is the one the user corrects most)

A hold must start and end at least the Config buffer away from any event marked Busy. Events marked Free (transparent availability) do not block. The user's recurring lunch block and reminder-style events are Free on purpose. Read the event's availability field. Do not guess from the title.

Why: back-to-back calls wreck their day, but their calendar is full of soft reminders that look like commitments and aren't.

Existing `📌 hold:` events count as Busy. Outstanding holds for one person must not collide with holds for another.

**All-day events:** marked Free, ignore. Marked Busy (OOO, travel), ask the user before placing holds on that day, and name the conflicting event when delivering results.

**Stale holds:** a `📌 hold:` event older than 5 business days with no pick is stale. Flag stale holds whenever this skill runs, so dead options don't clog the calendar.

## Timezone discipline

- **Detect the home zone first.** On first run, or whenever the Config home timezone is blank, call `list_calendars` and read the primary calendar's `timeZone`. Confirm once with the user ("Your calendar is set to America/New_York, use that as home?"), then use it. A value in Config overrides detection.
- The `dateTime` offset in calendar data is authoritative. Ignore the IANA label if they disagree.
- If the contact is in another timezone, list their timezone first, home timezone second: `10:30 AM PT (1:30 PM ET)`.
- If the contact is in the home timezone (or unknown), home timezone only.
- Keep every slot inside the contact's working hours in their own zone (Config). Never propose a time that lands before their morning start or after their evening end.

## Workflow

1. **Confirm the home zone.** If the Config home timezone is blank, detect it from the primary calendar and confirm once (see Timezone discipline).
2. **Read the calendar** for the full window before proposing anything (Google Calendar `list_events`). Never propose a time you haven't checked.
3. **Pick slots** using the defaults and buffer rule above.
4. **Flag holidays** that fall in the window by checking the user's subscribed holiday calendar (from `list_calendars`). Include the slot if the user asked for that day, but say so. The contact may be off.
5. **Create the holds.** One `create_event` per slot with the settings above.
6. **Return the paste-ready list** (format below), confirming holds are on the calendar.
7. **Offer cleanup** when the contact picks (rename, then ask before deleting the rest, per above).

## Output format

One line per slot, in a code block so it copies clean. No bullets, no bold, no day-grouping. Always open with the holding line and end with the closing line.

Dates use numeric month/day (M/D, no leading zeros), keeping the weekday abbreviation in title case (Mon, Tue, Wed). So: `Fri, 7/3 at 11:00 AM ET`.

**Contact in home timezone (example: Dale Cooper, ET):**
```
Holding these times for a call. If one works, I'll send an invite.

Fri, 7/3 at 11:00 AM ET
Mon, 7/6 at 10:00 AM ET
Mon, 7/6 at 2:30 PM ET
Tue, 7/7 at 11:30 AM ET
Tue, 7/7 at 3:00 PM ET

Or propose a time that works better for you.
```

**Contact in another timezone, their zone first (example: Audrey Horne, PT):**
```
Holding these times for a call. If one works, I'll send an invite.

Mon, 6/8 at 10:30 AM PT (1:30 PM ET)
Mon, 6/8 at 12:30 PM PT (3:30 PM ET)
Tue, 6/9 at 9:00 AM PT (12:00 PM ET)
Tue, 6/9 at 1:00 PM PT (4:00 PM ET)
Wed, 6/10 at 10:00 AM PT (1:00 PM ET)

Or propose a time that works better for you.
```
