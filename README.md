# FundCo group — Exchange Online email signatures

One HTML footer (Exchange Online transport-rule disclaimer) per company, built per
the shared design spec in [SPEC.md](SPEC.md). See [MANIFEST.md](MANIFEST.md) for
the logo-URL traceability record.

## What's in here

```
export/           banner PNGs, 1x + 2x, per company
templates/        the 10 footer HTML files actually deployed
previews/         rendered screenshot of each footer, for a quick visual check
source-assets/    intermediate/cropped logo files used to build the banners
SPEC.md           original design brief
MANIFEST.md       logo placeholder -> real URL traceability record
deploy-signatures.ps1   Exchange Online transport-rule deployment script
```

## Per-company reference

| Company | Template | Domain | Font fallback stack | Size (chars) |
|---|---|---|---|---|
| FundCo Capital Managers | `fundco-ng-footer.html` | fundco.ng | `'Segoe UI', Arial, Helvetica, sans-serif` (site font Montserrat, geometric) | 4,593 |
| OneCap Investment Limited | `onecapinvestment-ng-footer.html` | onecapinvestment.ng | `Arial, Helvetica, sans-serif` (site font Inter, grotesque/neutral) | 3,452 |
| Agronomie | `agronomie-ng-footer.html` | agronomie.ng | `'Segoe UI', Arial, Helvetica, sans-serif` (site font Poppins, geometric) | 3,360 |
| Electrify Microgrid Limited | `electrifymicrogrid-ng-footer.html` | electrifymicrogrid.ng | `'Segoe UI', Arial, Helvetica, sans-serif` (site font Poppins, geometric) | 4,117 |
| E-Mobilite | `e-mobilite-ng-footer.html` | e-mobilite.ng | `'Segoe UI', Arial, Helvetica, sans-serif` (site font Space Grotesk, geometric) | 3,606 |
| Regenloop | `regenloop-ng-footer.html` | regenloop.ng | `'Segoe UI', Arial, Helvetica, sans-serif` (site font Sora, geometric) | 3,081 |
| Clean Energy Local Currency Fund | `cleanenergyfund-ng-footer.html` | cleanenergyfund.ng | heading `'Segoe UI', Arial, Helvetica, sans-serif` (Montserrat) / body `Arial, Helvetica, sans-serif` (Open Sans) | 3,512 |
| MeshWorks Solar Limited | `meshworks-ng-footer.html` | meshworks.ng | `'Segoe UI', Arial, Helvetica, sans-serif` (site font Geist, geometric) | 4,022 |
| GreenKiosk | `greenkiosk-ng-footer.html` | greenkiosk.ng | `'Segoe UI', Arial, Helvetica, sans-serif` (site font Geist, geometric) | 3,815 |
| GroSolar **(pre-launch — domain unconfirmed)** | `grosolar-ng-footer.html` | grosolar.ng *(placeholder)* | `Arial, Helvetica, sans-serif` (no brand font established yet, deliberately neutral) | 3,475 |

All 10 are well under the spec's ~8,000-character ceiling (checked via `wc -c`, matches
the spec's `(Get-Content file -Raw).Length` check).

**No file uses JavaScript or forms.** Confirmed by grepping every template for
`<script`, `<form`, `onclick`, and `javascript:` — zero matches across all 10. These
are plain table-based HTML with every style inline, as required for Outlook/OWA/mobile
rendering reliability.

**Image hosting.** All banner images are hotlinked from this repo's own public GitHub
remote (`raw.githubusercontent.com/FundCo-Capital-Managers-Limited/email-signatures/...`)
— the repo is public specifically so these URLs resolve with no auth, which is what
lets them load in Outlook/OWA/mobile without any sign-in prompt. See MANIFEST.md for
the full URL list. A mirror of the same files was separately uploaded to SharePoint for
internal review, but GitHub is the one actually referenced by the live HTML.

Whether staying on a public GitHub repo is acceptable long-term, versus moving the
images to a private host with public-read only on the image objects (e.g. Azure Blob
Storage), is still an open decision — not resolved by this README.

## Deploying to Exchange Online

The footers are deployed as Exchange Online **transport rules** (server-side HTML
disclaimers), not as per-user Outlook signature settings — this way they apply to
every outgoing message regardless of device or Outlook version, with zero per-person
setup.

```powershell
# 1. Install the module if you don't already have it
Install-Module ExchangeOnlineManagement

# 2. Connect with an account that has Organization Management
#    (or equivalent transport-rule) permissions
Connect-ExchangeOnline -UserPrincipalName you@fundco.ng

# 3. Dry-run first - creates/updates the rules in Audit mode, no mail is
#    actually changed yet
cd email-signatures
.\deploy-signatures.ps1

# 4. Review what was created in the Exchange admin center
#    (Mail flow -> Rules), or from PowerShell:
Get-TransportRule | Where-Object { $_.Comments -like 'Managed by deploy-signatures.ps1*' } | Format-Table Name, Priority, Mode, State

# 5. Send a few test emails from each domain and confirm the footer renders
#    correctly (Outlook desktop, OWA, and at least one mobile client)

# 6. Go live
.\deploy-signatures.ps1 -Enforce
```

Notes:
- Rules are ordered most-specific-domain-first with `-StopRuleProcessing`, so a
  sender only ever picks up their own company's footer. FundCo's own rule has no
  domain filter and sits last, acting as the catch-all for fundco.ng senders and
  anyone not matched by an earlier rule.
- GroSolar is deliberately **not** deployed by the script yet — `grosolar.ng` is an
  unconfirmed placeholder domain with no live site. Its template and banner exist
  and are correct; uncomment its block in `deploy-signatures.ps1` once the real
  domain is confirmed.
- To change a footer later: edit the template HTML in `templates/`, then re-run
  `deploy-signatures.ps1` — never hand-edit the disclaimer text directly in the
  admin center, it'll just get overwritten on the next script run.
- If your tenant already has other transport rules, check `Get-TransportRule |
  Select Name, Priority` before running — the script assigns priorities 0 upward
  and doesn't reconcile against unrelated existing rules.
