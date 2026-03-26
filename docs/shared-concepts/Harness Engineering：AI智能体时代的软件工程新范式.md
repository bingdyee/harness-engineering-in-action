# Harness Engineering：AI智能体时代的软件工程新范式

> **文档版本**: v1.0  
> **生成日期**: 2026年3月27日  
> **适用对象**: 软件工程师、AI应用开发者、技术管理者

---

## 📚 目录

1. [核心概念](#核心概念)
2. [与传统工程的对比](#与传统工程的对比)
3. [关键原则](#关键原则)
4. [核心组件](#核心组件)
5. [实践方法](#实践方法)
6. [成功案例](#成功案例)
7. [实践指南：基于 Ralph + Superpowers 实现](#实践指南基于-ralph--superpowers-实现)
8. [总结与展望](#总结与展望)

---

## 核心概念

### 什么是 Harness Engineering？

**Harness Engineering（驭缰工程）** 是继 Prompt Engineering 和 Context Engineering 之后的第三次AI工程范式跃迁。它是一种围绕AI智能体构建的**测试、验证与约束基础设施**，包括：

- **验收基线**：明确任务完成标准的可执行条件
- **执行边界**：通过工作空间隔离、白名单等机制限制Agent的操作范围
- **反馈信号**：利用日志、指标、追踪等可观测性数据提供实时反馈
- **回退手段**：确保任务状态可持久化、可恢复，避免单点失败导致全盘崩溃

> **核心洞察**：模型虽然重要，但决定系统能否稳定运行的，往往是这些外围工程条件。Harness 要做的就是把任务推进到"目标明确、结果可自动验证"的状态。

### 与前两代范式的对比

| 范式 | 关注点 | 核心问题 | 解决方案 |
|------|--------|----------|----------|
| **Prompt Engineering** | 如何提问 | "如何让模型理解我的意图" | 精心设计的提示词模板 |
| **Context Engineering** | 如何提供信息 | "如何让模型获得足够的背景知识" | RAG、知识库、上下文窗口优化 |
| **Harness Engineering** | 如何约束行为 | "如何让模型在边界内可靠执行" | 自动化测试、质量门控、反馈循环 |

---

## 与传统工程的对比

### 传统软件工程 vs Harness Engineering

| 维度 | 传统软件工程 | Harness Engineering |
|------|-------------|---------------------|
| **核心角色** | 人类工程师编写代码 | AI智能体编写代码，人类设计约束系统 |
| **知识传递** | 文档、注释、口头交流 | 仓库即记录系统，所有内容必须版本化 |
| **质量控制** | 人工Code Review + CI/CD | 自动化linter、结构测试、自我纠正机制 |
| **合并策略** | 谨慎合并，长时间审查 | 快速合并，偶发失败通过重跑解决 |
| **技术债** | 定期人工重构 | 自动扫描偏差、定期发起重构PR |

### 核心理念转变

1. **从"编写代码"到"设计约束"**  
   工程师的核心工作不再是直接编写代码，而是设计让AI能够可靠执行的约束系统。

2. **从"事后审查"到"前置约束"**  
   通过linter、类型系统、CI规则在AI执行过程中就强制执行规范，而非依赖事后的人工审查。

3. **从"完全正确"到"快速纠错"**  
   在智能体吞吐量远超人类注意力的系统中，纠错成本低于等待成本，PR生命周期缩短。

---

## 关键原则

### 1. 仓库即记录系统（Repo as Source of Truth）

**核心思想**：所有决策、规范、计划必须版本化并存入仓库，否则对智能体不可见。

- 不在仓库中的内容（如Slack讨论、脑内知识）无法被智能体使用
- 外部文档按需注入，但核心知识必须内置化
- Git不仅是版本控制，更是AI智能体间的交接机制

**实践要点**：
```
项目根目录/
├── AGENTS.md          # 智能体导航入口（约100行）
├── concepts/          # 核心概念文档
│   └── AGENTS.md      # 该目录的使用说明
├── practice/          # 实践指南
│   └── AGENTS.md
└── feedback/          # 反馈循环机制
    └── AGENTS.md
```

### 2. 地图而非手册（Map, Not Manual）

**核心思想**：使用渐进式披露，避免编写冗长的指令文件。

- AGENTS.md作为入口文件（约100行），指向更深层文档
- 长文件会挤占上下文、难以维护和验证
- 智能体从小入口点开始，逐步深入细节

**错误做法**：
```markdown
# AGENTS.md（500行的详细手册）
这里是关于如何开发的所有细节...（内容过多）
```

**正确做法**：
```markdown
# AGENTS.md
本项目采用模块化架构，各模块说明见：
- 数据层：见 `data/AGENTS.md`
- 业务层：见 `service/AGENTS.md`
- API层：见 `api/AGENTS.md`
```

### 3. 机械化执行（Mechanistic Enforcement）

**核心思想**：通过自定义linter和结构测试自动化执行规则，确保文档不"腐烂"。

- lint错误信息内嵌修复指令，使智能体可自我纠正
- 结构测试守护系统不变量，确保架构规则被遵守
- 不依赖文档规范，而是通过代码强制执行

**示例：自定义linter规则**
```yaml
# .linterrc.yml
rules:
  - name: "require-agents-md"
    pattern: "**/"
    check: "exists('AGENTS.md')"
    message: |
      ❌ 每个模块目录必须包含 AGENTS.md
      💡 创建一个 AGENTS.md 文件，说明该模块的用途和开发规范
```

### 4. 智能体可读性优先

**核心思想**：优先选择API稳定、训练集覆盖好的"无聊"技术。

- 避免使用过于新颖或小众的技术栈
- 必要时重新实现子集，而非包装不透明的上游行为
- 选择训练数据中常见的设计模式

**技术选型建议**：
- ✅ React（训练数据丰富）
- ❌ 上周刚发布的新框架
- ✅ REST API（稳定可预测）
- ❌ 复杂的GraphQL自定义指令

### 5. 吞吐量改变合并理念

**核心思想**：PR生命周期短，测试偶发失败可通过重跑解决。

在智能体吞吐量远超人类注意力的系统中：
- 纠错成本 < 等待成本
- 快速合并 > 完美合并
- 自动重试机制处理偶发失败

**实践策略**：
```yaml
# CI配置
retry:
  max_attempts: 3
  delay: 30s
  conditions:
    - "test_flakiness_detected"
```

### 6. 熵管理 = 垃圾回收

**核心思想**：技术债如高息贷款，智能体会复现仓库中的坏模式。

- 定期扫描偏差、更新质量评分
- 发起重构PR，编码"黄金规则"进仓库
- 后台任务自动检测技术债

**自动化熵管理**：
```bash
# 每日自动扫描脚本
#!/bin/bash
# 扫描代码质量偏差
npm run quality-scan

# 检测重复代码
npx jscpd --min-lines 50 --reporters json

# 自动发起重构PR
if [ quality_score < 80 ]; then
  gh pr create --title "自动重构：提升代码质量" --body "..."
fi
```

---

## 核心组件

### 1. 验收基线（Acceptance Baseline）

**定义**：明确任务完成标准的可执行条件。

**组成部分**：
- 功能验收：单元测试、集成测试
- 性能验收：性能基准测试
- 安全验收：安全扫描、依赖检查

**示例**：
```json
{
  "story": "用户登录功能",
  "acceptance_criteria": [
    "tests/login.test.ts 通过",
    "类型检查无错误",
    "浏览器验证：登录表单可提交",
    "安全扫描：无高危漏洞"
  ],
  "passes": false
}
```

### 2. 执行边界（Execution Boundary）

**定义**：通过工作空间隔离、白名单等机制限制Agent的操作范围。

**实现方式**：
- **文件系统隔离**：使用git worktree或Docker容器
- **操作白名单**：只允许执行预定义的命令
- **网络隔离**：限制外部网络访问
- **权限控制**：最小权限原则

**示例配置**：
```json
{
  "execution_boundary": {
    "allowed_paths": ["src/", "tests/", "docs/"],
    "forbidden_paths": [".env", "secrets/", "production/"],
    "allowed_commands": ["npm", "git", "docker"],
    "network_whitelist": ["registry.npmjs.org"]
  }
}
```

### 3. 反馈信号（Feedback Signal）

**定义**：利用日志、指标、追踪等可观测性数据提供实时反馈。

**反馈类型**：
- **即时反馈**：编译错误、测试失败
- **延迟反馈**：性能指标、用户行为
- **异常反馈**：错误日志、崩溃报告

**可观测性架构**：
```
AI Agent
   ↓
[执行代码]
   ↓
[监控层] → 日志收集器 → 结构化日志
   ↓
[指标层] → Prometheus → 性能指标
   ↓
[追踪层] → Jaeger → 分布式追踪
   ↓
[反馈层] → AI Agent 接收反馈
```

### 4. 回退手段（Rollback Mechanism）

**定义**：确保任务状态可持久化、可恢复，避免单点失败导致全盘崩溃。

**机制设计**：
- **检查点（Checkpoint）**：定期保存任务状态
- **原子性更新**：要么全部成功，要么全部回滚
- **版本回退**：Git历史记录作为安全网

**状态持久化**：
```json
{
  "task_id": "implement-login-001",
  "checkpoints": [
    {
      "step": 1,
      "description": "设计数据模型",
      "state_file": "checkpoints/001-model.json",
      "timestamp": "2026-03-27T10:00:00Z"
    },
    {
      "step": 2,
      "description": "实现API端点",
      "state_file": "checkpoints/002-api.json",
      "timestamp": "2026-03-27T10:15:00Z"
    }
  ],
  "rollback_to": "checkpoints/001-model.json"
}
```

---

## 实践方法

### 1. 仓库结构设计

**最佳实践**：

```
project/
├── AGENTS.md                    # 根导航入口（必需）
├── .harness/                    # Harness配置目录
│   ├── linter/                  # 自定义linter规则
│   ├── tests/                   # 结构测试
│   └── scripts/                 # 自动化脚本
├── src/                         # 源代码
│   └── AGENTS.md               # 模块说明
├── tests/                       # 测试代码
│   └── AGENTS.md
├── docs/                        # 文档
│   ├── concepts/               # 核心概念
│   ├── practice/               # 实践指南
│   └── feedback/               # 反馈机制
└── .github/
    └── workflows/              # CI/CD配置
        ├── quality-gate.yml    # 质量门控
        └── entropy-scan.yml    # 熵管理扫描
```

### 2. 自动化质量门控

**质量门控配置**：

```yaml
# .github/workflows/quality-gate.yml
name: Quality Gate
on: [push, pull_request]

jobs:
  quality-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      # 类型检查
      - name: Type Check
        run: npm run type-check
      
      # 单元测试
      - name: Unit Tests
        run: npm test
        continue-on-error: true
      
      # 结构测试
      - name: Structure Tests
        run: npm run test:structure
      
      # 自定义linter
      - name: Custom Linter
        run: npm run lint:harness
      
      # 质量评分
      - name: Quality Score
        run: |
          SCORE=$(npm run quality-score)
          echo "Quality Score: $SCORE"
          if [ $SCORE -lt 80 ]; then
            echo "❌ Quality gate failed"
            exit 1
          fi
```

### 3. 三层自愈机制

**设计理念**：重试 → 重启 → 诊断

```
┌─────────────┐
│  执行任务   │
└──────┬──────┘
       │
       ▼
┌─────────────┐     成功     ┌──────────┐
│  质量检查   │ ─────────────→│ 更新状态 │
└──────┬──────┘              └──────────┘
       │ 失败
       ▼
┌─────────────┐     < 3次    ┌──────────┐
│  重试机制   │ ─────────────→│ 重新执行 │
└──────┬──────┘              └──────────┘
       │ >= 3次
       ▼
┌─────────────┐     可恢复   ┌──────────┐
│  重启任务   │ ─────────────→│ 回退检查点│
└──────┬──────┘              └──────────┘
       │ 不可恢复
       ▼
┌─────────────┐
│  诊断模式   │ → 生成错误报告 → 通知人工介入
└─────────────┘
```

**实现代码**：

```bash
#!/bin/bash
# 自愈脚本

MAX_RETRIES=3
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  # 执行任务
  npm run task
  
  # 质量检查
  if npm run quality-check; then
    echo "✅ 任务成功完成"
    npm run update-state
    exit 0
  fi
  
  RETRY_COUNT=$((RETRY_COUNT + 1))
  echo "⚠️ 第 $RETRY_COUNT 次重试..."
  sleep 10
done

# 重试失败，进入诊断模式
echo "🔍 进入诊断模式..."
npm run diagnose > diagnosis-report.md
gh issue create --title "自动诊断报告" --body-file diagnosis-report.md
```

### 4. 智能体协作模式

#### Ralph循环模式

**特点**：智能体在循环中自主工作直至任务完成。

```
┌─────────────────────────────────────┐
│          Ralph 循环                 │
│                                     │
│  ┌──────┐   ┌──────┐   ┌──────┐   │
│  │ PRD  │→ │ 规划  │→ │ 执行  │   │
│  └──────┘   └──────┘   └──┬───┘   │
│                        │          │
│         ┌──────────────┘          │
│         ▼                          │
│    ┌─────────┐   通过   ┌─────┐  │
│    │质量门控 │ ─────────→│更新 │  │
│    └────┬────┘           │状态 │  │
│         │ 失败            └──┬──┘  │
│         ▼                    │     │
│    ┌─────────┐               │     │
│    │ 重试或  │←──────────────┘     │
│    │ 回退    │                      │
│    └─────────┘                      │
│                                     │
└─────────────────────────────────────┘
```

#### 事件驱动协调模式

**特点**：多智能体通过事件机制协同。

```
Planner Agent（规划者）
     ↓ 发出任务事件
Generator Agent（生成者）
     ↓ 发出完成事件
Evaluator Agent（评估者）
     ↓ 发出验证事件
Integrator Agent（整合者）
     ↓ 发出合并事件
Notification Agent（通知者）
```

---

## 成功案例

### OpenAI 的 Agent 优先开发实践

**团队规模与成果**：
- 团队：3人 → 7人（5个月）
- 代码量：约100万行
- PR数量：约1500个
- 人均日PR：3.5个（持续增长）
- 单次运行时长：6+小时（常在夜间执行）
- **效率提升：约为手工编写时间的1/10**

**关键实践**：

1. **知识内置化**
   - Agent只能看到代码库内的内容
   - 外部文档按需注入
   - 所有规范编码为可执行规则

2. **约束编码化**
   - 通过Linter、类型系统、CI规则强制执行规范
   - 不依赖文档，而是依赖代码
   - 错误信息内嵌修复指令

3. **端到端自主完成任务**
   - 从复现Bug、实现修复、验证到提交PR
   - 全链路无需人工干预
   - 自动化重跑处理偶发失败

4. **最小化合并阻力**
   - 快速合并策略
   - 自动化测试覆盖
   - 减少人工审查阻塞

---

## 实践指南：基于 Ralph + Superpowers 实现

### 一、技术栈介绍

#### Ralph：自主AI代理循环框架

**核心特点**：
- **新鲜上下文架构**：每次迭代都启动全新的AI实例（无记忆）
- **文件持久化状态**：完全依赖文件系统保存状态
- **自动质量门控**：类型检查、测试、浏览器验证
- **自主完成判定**：当所有用户故事标记为 `passes: true` 时自动停止

**核心文件结构**：

```
ralph-project/
├── ralph.sh          # 主循环脚本
├── prd.json          # 结构化用户故事
├── progress.txt      # 全局代码库模式和学习记录
├── AGENTS.md         # 模块特定的开发规范
└── .git/             # Git历史记录
```

#### Superpowers：技能驱动的工作流框架

**核心特点**：
- **强制性技能系统**：技能不是建议，条件匹配时必须使用
- **标准化6步流程**：头脑风暴 → 设计确认 → 实现计划 → TDD执行 → 代码审查 → 分支收尾
- **可组合性**：技能可以组合使用，形成复杂工作流
- **多平台支持**：Claude Code、Codex、Cursor等

**核心技能分类**：

| 类别 | 技能名称 | 作用 |
|------|---------|------|
| **设计与规划** | brainstorming | 理解需求，澄清模糊点 |
| | writing-plans | 编写实现计划 |
| **开发与执行** | using-git-worktrees | 使用Git工作树隔离 |
| | subagent-driven-development | 子代理驱动开发 |
| | test-driven-development | 测试驱动开发 |
| **审查与收尾** | requesting-code-review | 请求代码审查 |
| | finishing-a-development-branch | 完成开发分支 |
| | verification-before-completion | 完成前验证 |
| **调试** | systematic-debugging | 系统化调试 |

### 二、整合架构设计

**核心理念**：Ralph提供自主循环能力，Superpowers提供结构化技能，两者结合形成完整的Harness Engineering实践。

```
┌─────────────────────────────────────────────────────┐
│                   整合架构                          │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │          Ralph 自主循环层                     │   │
│  │  ┌──────────┐   ┌──────────┐   ┌──────────┐│   │
│  │  │  PRD解析 │→ │ 迭代循环 │→ │ 质量门控 ││   │
│  │  └──────────┘   └─────┬────┘   └──────────┘│   │
│  └───────────────────────┼──────────────────────┘   │
│                          │                          │
│                          ▼                          │
│  ┌─────────────────────────────────────────────┐   │
│  │       Superpowers 技能执行层                 │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐     │   │
│  │  │Brainstorm│→ │  Plan   │→ │  TDD    │     │   │
│  │  └─────────┘  └─────────┘  └─────────┘     │   │
│  │       ↓            ↓            ↓          │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐     │   │
│  │  │ Execute │  │ Review  │  │ Finish  │     │   │
│  │  └─────────┘  └─────────┘  └─────────┘     │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │          Harness 基础设施层                  │   │
│  │  • 验收基线（prd.json）                      │   │
│  │  • 执行边界（git worktree）                 │   │
│  │  • 反馈信号（质量门控）                      │   │
│  │  • 回退手段（progress.txt + checkpoints）   │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 三、实施步骤

#### 步骤1：环境准备

**安装依赖**：

```bash
# 安装Ralph
git clone https://github.com/snarktank/ralph.git
cd ralph
chmod +x ralph.sh

# 安装Superpowers（用户级）
git clone https://github.com/obra/superpowers.git ~/.workbuddy/skills/superpowers

# 安装必需工具
# macOS
brew install jq git node

# Ubuntu/Debian
sudo apt-get install jq git nodejs npm

# Windows (使用WSL或Git Bash)
# 通过scoop或chocolatey安装
```

**配置Superpowers技能**：

```bash
# 创建技能配置
mkdir -p ~/.workbuddy/skills
ln -s /path/to/superpowers ~/.workbuddy/skills/superpowers
```

#### 步骤2：项目结构初始化

**创建标准Harness项目结构**：

```bash
#!/bin/bash
# init-harness-project.sh

PROJECT_NAME=$1
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# 创建标准目录结构
mkdir -p {src,tests,docs,.harness}
mkdir -p docs/{concepts,practice,feedback}
mkdir -p .harness/{linter,scripts,checkpoints}

# 创建根AGENTS.md
cat > AGENTS.md << 'EOF'
# 项目导航入口

## 项目概述
本项目采用 Harness Engineering 实践。

## 核心模块
- **src/**: 源代码，详见 `src/AGENTS.md`
- **tests/**: 测试代码，详见 `tests/AGENTS.md`
- **docs/**: 项目文档，详见 `docs/AGENTS.md`

## 开发规范
1. 所有代码必须通过类型检查
2. 所有功能必须有对应测试
3. 所有PR必须通过质量门控

## 智能体工作流程
1. 阅读 `docs/concepts/` 理解核心概念
2. 查看 `prd.json` 了解当前任务
3. 使用Superpowers技能执行开发
4. 确保通过 `.harness/quality-gate.yml` 检查
EOF

# 创建子模块AGENTS.md
cat > src/AGENTS.md << 'EOF'
# 源代码模块

## 架构设计
采用分层架构：Controller → Service → Repository

## 编码规范
- 使用TypeScript严格模式
- 每个文件不超过300行
- 函数复杂度不超过10
EOF

cat > tests/AGENTS.md << 'EOF'
# 测试模块

## 测试策略
- 单元测试覆盖率 ≥ 80%
- 集成测试覆盖核心流程
- E2E测试覆盖关键用户路径

## 测试命令
- 单元测试: `npm test`
- 覆盖率: `npm run test:coverage`
- E2E测试: `npm run test:e2e`
EOF

# 初始化prd.json
cat > prd.json << 'EOF'
{
  "project_name": "示例项目",
  "version": "1.0.0",
  "stories": [
    {
      "id": "story-001",
      "title": "用户登录功能",
      "priority": "high",
      "acceptance_criteria": [
        "tests/login.test.ts 通过",
        "类型检查无错误",
        "浏览器验证：登录表单可提交"
      ],
      "passes": false,
      "attempts": 0
    }
  ]
}
EOF

# 创建progress.txt
touch progress.txt

# 初始化Git仓库
git init
git add .
git commit -m "初始化 Harness Engineering 项目结构"
```

#### 步骤3：配置质量门控

**创建质量门控配置**：

```yaml
# .harness/quality-gate.yml
name: Harness Quality Gate

# 质量门控步骤
steps:
  # 1. 类型检查
  - name: Type Check
    command: npm run type-check
    required: true
    fix_hint: |
      运行 `npm run type-check` 查看详细错误
      常见修复：
      - 添加缺失的类型定义
      - 修复类型不匹配的赋值
  
  # 2. 单元测试
  - name: Unit Tests
    command: npm test
    required: true
    retry: 3
    fix_hint: |
      测试失败，请检查：
      1. 测试用例是否正确
      2. 实现代码是否满足测试期望
      3. 是否有异步操作未正确处理
  
  # 3. 代码规范检查
  - name: Lint Check
    command: npm run lint
    required: true
    fix_hint: |
      运行 `npm run lint -- --fix` 自动修复
      手动修复：检查未使用的变量、格式问题等
  
  # 4. 结构测试
  - name: Structure Tests
    command: npm run test:structure
    required: false
    fix_hint: |
      结构测试失败，检查：
      - 每个模块是否包含 AGENTS.md
      - 文件命名是否符合规范
  
  # 5. 安全扫描
  - name: Security Scan
    command: npm audit
    required: false
    severity_threshold: high
    fix_hint: |
      发现安全漏洞，运行：
      - `npm audit fix` 自动修复
      - `npm audit fix --force` 强制修复（谨慎使用）

# 质量评分规则
quality_score:
  weights:
    type_check: 30%
    unit_tests: 30%
    lint: 20%
    structure: 10%
    security: 10%
  threshold: 80

# 失败处理策略
failure_handling:
  auto_retry: true
  max_retries: 3
  retry_delay: 30s
  escalation:
    threshold: 3
    action: "create_issue"
    assignee: "human"
```

#### 步骤4：创建Ralph主循环脚本

**自定义ralph.sh**：

```bash
#!/bin/bash
# .harness/scripts/ralph-custom.sh

set -e

PROJECT_ROOT=$(git rev-parse --show-toplevel)
PRD_FILE="$PROJECT_ROOT/prd.json"
PROGRESS_FILE="$PROJECT_ROOT/progress.txt"
LOG_DIR="$PROJECT_ROOT/.harness/logs"

mkdir -p $LOG_DIR

echo "🚀 启动 Ralph + Superpowers 循环..."
echo "📋 读取 PRD: $PRD_FILE"

# 检查是否有未完成的任务
PENDING_STORIES=$(jq '.stories[] | select(.passes == false)' $PRD_FILE)

if [ -z "$PENDING_STORIES" ]; then
  echo "✅ 所有任务已完成！"
  exit 0
fi

# 主循环
while true; do
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📊 当前状态："
  jq '.stories[] | {id, title, passes, attempts}' $PRD_FILE
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # 获取下一个待完成的任务
  STORY_ID=$(jq -r '.stories[] | select(.passes == false) | .id' $PRD_FILE | head -1)
  STORY_TITLE=$(jq -r ".stories[] | select(.id == \"$STORY_ID\") | .title" $PRD_FILE)
  
  echo ""
  echo "🎯 开始处理任务: $STORY_TITLE (ID: $STORY_ID)"
  
  # 创建新的git worktree（隔离执行环境）
  WORKTREE_PATH="/tmp/ralph-worktree-$STORY_ID"
  git worktree add $WORKTREE_PATH 2>/dev/null || true
  
  cd $WORKTREE_PATH
  
  # 调用Superpowers技能执行开发
  echo ""
  echo "⚡ 使用 Superpowers 技能..."
  
  # 步骤1: 头脑风暴（使用brainstorming技能）
  echo "  → 头脑风暴：理解需求..."
  # 这里调用AI工具的命令，例如：
  # claude-code --skill brainstorming --task "$STORY_TITLE"
  
  # 步骤2: 制定实现计划（使用writing-plans技能）
  echo "  → 制定实现计划..."
  # claude-code --skill writing-plans --task "$STORY_TITLE"
  
  # 步骤3: TDD开发（使用test-driven-development技能）
  echo "  → TDD开发..."
  # claude-code --skill test-driven-development --task "$STORY_TITLE"
  
  # 步骤4: 代码审查（使用requesting-code-review技能）
  echo "  → 代码审查..."
  # claude-code --skill requesting-code-review
  
  # 运行质量门控
  echo ""
  echo "🔍 运行质量门控..."
  
  QUALITY_PASSED=true
  
  # 类型检查
  if ! npm run type-check > $LOG_DIR/type-check.log 2>&1; then
    echo "  ❌ 类型检查失败"
    QUALITY_PASSED=false
  else
    echo "  ✅ 类型检查通过"
  fi
  
  # 单元测试
  if ! npm test > $LOG_DIR/tests.log 2>&1; then
    echo "  ❌ 单元测试失败"
    QUALITY_PASSED=false
  else
    echo "  ✅ 单元测试通过"
  fi
  
  # 代码规范
  if ! npm run lint > $LOG_DIR/lint.log 2>&1; then
    echo "  ❌ 代码规范检查失败"
    QUALITY_PASSED=false
  else
    echo "  ✅ 代码规范检查通过"
  fi
  
  cd $PROJECT_ROOT
  
  if [ "$QUALITY_PASSED" = true ]; then
    echo ""
    echo "✅ 质量门控通过！更新状态..."
    
    # 更新prd.json
    ATTEMPTS=$(jq ".stories[] | select(.id == \"$STORY_ID\") | .attempts" $PRD_FILE)
    jq ".stories = [.stories[] | if .id == \"$STORY_ID\" then .passes = true else . end]" $PRD_FILE > tmp.json
    mv tmp.json $PRD_FILE
    
    # 更新progress.txt
    echo "[$(date -Iseconds)] ✅ 完成: $STORY_TITLE" >> $PROGRESS_FILE
    
    # 提交代码
    git add .
    git commit -m "完成: $STORY_TITLE (ID: $STORY_ID)"
    
    # 清理worktree
    git worktree remove $WORKTREE_PATH
    
    echo "✨ 任务完成: $STORY_TITLE"
  else
    echo ""
    echo "⚠️ 质量门控未通过，将在下一轮重试..."
    
    # 增加尝试次数
    ATTEMPTS=$(jq ".stories[] | select(.id == \"$STORY_ID\") | .attempts" $PRD_FILE)
    NEW_ATTEMPTS=$((ATTEMPTS + 1))
    jq ".stories = [.stories[] | if .id == \"$STORY_ID\" then .attempts = $NEW_ATTEMPTS else . end]" $PRD_FILE > tmp.json
    mv tmp.json $PRD_FILE
    
    # 记录失败
    echo "[$(date -Iseconds)] ⚠️ 失败 (尝试 $NEW_ATTEMPTS): $STORY_TITLE" >> $PROGRESS_FILE
    
    # 清理worktree
    git worktree remove $WORKTREE_PATH --force
    
    # 如果尝试次数超过阈值，进入诊断模式
    if [ $NEW_ATTEMPTS -ge 3 ]; then
      echo ""
      echo "🔍 进入诊断模式..."
      # 调用systematic-debugging技能
      # claude-code --skill systematic-debugging --task "$STORY_TITLE"
      
      # 创建诊断报告
      cat > diagnosis-report.md << EOF
# 诊断报告：$STORY_TITLE

## 任务信息
- ID: $STORY_ID
- 标题: $STORY_TITLE
- 尝试次数: $NEW_ATTEMPTS

## 失败日志
### 类型检查
\`\`\`
$(cat $LOG_DIR/type-check.log 2>/dev/null || echo "无日志")
\`\`\`

### 单元测试
\`\`\`
$(cat $LOG_DIR/tests.log 2>/dev/null || echo "无日志")
\`\`\`

### 代码规范
\`\`\`
$(cat $LOG_DIR/lint.log 2>/dev/null || echo "无日志")
\`\`\`

## 建议
需要人工介入审查。
EOF
      
      # 创建GitHub Issue
      # gh issue create --title "自动诊断：$STORY_TITLE 失败" --body-file diagnosis-report.md
      
      echo "📝 已创建诊断报告: diagnosis-report.md"
    fi
  fi
  
  # 检查是否所有任务都已完成
  PENDING_COUNT=$(jq '[.stories[] | select(.passes == false)] | length' $PRD_FILE)
  
  if [ $PENDING_COUNT -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 所有任务已完成！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    break
  fi
  
  # 短暂休息
  sleep 5
done

echo ""
echo "📊 最终状态："
jq '.stories[] | {id, title, passes, attempts}' $PRD_FILE
```

#### 步骤5：创建熵管理脚本

**自动扫描技术债**：

```bash
#!/bin/bash
# .harness/scripts/entropy-scan.sh

PROJECT_ROOT=$(git rev-parse --show-toplevel)
ENTROPY_REPORT="$PROJECT_ROOT/.harness/entropy-report.md"

echo "🔍 开始熵管理扫描..."

# 1. 代码重复检测
echo "检查代码重复..."
DUPLICATES=$(npx jscpd --min-lines 50 --reporters json 2>/dev/null | jq '.statistics.total.files')

# 2. 复杂度分析
echo "分析代码复杂度..."
HIGH_COMPLEXITY=$(npx eslint --format json . 2>/dev/null | jq '.[] | .messages | length')

# 3. 测试覆盖率
echo "检查测试覆盖率..."
COVERAGE=$(npm run test:coverage --silent 2>/dev/null | grep 'All files' | awk '{print $4}' | sed 's/%//')

# 4. 依赖安全
echo "扫描依赖安全..."
VULNERABILITIES=$(npm audit --json 2>/dev/null | jq '.metadata.vulnerabilities.total')

# 计算熵评分
QUALITY_SCORE=$((100 - DUPLICATES * 2 - HIGH_COMPLEXITY - (100 - COVERAGE) * 2))

# 生成报告
cat > $ENTROPY_REPORT << EOF
# 熵管理扫描报告

**扫描时间**: $(date -Iseconds)

## 质量指标

| 指标 | 数值 | 状态 |
|------|------|------|
| 代码重复 | $DUPLICATES 个文件 | $(if [ $DUPLICATES -lt 5 ]; then echo "✅"; else echo "⚠️"; fi) |
| 高复杂度警告 | $HIGH_COMPLEXITY 个 | $(if [ $HIGH_COMPLEXITY -lt 10 ]; then echo "✅"; else echo "⚠️"; fi) |
| 测试覆盖率 | ${COVERAGE}% | $(if [ $COVERAGE -gt 80 ]; then echo "✅"; else echo "⚠️"; fi) |
| 安全漏洞 | $VULNERABILITIES 个 | $(if [ $VULNERABILITIES -eq 0 ]; then echo "✅"; else echo "❌"; fi) |

## 总体质量评分

**评分**: $QUALITY_SCORE / 100

$(if [ $QUALITY_SCORE -lt 80 ]; then echo "⚠️ 质量评分低于阈值，建议发起重构PR"; else echo "✅ 代码质量良好"; fi)

## 建议行动

EOF

# 添加具体建议
if [ $DUPLICATES -ge 5 ]; then
  echo "- 🔴 检测到代码重复，建议提取公共组件" >> $ENTROPY_REPORT
fi

if [ $HIGH_COMPLEXITY -ge 10 ]; then
  echo "- 🟡 存在高复杂度代码，建议重构简化" >> $ENTROPY_REPORT
fi

if [ $COVERAGE -lt 80 ]; then
  echo "- 🟡 测试覆盖率不足，建议补充测试" >> $ENTROPY_REPORT
fi

if [ $VULNERABILITIES -gt 0 ]; then
  echo "- 🔴 发现安全漏洞，运行 \`npm audit fix\` 修复" >> $ENTROPY_REPORT
fi

echo ""
echo "📊 熵管理报告已生成: $ENTROPY_REPORT"

# 如果质量评分低于阈值，自动创建重构PR
if [ $QUALITY_SCORE -lt 80 ]; then
  echo ""
  echo "⚠️ 质量评分低于阈值，创建重构PR..."
  
  # 调用finishing-a-development-branch技能
  # gh pr create --title "自动重构：提升代码质量" --body-file $ENTROPY_REPORT
fi
```

#### 步骤6：完整工作流示例

**端到端流程**：

```bash
# 1. 初始化项目
./init-harness-project.sh my-project
cd my-project

# 2. 编辑prd.json，添加任务
# 定义清晰的验收标准

# 3. 启动Ralph循环
./.harness/scripts/ralph-custom.sh

# Ralph会自动：
# - 读取prd.json中的任务
# - 使用Superpowers技能执行开发
# - 运行质量门控检查
# - 更新任务状态
# - 记录进度到progress.txt
# - 所有任务完成后自动停止

# 4. 定期运行熵管理扫描
# 可以配置为每日自动任务
crontab -e
# 添加：0 2 * * * /path/to/project/.harness/scripts/entropy-scan.sh

# 5. 查看进度
cat progress.txt
cat prd.json | jq '.stories[] | {id, title, passes, attempts}'
```

### 四、最佳实践总结

#### 1. PRD编写规范

**好的PRD示例**：

```json
{
  "stories": [
    {
      "id": "story-001",
      "title": "用户登录功能",
      "priority": "high",
      "acceptance_criteria": [
        "tests/login.test.ts 通过",
        "类型检查无错误",
        "POST /api/login 返回200状态码",
        "错误密码返回401状态码",
        "浏览器验证：登录表单可提交"
      ],
      "passes": false,
      "attempts": 0,
      "implementation_notes": "使用JWT认证，token有效期24小时"
    }
  ]
}
```

**关键要素**：
- ✅ 明确的、可验证的验收标准
- ✅ 具体的文件路径和API端点
- ✅ 明确的优先级
- ✅ 实现提示（可选）

#### 2. AGENTS.md编写规范

**原则**：
- 保持简洁（100行左右）
- 渐进式披露（指向更详细文档）
- 包含可执行的命令
- 说明"是什么"和"为什么"

**模板**：

```markdown
# [模块名称]

## 概述
一句话说明该模块的作用。

## 核心职责
- 职责1
- 职责2
- 职责3

## 关键文件
- `file1.ts`: 用途说明
- `file2.ts`: 用途说明

## 开发命令
- 开发: `npm run dev`
- 测试: `npm test`
- 构建: `npm run build`

## 注意事项
- 重要约束1
- 重要约束2

## 相关文档
- 详细设计: `docs/design.md`
- API文档: `docs/api.md`
```

#### 3. 质量门控配置建议

**分层质量门控**：

```yaml
# 必须通过的门控（阻塞合并）
required_gates:
  - type_check
  - unit_tests
  - lint

# 建议通过的门控（警告但不阻塞）
recommended_gates:
  - structure_tests
  - security_scan
  - coverage_check

# 门控失败的处理
failure_handling:
  required:
    action: block_merge
    message: "❌ 必须修复后才能合并"
  
  recommended:
    action: warn
    message: "⚠️ 建议修复以提升代码质量"
```

#### 4. 常见问题与解决

**问题1：质量门控频繁失败**

原因：
- 测试不稳定（flaky tests）
- 环境配置不一致
- 依赖版本冲突

解决：
```bash
# 1. 重试机制
npm test -- --retry 3

# 2. 锁定依赖版本
npm shrinkwrap

# 3. 容器化环境
docker run --rm -v $(pwd):/app node:18 npm test
```

**问题2：AI智能体重复犯同样的错误**

原因：
- progress.txt未正确记录学习内容
- 缺乏有效的反馈机制

解决：
```bash
# 1. 强化progress.txt记录
echo "[$(date -Iseconds)] 💡 学习：避免使用any类型，应使用具体类型" >> progress.txt

# 2. 更新AGENTS.md规范
echo "- 禁止使用any类型，必须使用具体类型定义" >> src/AGENTS.md

# 3. 添加自定义linter规则
echo '{"rules": {"no-explicit-any": "error"}}' >> .eslintrc.json
```

**问题3：任务无法自动完成**

原因：
- 验收标准不清晰
- 缺乏自动化测试
- 任务粒度过大

解决：
```bash
# 1. 细化验收标准
# 将"实现登录功能"改为：
# - 创建login.ts文件
# - 实现authenticate函数
# - 添加单元测试
# - 通过API测试

# 2. 补充自动化测试
npm run test:create -- --name login

# 3. 拆分大任务
jq '.stories += [
  {"id": "story-001-a", "title": "创建登录数据模型"},
  {"id": "story-001-b", "title": "实现认证逻辑"},
  {"id": "story-001-c", "title": "创建登录API"}
]' prd.json > tmp.json && mv tmp.json prd.json
```

---

## 总结与展望

### 核心价值

Harness Engineering 代表了AI时代软件工程的范式转变：

1. **从"编写代码"到"设计约束"**  
   工程师的核心职责从编码转向设计让AI可靠执行的约束系统。

2. **从"人工审查"到"机器执行"**  
   通过自动化质量门控替代人工Code Review，实现规模化。

3. **从"完全正确"到"快速纠错"**  
   在AI高吞吐量场景下，纠错成本低于等待成本。

4. **从"知识文档"到"知识编码"**  
   将最佳实践编码为可执行的规则，而非静态文档。

### 实践要点

**成功实施 Harness Engineering 的关键**：

- ✅ **仓库即记录系统**：所有知识必须版本化
- ✅ **自动化质量门控**：不依赖人工审查
- ✅ **渐进式披露**：AGENTS.md作为导航入口
- ✅ **新鲜上下文架构**：每次迭代从干净状态开始
- ✅ **熵管理机制**：定期扫描并自动发起重构

### Ralph + Superpowers 的优势

**组合使用的独特价值**：

1. **Ralph提供自主循环能力**
   - 新鲜上下文架构避免状态污染
   - 文件持久化确保跨会话连续性
   - 自动质量门控保障代码质量

2. **Superpowers提供结构化技能**
   - 强制性流程确保开发质量
   - 可组合技能应对复杂场景
   - 标准化工作流降低认知负担

3. **二者结合形成完整闭环**
   - Ralph负责宏观的任务循环
   - Superpowers负责微观的执行细节
   - Harness基础设施提供质量保障

### 未来展望

随着AI能力的不断提升，Harness Engineering 将成为：

- **AI-Native开发的标准范式**
  - 所有软件项目都采用Harness架构
  - 代码审查、测试、部署全面自动化

- **企业级AI应用的基础设施**
  - 标准化的Harness框架和工具链
  - 成熟的培训和认证体系

- **软件工程教育的核心内容**
  - 从"如何编写代码"到"如何设计约束"
  - 从"人工协作"到"人机协作"

---

## 附录

### A. 相关资源

**官方文档**：
- OpenAI Harness Engineering: https://openai.com/zh-Hans-CN/index/harness-engineering/
- Ralph项目: https://github.com/snarktank/ralph
- Superpowers框架: https://github.com/obra/superpowers

**社区资源**：
- Harness Engineering 学习指南: https://github.com/deusyu/harness-engineering
- Agent原理与实践: https://tw93.fun/2026-03-21/agent.html

### B. 技能清单

**Superpowers核心技能**：

| 技能名称 | 触发场景 | 核心作用 |
|---------|---------|---------|
| brainstorming | 新需求、模糊需求 | 理解需求，澄清模糊点 |
| writing-plans | 复杂任务、多步骤任务 | 制定实现计划 |
| using-git-worktrees | 需要隔离开发环境 | 创建隔离的git工作树 |
| subagent-driven-development | 可并行的独立任务 | 分派子代理并行执行 |
| test-driven-development | 功能开发 | 测试驱动的开发流程 |
| requesting-code-review | 代码完成待审查 | 请求代码审查 |
| finishing-a-development-branch | 分支开发完成 | 合并分支、创建PR |
| systematic-debugging | Bug修复、异常处理 | 系统化调试流程 |
| verification-before-completion | 宣称完成前 | 验证工作确实完成 |

### C. 术语表

| 术语 | 英文 | 定义 |
|------|------|------|
| 驭缰工程 | Harness Engineering | 围绕AI智能体构建的测试、验证与约束基础设施 |
| 验收基线 | Acceptance Baseline | 明确任务完成标准的可执行条件 |
| 执行边界 | Execution Boundary | 限制Agent操作范围的机制 |
| 反馈信号 | Feedback Signal | 提供实时反馈的可观测性数据 |
| 回退手段 | Rollback Mechanism | 确保任务可持久化、可恢复的机制 |
| 新鲜上下文 | Fresh Context | 每次迭代启动全新AI实例的架构 |
| 质量门控 | Quality Gate | 强制执行的质量检查机制 |
| 熵管理 | Entropy Management | 定期扫描并修复技术债的机制 |

---

**文档版本**: v1.0  
**最后更新**: 2026年3月27日  
**维护者**: WorkBuddy AI Assistant

---

> "模型虽然重要，但决定系统能否稳定运行的，往往是这些外围工程条件。"  
> — Harness Engineering 核心洞察
