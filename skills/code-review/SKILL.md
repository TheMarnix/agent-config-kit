---
name: code-review
description: Review a diff or pull request for correctness, security and maintainability. Use when asked to review changes, check a PR, or look over code before merge.
---

# Code review

An example skill. Edit it to match your team's standards.

## Process

1. Read the PR description or commit messages to learn the intent.
2. Read the diff in full before commenting.
3. Run the tests and linter if the project has them.

## What to look for, in order

1. **Correctness:** wrong results, unhandled errors, off-by-one, race conditions.
2. **Security:** injection, secrets in code, missing authorisation checks, unsafe deserialisation.
3. **Tests:** is the new behaviour covered, and would the test fail without the change?
4. **Maintainability:** duplicated logic, unclear names, comments that restate the code.

## Output

- List findings most severe first, each with file and line, the problem and a suggested fix.
- Say plainly when you found nothing. Do not pad the review.
