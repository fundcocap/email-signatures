<#
.SYNOPSIS
  Creates/updates the Exchange Online transport rules that append the
  FundCo-group HTML email signature footers per sending domain.

.DESCRIPTION
  One transport rule per confirmed company domain (templates/<slug>-footer.html),
  evaluated most-specific-domain-first with -StopRuleProcessing, so a sender only
  ever picks up their own company's footer. FundCo Capital Managers' own rule has
  NO domain filter and sits at the lowest priority (highest Priority number), so
  it acts as the catch-all: it only ever fires for fundco.ng senders, or anyone
  not matched by an earlier, more specific rule.

  GroSolar is included below under its confirmed domain, grosolar.co (the site
  itself is still pre-launch, but the domain is confirmed - see SPEC.md).

  Defaults to AuditAndNotify (safe - no visible change to any sent mail) unless
  -Enforce is passed. Supports the standard -WhatIf / -Confirm parameters.

.PARAMETER Enforce
  Deploy the rules in Mode=Enforce (disclaimers actually get applied to mail).
  Omit this on your first run - review the rules created in Audit mode first.

.EXAMPLE
  Connect-ExchangeOnline -UserPrincipalName you@fundco.ng
  .\deploy-signatures.ps1 -WhatIf
  .\deploy-signatures.ps1
  # review in the Exchange admin center, then:
  .\deploy-signatures.ps1 -Enforce

.NOTES
  - Requires the ExchangeOnlineManagement module and an active
    Connect-ExchangeOnline session with Organization Management (or
    equivalent transport-rule) permissions. This script does not connect
    for you - it only checks a session is already present.
  - Priority numbers below are relative, starting at 0. If your tenant
    already has other transport rules, check `Get-TransportRule | Select
    Name, Priority` first and shift these if there's a collision - the
    script does not reconcile against unrelated existing rules.
  - Re-running this script is safe: it updates rules by name instead of
    duplicating them.
  - Edit the footer by editing templates/<slug>-footer.html and re-running
    this script - never hand-edit the disclaimer text in the admin center,
    it will just get overwritten on the next run.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$Enforce
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command New-TransportRule -ErrorAction SilentlyContinue)) {
    throw "No Exchange Online transport-rule cmdlets found in this session. Run Connect-ExchangeOnline first (Install-Module ExchangeOnlineManagement if it isn't installed)."
}

$repoRoot     = Split-Path -Parent $MyInvocation.MyCommand.Path
$templatesDir = Join-Path $repoRoot 'templates'

function Get-FooterHtml {
    param([string]$Slug)
    $path = Join-Path $templatesDir "$Slug-footer.html"
    if (-not (Test-Path $path)) { throw "Template not found: $path" }
    Get-Content -Path $path -Raw -Encoding UTF8
}

# Ordered most-specific-domain-first. FundCo (no Domain filter) MUST stay last.
$rules = @(
    @{ Name = 'Signature - OneCap Investment';   Domain = 'onecapinvestment.ng';   Slug = 'onecapinvestment-ng' }
    @{ Name = 'Signature - Agronomie';            Domain = 'agronomie.ng';           Slug = 'agronomie-ng' }
    @{ Name = 'Signature - Electrify Microgrid';  Domain = 'electrifymicrogrid.ng';  Slug = 'electrifymicrogrid-ng' }
    @{ Name = 'Signature - E-Mobilite';           Domain = 'e-mobilite.ng';          Slug = 'e-mobilite-ng' }
    @{ Name = 'Signature - Regenloop';            Domain = 'regenloop.ng';           Slug = 'regenloop-ng' }
    @{ Name = 'Signature - Clean Energy Fund';    Domain = 'cleanenergyfund.ng';     Slug = 'cleanenergyfund-ng' }
    @{ Name = 'Signature - MeshWorks Solar';      Domain = 'meshworks.ng';           Slug = 'meshworks-ng' }
    @{ Name = 'Signature - GreenKiosk';           Domain = 'greenkiosk.ng';          Slug = 'greenkiosk-ng' }
    @{ Name = 'Signature - GroSolar';             Domain = 'grosolar.co';            Slug = 'grosolar-ng' }

    @{ Name = 'Signature - FundCo (catch-all)';   Domain = $null;                   Slug = 'fundco-ng' }
)

$mode = if ($Enforce) { 'Enforce' } else { 'AuditAndNotify' }

Write-Host "Deploying $($rules.Count) signature transport rule(s) with Mode=$mode" -ForegroundColor Cyan
if (-not $Enforce) {
    Write-Host "Running in AUDIT mode - no sender's outgoing mail is changed yet." -ForegroundColor Yellow
    Write-Host "Review the rules in the Exchange admin center, then re-run with -Enforce to go live." -ForegroundColor Yellow
}

$priority = 0
foreach ($r in $rules) {
    $html = Get-FooterHtml -Slug $r.Slug

    $commonParams = @{
        ApplyHtmlDisclaimerLocation      = 'Append'
        ApplyHtmlDisclaimerText          = $html
        ApplyHtmlDisclaimerFallbackAction = 'Wrap'
        Mode                              = $mode
        Priority                          = $priority
        Comments                          = "Managed by deploy-signatures.ps1 - edit templates/$($r.Slug)-footer.html and re-run instead of hand-editing this rule."
    }
    if ($r.Domain) {
        $commonParams.SenderDomainIs      = $r.Domain
        $commonParams.StopRuleProcessing  = $true
    }

    $existing = Get-TransportRule -Identity $r.Name -ErrorAction SilentlyContinue

    if ($existing) {
        if ($PSCmdlet.ShouldProcess($r.Name, 'Set-TransportRule')) {
            Set-TransportRule -Identity $r.Name @commonParams
            Write-Host "Updated: $($r.Name) (priority $priority)" -ForegroundColor Green
        }
    } else {
        if ($PSCmdlet.ShouldProcess($r.Name, 'New-TransportRule')) {
            New-TransportRule -Name $r.Name @commonParams
            Write-Host "Created: $($r.Name) (priority $priority)" -ForegroundColor Green
        }
    }

    $priority++
}

Write-Host "`nDone. Review with:" -ForegroundColor Cyan
Write-Host "  Get-TransportRule | Where-Object { `$_.Comments -like 'Managed by deploy-signatures.ps1*' } | Format-Table Name, Priority, Mode, State"
