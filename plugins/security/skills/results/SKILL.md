---
name: results
description: View the most recent security scan results without re-running the scan
disable-model-invocation: true
allowed-tools:
  - Read
  - Bash
---

# Security Results

Display the most recent security scan report.

## Step 1: Check for Results

Look for `.security/report.md` in the project root.

If it exists, read and display the full report.

If it does not exist, display:

```
No security scan results found.

Run /security:scan to perform a security assessment.
```

## Step 2: Show Report Age

Check the file modification time:

```bash
stat -c %Y .security/report.md 2>/dev/null || stat -f %m .security/report.md 2>/dev/null
```

Display: "Last scan: [relative time ago]"

If the report is older than 24 hours, suggest: "Results are over 24 hours old. Consider running `/security:scan` for fresh results."

## Step 3: Display Report

Read and display `.security/report.md` in its entirety.
