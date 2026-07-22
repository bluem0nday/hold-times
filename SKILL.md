---
name: hold-times
description: Finds open calendar slots, creates hold events, and returns paste-ready meeting times in the user's email format. When the contact picks one, converts the winning hold into a ready-to-send invite and clears the rest. Use whenever the user says "hold times", "hold time for [person]", "find time", "find times", "put holds on my calendar", "give me times for [person]", "send [person] some options", or any request to propose meeting times to a contact. Also trigger for booking — the user says "book times", "book [Name]", "lock in [Name]", "confirm [Name]", pastes a reply where the contact picks one of the proposed times, or reports a confirmed time in any phrasing. Also trigger when the user asks to check whether proposed times conflict with their calendar. Trigger even if the request is loose ("hold times next week for Dale Cooper") — the skill carries all of the user's scheduling preferences so they never have to re-explain them.
---

# Hold Times

Find open calendar slots, place hold events, and hand back paste-ready times for an email. When the contact picks one, book it: the winning hold becomes a ready-to-send invite and the leftover holds clear off the calendar. All of the user's scheduling preferences live here — never make them re-explain them.

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
- **Confirmed-meeting title:** `[Your Full Name] <> [Their Full Name]`. Put your own name in before first use. No meeting medium in the title — the user adds Google Meet, phone, or a location themselves when they send the invite.
- **Confirmed-meeting color:** Grape (colorId 3)
- **Color fallback:** the Calendar API accepts only the 11 classic event colors (Lavender through Tomato). Colors from Google Calendar's newer UI palette — Birch and the rest — cannot be set through the API. When the user asks for one of those, use Lavender (colorId 1) and say so.
- **Invite note** (goes in the confirmed event's description, verbatim — replace the bracketed parts with your own before first use):
  > Looking forward to catching up. If anything comes up closer to our meeting time, text me anytime at [your mobile number]. Cheers, [your first name]
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
- **No attendees on holds, no emails ever.** Holds go on the user's primary calendar only. The contact becomes an attendee only at booking time, and even then the skill never sends the invite — the user reviews it and sends it themselves.

## Hold event settings

- **Title:** the Config hold title. Full name, no acronyms or nicknames the user hasn't used themselves.
- **Availability:** Busy. Holds must block the time so later scans don't double-book against them.
- **Color:** the Config hold color, so holds are easy to spot and sweep.
- **Visibility:** the Config hold visibility. Private by default, so anyone who shares the user's calendar sees only "Busy," not who the hold is for. Pass `visibility` explicitly in every create call. Leaving it out silently falls back to the calendar default, which exposes the contact's name.

## Booking: after the contact picks

Trigger: the user says "book times", "book [Name]", "lock in [Name]", "confirm [Name]", pastes a reply where the contact picks one of the proposed times, or reports a confirmed time in any phrasing. Run all of these steps in one reply. Do not stop partway.

1. **Read the pick.** From the pasted reply or the user's instruction, identify the contact and the exact date and time chosen. If the pick is written in the contact's timezone, convert it to the home timezone before searching.
2. **Find the matching hold.** Search for `📌 hold: [Full Name]` events around that date and match the one whose start equals the picked slot. No match, or holds only at other times: do not guess. Tell the user what was found and offer to create a fresh confirmed event at the picked time instead. Two holds at the same start time: list them and ask which one.
3. **Get the contact's email** from their person file or the pasted thread. If it isn't available in either place, ask the user. Never invent an address.
4. **Convert the hold to the confirmed meeting** with a single `update_event`:
   - Title → the Config confirmed-meeting title. Drop the 📌. No medium in the title.
   - Add the contact as an attendee with their email, `responseStatus: needsAction`.
   - Description → the Config invite note, verbatim.
   - Color → the Config confirmed-meeting color. Keep Busy. Keep visibility private.
   - `notificationLevel: NONE` — no email goes out. The skill never sends the invite. The user reviews it and sends it themselves.
   - Do not add a Google Meet link. Then check the returned event data: if the calendar auto-attached conferencing (a Google Calendar setting can do this when an attendee is added), strip it with another `update_event` before reporting the booking as done.
5. **Clear the other holds automatically.** Only after step 4 succeeds, delete every remaining `📌 hold: [Full Name]` event for that contact (`notificationLevel: NONE` on every delete) and list each deletion in the reply by date and time. This is a standing pre-authorized exception to the ask-before-deleting rule, scoped to that one contact's own `📌 hold:` placeholders and nothing else. Never delete an event titled for anyone else, never touch an event that has attendees, and if step 4 failed, delete nothing.
6. **Hand back the link.** Return the confirmed event's `htmlLink` so the user can open it in one click. State plainly that no invite has been sent yet — the user picks the medium and sends.
7. **Log it** (when running inside Job Search OS): append a dated entry to the contact's person file and the ops doc with the picked time, the verbatim quote if one was pasted, and a note that the unused holds were released.

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
4. **Flag holidays** that fall in the window by checking the user's subscribed holiday calendar (from `list_calendars`). Include the slot if the user asked for that day, but say so. The other person may have the day off. If no holiday calendar is subscribed, say so once ("no holiday calendar found, so holidays won't be flagged") and keep going. Never guess holidays from memory.
5. **Create the holds.** One `create_event` per slot. Every call must explicitly set: the hold title, Busy availability, the Config hold color, and `visibility: private`. Do not rely on defaults for any of these. Then check the returned event data. If visibility came back missing or not private, fix it with `update_event` before reporting the holds as placed.
6. **Return the paste-ready list** (format below), confirming holds are on the calendar.
7. **Book the winner** when the contact picks (see Booking). The convert and the cleanup run in the same reply.

## Output format

Never hand-compose the paste block. Build the slot lines, then generate the block by running the bundled script — its output is the deliverable, pasted verbatim into a code block so it copies clean. The opening line, the closing line, and the blank-line spacing live only in the script, so the frame cannot be dropped.

Slot-line rules (these are the only parts the model writes):

- Dates use numeric month/day (M/D, no leading zeros), keeping the weekday abbreviation in title case (Mon, Tue, Wed). So: `Fri, 7/3 at 11:00 AM ET`.
- Contact in the home timezone (or unknown): home timezone only — `Fri, 7/3 at 11:00 AM ET`
- Contact in another timezone: their zone first, home zone second — `Mon, 6/8 at 10:30 AM PT (1:30 PM ET)`
- No bullets, no bold, no day-grouping.

Generate the block with the script at `scripts/make-times-block.sh` inside this skill's base directory. Call it through `bash` with the full path quoted (installed paths can contain spaces), one argument per slot line, in order. Do not depend on the working directory or on the script's executable bit:

    bash "<skill base directory>/scripts/make-times-block.sh" \
      "Mon, 6/8 at 10:30 AM PT (1:30 PM ET)" \
      "Tue, 6/9 at 9:00 AM PT (12:00 PM ET)" \
      "Wed, 6/10 at 10:00 AM PT (1:00 PM ET)"

Paste the script's output exactly as returned. If the output doesn't open with the holding line and end with the proposal line, the script is broken — stop and say so rather than patching the block by hand. If the session has no shell to run the script, read the script file and copy the frame lines from it verbatim instead of reconstructing them from memory.
