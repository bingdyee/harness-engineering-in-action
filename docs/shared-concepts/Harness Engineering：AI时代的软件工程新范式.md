# Harness Engineering：AI时代的软件工程新范式

> 从写代码到设计控制系统——当AI Agent能端到端写出百万行代码时，工程师的角色被推向了更高的维度

---

## 📋 目录

1. [引言：软件工程的范式转移](#引言软件工程的范式转移)
2. [什么是Harness Engineering](#什么是harness-engineering)
3. [OpenAI实战案例：百万行代码的零手写实验](#openai实战案例百万行代码的零手写实验)
4. [核心概念体系](#核心概念体系)
5. [实践方法论](#实践方法论)
6. [技术架构设计](#技术架构设计)
7. [挑战与应对](#挑战与应对)
8. [生产级Harness Engineering设计方案](#生产级harness-engineering设计方案)
9. [总结与展望](#总结与展望)

---

## 引言：软件工程的范式转移

### 传统软件工程 vs AI驱动的软件工程

| 维度 | 传统软件工程 | AI驱动的软件工程 |
|------|------------|----------------|
| **工程师核心工作** | 编写代码、调试、重构 | 设计约束、明确意图、构建反馈循环 |
| **交付物** | 源代码 | AGENTS.md、架构规则、自定义Linter、反馈回路 |
| **知识载体** | 文档、Wiki、注释 | Git仓库作为唯一事实源 |
| **质量控制** | Code Review + 测试 | 机械化执行 + 自愈系统 |
| **效率瓶颈** | 人类编写速度 | 提示词设计 + 反馈循环优化 |

### 核心转变

**从"如何做"到"做什么"**
- 传统：工程师编写具体实现逻辑
- 现在：工程师定义约束和目标，AI生成实现

**从"手工生产"到"系统设计"**
- 传统：每个功能需要手动编码
- 现在：构建自动化生成系统

---

## 什么是Harness Engineering

### 定义

**Harness Engineering（驾驭工程）** 是设计和实现约束、护栏、反馈循环和生命周期工具的工程实践，其目的在于使LLM上的AI Agent能够持续产生正确、可审计、可维护的输出。

### 核心类比

如果LLM是一匹**骏马**（强大的动力源），那么**Harness**（马具）就是：
- **缰绳**：约束和引导机制
- **马鞍**：稳定的运行环境
- **跑道围栏**：防止偏离目标的护栏

### 术语来源

- **2026年2月**：HashiCorp联合创始人Mitchell Hashimoto首次使用该术语，描述为Agent构建"防止重复犯错机制"的工程实践
- **后续发展**：OpenAI发表重磅文章《Harness engineering: leveraging Codex in an agent-first world》，分享了完整的实战经验

---

## OpenAI实战案例：百万行代码的零手写实验

### 实验背景

**实验时间**：2025年8月 - 2026年1月（5个月）  
**团队规模**：3人起步 → 7人  
**实验目标**：完全使用Codex生成代码，构建并交付一款内部Beta版软件产品

### 关键数据

```
📊 惊人的效率数据
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
代码总量      : 约 1,000,000 行
PR数量        : 约 1,500 个
人均日PR      : 3.5 个（扩展后仍在增长）
开发效率      : 手写代码的 1/10 时间
单次运行时长  : 6+ 小时（通常在人类睡眠时间）
用户覆盖      : 数百名内部用户 + 外部Alpha测试者
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 核心突破点

1. **零手写代码**：应用逻辑、测试、CI配置、文档、可观测性、内部工具全部由Codex生成
2. **端到端自主性**：Agent可自主完成从问题复现到修复验证的全流程
3. **规模化交付**：证明了Agent-first模式在百万行代码级别的可行性

---

## 核心概念体系

### 1. 仓库即记录系统（Repository as Source of Truth）

**核心理念**：不在仓库里的东西对智能体不存在

**实践要点**：
- 所有决策、规范、计划必须以版本化工件提交到仓库
- 避免口头约定或外部文档（如Confluence、Notion）
- 代码库是唯一可信的知识源

**实现方式**：
```
docs/
├── architecture/
│   ├── layering.md          # 架构分层规则
│   └── dependencies.md      # 依赖约束
├── conventions/
│   ├── coding-standards.md  # 编码规范
│   └── commit-style.md      # 提交风格
└── decisions/
    ├── ADR-001-*.md         # 架构决策记录
    └── ADR-002-*.md
```

---

### 2. 地图而非手册（Map, Not Manual）

**核心理念**：AGENTS.md是目录页，而非百科全书

**设计原则**：
- 控制在100行以内，提供导航而非细节
- 采用渐进式披露（Progressive Disclosure）
- 让智能体按需深入，避免信息过载

**AGENTS.md示例**：
```markdown
# AGENTS.md - 仓库导航

## 🎯 项目概况
本项目是一个电商平台后端服务，采用微服务架构。

## 📂 目录结构
- `src/` - 源代码（详见 src/AGENTS.md）
- `docs/` - 文档（详见 docs/AGENTS.md）
- `tests/` - 测试（详见 tests/AGENTS.md）

## 🔑 核心约定
1. 遵循分层架构：Types → Config → Repo → Service → API
2. 所有新功能必须有单元测试和集成测试
3. 使用 conventional commits 提交格式

## 🚀 快速开始
1. 阅读 docs/architecture/layering.md 了解架构
2. 查看 src/AGENTS.md 了解代码组织
3. 运行 `make test` 确保环境正常
```

---

### 3. 机械化执行（Mechanical Enforcement）

**核心理念**：用工具而非文档来约束行为

**实践方式**：
- 自定义Linter强制执行架构不变式
- Lint错误信息内嵌修复指令
- 结构化测试验证依赖关系

**自定义Linter示例**：
```python
# custom_linter/architecture_linter.py

class ArchitectureLinter:
    """
    架构不变式检查器
    规则：
    1. API层不能直接访问Repo层（必须通过Service）
    2. Service层不能直接返回DB实体（必须转换为DTO）
    3. 所有public方法必须有类型注解
    """
    
    def check_layer_violation(self, file_path: str, imports: list):
        violations = []
        if 'src/api/' in file_path:
            for imp in imports:
                if 'src/repo/' in imp:
                    violations.append({
                        'file': file_path,
                        'error': 'API层直接导入Repo层',
                        'fix': '请通过Service层访问数据，例如：from src.service.user_service import UserService'
                    })
        return violations
    
    def check_return_type(self, file_path: str, function_node):
        violations = []
        if function_node.is_public and not function_node.return_annotation:
            violations.append({
                'file': file_path,
                'line': function_node.line,
                'error': f'公开函数 {function_node.name} 缺少返回类型注解',
                'fix': '添加返回类型注解，例如：def get_user(id: int) -> UserDTO:'
            })
        return violations

# 运行Linter
if __name__ == '__main__':
    linter = ArchitectureLinter()
    violations = linter.run_all_checks()
    
    for v in violations:
        print(f"❌ {v['file']}:{v.get('line', 1)}")
        print(f"   错误: {v['error']}")
        print(f"   修复: {v['fix']}")
```

**CI集成**：
```yaml
# .github/workflows/lint.yml
name: Architecture Lint
on: [pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Architecture Linter
        run: |
          python custom_linter/architecture_linter.py
          if [ $? -ne 0 ]; then
            echo "Architecture violations found. Please fix before merging."
            exit 1
          fi
```

---

### 4. 智能体可读性（Agent Readability）

**核心理念**：优先为智能体的推理能力优化

**技术选择原则**：
- 选择API稳定、训练集覆盖好的"无聊"技术
- 避免最新框架或实验性工具
- 优先使用广泛采用的设计模式

**技术栈选择示例**：
```
✅ 推荐选择（训练集覆盖好）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
语言        : Python, JavaScript/TypeScript, Go
框架        : FastAPI, Express, Django, Spring Boot
数据库      : PostgreSQL, Redis, MongoDB
消息队列    : RabbitMQ, Kafka
容器化      : Docker, Kubernetes

❌ 避免选择（训练集覆盖少）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
最新框架    : 上周刚发布的框架
冷门语言    : 小众编程语言
实验性工具  : Beta版本的工具
自定义DSL   : 领域特定语言
```

**代码风格优化**：
```python
# ✅ 智能体友好的代码（清晰的命名、结构化、常见模式）

class UserService:
    """用户业务逻辑服务"""
    
    def __init__(self, user_repo: UserRepository):
        self.user_repo = user_repo
    
    def get_user_by_id(self, user_id: int) -> Optional[UserDTO]:
        """
        根据ID获取用户信息
        
        Args:
            user_id: 用户ID
            
        Returns:
            UserDTO if found, None otherwise
            
        Raises:
            DatabaseError: 数据库连接失败
        """
        try:
            user_entity = self.user_repo.find_by_id(user_id)
            if user_entity:
                return self._to_dto(user_entity)
            return None
        except DatabaseError as e:
            logger.error(f"Failed to get user {user_id}: {e}")
            raise
    
    def _to_dto(self, entity: UserEntity) -> UserDTO:
        """将数据库实体转换为DTO"""
        return UserDTO(
            id=entity.id,
            username=entity.username,
            email=entity.email,
            created_at=entity.created_at
        )

# ❌ 智能体不友好的代码（隐式约定、魔法数字、非常规模式）

class US:
    def get(self, i):
        # 魔法数字、无类型注解、无文档
        u = self.r.get(i)
        return u and {'id': u.id, 'n': u.n, 'e': u.e, 't': u.t} or None
```

---

### 5. 吞吐量改变合并理念（Throughput Changes Merge Philosophy）

**核心理念**：PR生命周期短，快速失败，快速修复

**实践方式**：
- 测试偶发失败通过重跑解决
- 纠错成本低于等待成本
- 优先合并，快速迭代

**合并策略对比**：
```
传统模式
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. 提交PR → 等待所有测试通过
2. 人工Code Review
3. 修复所有问题
4. 再次等待测试
5. 合并（周期：1-3天）

Harness模式
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Agent提交PR → 自动化检查
2. 快速合并（核心测试通过即可）
3. 生产环境自动监控
4. Agent自动修复问题
5. 提交修复PR（周期：1-3小时）
```

**CI配置示例**：
```yaml
# .github/workflows/ci.yml
name: Fast CI
on:
  pull_request:
  push:
    branches: [main]

jobs:
  fast-tests:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v3
      - name: Run Critical Tests
        run: make test-critical  # 只运行核心测试，10分钟内完成
        
  full-tests:
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    timeout-minutes: 60
    steps:
      - uses: actions/checkout@v3
      - name: Run Full Tests
        run: make test-full  # 完整测试套件，合并后异步运行
```

---

### 6. 熵管理 = 垃圾回收（Entropy Management = Garbage Collection）

**核心理念**：技术债是高息贷款，智能体会复现仓库中的坏模式

**实践方式**：
- 定期扫描代码偏差
- 更新质量评分
- 自动发起重构PR

**熵管理自动化**：
```python
# scripts/entropy_scanner.py

class EntropyScanner:
    """代码熵值扫描器"""
    
    def scan_codebase(self):
        """扫描整个代码库，生成熵值报告"""
        issues = []
        
        # 1. 检测重复代码
        duplicates = self.find_duplicate_functions()
        if duplicates:
            issues.append({
                'type': 'duplicate_code',
                'severity': 'high',
                'count': len(duplicates),
                'files': [d.file for d in duplicates],
                'fix': '建议提取公共函数到 src/common/utils.py'
            })
        
        # 2. 检测过长函数
        long_functions = self.find_long_functions(max_lines=50)
        if long_functions:
            issues.append({
                'type': 'long_function',
                'severity': 'medium',
                'count': len(long_functions),
                'fix': '建议拆分为多个子函数'
            })
        
        # 3. 检测循环依赖
        circular_deps = self.find_circular_dependencies()
        if circular_deps:
            issues.append({
                'type': 'circular_dependency',
                'severity': 'critical',
                'count': len(circular_deps),
                'fix': '建议使用依赖注入或事件驱动解耦'
            })
        
        return self.generate_report(issues)
    
    def schedule_refactor_pr(self, issue):
        """自动创建重构任务"""
        task = {
            'title': f'[熵管理] {issue["type"]} - {issue["count"]} instances',
            'body': f"""
## 🧹 熵管理任务

**问题类型**: {issue['type']}
**严重程度**: {issue['severity']}
**影响文件数**: {issue['count']}

**修复建议**: {issue['fix']}

**影响文件**:
{chr(10).join([f'- {f}' for f in issue['files']])}

---
*此任务由熵管理自动生成*
            """,
            'labels': ['entropy-management', 'refactor', 'auto-generated']
        }
        return self.create_github_issue(task)

# 定期运行（每周一凌晨）
if __name__ == '__main__':
    scanner = EntropyScanner()
    report = scanner.scan_codebase()
    
    # 生成报告
    scanner.save_report(report, 'entropy-report.md')
    
    # 自动创建高优先级任务
    for issue in report['issues']:
        if issue['severity'] in ['critical', 'high']:
            scanner.schedule_refactor_pr(issue)
```

---

## 实践方法论

### Ralph循环模式

**核心理念**：让智能体在反馈循环中自主工作

**Ralph Wiggum循环**：
```
┌─────────────────────────────────────────┐
│          Ralph循环                       │
│                                          │
│  1. 接收任务（从AGENTS.md或Issue）       │
│     ↓                                    │
│  2. 生成代码/修改                        │
│     ↓                                    │
│  3. 运行测试/Linter                      │
│     ↓                                    │
│  4. 发现错误 → 修复 → 回到步骤3           │
│     ↓                                    │
│  5. 提交PR                               │
│     ↓                                    │
│  6. 人类审查 → 反馈 → 回到步骤2           │
│     ↓                                    │
│  7. 合并 → 任务完成                      │
│                                          │
└─────────────────────────────────────────┘
```

**实现架构**：
```bash
# ralph-loop.sh - Ralph循环启动脚本

#!/bin/bash

while true; do
    # 1. 获取下一个任务
    TASK=$(curl -s http://task-queue/next)
    
    if [ -z "$TASK" ]; then
        echo "No tasks, sleeping..."
        sleep 60
        continue
    fi
    
    # 2. 创建工作分支
    git checkout -b "agent/$(date +%Y%m%d%H%M%S)"
    
    # 3. Agent执行任务
    codex-agent execute "$TASK"
    
    # 4. 运行验证
    make lint test
    
    # 5. 如果失败，修复并重试（最多3次）
    RETRY_COUNT=0
    while [ $? -ne 0 ] && [ $RETRY_COUNT -lt 3 ]; do
        codex-agent fix-errors
        make lint test
        RETRY_COUNT=$((RETRY_COUNT + 1))
    done
    
    # 6. 提交PR
    if [ $? -eq 0 ]; then
        git add .
        git commit -m "feat: $TASK"
        git push origin HEAD
        gh pr create --title "$TASK" --body "Auto-generated by Ralph"
    fi
    
    # 7. 清理工作区
    git checkout main
    git branch -D $(git branch --list 'agent/*')
done
```

---

### 端到端任务执行流程

**示例：Agent修复生产环境Bug**

```
任务: 修复用户登录失败问题（Issue #1234）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

步骤1: 问题分析
  Agent读取Issue描述
  Agent搜索相关代码（使用codebase search）
  Agent定位问题：密码验证逻辑有缺陷

步骤2: 生成修复方案
  Agent生成修复代码（更新密码验证逻辑）
  Agent编写单元测试（覆盖边界情况）
  Agent更新相关文档

步骤3: 自动验证
  运行单元测试 ✓
  运行集成测试 ✓
  运行架构Linter ✓
  运行性能基准测试 ✓

步骤4: 提交PR
  自动创建PR（包含修复、测试、文档）
  自动填写PR描述（引用Issue、说明修改）

步骤5: 人类审查
  工程师审查代码
  提出修改建议："请增加日志记录"

步骤6: 迭代修复
  Agent接收反馈
  Agent添加日志记录
  Agent更新测试
  再次提交

步骤7: 合并部署
  工程师批准并合并
  自动部署到测试环境
  自动运行端到端测试
  部署到生产环境

总耗时: 约2小时（人类参与时间: 15分钟）
```

---

## 技术架构设计

### Harness架构总览

```
┌─────────────────────────────────────────────────────────┐
│                    Harness架构                          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │          控制层（Control Layer）                  │   │
│  │  • AGENTS.md（导航）                              │   │
│  │  • 架构规则（Architecture Rules）                │   │
│  │  • 约束系统（Constraints）                        │   │
│  └──────────────────────────────────────────────────┘   │
│                         ↓                               │
│  ┌──────────────────────────────────────────────────┐   │
│  │          执行层（Execution Layer）                │   │
│  │  • Agent Runner（Ralph循环）                      │   │
│  │  • Task Queue（任务队列）                         │   │
│  │  • Codex/API（代码生成）                          │   │
│  └──────────────────────────────────────────────────┘   │
│                         ↓                               │
│  ┌──────────────────────────────────────────────────┐   │
│  │          验证层（Validation Layer）               │   │
│  │  • Custom Linters（架构检查）                     │   │
│  │  • Test Suite（测试套件）                         │   │
│  │  • CI/CD Pipeline（持续集成）                     │   │
│  └──────────────────────────────────────────────────┘   │
│                         ↓                               │
│  ┌──────────────────────────────────────────────────┐   │
│  │          监控层（Monitoring Layer）               │   │
│  │  • Entropy Scanner（熵值扫描）                    │   │
│  │  • Observability（可观测性）                      │   │
│  │  • Alerting（告警系统）                           │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

### 分层架构设计

**架构分层规则**：
```
Types层（类型定义）
  ↓ 依赖
Config层（配置管理）
  ↓ 依赖
Repo层（数据访问）
  ↓ 依赖
Service层（业务逻辑）
  ↓ 依赖
API层（接口层）
  ↓ 依赖
UI层（用户界面）
```

**依赖约束Linter实现**：
```python
# custom_linter/dependency_checker.py

LAYER_HIERARCHY = {
    'types': 0,
    'config': 1,
    'repo': 2,
    'service': 3,
    'api': 4,
    'ui': 5
}

def check_dependency(from_layer: str, to_layer: str) -> bool:
    """
    检查依赖是否合法
    
    规则：只能依赖下层，不能依赖上层或跨层依赖
    """
    from_level = LAYER_HIERARCHY.get(from_layer)
    to_level = LAYER_HIERARCHY.get(to_layer)
    
    if from_level is None or to_level is None:
        return False
    
    # 允许：同层依赖、向下依赖
    # 禁止：向上依赖、跨层依赖（超过一层）
    return abs(from_level - to_level) <= 1 and from_level >= to_level
```

---

## 挑战与应对

### 挑战1：架构漂移

**问题**：完全由代理生成的系统如何长期保持架构一致性？

**应对策略**：
- 强化Linter检查（实时、强制）
- 定期架构审查（每周）
- 自动化重构（熵管理）

### 挑战2：人类判断的编码

**问题**：如何将人类的设计决策转化为代理可理解的规则？

**应对策略**：
- 将隐性知识显式化（写入AGENTS.md）
- 使用决策记录模板（ADR）
- 建立模式库（设计模式示例）

### 挑战3：规模化维护

**问题**：随着模型能力提升，系统需适应更复杂的反馈循环

**应对策略**：
- 模块化设计（易于扩展）
- 可插拔架构（替换组件）
- 版本管理（跟踪变更）

---

## 生产级Harness Engineering设计方案

### 设计目标

基于上述理论和实践，设计一套**可用于实际生产环境**的Harness Engineering系统，满足：
1. 可快速部署（1-2周内上线）
2. 易于维护（低运维成本）
3. 高可靠性（99%+成功率）
4. 可扩展（支持100+开发者）

---

### 系统架构设计

#### 1. 整体架构图

```
┌─────────────────────────────────────────────────────────────┐
│                  生产级Harness系统                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  前端层（Frontend）                                   │   │
│  │  • Web Dashboard（任务管理、监控面板）                │   │
│  │  • Slack/Teams Bot（即时通知、快速交互）              │   │
│  │  • CLI工具（开发者本地调试）                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↕                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  API层（API Gateway）                                │   │
│  │  • REST API（任务提交、状态查询）                     │   │
│  │  • GraphQL（复杂数据查询）                            │   │
│  │  • WebSocket（实时状态推送）                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↕                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  调度层（Orchestration Layer）                        │   │
│  │  • Task Queue（Redis/RabbitMQ）                      │   │
│  │  • Task Scheduler（Celery/Temporal）                 │   │
│  │  • Priority Manager（优先级管理）                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↕                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  执行层（Agent Execution Layer）                     │   │
│  │  • Agent Pool（K8s Pods）                            │   │
│  │  • Codex/GPT-4 Integration                           │   │
│  │  • Code Runner（沙箱环境）                            │   │
│  │  • Git Manager（版本控制）                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↕                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  验证层（Validation Layer）                           │   │
│  │  • Custom Linters（架构检查）                         │   │
│  │  • Test Runner（测试执行）                            │   │
│  │  • Security Scanner（安全扫描）                       │   │
│  │  • Performance Checker（性能基准）                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↕                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  监控层（Observability Layer）                        │   │
│  │  • Metrics（Prometheus + Grafana）                   │   │
│  │  • Logs（ELK Stack）                                 │   │
│  │  • Traces（Jaeger）                                  │   │
│  │  • Alerts（PagerDuty/OpsGenie）                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  数据层（Data Layer）                                 │   │
│  │  • PostgreSQL（任务、配置、审计）                     │   │
│  │  • Redis（缓存、队列）                                │   │
│  │  • Object Storage（代码快照、报告）                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

#### 2. 核心组件详细设计

##### 2.1 AGENTS.md模板系统

**仓库根目录AGENTS.md**：
```markdown
# AGENTS.md - 项目导航入口

## 🎯 项目概况
[项目名称] 是一个 [简要描述]，采用 [技术栈]。

**当前状态**: 生产环境运行中  
**团队规模**: [X]人  
**代码规模**: [X]万行  

## 📂 核心目录结构
```
project/
├── src/           # 源代码（详见 src/AGENTS.md）
├── tests/         # 测试代码（详见 tests/AGENTS.md）
├── docs/          # 文档（详见 docs/AGENTS.md）
├── scripts/       # 自动化脚本
└── harness/       # Harness系统配置
    ├── agents/    # Agent配置
    ├── linters/   # 自定义Linter
    └── workflows/ # 工作流定义
```

## 🏗️ 架构约束
1. **分层架构**: Types → Config → Repo → Service → API → UI
2. **依赖方向**: 只能依赖下层，禁止反向依赖
3. **命名规范**: 
   - 类名: PascalCase
   - 函数名: snake_case
   - 常量: UPPER_SNAKE_CASE

## 🔑 开发约定
1. 所有新功能必须有单元测试（覆盖率≥80%）
2. 所有public API必须有类型注解和文档字符串
3. 使用conventional commits格式提交
4. PR描述必须引用Issue编号

## 🚀 快速开始
1. 阅读 docs/architecture/overview.md 了解架构
2. 查看 src/AGENTS.md 了解代码组织
3. 运行 `make dev-setup` 配置开发环境
4. 运行 `make test` 确保环境正常

## 📋 常见任务模板
- 新增功能: `make task-new-feature`
- 修复Bug: `make task-fix-bug`
- 重构代码: `make task-refactor`
- 更新文档: `make task-update-docs`

## 🔗 重要链接
- API文档: docs/api/README.md
- 架构决策记录: docs/decisions/
- 运维手册: docs/operations/
```

---

##### 2.2 自定义Linter系统

**架构检查Linter**：
```python
# harness/linters/architecture_linter.py

import ast
import os
from typing import List, Dict
from pathlib import Path

class ArchitectureLinter:
    """
    架构不变式检查器
    """
    
    # 分层定义
    LAYERS = {
        'types': 0,
        'config': 1,
        'repo': 2,
        'service': 3,
        'api': 4,
        'ui': 5
    }
    
    def __init__(self, repo_root: str):
        self.repo_root = Path(repo_root)
        self.violations = []
    
    def check_layer_violations(self, file_path: Path) -> List[Dict]:
        """检查分层违规"""
        violations = []
        
        # 提取文件所在层
        file_layer = self._extract_layer(file_path)
        if not file_layer:
            return violations
        
        # 解析导入
        with open(file_path, 'r', encoding='utf-8') as f:
            tree = ast.parse(f.read())
        
        for node in ast.walk(tree):
            if isinstance(node, ast.ImportFrom):
                imported_layer = self._extract_layer_from_import(node.module)
                if imported_layer:
                    if not self._is_valid_dependency(file_layer, imported_layer):
                        violations.append({
                            'file': str(file_path),
                            'line': node.lineno,
                            'error': f'{file_layer}层导入{imported_layer}层违反分层规则',
                            'fix': f'请通过Service层访问数据，当前层: {file_layer}，导入层: {imported_layer}'
                        })
        
        return violations
    
    def _extract_layer(self, file_path: Path) -> str:
        """提取文件所在层"""
        parts = file_path.relative_to(self.repo_root).parts
        if len(parts) >= 2 and parts[0] == 'src':
            return parts[1]
        return None
    
    def _extract_layer_from_import(self, module_path: str) -> str:
        """从导入路径提取层"""
        if module_path and module_path.startswith('src.'):
            parts = module_path.split('.')
            if len(parts) >= 2:
                return parts[1]
        return None
    
    def _is_valid_dependency(self, from_layer: str, to_layer: str) -> bool:
        """检查依赖是否合法"""
        if from_layer not in self.LAYERS or to_layer not in self.LAYERS:
            return True
        
        from_level = self.LAYERS[from_layer]
        to_level = self.LAYERS[to_layer]
        
        # 只能依赖下层或同层
        return from_level >= to_level
    
    def check_naming_conventions(self, file_path: Path) -> List[Dict]:
        """检查命名规范"""
        violations = []
        
        with open(file_path, 'r', encoding='utf-8') as f:
            tree = ast.parse(f.read())
        
        for node in ast.walk(tree):
            # 检查类名
            if isinstance(node, ast.ClassDef):
                if not node.name[0].isupper():
                    violations.append({
                        'file': str(file_path),
                        'line': node.lineno,
                        'error': f'类名 {node.name} 不符合PascalCase规范',
                        'fix': f'建议改为: {node.name.capitalize()}'
                    })
            
            # 检查函数名
            elif isinstance(node, ast.FunctionDef):
                if node.name.isupper() or node.name[0].isupper():
                    if not node.name.startswith('_'):  # 忽略私有方法
                        violations.append({
                            'file': str(file_path),
                            'line': node.lineno,
                            'error': f'函数名 {node.name} 应使用snake_case',
                            'fix': f'建议改为: {self._to_snake_case(node.name)}'
                        })
        
        return violations
    
    def _to_snake_case(self, name: str) -> str:
        """转换为snake_case"""
        import re
        s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
        return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()
    
    def check_type_annotations(self, file_path: Path) -> List[Dict]:
        """检查类型注解"""
        violations = []
        
        with open(file_path, 'r', encoding='utf-8') as f:
            tree = ast.parse(f.read())
        
        for node in ast.walk(tree):
            if isinstance(node, ast.FunctionDef):
                # 检查公开函数
                if not node.name.startswith('_'):
                    # 检查参数类型
                    for arg in node.args.args:
                        if arg.annotation is None and arg.arg != 'self':
                            violations.append({
                                'file': str(file_path),
                                'line': node.lineno,
                                'error': f'函数 {node.name} 的参数 {arg.arg} 缺少类型注解',
                                'fix': f'添加类型注解，例如: {arg.arg}: <Type>'
                            })
                    
                    # 检查返回类型
                    if node.returns is None:
                        violations.append({
                            'file': str(file_path),
                            'line': node.lineno,
                            'error': f'函数 {node.name} 缺少返回类型注解',
                            'fix': '添加返回类型注解，例如: -> ReturnType 或 -> None'
                        })
        
        return violations
    
    def run_all_checks(self) -> List[Dict]:
        """运行所有检查"""
        all_violations = []
        
        # 扫描所有Python文件
        for py_file in self.repo_root.rglob('*.py'):
            if 'test' not in str(py_file).lower():  # 跳过测试文件
                all_violations.extend(self.check_layer_violations(py_file))
                all_violations.extend(self.check_naming_conventions(py_file))
                all_violations.extend(self.check_type_annotations(py_file))
        
        return all_violations

def main():
    import sys
    
    repo_root = sys.argv[1] if len(sys.argv) > 1 else '.'
    linter = ArchitectureLinter(repo_root)
    violations = linter.run_all_checks()
    
    if violations:
        print(f"❌ 发现 {len(violations)} 个架构违规:\n")
        for v in violations:
            print(f"  📄 {v['file']}:{v['line']}")
            print(f"     错误: {v['error']}")
            print(f"     修复: {v['fix']}\n")
        sys.exit(1)
    else:
        print("✅ 所有架构检查通过!")
        sys.exit(0)

if __name__ == '__main__':
    main()
```

---

##### 2.3 Agent任务调度系统

**任务队列设计**：
```python
# harness/scheduler/task_queue.py

from datetime import datetime
from enum import Enum
from typing import Dict, List, Optional
import redis
import json

class TaskPriority(Enum):
    CRITICAL = 0   # 生产环境Bug
    HIGH = 1       # 功能开发
    NORMAL = 2     # 日常任务
    LOW = 3        # 重构、文档

class TaskStatus(Enum):
    PENDING = 'pending'
    RUNNING = 'running'
    COMPLETED = 'completed'
    FAILED = 'failed'

class TaskQueue:
    """
    基于Redis的任务队列
    """
    
    def __init__(self, redis_url: str = 'redis://localhost:6379'):
        self.redis = redis.from_url(redis_url)
        self.queue_key = 'harness:task_queue'
        self.task_prefix = 'harness:task:'
    
    def submit_task(
        self,
        task_type: str,
        description: str,
        priority: TaskPriority = TaskPriority.NORMAL,
        context: Dict = None,
        max_retries: int = 3
    ) -> str:
        """
        提交新任务
        
        Args:
            task_type: 任务类型（new_feature, fix_bug, refactor, docs）
            description: 任务描述（自然语言）
            priority: 优先级
            context: 额外上下文（文件路径、Issue编号等）
            max_retries: 最大重试次数
            
        Returns:
            task_id: 任务ID
        """
        task_id = f"task_{datetime.now().strftime('%Y%m%d%H%M%S%f')}"
        
        task_data = {
            'id': task_id,
            'type': task_type,
            'description': description,
            'priority': priority.value,
            'status': TaskStatus.PENDING.value,
            'context': context or {},
            'max_retries': max_retries,
            'retry_count': 0,
            'created_at': datetime.now().isoformat(),
            'updated_at': datetime.now().isoformat(),
            'agent_id': None,
            'result': None,
            'error': None
        }
        
        # 存储任务数据
        self.redis.hset(
            f'{self.task_prefix}{task_id}',
            mapping=task_data
        )
        
        # 添加到队列（按优先级排序）
        self.redis.zadd(
            self.queue_key,
            {task_id: priority.value}
        )
        
        return task_id
    
    def get_next_task(self) -> Optional[Dict]:
        """
        获取下一个任务（按优先级）
        
        Returns:
            任务数据字典，如果没有任务返回None
        """
        # 获取优先级最高的任务
        result = self.redis.zpopmin(self.queue_key)
        
        if not result:
            return None
        
        task_id = result[0][0].decode('utf-8')
        
        # 获取任务数据
        task_data = self.redis.hgetall(f'{self.task_prefix}{task_id}')
        task_data = {k.decode('utf-8'): v.decode('utf-8') for k, v in task_data.items()}
        
        # 更新状态为运行中
        self._update_task_status(task_id, TaskStatus.RUNNING)
        
        return task_data
    
    def complete_task(self, task_id: str, result: Dict):
        """标记任务完成"""
        self.redis.hset(
            f'{self.task_prefix}{task_id}',
            mapping={
                'status': TaskStatus.COMPLETED.value,
                'result': json.dumps(result),
                'updated_at': datetime.now().isoformat()
            }
        )
    
    def fail_task(self, task_id: str, error: str, retry: bool = True):
        """标记任务失败"""
        task_data = self.redis.hgetall(f'{self.task_prefix}{task_id}')
        task_data = {k.decode('utf-8'): v.decode('utf-8') for k, v in task_data.items()}
        
        retry_count = int(task_data.get('retry_count', 0))
        max_retries = int(task_data.get('max_retries', 3))
        
        if retry and retry_count < max_retries:
            # 重试
            self.redis.hset(
                f'{self.task_prefix}{task_id}',
                mapping={
                    'status': TaskStatus.PENDING.value,
                    'retry_count': retry_count + 1,
                    'error': error,
                    'updated_at': datetime.now().isoformat()
                }
            )
            
            # 重新添加到队列
            priority = int(task_data.get('priority', 2))
            self.redis.zadd(self.queue_key, {task_id: priority})
        else:
            # 最终失败
            self.redis.hset(
                f'{self.task_prefix}{task_id}',
                mapping={
                    'status': TaskStatus.FAILED.value,
                    'error': error,
                    'updated_at': datetime.now().isoformat()
                }
            )
    
    def _update_task_status(self, task_id: str, status: TaskStatus):
        """更新任务状态"""
        self.redis.hset(
            f'{self.task_prefix}{task_id}',
            mapping={
                'status': status.value,
                'updated_at': datetime.now().isoformat()
            }
        )
    
    def get_task_status(self, task_id: str) -> Dict:
        """查询任务状态"""
        task_data = self.redis.hgetall(f'{self.task_prefix}{task_id}')
        return {k.decode('utf-8'): v.decode('utf-8') for k, v in task_data.items()}
    
    def list_pending_tasks(self, limit: int = 10) -> List[Dict]:
        """列出待处理任务"""
        task_ids = self.redis.zrange(self.queue_key, 0, limit - 1)
        tasks = []
        
        for task_id in task_ids:
            task_data = self.get_task_status(task_id.decode('utf-8'))
            tasks.append(task_data)
        
        return tasks

# 使用示例
if __name__ == '__main__':
    queue = TaskQueue()
    
    # 提交任务
    task_id = queue.submit_task(
        task_type='fix_bug',
        description='修复用户登录失败的问题，错误出现在密码验证逻辑',
        priority=TaskPriority.CRITICAL,
        context={
            'issue_number': '1234',
            'affected_files': ['src/service/auth_service.py', 'src/api/auth_api.py']
        }
    )
    
    print(f"任务已提交: {task_id}")
    
    # 获取下一个任务
    next_task = queue.get_next_task()
    if next_task:
        print(f"下一个任务: {next_task['id']}")
        print(f"描述: {next_task['description']}")
```

---

##### 2.4 Agent执行器

**Agent执行流程**：
```python
# harness/executor/agent_executor.py

import subprocess
import json
from typing import Dict, List
from pathlib import Path
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class AgentExecutor:
    """
    Agent执行器 - 在沙箱环境中执行代码生成任务
    """
    
    def __init__(
        self,
        repo_root: str,
        agent_id: str,
        code_generator='codex'  # 'codex' or 'gpt-4'
    ):
        self.repo_root = Path(repo_root)
        self.agent_id = agent_id
        self.code_generator = code_generator
        self.work_branch = f"agent/{agent_id}"
        
    def execute_task(self, task: Dict) -> Dict:
        """
        执行任务
        
        Args:
            task: 任务数据
            
        Returns:
            执行结果
        """
        logger.info(f"Agent {self.agent_id} 开始执行任务: {task['id']}")
        
        try:
            # 1. 创建工作分支
            self._create_work_branch()
            
            # 2. 生成代码
            generated_files = self._generate_code(task)
            
            # 3. 运行验证
            validation_result = self._run_validation()
            
            if not validation_result['success']:
                # 4. 如果验证失败，尝试修复
                if task['retry_count'] < task['max_retries']:
                    logger.warning("验证失败，尝试自动修复...")
                    self._fix_errors(validation_result['errors'])
                    
                    # 再次验证
                    validation_result = self._run_validation()
            
            # 5. 提交PR
            if validation_result['success']:
                pr_url = self._submit_pr(task, generated_files)
                return {
                    'success': True,
                    'pr_url': pr_url,
                    'files_modified': generated_files
                }
            else:
                return {
                    'success': False,
                    'error': '验证失败，已达到最大重试次数',
                    'validation_errors': validation_result['errors']
                }
        
        except Exception as e:
            logger.error(f"任务执行失败: {e}")
            return {
                'success': False,
                'error': str(e)
            }
        
        finally:
            # 清理工作分支
            self._cleanup()
    
    def _create_work_branch(self):
        """创建工作分支"""
        subprocess.run(
            ['git', 'checkout', '-b', self.work_branch],
            cwd=self.repo_root,
            check=True
        )
        logger.info(f"创建工作分支: {self.work_branch}")
    
    def _generate_code(self, task: Dict) -> List[str]:
        """
        生成代码
        
        Returns:
            生成的文件列表
        """
        logger.info(f"生成代码: {task['description']}")
        
        # 构建提示词
        prompt = self._build_prompt(task)
        
        # 调用代码生成API
        if self.code_generator == 'codex':
            generated_code = self._call_codex(prompt)
        else:
            generated_code = self._call_gpt4(prompt)
        
        # 写入文件
        generated_files = []
        for file_path, code in generated_code.items():
            full_path = self.repo_root / file_path
            full_path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(full_path, 'w', encoding='utf-8') as f:
                f.write(code)
            
            generated_files.append(str(file_path))
            logger.info(f"生成文件: {file_path}")
        
        return generated_files
    
    def _build_prompt(self, task: Dict) -> str:
        """构建提示词"""
        # 读取AGENTS.md作为上下文
        agents_md = self._read_agents_md()
        
        # 读取相关文件作为上下文
        context_files = self._load_context_files(task.get('context', {}))
        
        prompt = f"""
你是一个专业的软件工程师Agent，正在执行以下任务：

任务类型: {task['type']}
任务描述: {task['description']}

项目上下文:
{agents_md}

相关文件:
{context_files}

请根据以上信息：
1. 分析任务需求
2. 生成符合项目架构的代码
3. 确保遵循项目的编码规范
4. 添加必要的测试和文档

输出格式：
{{
    "files": {{
        "<relative_path>": "<code_content>"
    }},
    "tests": {{
        "<test_file_path>": "<test_code>"
    }},
    "documentation": "<updated_docs>"
}}
"""
        return prompt
    
    def _call_codex(self, prompt: str) -> Dict[str, str]:
        """调用Codex API"""
        # 实际实现需要调用Codex API
        # 这里是伪代码示例
        import openai
        
        response = openai.Completion.create(
            model="code-davinci-002",
            prompt=prompt,
            max_tokens=2000,
            temperature=0.7
        )
        
        # 解析响应
        generated_code = json.loads(response.choices[0].text)
        return generated_code.get('files', {})
    
    def _call_gpt4(self, prompt: str) -> Dict[str, str]:
        """调用GPT-4 API"""
        # 类似Codex的实现
        pass
    
    def _read_agents_md(self) -> str:
        """读取AGENTS.md"""
        agents_md_path = self.repo_root / 'AGENTS.md'
        if agents_md_path.exists():
            with open(agents_md_path, 'r', encoding='utf-8') as f:
                return f.read()
        return ""
    
    def _load_context_files(self, context: Dict) -> str:
        """加载上下文文件"""
        context_content = ""
        
        if 'affected_files' in context:
            for file_path in context['affected_files']:
                full_path = self.repo_root / file_path
                if full_path.exists():
                    with open(full_path, 'r', encoding='utf-8') as f:
                        context_content += f"\n\n--- {file_path} ---\n{f.read()}"
        
        return context_content
    
    def _run_validation(self) -> Dict:
        """运行验证"""
        logger.info("运行验证...")
        
        errors = []
        
        # 1. 运行架构Linter
        try:
            subprocess.run(
                ['python', 'harness/linters/architecture_linter.py', '.'],
                cwd=self.repo_root,
                check=True,
                capture_output=True
            )
        except subprocess.CalledProcessError as e:
            errors.append({
                'type': 'architecture_violation',
                'message': e.stderr.decode('utf-8')
            })
        
        # 2. 运行测试
        try:
            subprocess.run(
                ['pytest', 'tests/', '-v'],
                cwd=self.repo_root,
                check=True,
                capture_output=True
            )
        except subprocess.CalledProcessError as e:
            errors.append({
                'type': 'test_failure',
                'message': e.stdout.decode('utf-8')
            })
        
        # 3. 运行安全扫描
        try:
            subprocess.run(
                ['bandit', '-r', 'src/'],
                cwd=self.repo_root,
                check=True,
                capture_output=True
            )
        except subprocess.CalledProcessError as e:
            errors.append({
                'type': 'security_issue',
                'message': e.stdout.decode('utf-8')
            })
        
        return {
            'success': len(errors) == 0,
            'errors': errors
        }
    
    def _fix_errors(self, errors: List[Dict]):
        """自动修复错误"""
        logger.info(f"尝试修复 {len(errors)} 个错误")
        
        for error in errors:
            if error['type'] == 'architecture_violation':
                # 生成修复提示词
                fix_prompt = f"""
以下代码违反了架构规则：

错误信息:
{error['message']}

请修复代码以符合架构约束。
"""
                # 重新生成代码
                self._generate_code({'description': fix_prompt})
    
    def _submit_pr(self, task: Dict, files: List[str]) -> str:
        """提交Pull Request"""
        logger.info("提交PR...")
        
        # 提交代码
        subprocess.run(['git', 'add', '.'], cwd=self.repo_root, check=True)
        subprocess.run(
            ['git', 'commit', '-m', f"{task['type']}: {task['description']}"],
            cwd=self.repo_root,
            check=True
        )
        subprocess.run(
            ['git', 'push', '-u', 'origin', self.work_branch],
            cwd=self.repo_root,
            check=True
        )
        
        # 创建PR
        pr_title = f"[Agent] {task['type']}: {task['description']}"
        pr_body = f"""
## 🤖 Agent自动生成

**任务ID**: {task['id']}  
**任务类型**: {task['type']}  
**Agent**: {self.agent_id}

## 📝 修改内容
{chr(10).join([f'- {f}' for f in files])}

## ✅ 验证状态
- [x] 架构Linter检查通过
- [x] 单元测试通过
- [x] 安全扫描通过

## 📋 关联Issue
Closes #{task['context'].get('issue_number', '')}

---
*此PR由Harness Agent自动生成和提交*
"""
        
        # 使用gh CLI创建PR
        result = subprocess.run(
            [
                'gh', 'pr', 'create',
                '--title', pr_title,
                '--body', pr_body,
                '--label', 'agent-generated',
                '--assignee', '@me'
            ],
            cwd=self.repo_root,
            capture_output=True,
            text=True
        )
        
        pr_url = result.stdout.strip()
        logger.info(f"PR已创建: {pr_url}")
        
        return pr_url
    
    def _cleanup(self):
        """清理工作环境"""
        subprocess.run(['git', 'checkout', 'main'], cwd=self.repo_root)
        subprocess.run(
            ['git', 'branch', '-D', self.work_branch],
            cwd=self.repo_root,
            stderr=subprocess.DEVNULL
        )
        logger.info("工作环境已清理")
```

---

##### 2.5 监控与可观测性

**监控系统配置**：
```yaml
# harness/monitoring/prometheus.yml

global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'harness-agents'
    static_configs:
      - targets: ['localhost:9090']
    
  - job_name: 'harness-queue'
    static_configs:
      - targets: ['localhost:9091']
    
  - job_name: 'harness-executor'
    static_configs:
      - targets: ['localhost:9092']

# 告警规则
rule_files:
  - 'alerts.yml'

# alerts.yml
groups:
  - name: harness-alerts
    rules:
      - alert: HighTaskFailureRate
        expr: rate(harness_task_failures_total[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High task failure rate detected"
          description: "Task failure rate is {{ $value }} per second"
      
      - alert: LongRunningTask
        expr: harness_task_duration_seconds > 3600
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "Task running for more than 1 hour"
          description: "Task {{ $labels.task_id }} has been running for {{ $value }} seconds"
      
      - alert: QueueBacklog
        expr: harness_queue_size > 100
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Large task queue backlog"
          description: "{{ $value }} tasks pending in queue"
```

**Grafana Dashboard配置**：
```json
{
  "dashboard": {
    "title": "Harness Engineering Dashboard",
    "panels": [
      {
        "title": "任务队列状态",
        "type": "graph",
        "targets": [
          {
            "expr": "harness_queue_size",
            "legendFormat": "待处理任务"
          },
          {
            "expr": "rate(harness_tasks_completed_total[5m])",
            "legendFormat": "完成速率"
          }
        ]
      },
      {
        "title": "Agent执行性能",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, harness_task_duration_seconds_bucket)",
            "legendFormat": "P95执行时间"
          },
          {
            "expr": "histogram_quantile(0.99, harness_task_duration_seconds_bucket)",
            "legendFormat": "P99执行时间"
          }
        ]
      },
      {
        "title": "成功率",
        "type": "singlestat",
        "targets": [
          {
            "expr": "sum(rate(harness_tasks_completed_total[5m])) / sum(rate(harness_tasks_total[5m]))",
            "legendFormat": "成功率"
          }
        ]
      },
      {
        "title": "活跃Agent数量",
        "type": "singlestat",
        "targets": [
          {
            "expr": "count(harness_agent_active)",
            "legendFormat": "活跃Agent"
          }
        ]
      }
    ]
  }
}
```

---

##### 2.6 熵管理系统

**自动化熵扫描**：
```python
# harness/entropy/entropy_manager.py

from datetime import datetime
from typing import List, Dict
import subprocess
import json

class EntropyManager:
    """
    熵值管理器 - 定期扫描并修复代码熵
    """
    
    def __init__(self, repo_root: str):
        self.repo_root = repo_root
    
    def scan_and_fix(self):
        """扫描并自动修复熵值"""
        print(f"🔍 开始熵值扫描 - {datetime.now()}")
        
        # 1. 扫描重复代码
        duplicates = self._find_duplicates()
        if duplicates:
            self._fix_duplicates(duplicates)
        
        # 2. 扫描长函数
        long_functions = self._find_long_functions()
        if long_functions:
            self._create_refactor_tasks(long_functions)
        
        # 3. 扫描复杂度
        complexity_issues = self._check_complexity()
        if complexity_issues:
            self._create_refactor_tasks(complexity_issues)
        
        # 4. 检查依赖健康度
        dep_issues = self._check_dependencies()
        if dep_issues:
            self._create_refactor_tasks(dep_issues)
        
        print(f"✅ 熵值扫描完成 - 发现并处理 {len(duplicates) + len(long_functions)} 个问题")
    
    def _find_duplicates(self) -> List[Dict]:
        """检测重复代码"""
        # 使用工具检测重复代码
        result = subprocess.run(
            ['jscpd', '--min-lines', '10', '--format', 'json', 'src/'],
            cwd=self.repo_root,
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            duplicates = json.loads(result.stdout)
            return duplicates.get('duplicates', [])
        
        return []
    
    def _fix_duplicates(self, duplicates: List[Dict]):
        """修复重复代码"""
        print(f"🔨 发现 {len(duplicates)} 处重复代码，正在提取公共函数...")
        
        for dup in duplicates:
            # 提取公共函数
            common_code = dup['code']
            file_paths = [f['path'] for f in dup['files']]
            
            # 生成重构任务
            refactor_task = {
                'type': 'refactor',
                'description': f'提取重复代码到公共函数',
                'files': file_paths,
                'code': common_code
            }
            
            # 提交到任务队列
            self._submit_refactor_task(refactor_task)
    
    def _find_long_functions(self) -> List[Dict]:
        """检测过长函数"""
        long_functions = []
        
        # 使用radon检测复杂度和行数
        result = subprocess.run(
            ['radon', 'cc', 'src/', '-a', '-j'],
            cwd=self.repo_root,
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            complexity_data = json.loads(result.stdout)
            
            for file_path, functions in complexity_data.items():
                for func in functions:
                    if func.get('lines', 0) > 50:
                        long_functions.append({
                            'file': file_path,
                            'function': func['name'],
                            'lines': func['lines'],
                            'complexity': func.get('complexity', 'N/A')
                        })
        
        return long_functions
    
    def _check_complexity(self) -> List[Dict]:
        """检查代码复杂度"""
        issues = []
        
        result = subprocess.run(
            ['radon', 'cc', 'src/', '-nc', '-j'],
            cwd=self.repo_root,
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            complexity_data = json.loads(result.stdout)
            
            for file_path, functions in complexity_data.items():
                for func in functions:
                    if func['type'] in ['C', 'D', 'F']:  # 复杂度等级
                        issues.append({
                            'file': file_path,
                            'function': func['name'],
                            'complexity': func['type'],
                            'message': f'函数 {func["name"]} 复杂度过高 (等级 {func["type"]})'
                        })
        
        return issues
    
    def _check_dependencies(self) -> List[Dict]:
        """检查依赖健康度"""
        issues = []
        
        # 检查过时依赖
        result = subprocess.run(
            ['pip', 'list', '--outdated', '--format=json'],
            cwd=self.repo_root,
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            outdated = json.loads(result.stdout)
            for pkg in outdated:
                issues.append({
                    'type': 'outdated_dependency',
                    'package': pkg['name'],
                    'current_version': pkg['version'],
                    'latest_version': pkg['latest_version']
                })
        
        return issues
    
    def _create_refactor_tasks(self, issues: List[Dict]):
        """创建重构任务"""
        for issue in issues:
            self._submit_refactor_task({
                'type': 'entropy_refactor',
                'description': f"熵管理重构: {issue.get('message', '代码优化')}",
                'details': issue,
                'priority': 'low'
            })
    
    def _submit_refactor_task(self, task: Dict):
        """提交重构任务到队列"""
        # 调用TaskQueue API
        import requests
        
        response = requests.post(
            'http://localhost:8000/api/tasks',
            json=task
        )
        
        if response.status_code == 200:
            print(f"  ✓ 已创建重构任务: {task['description']}")
        else:
            print(f"  ✗ 创建任务失败: {response.text}")

# 定期执行（每周日凌晨2点）
if __name__ == '__main__':
    import schedule
    import time
    
    def job():
        manager = EntropyManager('.')
        manager.scan_and_fix()
    
    # 每周日凌晨2点执行
    schedule.every().sunday.at("02:00").do(job)
    
    print("🧹 熵管理器已启动，将在每周日凌晨2点自动运行...")
    
    while True:
        schedule.run_pending()
        time.sleep(60)
```

---

#### 3. 部署方案

##### 3.1 Docker容器化部署

**Docker Compose配置**：
```yaml
# docker-compose.yml

version: '3.8'

services:
  # API Gateway
  api:
    build: ./harness/api
    ports:
      - "8000:8000"
    environment:
      - REDIS_URL=redis://redis:6379
      - DATABASE_URL=postgresql://user:pass@postgres:5432/harness
    depends_on:
      - redis
      - postgres
    volumes:
      - ./repos:/app/repos
  
  # 任务调度器
  scheduler:
    build: ./harness/scheduler
    environment:
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis
  
  # Agent执行器（可扩展）
  executor:
    build: ./harness/executor
    deploy:
      replicas: 5  # 5个并发Agent
    environment:
      - AGENT_ID=executor-{{.TaskSlot}}
      - CODEX_API_KEY=${CODEX_API_KEY}
    volumes:
      - ./repos:/app/repos
      - /var/run/docker.sock:/var/run/docker.sock
  
  # 熵管理器
  entropy-manager:
    build: ./harness/entropy
    environment:
      - REPO_ROOT=/app/repos
    volumes:
      - ./repos:/app/repos
  
  # Redis（队列和缓存）
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
  
  # PostgreSQL（持久化存储）
  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=harness
    volumes:
      - postgres-data:/var/lib/postgresql/data
  
  # Prometheus（监控）
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./harness/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
  
  # Grafana（可视化）
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
      - ./harness/monitoring/dashboards:/etc/grafana/provisioning/dashboards

volumes:
  redis-data:
  postgres-data:
  grafana-data:
```

---

##### 3.2 Kubernetes生产部署

**K8s Deployment配置**：
```yaml
# k8s/harness-deployment.yml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: harness-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: harness-api
  template:
    metadata:
      labels:
        app: harness-api
    spec:
      containers:
      - name: api
        image: harness/api:latest
        ports:
        - containerPort: 8000
        env:
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: harness-secrets
              key: redis-url
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: harness-secrets
              key: database-url
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: harness-executor
spec:
  replicas: 10  # 10个并发Agent
  selector:
    matchLabels:
      app: harness-executor
  template:
    metadata:
      labels:
        app: harness-executor
    spec:
      containers:
      - name: executor
        image: harness/executor:latest
        env:
        - name: CODEX_API_KEY
          valueFrom:
            secretKeyRef:
              name: harness-secrets
              key: codex-api-key
        resources:
          requests:
            memory: "2Gi"
            cpu: "2000m"
          limits:
            memory: "4Gi"
            cpu: "4000m"
        volumeMounts:
        - name: repos
          mountPath: /app/repos
      volumes:
      - name: repos
        persistentVolumeClaim:
          claimName: repos-pvc

---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: harness-executor-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: harness-executor
  minReplicas: 5
  maxReplicas: 50
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: External
    external:
      metric:
        name: harness_queue_size
      target:
        type: AverageValue
        averageValue: 10
```

---

#### 4. 运维手册

##### 4.1 日常运维检查清单

```markdown
# Harness系统运维检查清单

## 每日检查（09:00）

- [ ] 检查Grafana Dashboard，确认关键指标正常
  - 任务成功率 ≥ 95%
  - 任务队列积压 ≤ 50
  - Agent平均执行时间 ≤ 30分钟
  
- [ ] 检查告警系统
  - 无未处理的P0/P1告警
  - 已处理告警有明确记录
  
- [ ] 检查熵管理报告
  - 确认昨日熵扫描完成
  - 查看新增重构任务

## 每周检查（周一 10:00）

- [ ] 审查架构一致性
  - 检查Linter违规趋势
  - 确认架构决策记录更新
  
- [ ] Agent性能审查
  - 统计上周任务完成情况
  - 分析失败任务原因
  - 优化提示词模板
  
- [ ] 依赖健康检查
  - 更新过时依赖
  - 修复安全漏洞

## 每月检查（1日）

- [ ] 容量规划
  - 分析资源使用趋势
  - 调整Agent池大小
  - 评估API配额
  
- [ ] 成本优化
  - 分析API调用成本
  - 优化执行效率
  - 调整自动扩缩容策略
  
- [ ] 系统备份
  - 备份PostgreSQL数据库
  - 备份配置文件
  - 验证恢复流程
```

---

##### 4.2 故障处理手册

```markdown
# 故障处理手册

## 故障1: 任务队列积压

**症状**: 
- 队列积压 > 100任务
- 任务执行时间 > 1小时

**排查步骤**:
1. 检查Agent Pod状态: `kubectl get pods -l app=harness-executor`
2. 检查Pod资源使用: `kubectl top pods`
3. 查看Agent日志: `kubectl logs <pod-name>`

**解决方案**:
- 手动扩容: `kubectl scale deployment harness-executor --replicas=20`
- 清理卡死任务: `python scripts/clear_stuck_tasks.py`
- 重启异常Pod: `kubectl delete pod <pod-name>`

## 故障2: API限流

**症状**:
- Codex/GPT-4 API返回429错误
- 任务执行失败率突增

**排查步骤**:
1. 检查API调用日志
2. 确认API配额使用情况

**解决方案**:
- 临时降低并发度: 修改`hpa`配置
- 切换到备用API: 更新环境变量
- 联系供应商提升配额

## 故障3: 数据库连接池耗尽

**症状**:
- API返回5xx错误
- 日志显示"connection pool exhausted"

**排查步骤**:
1. 检查数据库连接数: `SELECT count(*) FROM pg_stat_activity;`
2. 检查长时间运行的事务

**解决方案**:
- 重启API服务: `kubectl rollout restart deployment/harness-api`
- 增加连接池大小: 更新配置
- 优化数据库查询
```

---

#### 5. 最佳实践建议

##### 5.1 团队协作

```
团队规模建议
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
小型团队（3-5人）
  ✓ 1人专职：Harness系统维护
  ✓ 其他成员：提示词优化、架构设计
  ✓ 建议架构：单机部署 + 基础监控

中型团队（10-20人）
  ✓ 2人专职：Harness运维 + Agent调优
  ✓ 设置Harness评审会（每周）
  ✓ 建议架构：K8s部署 + 完整监控

大型团队（50+人）
  ✓ 专职团队：Harness Platform Team（3-5人）
  ✓ 制定Harness使用规范
  ✓ 建立多租户隔离机制
  ✓ 建议架构：多集群 + 企业级监控
```

##### 5.2 安全最佳实践

```yaml
安全检查清单
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. API密钥管理
   - [ ] 使用K8s Secrets存储
   - [ ] 定期轮换（90天）
   - [ ] 最小权限原则

2. 代码审查
   - [ ] 所有Agent生成的代码必须审查
   - [ ] 安全扫描（bandit, safety）
   - [ ] 敏感信息检测

3. 网络隔离
   - [ ] Agent运行在隔离网络
   - [ ] 限制外部API访问
   - [ ] 审计日志完整

4. 备份恢复
   - [ ] 每日增量备份
   - [ ] 每周全量备份
   - [ ] 每月恢复演练
```

---

#### 6. ROI分析

##### 6.1 效率提升对比

```
传统开发模式 vs Harness模式
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

指标              传统模式        Harness模式      提升
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
代码编写速度      100行/天        1000行/天       10x
Bug修复时间       4小时           0.5小时         8x
文档更新          手动            自动生成         5x
测试覆盖率        60%             85%             1.4x
PR审查时间        1小时           15分钟          4x
新功能交付周期    2周             2天             7x
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

##### 6.2 成本分析

```
成本对比（年，10人团队）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

成本项                传统模式        Harness模式
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
人力成本              $1,000,000      $500,000
API调用成本           $0              $100,000
基础设施成本          $50,000         $100,000
培训成本              $10,000         $30,000
维护成本              $20,000         $50,000
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
总计                  $1,080,000      $780,000

年度节省: $300,000 (28%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 总结与展望

### 核心要点总结

1. **范式转移**：软件工程师的角色从"代码编写者"转变为"系统设计者"
2. **核心能力**：约束设计、反馈循环优化、熵管理
3. **关键技术**：AGENTS.md、自定义Linter、Agent执行器、监控系统
4. **效率提升**：10倍代码生成速度、8倍Bug修复速度

### 未来发展方向

1. **更智能的Agent**
   - 自主学习能力
   - 多Agent协作
   - 领域知识积累

2. **更强大的Harness**
   - 实时架构演化
   - 自动性能优化
   - 跨项目知识迁移

3. **更完善的生态**
   - Harness设计模式库
   - 开源工具链
   - 社区最佳实践

---

## 参考资源

1. [OpenAI官方文章 - Harness Engineering](https://openai.com/zh-Hant-HK/index/harness-engineering/)
2. [GitHub - deusyu/harness-engineering](https://github.com/deusyu/harness-engineering)
3. [Anthropic - Harness design for long-running apps](https://www.anthropic.com/engineering/harness-design-long-running-apps)
4. [Ralph系列工具](https://github.com/snarktank/ralph)
5. [Martin Fowler分析文章](https://martinfowler.com/)

---

**文档版本**: v1.0  
**创建日期**: 2026-03-27  
**适用场景**: 生产环境部署、团队培训、架构设计参考

---

## 附录：快速开始指南

### 第一步：环境准备

```bash
# 1. 克隆项目模板
git clone https://github.com/your-org/harness-template.git
cd harness-template

# 2. 安装依赖
make install

# 3. 配置环境变量
cp .env.example .env
# 编辑.env文件，填入API密钥

# 4. 启动服务
make start
```

### 第二步：编写第一个AGENTS.md

```markdown
# AGENTS.md - 我的项目

## 项目概况
这是一个[项目描述]，主要功能是[核心功能]。

## 架构
采用[架构风格]，分为以下几层：
- [层1]: [职责]
- [层2]: [职责]

## 开发约定
1. [约定1]
2. [约定2]

## 快速开始
1. [步骤1]
2. [步骤2]
```

### 第三步：提交第一个任务

```bash
# 使用CLI提交任务
harness task create \
  --type new_feature \
  --description "实现用户登录功能" \
  --priority high

# 或使用API
curl -X POST http://localhost:8000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "type": "new_feature",
    "description": "实现用户登录功能",
    "priority": "high"
  }'
```

### 第四步：监控与优化

1. 访问Grafana Dashboard: http://localhost:3000
2. 查看任务执行情况
3. 根据反馈优化提示词
4. 迭代改进系统

---

**恭喜！您已完成Harness Engineering系统的基础搭建，开始享受AI驱动的软件工程新范式！** 🎉
