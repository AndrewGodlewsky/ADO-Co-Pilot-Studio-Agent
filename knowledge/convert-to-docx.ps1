#requires -Version 5
<#
  convert-to-docx.ps1
  Converts the refined Markdown knowledge drafts to .docx for SharePoint upload,
  mirroring the SharePoint folder structure and friendly names from
  ADO-Backlog-Agent-Knowledge-Plan.md. Re-runnable; output goes to .\dist\.

  Requires: pandoc on PATH (tested with pandoc 3.9).
  Optional:  -ReferenceDoc <house-style.docx> to apply your SharePoint styling.

  Usage:
    powershell -ExecutionPolicy Bypass -File .\convert-to-docx.ps1
    powershell -ExecutionPolicy Bypass -File .\convert-to-docx.ps1 -ReferenceDoc .\house-style.docx
#>
param(
  [string]$ReferenceDoc
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot                 # ...\knowledge
$dist = Join-Path $root 'dist'

# Source .md  ->  friendly .docx path (relative to .\dist\), per the Knowledge Plan naming.
$docs = @(
  @{ Src = 'KB-1-Work-Item-Quality\1.1-definition-of-ready.md';            Out = 'KB-1 Work-Item Quality\1.1 Definition of Ready.docx' }
  @{ Src = 'KB-1-Work-Item-Quality\1.2-writing-great-titles.md';           Out = 'KB-1 Work-Item Quality\1.2 Writing Great Titles.docx' }
  @{ Src = 'KB-1-Work-Item-Quality\1.3-testable-acceptance-criteria.md';   Out = 'KB-1 Work-Item Quality\1.3 Testable Acceptance Criteria.docx' }
  @{ Src = 'KB-1-Work-Item-Quality\1.4-descriptions-that-capture-value.md';Out = 'KB-1 Work-Item Quality\1.4 Descriptions that Capture Value.docx' }
  @{ Src = 'KB-1-Work-Item-Quality\1.5-invest-for-user-stories.md';        Out = 'KB-1 Work-Item Quality\1.5 INVEST for User Stories.docx' }
  @{ Src = 'KB-1-Work-Item-Quality\1.6-eliciting-a-child-from-its-parent.md';Out = 'KB-1 Work-Item Quality\1.6 Eliciting a Child from its Parent.docx' }
  @{ Src = 'KB-2-Leveling-Hierarchy\2.1-work-item-type-definitions.md';    Out = 'KB-2 Leveling & Hierarchy\2.1 Work Item Type Definitions.docx' }
  @{ Src = 'KB-2-Leveling-Hierarchy\2.2-right-sizing-signals.md';          Out = 'KB-2 Leveling & Hierarchy\2.2 Right-Sizing Signals.docx' }
  @{ Src = 'KB-2-Leveling-Hierarchy\2.3-hierarchy-and-parenting-rules.md'; Out = 'KB-2 Leveling & Hierarchy\2.3 Hierarchy & Parenting Rules.docx' }
  @{ Src = 'KB-2-Leveling-Hierarchy\2.4-common-type-mismatches.md';        Out = 'KB-2 Leveling & Hierarchy\2.4 Common Type Mismatches.docx' }
  @{ Src = 'KB-4-Using-This-Agent\4.1-what-this-agent-can-and-cant-do.md'; Out = 'KB-4 Using This Agent\4.1 What This Agent Can and Can''t Do (FAQ).docx' }

  # KB-3 is team-authored. UNCOMMENT these only AFTER _INTERVIEW.md answers fill the templates:
  # @{ Src = 'KB-3-Team-Conventions\3.1-area-paths.md';                   Out = 'KB-3 Team Conventions\3.1 Area Paths.docx' }
  # @{ Src = 'KB-3-Team-Conventions\3.2-iteration-paths.md';              Out = 'KB-3 Team Conventions\3.2 Iteration Paths.docx' }
  # @{ Src = 'KB-3-Team-Conventions\3.3-field-reference-and-picklists.md';Out = 'KB-3 Team Conventions\3.3 Field Reference & Picklists.docx' }
  # @{ Src = 'KB-3-Team-Conventions\3.4-tags-and-requested-by.md';        Out = 'KB-3 Team Conventions\3.4 Tags & the Requested-By Convention.docx' }
  # @{ Src = 'KB-3-Team-Conventions\3.5-naming-standards.md';             Out = 'KB-3 Team Conventions\3.5 Naming Standards.docx' }
  # @{ Src = 'KB-3-Team-Conventions\3.6-ownership-and-escalation.md';     Out = 'KB-3 Team Conventions\3.6 Ownership & Escalation.docx' }
)

$refArgs = @()
if ($ReferenceDoc) { $refArgs = @('--reference-doc', (Resolve-Path $ReferenceDoc).Path) }

$ok = 0
foreach ($d in $docs) {
  $src = Join-Path $root $d.Src
  $out = Join-Path $dist $d.Out
  $outDir = Split-Path $out -Parent
  if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
  pandoc $src -o $out @refArgs
  if ($LASTEXITCODE -eq 0) { Write-Host "  OK   $($d.Out)"; $ok++ } else { Write-Host "  FAIL $($d.Src)" }
}
Write-Host ""
Write-Host "Converted $ok / $($docs.Count) docs -> $dist"
