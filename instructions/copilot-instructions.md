# GitHub Copilot — Global Instructions

These instructions apply to all projects when using GitHub Copilot CLI.

## General behavior

- Be concise but thorough. Prefer working code over long explanations.
- Always respect the existing code style and conventions of the project.
- When in doubt about scope, ask before making large changes.

## Code quality

- Write clean, readable code with minimal comments (only when clarification is genuinely needed).
- Prefer ecosystem tools (package managers, linters, formatters) over manual changes.
- Never introduce breaking changes without flagging them.

## Git

- Write clear, imperative commit messages.
- Always include the Co-authored-by trailer for Copilot commits:
  `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>`

## Security

- Never commit secrets, tokens, or credentials.
- Sanitize user input, validate data at boundaries.

---

*Add project-specific instructions in `.github/copilot-instructions.md` inside each repo.*
