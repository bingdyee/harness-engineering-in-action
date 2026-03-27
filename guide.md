# Harness Engineering 完全指南

> **AI智能体时代的软件工程新范式**  
> 版本: v1.0 | 更新日期: 2026年3月27日

---

## 目录

1. [前言：为什么Harness Engineering如此重要](#1-前言)
2. [核心概念与理论基础](#2-核心概念)
3. [六大核心原则](#3-六大核心原则)
4. [三大支柱详解](#4-三大支柱)
5. [核心组件架构](#5-核心组件)
6. [实战案例与数据](#6-实战案例)
7. [常见架构模式](#7-架构模式)
8. [工具设计与ACI实践](#8-工具设计)
9. [评测体系构建](#9-评测体系)
10. [生产级实施方案](#10-生产方案)
11. [Ralph + Superpowers 实践](#11-ralph实践)
12. [附录：资源与参考](#12-附录)

---

## 1. 前言

### 1.1 AI工程范式的三次跃迁

```
Prompt Engineering (2023)     → "如何提问"
       ↓
Context Engineering (2024)    → "如何组织信息"
       ↓
Harness Engineering (2026)      → "如何设计系统"
```

**核心转变**：从"工程师写代码"到"工程师设计环境，AI智能体执行"。

### 1.2 定义

> **Harness Engineering（驭缰工程）**：设计和实施约束、引导、验证、纠正AI智能体的系统，使其可靠地生成代码或完成任务。

**核心类比**：如果LLM是一匹**骏马**（强大的动力源），那么**Harness**（马具）就是：
- **缰绳**：约束和引导机制
- **马鞍**：稳定的运行环境
- **跑道围栏**：防止偏离目标的护栏

### 1.3 为什么现在必须掌握

- **2025年**：证明了Agent能工作
- **2026年**：要解决如何让Agent高效、稳定、可维护地工作
- OpenAI、Stripe、LangChain等头部团队已大规模应用
- LangChain仅靠优化Harness，Terminal Bench排名从第30跃升至第5

---

## 2. 核心概念

### 2.1 与传统软件工程的对比

| 维度 | 传统软件工程 | Harness Engineering |
|------|-------------|---------------------|
| **核心角色** | 人类工程师编写代码 | AI智能体编写代码，人类设计约束系统 |
| **知识传递** | 文档、注释、口头交流 | 仓库即记录系统，所有内容必须版本化 |
| **质量控制** | 人工Code Review + CI/CD | 自动化linter、结构测试、自我纠正机制 |
| **合并策略** | 谨慎合并，长时间审查 | 快速合并，偶发失败通过重跑解决 |
| **技术债** | 定期人工重构 | 自动扫描偏差、定期发起重构PR |

### 2.2 核心理念转变

1. **从"编写代码"到"设计约束"**  
   工程师的核心工作不再是直接编写代码，而是设计让AI能够可靠执行的约束系统。

2. **从"事后审查"到"前置约束"**  
   通过linter、类型系统、CI规则在AI执行过程中就强制执行规范。

3. **从"完全正确"到"快速纠错"**  
   在智能体吞吐量远超人类注意力的系统中，纠错成本低于等待成本。

---

## 3. 六大核心原则

### 原则①：仓库即记录系统（Repo as Source of Truth）

**核心理念**：不在仓库里的东西对智能体不存在。

```yaml
原则: 所有决策、规范、计划必须版本化并提交到仓库
原因: 运行中的智能体只能访问代码库内信息
实践:
  - 外部文档对Agent不可见
  - 细节知识拆分到具体目录按需引用
  - AGENTS.md作为统一入口
```

### 原则②：地图而非手册（Map, Not Manual）

**核心理念**：AGENTS.md是目录页，而非百科全书。

```
问题: 巨型指令文件 → 上下文挤占 + 难维护 + 难验证
解决: 渐进式披露
```

**推荐结构**：
```
project/
├── AGENTS.md          # 100行入口，指向深层文档
├── concepts/
│   ├── AGENTS.md      # 子目录导航
│   └── 01-repo.md
└── practice/
    └── AGENTS.md
```

### 原则③：机械化执行（Mechanical Enforcement）

**核心理念**：用工具而非文档来约束行为。

```python
# 错误：依赖人类记忆
规范: "所有API必须有错误处理"

# 正确：Linter强制
class APIErrorChecker(Linter):
    def check_function(self, func):
        if is_api_endpoint(func) and not has_error_handling(func):
            yield Error(
                f"{func.name} 缺少错误处理",
                fix="添加 try-except 或使用 @handle_errors 装饰器"
            )
```

### 原则④：智能体可读性（Agent Readability）

**选择技术的标准**：
- ✅ API稳定性：优先选择成熟稳定的技术
- ✅ 训练集覆盖：选择LLM训练数据中常见的技术栈
- ❌ 避免：最新发布的框架、冷门语言、实验性工具

**推荐技术栈**：
```
✅ 推荐：Python, JavaScript/TypeScript, Go, FastAPI, Express, PostgreSQL, Redis, Docker
❌ 避免：上周刚发布的框架、自定义DSL、Beta版本工具
```

### 原则⑤：吞吐量改变合并理念

```yaml
传统模式:
  - PR生命周期长（数天到数周）
  - 测试失败 = 阻塞
  - 人工审查成本高

Harness模式:
  - PR生命周期短（数小时）
  - 测试偶发失败 → 重跑
  - 纠错成本低，合并阻力最小化
```

### 原则⑥：熵管理 = 垃圾回收

```yaml
熵的表现:
  - 文档漂移（代码更新但文档未更新）
  - 死代码堆积
  - 模式复现（包括坏模式）

熵管理策略:
  1. 黄金规则编码化（写入Linter）
  2. 定期扫描偏差
  3. 自动发起重构PR
  4. 文档一致性智能体（每日运行）
```

---

## 4. 三大支柱

### 4.1 上下文工程（Context Engineering）

#### 分层加载策略

```
┌─────────────────────────────────┐
│   常驻层（System Prompt）         │  身份、核心约束
├─────────────────────────────────┤
│   按需加载层（Skills）            │  触发时注入完整知识
├─────────────────────────────────┤
│   运行时注入层（Context）         │  当前任务相关信息
├─────────────────────────────────┤
│   记忆层（MEMORY.md）            │  跨会话持久化
└─────────────────────────────────┘
```

### 4.2 架构约束（Architectural Constraints）

#### 依赖分层示例

```yaml
架构规则:
  Types → Config → Repo → Service → Runtime → UI
  
禁止:
  - UI 直接依赖 Repo
  - Service 直接访问 DB（必须通过 Repo）
  - 跨服务调用（使用消息队列）

执行工具矩阵:
  - 确定性Linter（依赖方向检查）
  - 结构测试（架构边界验证）
  - Pre-commit钩子（即时反馈）
```

### 4.3 熵管理（Entropy Management）

#### 四大熵管理智能体

```yaml
1. 文档一致性智能体:
   频率: 每日运行
   任务: 检查代码与文档的一致性
   输出: 自动创建更新PR

2. 约束违规扫描器:
   频率: 每次提交
   任务: 扫描违反黄金规则的代码

3. 模式强化智能体:
   频率: 每周
   任务: 识别重复模式并抽象

4. 依赖审计员:
   频率: 每周
   任务: 检测未使用的依赖和死代码
```

---

## 5. 核心组件

### 5.1 Harness架构总览

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

### 5.2 四大核心组件

| 组件 | 定义 | 实现方式 |
|------|------|----------|
| **验收基线** | 明确任务完成标准的可执行条件 | 单元测试、集成测试、性能基准 |
| **执行边界** | 限制Agent操作范围的机制 | Git worktree、白名单、权限控制 |
| **反馈信号** | 提供实时反馈的可观测性数据 | 日志、指标、追踪、错误信息 |
| **回退手段** | 确保任务可持久化、可恢复的机制 | 检查点、原子性更新、版本回退 |

---

## 6. 实战案例

### 6.1 OpenAI Codex实验

```yaml
团队规模: 3人 → 7人（5个月）
代码量: 100万+ 行生产级代码
PR数量: ~1500个
人均日PR: 3.5个
效率提升: 约10倍（约为手写时间的1/10）
单次运行时长: 6+小时（通常在夜间执行）

关键特征:
  ✅ 零人工编码
  ✅ 产品可部署
  ✅ 崩溃后自行修复
  ✅ 全流程由Harness管理

关键实践:
  1. 知识内置化：Agent只能看到代码库内内容
  2. 约束编码化：通过Linter、CI规则强制执行规范
  3. 端到端自主：从Bug复现到修复验证全自动化
  4. 最小化合并阻力：快速合并策略
```

### 6.2 Stripe Minions智能体

```yaml
规模: 每周超1000个合并PR
流程:
  1. Slack任务发布
  2. 智能体编码
  3. CI自动化测试
  4. PR创建
  5. 人工评审合并

效率:
  - 开发者专注评审，而非编码
  - 测试失败自动重跑
  - 合并阻力最小化
```

### 6.3 LangChain性能飞跃

```yaml
基准: Terminal Bench 2.0
改进前:
  通过率: 52.8%
  排名: 前30
  
改进后:
  通过率: 66.5%（+13.7%）
  排名: 前5

改进内容（仅优化Harness）:
  ✅ 增加自验证循环
  ✅ 上下文工程优化
  ✅ 循环检测中间层
  ✅ 推理三明治结构
```

---

## 7. 架构模式

### 7.1 五种控制模式

```yaml
1. 提示链（Prompt Chaining）:
   适用: 线性步骤任务
   示例: 生成内容 → 翻译 → 格式化

2. 路由（Routing）:
   适用: 输入分类后定向处理
   示例: 用户意图识别 → 不同处理分支

3. 并行（Parallelization）:
   适用: 独立任务并发
   示例: 分段生成、多次运行取共识

4. 编排器-工作者（Orchestrator-Workers）:
   适用: 复杂任务分解
   示例: 中央LLM分解任务 → 委派给工作者

5. 评估器-优化器（Evaluator-Optimizer）:
   适用: 质量敏感任务
   示例: 生成 → 评估 → 优化（循环直至达标）
```

### 7.2 Ralph循环模式

```python
# Ralph Wiggum 循环核心逻辑
def ralph_loop(task):
    while not task.complete:
        context = get_fresh_context()  # 清空上下文
        action = agent.decide(context, task)
        result = execute(action)
        
        if is_success(result):
            task.update(result)
        elif needs_backpressure(result):
            apply_backpressure(result)
            continue
        else:
            task.record_failure(result)
        
        if should_checkpoint():
            save_state(task)
    
    return task.result
```

**六条信条**：
1. **Fresh Context**: 每轮清空上下文，避免累积干扰
2. **Backpressure**: 遇到阻塞主动后退，寻求替代路径
3. **Plan Is Disposable**: 计划可随时抛弃，结果导向
4. **Verify After Each Step**: 每步立即验证
5. **Fail Fast, Recover Fast**: 快速失败，快速恢复
6. **Human in the Loop**: 关键决策点人工确认

### 7.3 多智能体协作模式

#### 指挥者模式（同步）

```yaml
架构:
  Orchestrator
    ├── Worker 1（前端）
    ├── Worker 2（后端）
    └── Worker 3（测试）

通信: 同步等待，结果汇总
适用: 任务依赖强，需要协调的场景
```

#### 统筹者模式（异步）

```yaml
架构:
  Coordinator
    └── 消息队列（JSONL）
         ├── Agent 1（异步执行）
         ├── Agent 2（异步执行）
         └── Agent 3（异步执行）

消息状态: pending → approved → completed
适用: 任务独立，可并行执行的场景
```

---

## 8. 工具设计

### 8.1 工具演进三阶段

```yaml
阶段1: API封装
  问题: 粒度过细，Agent需协调多个工具

阶段2: ACI（Agent-Computer Interface）
  核心: 工具对应Agent的目标，而非底层操作

阶段3: Advanced Tool Use
  特征: 动态工具发现、代码编排工具调用
```

### 8.2 工具设计四原则

#### ① 粒度：对应Agent目标

```python
# 错误：底层API操作
@tool
def get_file_content(path: str) -> str:
    """读取文件内容"""
    return read_file(path)

# 正确：高层目标
@tool
def update_api_endpoint(endpoint: str, changes: dict, reason: str) -> UpdateResult:
    """
    更新API端点
    
    Args:
        endpoint: API路径（如 /api/users）
        changes: 变更内容
        reason: 变更原因（自动写入commit message）
    
    Returns:
        UpdateResult包含：
        - 修改的文件列表
        - 影响的测试用例
        - 建议的验证步骤
    """
```

#### ② 返回：决策相关信息

```python
# 错误：返回完整原始数据
def get_user(user_id: str) -> dict:
    return database.query(f"SELECT * FROM users WHERE id = {user_id}")

# 正确：返回决策相关信息
@tool
def get_user_context(user_id: str) -> UserContext:
    """
    Returns:
        UserContext:
            - exists: bool（用户是否存在）
            - can_modify: bool（是否有权限修改）
            - related_entities: List[str]（关联实体）
            - suggested_actions: List[str]（建议的后续动作）
    """
```

#### ③ 错误处理：结构化信息

```python
@dataclass
class ToolError:
    error_code: str          # "FILE_NOT_FOUND"
    message: str             # 人类可读描述
    fix_suggestion: str      # Agent可执行的修复建议
    retry_possible: bool     # 是否可重试
    related_docs: str        # 相关文档链接
```

#### ④ 描述：明确使用边界

```python
@tool
def create_database_migration(changes: dict, auto_apply: bool = False) -> MigrationResult:
    """
    创建数据库迁移
    
    适用场景：
    ✅ 添加新表或新字段
    ✅ 修改字段类型或约束
    
    不适用场景：
    ❌ 删除表或字段（需人工确认）
    ❌ 修改核心业务数据（风险过高）
    """
```

---

## 9. 评测体系

### 9.1 Agent评测结构

```yaml
与传统评测的区别:
  传统评测: 单轮对话 → 直接评分
  Agent评测: 多轮执行 → 基于环境状态 + 执行记录评分

评测组成:
  1. 工具集（Tools）
  2. 执行环境（Environment）
  3. 任务定义（Task）
  4. 评分器（Evaluator）
```

### 9.2 三类评分器

| 类型 | 确定性 | 适用场景 |
|------|--------|----------|
| **代码评分器** | 最高 | 单元测试通过率、编译成功 |
| **模型评分器** | 中等 | 代码可读性、文档质量 |
| **人工评分器** | 基准 | 建立基准、校准其他评分器 |

### 9.3 关键指标

```yaml
Pass@k: k次运行至少一次成功
  用途: 探索能力上限
  示例: 10次运行中至少成功1次

Pass^k: k次运行全部成功
  用途: 回归测试、生产可靠性
  示例: 10次运行全部成功（严格要求）
```

### 9.4 评测搭建步骤

```yaml
步骤1: 从真实失败案例启动（20-50个）
步骤2: 环境隔离（Docker容器化）
步骤3: 评分器选择优先级：代码 → 模型 → 人工
步骤4: 定期审查执行记录（每周）
步骤5: 防止评测套件饱和（保持区分度）
```

---

## 10. 生产级实施方案

### 10.1 目录结构标准

```yaml
project-root/
├── .harness/                      # Harness配置目录
│   ├── config.yaml               # 全局配置
│   ├── agents/                   # 智能体配置
│   ├── constraints/              # 约束规则
│   ├── prompts/                  # Prompt模板
│   └── tools/                    # 工具定义
│
├── AGENTS.md                     # 智能体主入口
├── MEMORY.md                     # 长期记忆
│
├── docs/                         # 文档
│   ├── architecture/             # 架构文档
│   ├── api/                      # API文档
│   └── guides/                   # 开发指南
│
├── src/                          # 源代码
│   ├── types/                    # 类型定义（最底层）
│   ├── config/                   # 配置层
│   ├── repositories/             # 数据访问层
│   ├── services/                 # 业务逻辑层
│   └── ui/                       # 用户界面（最上层）
│
├── tests/                        # 测试
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── .github/                      # CI/CD
│   └── workflows/
│       ├── agent-ci.yaml        # Agent专用CI流程
│       └── entropy-scan.yaml    # 熵管理任务
│
└── evals/                        # 评测套件
    ├── tasks/                    # 任务定义
    ├── environments/            # 测试环境
    └── scorers/                 # 评分器
```

### 10.2 AGENTS.md模板

```markdown
# Agent导航入口

## 1. 项目概述
- **类型**：[项目类型]
- **技术栈**：[技术栈]
- **团队规模**：[X]人

## 2. 架构约束
```
依赖方向：Types → Config → Repos → Services → UI
禁止：UI直接依赖Repos
```

## 3. 编码规范
- **格式化**：使用Prettier
- **Lint**：ESLint + 自定义规则
- **命名**：PascalCase类名，camelCase函数

## 4. 工作流程
1. 接收任务 → 分析需求
2. 检查相关代码 → 设计方案
3. 实现功能 → 编写测试
4. 运行测试 → 修复问题
5. 提交PR → 等待审查

## 5. 工具使用指南
- `update_api_endpoint`：更新API端点
- `create_service`：创建新的服务
- `run_tests`：执行测试套件

## 6. 常见问题
### Q1: 测试失败怎么办？
1. 分析失败日志
2. 区分：代码问题 vs 环境问题
3. 修复后验证 → 提交

---
_本文件是Agent的主要入口，请保持简洁（<100行）_
```

### 10.3 分层实施路径

#### Level 1：个人开发者（1-2天）

```yaml
核心配置:
  - 基础AGENTS.md（50-100行）
  - Pre-commit钩子（格式化、Lint）
  - 基础测试套件
  - 简单的记忆系统（MEMORY.md）

预期效果:
  - 减少50%的编码时间
  - 代码质量提升30%
```

#### Level 2：小团队（1-2周）

```yaml
新增内容:
  - 团队级AGENTS.md（统一规范）
  - 自定义CI流程（Agent专用）
  - 共享Prompt模板库
  - 初步评测套件（20-30个任务）
  - 文档智能体（每日运行）

预期效果:
  - 团队效率提升2-3倍
  - PR合并速度提升50%
  - 代码质量问题减少60%
```

#### Level 3：工程组织（1-2月）

```yaml
新增内容:
  - 完整Harness平台（编排层、执行层）
  - 自定义工具集（ACI设计）
  - 完整评测体系（100+任务）
  - 可观测性栈（Logs, Metrics, Traces）
  - 熵管理智能体（每日/每周）
  - 多Agent协作系统

预期效果:
  - 整体效率提升5-10倍
  - 开发周期缩短60%
  - 技术债务持续可控
```

### 10.4 成功指标定义

```yaml
短期指标（1个月）:
  - 任务成功率 > 70%
  - Pass@3通过率 > 85%
  - 人工介入频率 < 20%

中期指标（3个月）:
  - 任务成功率 > 80%
  - Pass@1通过率 > 75%
  - 代码覆盖率 > 80%
  - PR合并周期 < 1天

长期指标（6个月）:
  - 任务成功率 > 90%
  - Pass@1通过率 > 85%
  - 熵增长率 < 5%/月
  - 团队效率提升 > 5倍
```

---

## 11. Ralph + Superpowers 实践

### 11.1 技术栈介绍

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

### 11.2 整合架构设计

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

### 11.3 实施步骤

#### 步骤1：项目结构初始化

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

#### 步骤2：配置质量门控

```yaml
# .harness/quality-gate.yml
name: Harness Quality Gate

steps:
  - name: Type Check
    command: npm run type-check
    required: true
    fix_hint: "运行 `npm run type-check` 查看详细错误"
  
  - name: Unit Tests
    command: npm test
    required: true
    retry: 3
    fix_hint: "测试失败，请检查测试用例和实现代码"
  
  - name: Lint Check
    command: npm run lint
    required: true
    fix_hint: "运行 `npm run lint -- --fix` 自动修复"
  
  - name: Security Scan
    command: npm audit
    required: false
    severity_threshold: high

quality_score:
  threshold: 80

failure_handling:
  auto_retry: true
  max_retries: 3
```

#### 步骤3：完整工作流示例

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

---

## 12. 附录

### 12.1 核心资源链接

```yaml
官方资源:
  - OpenAI Harness Engineering指南: https://openai.com/zh-Hans-CN/index/harness-engineering/
  - Anthropic Agent设计最佳实践: https://www.anthropic.com/research/building-effective-agents

开源项目:
  - deusyu/harness-engineering: https://github.com/deusyu/harness-engineering
  - Ralph项目: https://github.com/snarktank/ralph
  - Superpowers框架: https://github.com/obra/superpowers

深度文章:
  - Tw93: 你不知道的Agent: https://tw93.fun/2026-03-21/agent.html
```

### 12.2 关键概念速查表

| 概念 | 定义 | 核心要点 |
|------|------|---------|
| **Harness** | 约束、验证、纠正AI的系统 | 模型是商品，Harness是护城河 |
| **Context Engineering** | 在正确时间提供正确信息 | 分层加载、按需注入 |
| **Architectural Constraints** | 代码结构强制规则 | Linter化、CI强制 |
| **Entropy Management** | 技术债务自动化管理 | 定期扫描、自动重构 |
| **ACI** | Agent-Computer Interface | 工具对应目标而非操作 |
| **Pass@k** | k次运行至少一次成功 | 探索能力上限 |
| **Pass^k** | k次运行全部成功 | 生产可靠性要求 |
| **Ralph循环** | 清空上下文的迭代循环 | Fresh Context、Backpressure |
| **Trace** | 完整执行记录 | 比结果更重要 |

### 12.3 术语表

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

### 12.4 实施检查清单

```yaml
启动前检查（必须全部完成）:
  □ 代码库有测试套件（覆盖率 > 60%）
  □ 有明确的架构文档和规范
  □ 团队对Agent辅助开发有共识
  □ 准备了至少20个失败案例用于评测
  □ 确定了初始技术栈和Agent工具

Level 1 实施检查:
  □ 创建了AGENTS.md（<100行）
  □ 配置了Pre-commit钩子
  □ 建立了基础评测集（20个任务）
  □ 完成了首次Trace分析

Level 2 实施检查:
  □ 团队AGENTS.md统一
  □ CI流程支持Agent
  □ 评测集扩展到50个任务
  □ 文档智能体开始运行

Level 3 实施检查:
  □ 完整Harness平台上线
  □ 自定义工具集投入使用
  □ 评测集超过100个任务
  □ 可观测性栈完整部署
  □ 熵管理智能体定期运行
```

---

## 结语

Harness Engineering不是银弹，而是一种新的工程范式。它的核心价值在于：

> **让工程师从"写代码"解放出来，转向"设计系统"——这才是AI时代软件工程师的核心竞争力。**
> **Rules + 渐进式披露 + GIT Worktree + Agent Loop**

记住三个关键点：

1. **模型是商品，Harness是护城河**
2. **人类掌舵，智能体执行**
3. **验证闭环比单次成功更重要**


