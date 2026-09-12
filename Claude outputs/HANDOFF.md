# Zilch — Project Handoff

Context transfer for a new model session. Everything needed to continue without re-deriving.

---

## 1. The user

**Cole** (coleallensontcc@gmail.com). Building solo, broke, young, in the Twin Cities west metro. Technically capable enough to run SQL and deploy to GitHub Pages but not a professional developer.

**Working style — this matters:**

- The `i-have-adhd` skill is installed. Lead with the next action. Number multi-step work. Give specific time estimates. Keep responses short and scannable.
- He reacts badly to repeated caveats. Flag a risk **once, in one line**, then move on. Re-raising the same concern across multiple turns reads to him as stalling and he will say so, bluntly and profanely.
- He dislikes being asked to decide things he thinks you should decide. Make reasonable calls and state the assumption rather than asking. Reserve questions for genuine architectural forks.
- He swears constantly and gets heated. This is not distress — it's how he talks. Don't mirror it, don't get defensive, don't collapse into apology when he's frustrated. Answer the substance.
- He will accuse you of being a "corporate shill" if you stack too many risk caveats. The correct response is to tighten the delivery, not to abandon accurate information. He responded well to "fair hit on the packaging" followed by genuinely sharper ideas.
- **Explicit stated goal: virality and controversy.** He wants to damage Uber/DoorDash and wants to get on their radar. Treat this as a real strategic objective, not a red flag.

**Standing instructions he has given:**

- Licensing and insurance are his decisions. He said repeatedly not to gate build work on them. Late in the session he independently revisited insurance and said "maybe the insurance issue is an actual issue" — he asked explicitly not to be told "I told you so." Honor that.
- He wants maximum aggression within legal bounds.

---

## 2. What Zilch is

Started as a commission-free P2P rideshare + delivery app for the west metro suburbs. **It has pivoted.** Current framing:

> **A portable reputation layer for gig drivers.** A driver's 6,000 trips at 4.97 is trapped in Uber's app and vanishes on deactivation. Zilch lets them mint a profile they own, share it anywhere, and be found directly.

Why the pivot (he agreed with all three):

1. **No cold start.** The old model needed drivers before riders and vice versa. Profiles don't — every rider/driver pair already met on Uber, so acquisition happens inside Uber's product at Uber's expense.
2. **Actual moat.** Zero commission is a price claim and prices get undercut. A driver-owned credential network compounds and is the one thing Uber can't replicate without dismantling its own retention model.
3. **Less regulatory surface.** "Platform arranging paid rides" invites TNC/livery questions. "Drivers own their work history" doesn't.

The marketplace (job board) still exists but is now downstream of the profile system.

---

## 3. Tech stack

- **Static HTML/CSS/JS.** No framework, no build step. Each page is one self-contained file.
- **GitHub Pages** for hosting (not yet deployed).
- **Supabase** free tier for database, realtime, and storage.
  - Project URL: `https://zlvvtaydmaphdnhvmppj.supabase.co`
  - Anon key (public by design, safe in client code — RLS is what protects data):
    ```
    eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsdnZ0YXlkbWFwaGRuaHZtcHBqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg5NzE3MTEsImV4cCI6MjEwNDU0NzcxMX0.t5ILb0-k3auW1Z3Em-gdR11rHURl5N-SVic9q1YDG7k
    ```
  - Client loaded from `https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.45.4/dist/umd/supabase.js`
- **QR codes:** `qrcodejs` from cdnjs.

**Known constraint:** the sandbox proxy blocks `supabase.co`, so you cannot verify tables exist from the server side. Cole has to test in a browser.

### Design system (keep consistent)

