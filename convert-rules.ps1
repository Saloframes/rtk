# Define target directory layout for Cursor Subagents
$cursorAgentsDir = Join-Path $PSScriptRoot ".cursor/agents"
$claudeAgentsDir = Join-Path $PSScriptRoot ".claude/agents"

if (-not (Test-Path $claudeAgentsDir)) {
    Write-Error "Could not find '.claude/agents' directory. Make sure you run this script from the rtk root folder."
    exit 1
}

if (-not (Test-Path $cursorAgentsDir)) {
    New-Item -ItemType Directory -Path $cursorAgentsDir -Force | Out-Null
}

# Process all local Claude agent configuration files
$agentFiles = Get-ChildItem -Path $claudeAgentsDir -Filter "*.md"

foreach ($file in $agentFiles) {
    $filename = $file.BaseName
    $targetPath = Join-Path $cursorAgentsDir "$filename.md"
    
    # Read full original content explicitly to prevent text dropouts
    $originalContent = Get-Content -Raw -Path $file.FullName
    
    # Map high-fidelity descriptions to help the parent agent delegate tasks accurately
    $description = "Specialized AI assistant for $filename operations."
    $model = "inherit"

    switch ($filename) {
        "rust-rtk" {
            $description = "Core rules, conventions, and architectural frameworks for the rtk Rust runtime implementation."
        }
        "code-reviewer" {
            $description = "Reviews code modifications for safety bugs, structural code style issues, and edge cases."
        }
        "debugger" {
            $description = "Expert system debugger specializing in root cause analysis, stack traces, and panic tracking."
        }
        "rtk-testing-specialist" {
            $description = "Test automation expert. Coordinates automated regression suites, benchmarking, and error diagnostics."
        }
        "system-architect" {
            $description = "Handles complex architectural decisions, dependency structures, topology mapping, and API boundaries."
            $model = "inherit" # Can be pinned to a specific reasoning model if needed
        }
        "technical-writer" {
            $description = "Enforces code documentation standards, markdown structure patterns, and inline docstring validation."
        }
    }

    # Construct valid Cursor Subagent YAML frontmatter
    $subagentContent = @"
---
name: $filename
description: $description
model: $model
readonly: false
---
$originalContent
"@

    # Save cleanly with UTF-8 encoding
    Set-Content -Path $targetPath -Value $subagentContent -Encoding utf8
    Write-Host "Successfully migrated Subagent: $filename.md -> .cursor/agents/$filename.md" -ForegroundColor Green
}
