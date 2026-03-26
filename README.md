# harness-engineering-in-action

Harness Engineering: Long-running Autonomous Software Engineering


分析以下链接中的内容，输出一份Harness-engineering分享文档，文档最后给出基于 ralph + superpowers 实现harness-engineering的实践：
1、https://github.com/deusyu/harness-engineering；
2、https://openai.com/zh-Hans-CN/index/harness-engineering/；
3、https://tw93.fun/2026-03-21/agent.html；
4、https://github.com/snarktank/ralph；
5、https://github.com/obra/superpowers；


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

渐进式披露 + GIT Worktree + Agent Loop

## References

[OpenAI — Harness Engineering: Harnessing Codex in an Agent-First World](https://openai.com/zh-Hans-CN/index/harness-engineering/)
[Ralph Loop](https://github.com/snarktank/ralph)