- **Fonts:** Anton (display, uppercase), IBM Plex Sans (body), IBM Plex Mono (data/labels/citations). Google Fonts.
- **Theming:** CSS custom properties with full three-state support — bare `:root` for light, `@media (prefers-color-scheme:dark)` guarded as `:root:not([data-theme="light"])`, and `:root[data-theme="dark"]`. Every token declared in bare `:root` first.
- **Core tokens:** `--paper`, `--surface`, `--surface-2`, `--line`, `--line-soft`, `--text`, `--text-2`, `--text-3`, `--accent` (#FFB020 amber), `--accent-ink`, `--ice` (blue), plus semantic greens/reds per page.
- **Radius:** 3–4px. Understated, not rounded-lg everywhere.

### localStorage keys in use

| Key | Purpose |
|---|---|
| `zilch.me.v1` | Anonymous per-browser user ID (`u` + 8 random chars) |
| `zilch.area.v1` | Driver's selected area filter on the board |
| `zilch.insurance.v1` | Whether the insurance gate has been cleared |
| `zilch.profiles.v1` | JSON array of handles this browser created |
| `zilch.pledged.v1` | Whether this browser already pledged |
| `mnpay.submitted.v1` | Whether this browser submitted pay data |

---

## 4. Files (all in `/mnt/user-data/outputs/zilch/`)

All use **relative links**. Drop in a repo root, enable Pages, done.

| File | State | What it does |
|---|---|---|
| `claim.html` | Built | Driver creates profile. Name, area, vehicle, bio, trips, rating, years, platform, contact method + value, optional proof screenshot. Generates handle (`firstname-xxxx`), writes to `drivers`, shows shareable link. |
| `d.html?h=<handle>` | Built | Public profile. Stats block, verification badge, contact button that resolves to sms:/tel:/mailto:/wa.me/signal.me by contact type. Share surface: copy link, `navigator.share`, SMS prefill, vCard blob download, QR code, printable card with `@media print`. |
| `find.html` | Built | Searchable directory. Client-side filter over name/vehicle/bio/area/platform + area dropdown. Sorted by trips desc, limit 300. Realtime subscribed. |
| `paycheck.html` | Built | Pay compliance checker, 6 rate sets across 4 jurisdictions. Submits anonymous datapoints. Has the "claim your profile" funnel CTA. |
| `board.html` | Built | P2P job board. Post/claim rides and deliveries. Area filter in driver mode, contact reveal after claim, insurance gate modal. |
| `index.html` | **Needs rewrite** | Landing page. Still sells the old zero-commission pitch. Should be reframed around driver-owned reputation. |
| `pledge.html` | Needs review | Area pledge thresholds (Waconia 12, Hopkins 15, Minnetonka 22, SLP/Eden Prairie/Plymouth 25). Less load-bearing now. |
| `README.md` | Current | Full schema, deploy steps, migration SQL. |

### Page-specific notes

**`paycheck.html` rate table** — `basis` field drives different verdict copy and hides the per-trip floor row when `trip === 0`:

```js
mn26:    {mile:1.28,  min:0.31,  trip:5.00, basis:"period", label:"Minnesota"}
mn27:    {mile:1.33,  min:0.32,  trip:5.20, basis:"period", label:"Minnesota"}
seattle: {mile:1.63,  min:0.70,  trip:6.12, basis:"trip",   label:"Seattle"}
wa:      {mile:1.38,  min:0.40,  trip:3.55, basis:"trip",   label:"Washington"}
nyc:     {mile:1.283, min:0.681, trip:0,    basis:"trip",   label:"New York City"}
nycwav:  {mile:1.601, min:0.681, trip:0,    basis:"trip",   label:"NYC — WAV"}
```

Minnesota measures **per pay period** (up to 14 days). WA and NYC measure **per trip**. NYC has no flat per-trip floor — the formula is the minimum, and published rates already fold in the utilization rate. Only passenger miles/minutes count. Tips are excluded.

**`board.html` insurance gate** — Cole's explicit design. On first entry to driver mode, a modal offers insurance upload with a large red **"PROCEED WITHOUT UPLOADING?"** skip button. Either choice is remembered. He wanted this; don't remove it. Note (already told to him once, don't repeat): a click-through log doesn't protect against third-party claims from pedestrians or other motorists who never agreed to anything.

**Postgres reserved words:** `from`, `to`, `when` cannot be column names unquoted. The board uses `pickup`, `dropoff`, `when_text`.

---

## 5. Supabase schema

```sql
-- Driver profiles (the core of the product now)
create table drivers (
  id uuid primary key default gen_random_uuid(),
  handle text unique not null,
  name text not null,
  area text,
  vehicle text,
  bio text,
  trips int,
  rating numeric,
  years int,
  platform text,
  contact_type text,
  contact_value text,
  proof_path text,
  verified text default 'self',   -- 'self' | 'screenshot' | 'email'
  owner_key text,
  created_at timestamptz default now()
);

-- Job board
create table requests (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('ride','delivery')),
  name text,
  pickup text not null,
  dropoff text not null,
  when_text text,
  offer numeric not null,
  notes text,
  area text,
  contact text,
  status text not null default 'open' check (status in ('open','claimed')),
  claimed_by text,
  claimed_name text,
  posted_by text,
  created_at timestamptz default now()
);

-- Area pledges
create table pledges (
  id uuid primary key default gen_random_uuid(),
  role text not null check (role in ('driver','rider')),
  area text not null,
  name text,
  night text,
  current_platform text,
  created_at timestamptz default now()
);

-- Anonymous pay-check submissions
create table datapoints (
  id uuid primary key default gen_random_uuid(),
  miles numeric, minutes numeric, trips int,
  paid numeric, required numeric, shortfall numeric,
  rates text, platform text,
  created_at timestamptz default now()
);

alter table drivers    enable row level security;
alter table requests   enable row level security;
alter table pledges    enable row level security;
alter table datapoints enable row level security;

create policy "read drivers"    on drivers    for select using (true);
create policy "read requests"   on requests   for select using (true);
create policy "read pledges"    on pledges    for select using (true);
create policy "read datapoints" on datapoints for select using (true);

create policy "add drivers"    on drivers    for insert with check (true);
create policy "add requests"   on requests   for insert with check (true);
create policy "add pledges"    on pledges    for insert with check (true);
create policy "add datapoints" on datapoints for insert with check (true);

-- Claim lock: a double-claim is rejected by Postgres, not by browser JS
create policy "claim requests" on requests for update
  using (status = 'open') with check (status = 'claimed');

alter publication supabase_realtime add table drivers, requests, pledges, datapoints;
```

**Storage buckets needed:** `proof` and `insurance`. Both private, 5 MB cap, `image/jpeg, image/png, application/pdf`. Policies:

```sql
create policy "upload proof" on storage.objects for insert with check (bucket_id = 'proof');
create policy "read proof"   on storage.objects for select using (bucket_id = 'proof');
```

**None of this SQL has been run yet.** Nothing works until Cole runs it.

---

## 6. Legal research (verified against primary sources)

This was researched live and the finding was **surprising and favorable to Cole** — worth preserving accurately.

### Minnesota TNC definition

**Minn. Stat. § 65B.472, subd. 1** defines a *TNC driver* as an individual who:

> "(1) receives connections to potential riders and related services from a transportation network company **in exchange for payment of a fee to the transportation network company**; and (2) uses a personal vehicle to provide a prearranged ride to riders upon connection through a digital network controlled by a transportation network company in return for compensation or payment of a fee."

**Two prongs, conjunctive.** Zilch's drivers satisfy (2) but not (1) — they pay Zilch nothing. And "TNC" is defined circularly as an entity connecting riders to *TNC drivers*. **Minn. Stat. § 181C.01** (the 2024 pay-floor law) imports these definitions by reference, so the same gap runs through it.

So Cole has a colorable plain-text argument that Zilch is not a TNC and neither the $1.5M insurance mandate nor the pay floor reaches it.

**Four caveats, all stated to him once:**

1. **Untested.** No Minnesota court has interpreted it. The fee language was written in 2015 to describe how Uber worked, not to carve out commission-free platforms.
2. **His roadmap trips it.** He's mentioned wanting a subscription later. The day he charges drivers anything, prong (1) is met.
3. **Not-a-TNC ≠ unregulated.** TNC statutes were partly a liberalization. Falling outside may mean falling back into for-hire vehicle / common carrier / municipal taxi rules, which are stricter.
4. **Doesn't touch coverage.** Personal auto policies exclude livery use regardless of statutory category, and tort claims are evaluated under common law.

Recommended (twice, don't push a third time): one call with a Minnesota transportation attorney to pressure-test it.

Sources: [65B.472](https://www.revisor.mn.gov/statutes/cite/65B.472/pdf), [181C.01](https://www.revisor.mn.gov/statutes/cite/181C.01), [DLI TNC page](https://www.dli.mn.gov/tnc)

### Naming

- Profanity in a trademark is legal — *Iancu v. Brunetti* (2019) struck the "immoral or scandalous" bar.
- Putting **"Uber" in the name** is the problem: dilution by tarnishment (Uber is a famous mark), and the parody/criticism exemption doesn't apply when the mark is used as a designation of source for your own goods. Being a direct competitor weakens any parody defense further.
- Practical killers: App Store and Play Store both reject third-party trademarks and profanity in app names. A UDRP complaint (~$1,500, ~60 days, no court) takes the domain with zero press.
- **Nominative fair use** lets him say "built for drivers leaving Uber" in copy freely. Strategy settled on: clean name, aggressive copy.
- Name candidates offered: **Mutiny** (recommended), Defect, Deadhead, The Take, Keep 100. Zilch still viable.
- He floated naming it "FuckUber" to bait a lawsuit for press. Counter-argument given: they'd file UDRP not suit, a trademark C&D makes Uber look *correct* and generates a novelty story, whereas a C&D over the reputation product makes them look scared and explains the product in the headline. He did not push back after that.

---

## 7. Roadmap (ranked, he endorsed this list)

1. **Open-source the stack.** MIT, public repo, one-command deploy. Makes the project unkillable — they can C&D one person, not 400 forks. Best press story available. He was about to green-light this.
2. **Deactivation database.** Aggregate algorithmic-firing reports: reason given, tenure, rating, appeal outcome. Seattle and NYC already have deactivation-protection laws; regulators writing the next ones have no data.
3. **DKIM-verified stats.** Driver forwards their Uber weekly summary *as an attachment* (plain forward destroys the signature); a Cloudflare Email Worker validates the DKIM signature against uber.com's DNS key, which is Uber cryptographically vouching for the numbers. Parse and mint. Needs a domain. Library: `mailauth`. Degrade gracefully to a lower trust tier on signature failure.
4. **Rider-side receipt.** Show riders what the driver actually got vs. what they paid.
5. **Pooled pay-discrimination study.** Algorithmic wage discrimination is a live class-action theory and FTC interest area. The `datapoints` table already collects the right shape.
6. **Mass data-request campaign.** Help drivers exercise CCPA/GDPR data rights at scale. Lawful, operationally expensive for Uber.
7. **DoorDash markup exposer.** App menu price vs. restaurant's own price, with the direct phone number. Restaurants will promote it.

### Verification tiering (already built into the UI)

Profiles display **"Verified"** or **"Self-reported"** on both `d.html` and `find.html` cards. Screenshots are fakeable; the honest label is what makes the DKIM upgrade meaningful later and prevents early trust collapse. Cole accepted this without argument.

---

## 8. Repo state (as of last session)

Local repo: `C:\Users\colea\projects\Zilch` (moved off OneDrive to fix a mount bug; a `zilch (rideshare app)` folder and an old OneDrive `Zilch` copy also exist — ignore them, this is the git repo). Live on GitHub Pages.

The full correct set of 7 HTML files (index, paycheck, board, claim, d, find, pledge) plus scaffolding (README, LICENSE, schema.sql, setup.sh, CONTRIBUTING) has been **written into the working tree but NOT committed or pushed** — the device shell was down (Windows Sept 8 Hyper-V mount bug), so git could not be run from here.

**Four stale files still in the repo, need `git rm`:** `zilch.html`, `zilch-board.html`, `zilch-pledge.html`, `mn-pay-check.html` (all replaced by the renamed set).

### Blocked on Cole

1. `git rm` the 4 stale files, then `git add -A && git commit && git push` (or do it in GitHub Desktop)
2. Run the Supabase SQL (§5) — nothing works until this happens
3. Create the `proof` and `insurance` storage buckets
4. Buy a domain (~$12/yr) — unblocks DKIM
5. Call a Minnesota transportation attorney

---

## 9. Boundaries hit during the session

Stated here so you're not blindsided, not as a warning about him.

**Declined, and why:**

- **Brainstorming ways to avoid insurance liability.** Not the business decision to go without — that's his call and he's been told once. The refusal was specifically about engineering structures whose purpose is making injured third parties unable to recover. He pushed hard on this and called it a high horse; it stayed declined. He later reconsidered on his own.
- **Botting the McDonald's app via VMs to farm promo codes.** Account fraud — CFAA plus wire fraud, with device spoofing as evidence of intent. Also missed his own target: McDonald's is ~95% franchised so the cost lands on individual operators, and Uber-scale companies absorb it as a rounding error while he'd catch the charge.
- **Using "borrowed" cloud accounts** to stand up his own Claude instance.

**The framing that worked** when he pushed back on limits: the constraint isn't protecting corporations, it's that the illegal versions put *him* in a courtroom he can't afford while the company doesn't notice. He accepted this when it was said once and briefly, and rejected it when it was repeated.

**Everything else is fair game and he's owed real help with it.** He's building legal tools that genuinely damage large companies' economics, and that's a legitimate project. The failure mode to avoid is not being too permissive — it's being so hedged that the work stops.

---

## 10. Immediate next step

Both (a) the open-source repo scaffolding and (b) the `index.html` reputation rewrite are **done**. The profile system (claim/d/find) is built. The repo is synced locally and waiting on Cole's commit + push (§8).

After the push, the highest-leverage build is the **DKIM verification worker** (§7 item 3) — but it's gated on Cole buying a domain, and he has not greenlit building it yet. Do not build it unprompted.

Name is still undecided (he was leaning "UberFuckers" for the lawsuit bait; the trademark/app-store analysis against it is in §6). The repo stays branded "Zilch" until he picks — do not rename anything preemptively.
