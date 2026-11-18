# Manifest — logo placeholder tokens and their real URLs

Every footer template was originally authored with a `[LOGO_URL_<SLUG>]` placeholder
token in its banner `<img src>` (per SPEC.md rule #3). All ten have since been replaced
with real, publicly reachable `raw.githubusercontent.com` URLs pointing at the matching
file in `export/` — this file is the traceability record of that replacement, not an
outstanding to-do list.

A copy of this same `export/` folder has also been uploaded to SharePoint
(`fundcong.sharepoint.com/sites/email-signatures`) for internal review — the files
there are byte-identical to the ones listed below; GitHub remains the one actually
hotlinked by the HTML.

| Company | Template | Placeholder token (original) | Live URL (current) |
|---|---|---|---|
| FundCo Capital Managers | `fundco-ng-footer.html` | `[LOGO_URL_FUNDCO_NG]` | `https://raw.githubusercontent.com/FundCo-Capital-Managers-Limited/email-signatures/main/export/fundco-ng-logo-signature@2x.png` |
| OneCap Investment Limited | `onecapinvestment-ng-footer.html` | `[LOGO_URL_ONECAPINVESTMENT_NG]` | `https://raw.githubusercontent.com/FundCo-Capital-Managers-Limited/email-signatures/main/export/onecapinvestment-ng-logo-signature@2x.png` |
| Agronomie | `agronomie-ng-footer.html` | `[LOGO_URL_AGRONOMIE_NG]` | `https://raw.githubusercontent.com/FundCo-Capital-Managers-Limited/email-signatures/main/export/agronomie-ng-logo-signature@2x.png` |
| Electrify Microgrid Limited | `electrifymicrogrid-ng-footer.html` | `[LOGO_URL_ELECTRIFYMICROGRID_NG]` | `https://raw.githubusercontent.com/FundCo-Capital-Managers-Limited/email-signatures/main/export/electrifymicrogrid-ng-logo-signature@2x.png` |
| E-Mobilite | `e-mobilite-ng-footer.html` | `[LOGO_URL_E_MOBILITE_NG]` | `https://raw.githubusercontent.com/FundCo-Capital-Managers-Limited/email-signatures/main/export/e-mobilite-ng-logo-signature@2x.png` |
| Regenloop | `regenloop-ng-footer.html` | `[LOGO_URL_REGENLOOP_NG]` | `https://raw.githubusercontent.com/FundCo-Capital-Managers-Limited/email-signatures/main/export/regenloop-ng-logo-signature@2x.png` |
| Clean Energy Local Currency Fund | `cleanenergyfund-ng-footer.html` | `[LOGO_URL_CLEANENERGYFUND_NG]` | `https://raw.githubusercontent.com/FundCo-Capital-Managers-Limited/email-signatures/main/export/cleanenergyfund-ng-logo-signature@2x.png` |
| MeshWorks Solar Limited | `meshworks-ng-footer.html` | `[LOGO_URL_MESHWORKS_NG]` | `https://raw.githubusercontent.com/FundCo-Capital-Managers-Limited/email-signatures/main/export/meshworks-ng-logo-signature@2x.png` |
| GreenKiosk | `greenkiosk-ng-footer.html` | `[LOGO_URL_GREENKIOSK_NG]` | `https://raw.githubusercontent.com/FundCo-Capital-Managers-Limited/email-signatures/main/export/greenkiosk-ng-logo-signature@2x.png` |
| GroSolar **(pre-launch, domain confirmed as grosolar.co)** | `grosolar-ng-footer.html` | `[LOGO_URL_GROSOLAR_NG]` | `https://raw.githubusercontent.com/FundCo-Capital-Managers-Limited/email-signatures/main/export/grosolar-ng-logo-signature@2x.png` |

Notes:
- Every URL above resolves to a 1x-display, 2x-resolution PNG; the `<img>` tag in each
  template sets `width`/`height` to the 1x size so it renders crisp on retina displays
  without visually bloating the footer.
- GroSolar's real domain is confirmed as `grosolar.co` (the site itself is still
  pre-launch) — its transport rule is deployed like every other company's, see
  `deploy-signatures.ps1`.
- Open item, not yet decided: whether the `email-signatures` GitHub repo staying public
  (required for anonymous `raw.githubusercontent.com` hotlinking) is acceptable
  long-term, or whether the images should move to a private host with public-read only
  on the image objects (e.g. Azure Blob Storage) instead.
