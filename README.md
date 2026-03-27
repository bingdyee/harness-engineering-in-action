# Harness Engineering In Action

Harness Engineering: Long-running Autonomous Software Engineering

## Project Docs Content

```
AGENTS.md

ARCHITECTURE.md

docs/

├── design-docs/

│   ├── index.md

│   ├── core-beliefs.md

│   └── ...

├── exec-plans/

│   ├── active/

│   ├── completed/

│   └── tech-debt-tracker.md

├── generated/

│   └── db-schema.md

├── product-specs/

│   ├── index.md

│   ├── new-user-onboarding.md

│   └── ...

├── references/

│   ├── design-system-reference-llms.txt

│   ├── nixpacks-llms.txt

│   ├── uv-llms.txt

│   └── ...

├── DESIGN.md

├── FRONTEND.md

├── PLANS.md

├── PRODUCT\_SENSE.md

├── QUALITY\_SCORE.md

├── RELIABILITY.md

└── SECURITY.md

```

## 🛠️ Using Ralph - Harness-Engineering

1. Create a PRD
Use the PRD skill to generate a detailed requirements document:

Load the prd skill and create a PRD for [your feature description]
Answer the clarifying questions. The skill saves output to tasks/prd-[feature-name].md.

2. Convert PRD to Ralph format
Use the Ralph skill to convert the markdown PRD to JSON:

Load the ralph skill and convert tasks/prd-[feature-name].md to prd.json
This creates prd.json with user stories structured for autonomous execution.

3. Run Ralph with Claude Code
./scripts/ralph/ralph.sh --tool claude [max_iterations]
Default is 10 iterations. Use --tool amp or --tool claude to select your AI coding tool.

Ralph will:

1. Create a feature branch (from PRD branchName)
2. Pick the highest priority story where passes: false
3. Implement that single story
4. Run quality checks (typecheck, tests)
5. Commit if checks pass
6. Update prd.json to mark story as passes: true
7. Append learnings to progress.txt
8. Repeat until all stories pass or max iterations reached

## References

[OpenAI — Harness Engineering: Harnessing Codex in an Agent-First World](https://openai.com/zh-Hans-CN/index/harness-engineering/)
[Ralph Loop](https://github.com/snarktank/ralph)
