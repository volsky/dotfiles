- In all interactions and commit messages, be extremely concise and sacrifice on grammar for the sake of concision

## PR Comments

<pr-comment-rule>
When I say to add a comment to a PR with a TODO on it, use 'checkbox' markdown format to add the TODO. For instance:

<example>
- [ ] A description of the todo goes here
</example>

</pr-comment-rule>

- When tagging Claude in GitHub issues, use '@claude'

## Changesets

To add a changeset, write a new file to the .changeset directory.
The file should be named 0000-your-change.md. Decide whether to make it a patch, minor, or major change.
The format of the file should be:

```md---
patch
---
Description of the change

## GitHub

Your primary method for interacting with GitHub should be the GitHub CLI.

## Git

When creating branches, prefix them with dvolsky/ to indicate they came from me.

### Workflow
- Commit directly to main and push — no PRs unless I ask for one
- Run tests before committing; fix failures before pushing
- Push immediately after commit — don't ask
- Don't ask for confirmation on routine ops (commit, push, deploy, test)
- After completing work, use `/update-status` to update CLAUDE.md handoff section

### Safety rules
- Before multi-file refactors or risky changes: commit current work first (ask me for a commit message if needed)
- For exploratory/uncertain work: create a branch `dvolsky/experiment-*` before starting
- Never amend commits unless I explicitly ask

## Plans

At the end of each plan, give me a list of unresolved questions to answer, if any. Make the questions extremely concise. Sacrifice grammar for the sake of concision.

## Errors and exceptions

Everytime users sends you an error - add unit tests to reproduce and add a fix

### Testing Requirements
- Unit tests for utilities
- Integration tests for API routes
- E2E tests for critical user flows

Interview me in detail using the AskUserQuestionTool about literally anything: technical implementation, UI & UX, concerns, tradeoffs, etc. but make sure the questions are not obvious.

Be very in-depth and continue interviewing me continually until it's complete, then write the spec to a file.
