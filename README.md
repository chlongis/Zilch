# Zilch

**Drivers own their record.**

A rideshare driver's 6,000 trips at 4.97 stars is the single most valuable thing they have, and it isn't theirs. It lives inside an app they don't control, it can't be taken anywhere else, and it disappears the day they get deactivated by an algorithm with no appeal.

Zilch is a portable reputation layer for gig drivers, with a commission-free job board attached. Drivers mint a profile they own, hand it out however they like, and get found directly. No cut is taken from anything.

Static HTML, no build step, one free database. **Fork it and run it in your city in an afternoon.**

---

## What's in it

| Page | What it does |
|---|---|
| `claim.html` | A driver builds a profile — stats, vehicle, area, contact method, optional proof screenshot. Mints a permanent handle. |
| `d.html?h=<handle>` | The public profile. Stats, verification badge, one-tap contact, QR code, vCard, printable card. |
| `find.html` | Searchable directory by name, vehicle, bio and area. |
| `board.html` | Peer-to-peer job board. Post a ride or delivery, name your price, a driver claims it. |
| `paycheck.html` | Checks a pay period against the legal minimum in Minnesota, Washington, Seattle and New York City. |
| `pledge.html` | Launch-area pledges with per-suburb thresholds. |
| `index.html` | Landing page. |

---

## Run it in your city

You need a free [Supabase](https://supabase.com) account and a GitHub account. No build tools, no server, no npm.

**1. Fork this repo.**

**2. Create a Supabase project.** Copy the project URL and the **anon** key from Settings → API. The anon key is meant to be public and safe in client code — row level security is what protects the data. Never use the `service_role` key.

**3. Point the code at your project:**

```bash
./setup.sh https://yourproject.supabase.co your-anon-key
```

**4. Create the tables.** Paste all of `schema.sql` into the Supabase SQL Editor and run it once.

**5. Create two storage buckets** in the Supabase dashboard: `proof` and `insurance`. Both private, 5 MB limit, allowing `image/jpeg`, `image/png` and `application/pdf`. The policies are already in `schema.sql`.

**6. Set your own areas.** The suburb lists are hardcoded near the top of the script block in `pledge.html`, `claim.html`, `find.html` and `board.html`. Swap in your own. In `pledge.html` each area also has a `need` value — the number of drivers required before that area goes live. Smaller areas need fewer.

**7. Enable GitHub Pages.** Settings → Pages → Source: `main`, folder `/root`. Live in about a minute.

**8. Check it works.** Open `pledge.html`, submit a pledge, and watch the bar move. If it doesn't, the SQL in step 4 never ran.

---

## How some of it works

**Claiming is locked at the database.** The update policy on `requests` only permits changing a row that is still `open`, and only to `claimed`. Two drivers hitting the same job at the same moment: one wins and the other is rejected by Postgres, not by browser JavaScript that can be raced or bypassed.

**Verification is tiered and labelled honestly.** In order to prevent doctored ratings we use multiple methods to verify driver's ratings. A profile shows *Verified* when a stats screenshot is attached along with *Self-reported* when nothing is. Screenshots are fakeable, . The label appears on the profile and on every directory card so riders can weigh it themselves.

**Pay law differs by jurisdiction and the checker respects that.** Minnesota measures compliance across a pay period of up to 14 days. Washington and New York City measure each trip individually. NYC has no flat per-trip floor at all — the formula itself is the minimum, with the utilization rate already folded into the published rates. Only passenger miles and minutes count anywhere. Tips are excluded from the minimum everywhere.

**`from`, `to` and `when` are reserved words in Postgres.** The board's columns are `pickup`, `dropoff` and `when_text`.

---

## Pay rates

`paycheck.html` holds a `RATES` object. These change — Minnesota's adjust annually from 2027 alongside the state minimum wage. Update them when they move.

| | Per mile | Per minute | Per trip | Measured |
|---|---|---|---|---|
| Minnesota 2025–26 | $1.28 | $0.31 | $5.00 | pay period |
| Minnesota 2027+ | $1.33 | $0.32 | $5.20 | pay period |
| Seattle 2026 | $1.63 | $0.70 | $6.12 | per trip |
| Washington 2026 | $1.38 | $0.40 | $3.55 | per trip |
| NYC 2026 | $1.283 | $0.681 | — | per trip |
| NYC wheelchair-accessible | $1.601 | $0.681 | — | per trip |

Sources: Minn. Stat. § 181C.03, RCW 49.46.300, 35 RCNY § 59B-23.

---

## Not built yet

- Accounts and identity
- Payments
- In-app messaging after a claim
- DKIM-verified stats — driver forwards their weekly platform summary as an attachment, a worker validates the signature against the platform's DNS key, and the numbers become near-unfakeable. Needs a domain and a mail worker.
- Deactivation database

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Running it in a new city and reporting what broke is the most useful contribution there is.

## Licence

MIT. Do what you want with it, including running your own. See [LICENSE](LICENSE).

## Not legal advice

Pay rates, statutory citations and regulatory notes in this repo are provided as-is and change often. Whether operating this in your jurisdiction requires licensing, insurance or registration depends entirely on where you are and how you run it. Verify before relying on any of it.
