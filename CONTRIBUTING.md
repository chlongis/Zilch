# Contributing

## The most useful thing you can do

Run it in your city and report what broke. Every fork so far has hit something the original didn't: different pay law, different geography, a platform that formats its stats screen differently. That feedback is worth more than code.

## Ground rules

**No build step.** Static HTML, inline CSS and JS, one file per page. If a change requires npm, a bundler or a framework, it belongs in a fork rather than here. The whole point is that a driver with a Chromebook can read the source.

**No commission, ever.** Any change that inserts a cut, a fee, a markup or a rev-share between a rider and a driver will be closed. That's not a style preference — it's the only reason the project exists.

**Label uncertainty honestly.** If a stat isn't verified, the UI says so. Don't add badges that imply a check nobody performed.

**Keep the database boring.** Row level security on every table, public read and insert, no `service_role` key in client code, and no personal data stored beyond a display name and whatever contact method someone deliberately published.

## Adding a jurisdiction to the pay checker

This is the easiest high-value contribution. Add an entry to the `RATES` object in `paycheck.html`:

```js
yourplace: {
  mile: 1.42, min: 0.38, trip: 4.10,
  basis: "trip",              // "trip" or "period"
  label: "Your City",
  cite: "Statute or rule number",
  who: "Agency that takes complaints",
  tel: "...", email: "..."
}
```

Then add an `<option>` to the selector. Set `trip: 0` if there's no flat per-trip floor — the row hides itself.

**Cite the primary source in your pull request.** A link to the actual statute, rule or agency page, not a news article about it. Rates get quoted back to regulators and an incorrect one is worse than a missing one.

## Reporting a bug

Say what you did, what happened, what you expected, and which browser. If it's a database error, include what the Supabase logs said. A screenshot of a broken layout with the browser width is enough for a CSS bug.

## Security

If you find something that exposes user data or lets someone write where they shouldn't, open an issue marked **security** with enough detail to reproduce it. Don't post working exploit steps against a live deployment that isn't yours.
