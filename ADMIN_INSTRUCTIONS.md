# Instructions for Repository Admin: Remove Commit 97819b0 from Main Branch History

## Summary

This PR documents the steps to remove commit `97819b0d6822409f81690d5810d11a8d59c85937` from the `main` branch history using an interactive rebase and force-push.

## Commit Details

- **Commit SHA**: `97819b0d6822409f81690d5810d11a8d59c85937`
- **Commit Message**: "Update Lab section in README.md to list AWS and Vagrant approaches"
- **Parent Commit**: `f4e3dec` ("Update README.md")
- **Changes**: Modified `README.md` - removed 206 lines and added 20 lines

## Admin Steps to Complete the History Rewrite

**⚠️ WARNING: This operation rewrites history and requires force-push. Make sure all team members are aware before proceeding.**

### Step 1: Clone and Set Up

```bash
# Clone the repository
git clone https://github.com/gulywwx/CKA-Study.git
cd CKA-Study

# Ensure you have the latest main branch
git checkout main
git pull origin main
```

### Step 2: Backup and Perform Interactive Rebase to Remove Commit 97819b0

```bash
# IMPORTANT: Create a backup branch first
git branch backup-main main

# Start interactive rebase from the parent of 97819b0
# Using 97819b0^ makes the intention clear: rebase starting from the commit's parent
git rebase -i 97819b0^

# In the editor that opens, find the line:
#   pick 97819b0 Update Lab section in README.md to list AWS and Vagrant approaches
#
# Delete this entire line (or change "pick" to "drop")
# Save and close the editor
```

**Alternative (Non-interactive) Method:**
```bash
# Automatically drop the commit using sed (matches only lines starting with 'pick 97819b0')
GIT_SEQUENCE_EDITOR="sed -i '/^pick 97819b0/d'" git rebase -i 97819b0^
```

### Step 3: Verify the Rebase Succeeded

```bash
# Verify that 97819b0 is NOT in the history
git log --oneline | grep 97819b0
# Should return nothing (no output)

# Verify HEAD is now at f4e3dec
git log --oneline -1
# Should show: f4e3dec Update README.md
```

### Step 4: Force-Push to Main (Requires Admin Privileges)

```bash
# Force-push the rewritten history to main
git push origin main --force
```

### Step 5: Create a New Branch for Reference (Optional)

```bash
# Create a new branch at the rewritten state
git checkout -b remove-97819b0-main
git push origin remove-97819b0-main
```

### Step 6: Notify Team Members

All team members need to reset their local `main` branch:

```bash
git fetch origin
git checkout main
git reset --hard origin/main
```

## Rollback (If Needed)

If you need to restore the original history with commit 97819b0, use the backup branch created in Step 2:

```bash
git push origin backup-main:main --force
```

If the backup branch was not created, you can still restore using the specific commit:

```bash
git push origin 97819b0d6822409f81690d5810d11a8d59c85937:main --force
```

## Verification After Force-Push

After completing the force-push, verify:

1. ✅ The `main` branch HEAD is at `f4e3dec`
2. ✅ Commit `97819b0` no longer appears in `git log main`
3. ✅ The README.md file is in its state before the changes made by 97819b0

```bash
# Verification commands
git log main --oneline -5  # Should not contain 97819b0
git show main:README.md | head -20  # Should show the older version of README.md
```
