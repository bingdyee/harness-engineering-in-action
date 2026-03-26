# Harness Engineering：AI时代的软件工程革命

> **文档版本**：v1.0  
> **整理日期**：2026-03-27  
> **核心来源**：OpenAI官方、GitHub实战项目、Tw93工程实践  

---

## 📋 目录

1. [前言：为什么Harness Engineering如此重要](#前言)
2. [核心概念与理论基础](#核心概念)
3. [三大支柱详解](#三大支柱)
4. [实战案例与数据验证](#实战案例)
5. [常见架构模式](#架构模式)
6. [工具设计与ACI实践](#工具设计)
7. [评测体系构建](#评测体系)
8. [【生产级】Harness Engineering设计方案](#生产方案)
9. [实施路线图与最佳实践](#实施路线)
10. [附录：关键资源与参考](#附录)

---

<a name="前言"></a>
## 1. 前言：为什么Harness Engineering如此重要

### 1.1 AI工程范式的三次跃迁

```
Prompt Engineering (2023)
    ↓ "如何提问"
Context Engineering (2024)
    ↓ "如何组织信息"
Harness Engineering (2026)
    ↓ "如何设计系统"
```

**核心转变**：从"工程师写代码"到"工程师设计环境，AI智能体执行"。

### 1.2 一句话定义

> **Harness Engineering（驭缰工程）**：设计和实施约束、引导、验证、纠正AI智能体的系统，使其可靠地生成代码或完成任务。

### 1.3 为什么现在必须掌握

- **2025年证明了Agent能工作**
- **2026年要解决如何让Agent高效、稳定、可维护地工作**
- OpenAI、Stripe、LangChain等头部团队已大规模应用
- LangChain排名从第30跃升至第5，仅靠优化Harness

---

<a name="核心概念"></a>
## 2. 核心概念与理论基础

### 2.1 六大核心原则

#### ① 仓库即记录系统（Repo as Source of Truth）

```yaml
原则: 所有决策、规范、计划必须版本化并提交到仓库
原因: 运行中的智能体只能访问代码库内信息
实践:
  - 外部文档对Agent不可见
  - 细节知识拆分到具体目录按需引用
  - AGENTS.md作为统一入口
```

**案例**：OpenAI实践 - Agent无法看到外部的Confluence文档，所有架构决策必须在仓库内可见。

#### ② 地图而非手册（Map, Not Manual）

```
问题: 巨型指令文件 → 上下文挤占 + 难维护 + 难验证
解决: 渐进式披露
```

**实践结构**：
```
project/
├── AGENTS.md          # 100行入口，指向深层文档
├── concepts/
│   ├── AGENTS.md      # 子目录导航
│   ├── 01-repo.md
│   └── 02-mechanical.md
└── practice/
    └── AGENTS.md
```

#### ③ 机械化执行（Mechanical Enforcement）

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

**关键**：Lint错误信息必须内嵌修复指令。

#### ④ 智能体可读性（Agent Readability）

```yaml
选择技术的标准:
  API稳定性: ✅ 优先选择成熟稳定的技术
  训练集覆盖: ✅ 选择LLM训练数据中常见的技术栈
  文档完整性: ✅ 文档越详细，Agent理解越准确
  
反面案例:
  - 使用最新发布的框架（Agent无训练数据）
  - 包装不透明的上游库（重新实现子集可能更划算）
```

#### ⑤ 吞吐量改变合并理念

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

**Stripe案例**：每周自动产生超1000个PR，测试失败重跑，人工仅做最终审查。

#### ⑥ 熵管理 = 垃圾回收

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

<a name="三大支柱"></a>
## 3. 三大支柱详解

### 3.1 上下文工程（Context Engineering）

#### 静态上下文

```yaml
类型:
  - 架构规范文档
  - API契约定义
  - 编码风格指南
  - AGENTS.md / CLAUDE.md

最佳实践:
  仓库根目录:
    AGENTS.md: "# Agent导航入口
    - 架构决策 → docs/architecture/
    - 编码规范 → .editorconfig + linters/
    - API文档 → api/"
```

#### 动态上下文

```yaml
类型:
  - 可观测性数据（日志、指标、追踪）
  - 目录结构映射
  - CI/CD流水线状态
  - Git历史与分支信息

实现:
  observability:
    logs: Vector
    metrics: VictoriaMetrics
    traces: Jaeger
  
  agent_access:
    - 查询接口（Agent可自主验证系统状态）
    - 结构化错误信息（含错误码和修复建议）
```

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

### 3.2 架构约束（Architectural Constraints）

#### 依赖分层示例

```yaml
架构规则:
  Types → Config → Repo → Service → Runtime → UI
  
  禁止:
    - UI 直接依赖 Repo
    - Service 直接访问 DB（必须通过 Repo）
  
  强制工具:
    - 确定性Linter（依赖方向检查）
    - 结构测试（架构边界验证）
    - Pre-commit钩子（即时反馈）
```

#### 执行工具矩阵

| 工具类型 | 作用 | 时机 | 示例 |
|---------|------|------|------|
| 确定性Linter | 代码结构检查 | 写入时 | 依赖方向检查 |
| LLM审计员 | 语义质量检查 | PR创建时 | 代码异味检测 |
| 结构测试 | 架构边界验证 | CI阶段 | 模块耦合度测试 |
| Pre-commit钩子 | 即时反馈 | 本地提交前 | 格式化、静态分析 |

### 3.3 熵管理（Entropy Management）

#### 四大熵管理智能体

```yaml
1. 文档一致性智能体:
   频率: 每日运行
   任务: 检查代码与文档的一致性
   输出: 自动创建更新PR

2. 约束违规扫描器:
   频率: 每次提交
   任务: 扫描违反黄金规则的代码
   输出: 违规报告 + 自动修复建议

3. 模式强化智能体:
   频率: 每周
   任务: 识别重复模式并抽象
   输出: 重构建议 + 代码库健康度评分

4. 依赖审计员:
   频率: 每周
   任务: 检测未使用的依赖和死代码
   输出: 清理PR
```

---

<a name="实战案例"></a>
## 4. 实战案例与数据验证

### 4.1 OpenAI Codex实验

```yaml
团队规模: 3人 → 7人（5个月）
代码量: 100万+ 行生产级代码
PR数量: ~1500个
人均日PR: 3.5个
效率提升: 约10倍

关键特征:
  ✅ 零人工编码
  ✅ 产品可部署
  ✅ 崩溃后自行修复
  ✅ 全流程由Harness管理
```

### 4.2 Stripe Minions智能体

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

### 4.3 LangChain性能飞跃

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
  ✅ 循环检测中间件
  ✅ 推理三明治结构
```

---

<a name="架构模式"></a>
## 5. 常见架构模式

### 5.1 五种控制模式

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

### 5.2 Ralph循环模式

```python
# Ralph Wiggum 循环核心逻辑（不足20行）
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
```yaml
Fresh Context: 每轮清空上下文，避免累积干扰
Backpressure: 遇到阻塞主动后退，寻求替代路径
Plan Is Disposable: 计划可随时抛弃，结果导向
Verify After Each Step: 每步立即验证
Fail Fast, Recover Fast: 快速失败，快速恢复
Human in the Loop: 关键决策点人工确认
```

### 5.3 多智能体协作模式

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

通信: 异步消息队列，结构化状态管理
消息状态: pending → approved → completed
适用: 任务独立，可并行执行的场景
```

---

<a name="工具设计"></a>
## 6. 工具设计与ACI实践

### 6.1 工具演进三阶段

```yaml
阶段1: API封装
问题: 粒度过细，Agent需协调多个工具
示例:
  - get_file_content()
  - write_file()
  - commit_changes()
  
阶段2: ACI（Agent-Computer Interface）
核心: 工具对应Agent的目标，而非底层操作
示例:
  - update_api_endpoint()      # 高层目标
  - create_user_story()        # 业务意图
  - deploy_to_staging()        # 部署动作
  
阶段3: Advanced Tool Use
特征:
  - 动态工具发现
  - 代码编排工具调用
  - 示例驱动
```

### 6.2 工具设计四原则

#### ① 粒度：对应Agent目标

```python
# 错误：底层API操作
@tool
def get_file_content(path: str) -> str:
    """读取文件内容"""
    return read_file(path)

@tool
def write_file(path: str, content: str) -> bool:
    """写入文件"""
    return save_file(path, content)

# 正确：高层目标
@tool
def update_api_endpoint(
    endpoint: str,
    changes: dict,
    reason: str
) -> UpdateResult:
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
    # 内部自动处理：读取 → 修改 → 格式化 → Lint → 提交
    pass
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
    获取用户上下文（仅包含Agent决策所需信息）
    
    Returns:
        UserContext:
            - exists: bool（用户是否存在）
            - can_modify: bool（是否有权限修改）
            - related_entities: List[str]（关联实体，用于级联操作）
            - suggested_actions: List[str]（建议的后续动作）
    """
    pass
```

#### ③ 错误处理：结构化信息

```python
# 错误：简单字符串错误
raise Exception("File not found")

# 正确：结构化错误信息
@dataclass
class ToolError:
    error_code: str          # "FILE_NOT_FOUND"
    message: str             # 人类可读描述
    fix_suggestion: str      # Agent可执行的修复建议
    retry_possible: bool     # 是否可重试
    related_docs: str        # 相关文档链接

@tool
def deploy_service(config: dict) -> DeployResult:
    try:
        # 部署逻辑
        pass
    except ValidationError as e:
        return ToolError(
            error_code="INVALID_CONFIG",
            message=f"配置验证失败：{e}",
            fix_suggestion="检查config.yaml的schema，确保所有必需字段存在",
            retry_possible=True,
            related_docs="docs/deployment/config-schema.md"
        )
```

#### ④ 描述：明确使用边界

```python
@tool
def create_database_migration(
    changes: dict,
    auto_apply: bool = False
) -> MigrationResult:
    """
    创建数据库迁移
    
    适用场景：
    ✅ 添加新表或新字段
    ✅ 修改字段类型或约束
    ✅ 添加索引
    
    不适用场景：
    ❌ 删除表或字段（需人工确认）
    ❌ 修改核心业务数据（风险过高）
    ❌ 跨服务的数据迁移（需协调）
    
    参数示例：
        changes = {
            "add_table": {
                "name": "orders",
                "columns": [
                    {"name": "id", "type": "uuid", "primary": true},
                    {"name": "user_id", "type": "uuid", "reference": "users.id"}
                ]
            }
        }
    
    注意事项：
    - auto_apply=True 时会立即执行迁移
    - 生产环境必须设置 auto_apply=False
    - 迁移文件会自动添加到版本控制
    """
    pass
```

### 6.3 betaZodTool实践示例

```typescript
import { betaZodTool } from '@agent/core';
import { z } from 'zod';

const UpdateYuquePostSchema = z.object({
  post_id: z.string().describe("语雀文档ID"),
  title: z.string().optional().describe("新标题"),
  content: z.string().optional().describe("新内容（Markdown格式）"),
  update_reason: z.string().describe("更新原因，用于生成版本说明")
});

export const updateYuquePost = betaZodTool({
  name: "update_yuque_post",
  description: "更新语雀文档，适用于已存在文档的内容更新",
  parameters: UpdateYuquePostSchema,
  execute: async (params, context) => {
    // 1. 参数验证（自动完成）
    // 2. 权限检查
    if (!context.user.canEdit(params.post_id)) {
      return {
        success: false,
        error_code: "PERMISSION_DENIED",
        fix_suggestion: "请联系文档所有者获取编辑权限"
      };
    }
    
    // 3. 执行更新
    const result = await yuqueApi.updatePost(params);
    
    // 4. 返回决策相关信息
    return {
      success: true,
      updated_fields: Object.keys(params).filter(k => k !== 'update_reason'),
      version: result.version,
      view_url: result.url,
      suggested_next_steps: [
        "通知相关成员查看更新",
        "检查文档链接是否需要同步更新"
      ]
    };
  }
});
```

---

<a name="评测体系"></a>
## 7. 评测体系构建

### 7.1 Agent评测结构

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

### 7.2 三类评分器

#### ① 代码评分器（最高确定性）

```python
class CodeEvaluator:
    """
    适用场景：有明确答案的任务
    示例：单元测试通过率、编译成功、特定文件存在
    """
    def evaluate(self, task, environment):
        # 检查文件是否存在
        if task.target_file:
            if not os.path.exists(task.target_file):
                return Score(0, "目标文件未创建")
        
        # 执行测试套件
        test_result = run_tests(task.test_command)
        
        # 检查特定输出
        if task.expected_output:
            actual = read_file(task.output_file)
            if actual != task.expected_output:
                return Score(0.5, "输出部分匹配")
        
        return Score(1.0, "完全通过")
```

#### ② 模型评分器（中等确定性）

```python
class ModelEvaluator:
    """
    适用场景：语义质量、风格、用户体验
    示例：代码可读性、文档质量、错误提示友好度
    """
    def evaluate(self, task, transcript):
        prompt = f"""
        评估以下Agent执行结果的质量：
        
        任务：{task.description}
        执行记录：{transcript}
        
        评分维度（0-10分）：
        1. 完整性：是否完成了所有要求？
        2. 代码质量：是否符合最佳实践？
        3. 可维护性：代码是否易于理解和修改？
        
        输出JSON格式：
        {{
          "score": <0-10>,
          "reasoning": "<评分理由>",
          "improvements": ["<改进建议>"]
        }}
        """
        
        result = llm.evaluate(prompt)
        return Score(
            result.score / 10.0,
            result.reasoning
        )
```

#### ③ 人工评分器（校准基准）

```yaml
作用: 建立基准、校准其他评分器
频率: 
  - 初始评测集创建：全量人工标注
  - 定期抽样：每周随机抽取50个案例
  - 异常案例：评分器结果异常时人工复核

流程:
  1. 评审员独立评分（至少2人）
  2. 计算评审员间一致性（Cohen's Kappa）
  3. 不一致案例讨论达成共识
  4. 更新评分器校准参数
```

### 7.3 关键指标

```yaml
Pass@k: k次运行至少一次成功
  用途: 探索能力上限
  计算: Pass@k = 1 - (n-k+1)/(n+1) * C(n, k-1)
  示例: 10次运行中至少成功1次

Pass^k: k次运行全部成功
  用途: 回归测试、生产可靠性
  计算: Pass^k = (成功次数 / 总次数)^k
  示例: 10次运行全部成功（严格要求）
```

### 7.4 评测搭建步骤

```yaml
步骤1: 从真实失败案例启动
  数量: 20-50个
  来源: 
    - 用户反馈的Bug
    - 线上监控的异常
    - 人工Review发现的问题

步骤2: 环境隔离
  容器化: Docker环境隔离
  数据隔离: 每次评测使用独立数据集
  清理机制: 评测完成后自动清理

步骤3: 评分器选择优先级
  优先级: 代码评分器 → 模型评分器 → 人工校准
  理由: 确定性越高，反馈越快

步骤4: 定期审查执行记录
  频率: 每周
  内容: 
    - 评分器误判案例
    - 新发现的失败模式
    - 环境配置问题

步骤5: 防止评测套件饱和
  触发条件: 通过率接近100%
  动作: 补充更难任务
  目标: 保持评测集的区分度
```

### 7.5 评测系统故障排查流程

```yaml
当评测分数下降时:

步骤1: 检查评测系统本身
  □ 环境配置是否正确
  □ 评分器是否正常工作
  □ 测试用例是否过期
  □ 依赖版本是否变化

步骤2: 检查Agent工具定义
  □ 工具描述是否清晰
  □ 返回值是否包含必要信息
  □ 错误处理是否合理

步骤3: 检查Harness质量
  □ 约束是否过于严格或宽松
  □ 上下文是否充分
  □ 反馈回路是否有效

步骤4: 最后才考虑模型或Prompt调整
  ⚠️ 直接调整模型/Prompt往往是错误方向
```

---

<a name="生产方案"></a>
## 8. 【生产级】Harness Engineering设计方案

> 本部分提供一套完整可落地的实施方案，适用于10-50人的技术团队。

### 8.1 系统架构设计

#### 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                    Harness Engineering Platform              │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │ 任务发布层    │───→│ 编排层        │───→│ 执行层       │  │
│  │              │    │              │    │              │  │
│  │ - Slack/CLI  │    │ - Orchestrator│   │ - Agent Pool │  │
│  │ - Web UI     │    │ - Scheduler  │    │ - Tools      │  │
│  │ - API        │    │ - Monitor     │    │ - Sandbox    │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│          │                   │                   │           │
│          └───────────────────┴───────────────────┘           │
│                              ↓                                │
│  ┌──────────────────────────────────────────────────────────┐│
│  │                   Harness 层（核心）                      ││
│  ├──────────────────────────────────────────────────────────┤│
│  │                                                          ││
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐        ││
│  │  │上下文工程   │  │架构约束     │  │熵管理      │        ││
│  │  │            │  │            │  │            │        ││
│  │  │- AGENTS.md │  │- Linters   │  │- 扫描器    │        ││
│  │  │- 记忆系统   │  │- 测试框架   │  │- 重构Agent │        ││
│  │  │- 可观测性   │  │- CI规则    │  │- 依赖审计  │        ││
│  │  └────────────┘  └────────────┘  └────────────┘        ││
│  │                                                          ││
│  └──────────────────────────────────────────────────────────┘│
│                              ↓                                │
│  ┌──────────────────────────────────────────────────────────┐│
│  │                   评测与反馈层                            ││
│  ├──────────────────────────────────────────────────────────┤│
│  │  - 评测套件（Evals）                                      ││
│  │  - Trace收集与分析                                       ││
│  │  - 人工Review工作台                                      ││
│  │  - 指标仪表盘                                            ││
│  └──────────────────────────────────────────────────────────┘│
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

#### 核心组件清单

```yaml
1. 任务发布层:
   - Slack Bot（主流渠道集成）
   - Web Dashboard（可视化管理）
   - CLI工具（开发者本地使用）
   - REST API（系统集成）

2. 编排层:
   - Task Orchestrator（任务分解与调度）
   - Agent Scheduler（智能体池管理）
   - Health Monitor（健康检查与故障恢复）

3. 执行层:
   - Agent Pool（智能体池，支持多模型）
   - Tool Registry（工具注册中心）
   - Sandbox Environment（隔离执行环境）

4. Harness层（核心）:
   - Context Manager（上下文管理）
   - Constraint Engine（约束引擎）
   - Entropy Controller（熵控制器）

5. 评测与反馈层:
   - Eval Suite（评测套件）
   - Trace Collector（执行记录收集）
   - Review Workbench（人工审查工作台）
   - Metrics Dashboard（指标仪表盘）
```

### 8.2 目录结构设计

```yaml
project-root/
├── .harness/                      # Harness配置目录
│   ├── config.yaml               # 全局配置
│   ├── agents/                   # 智能体配置
│   │   ├── orchestrator.yaml
│   │   ├── coder.yaml
│   │   └── reviewer.yaml
│   ├── constraints/              # 约束规则
│   │   ├── architecture.yaml     # 架构约束
│   │   ├── lint-rules.yaml       # Lint规则
│   │   └── test-policy.yaml      # 测试策略
│   ├── prompts/                  # Prompt模板
│   │   ├── base.md
│   │   ├── coding.md
│   │   └── review.md
│   └── tools/                    # 工具定义
│       ├── code-tools.yaml
│       ├── git-tools.yaml
│       └── ci-tools.yaml
│
├── AGENTS.md                     # 智能体主入口
├── MEMORY.md                     # 长期记忆
│
├── docs/                         # 文档
│   ├── architecture/             # 架构文档
│   │   ├── AGENTS.md
│   │   ├── decisions/           # 架构决策记录
│   │   └── diagrams/            # 架构图
│   ├── api/                      # API文档
│   │   ├── AGENTS.md
│   │   └── contracts/
│   └── guides/                   # 开发指南
│       ├── AGENTS.md
│       └── coding-standards.md
│
├── src/                          # 源代码
│   ├── types/                    # 类型定义（最底层）
│   ├── config/                   # 配置层
│   ├── repositories/             # 数据访问层
│   ├── services/                 # 业务逻辑层
│   ├── runtime/                  # 运行时
│   └── ui/                       # 用户界面（最上层）
│
├── tests/                        # 测试
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── .github/                      # CI/CD
│   ├── workflows/
│   │   ├── agent-ci.yaml        # Agent专用CI流程
│   │   └── entropy-scan.yaml    # 熵管理任务
│   └── hooks/                    # Pre-commit hooks
│
└── evals/                        # 评测套件
    ├── tasks/                    # 任务定义
    ├── environments/            # 测试环境
    └── scorers/                 # 评分器
```

### 8.3 核心配置文件设计

#### `.harness/config.yaml`

```yaml
# Harness全局配置
version: "1.0"
metadata:
  project: "MyApp"
  team: "Platform Engineering"
  last_updated: "2026-03-27"

# 智能体配置
agents:
  orchestrator:
    model: "claude-3-opus"
    max_turns: 50
    timeout: "2h"
  
  coder:
    model: "claude-3-sonnet"
    max_turns: 100
    timeout: "4h"
  
  reviewer:
    model: "gpt-4-turbo"
    max_turns: 20
    timeout: "30m"

# 上下文工程
context:
  max_tokens: 200000
  layers:
    - name: "system"
      priority: 1
      persistent: true
    - name: "memory"
      priority: 2
      source: "MEMORY.md"
    - name: "task"
      priority: 3
      dynamic: true
  
  compression:
    strategy: "sliding_window"
    threshold: 0.8  # token使用率达80%时触发
    preserve:
      - "decision_points"
      - "error_contexts"

# 架构约束
constraints:
  dependency_layers:
    - "types"
    - "config"
    - "repositories"
    - "services"
    - "runtime"
    - "ui"
  
  enforcement:
    linter: true
    pre_commit: true
    ci_gate: true
  
  error_handling:
    auto_fix: true
    max_retries: 3

# 熵管理
entropy:
  schedule:
    daily: "02:00"
    weekly: "Sunday 03:00"
  
  scanners:
    - name: "doc_drift"
      enabled: true
    - name: "dead_code"
      enabled: true
    - name: "pattern_debt"
      enabled: true
  
  auto_fix:
    enabled: true
    max_pr_per_day: 5

# 评测配置
evaluation:
  enabled: true
  suite: "standard"
  frequency: "per_commit"
  
  scorers:
    - type: "code"
      weight: 0.6
    - type: "model"
      weight: 0.3
    - type: "human"
      weight: 0.1
  
  pass_criteria:
    min_score: 0.85
    max_regressions: 0
```

#### `AGENTS.md`（核心入口文件）

```markdown
# Agent导航入口

> 本文件是智能体的主要导航点，包含任务执行所需的关键信息。

## 1. 项目概述

- **类型**：微服务架构的电商平台
- **技术栈**：TypeScript + Node.js + PostgreSQL + Redis
- **团队规模**：10人
- **Agent角色**：主要负责编码、测试、重构任务

## 2. 架构约束

```
依赖方向：Types → Config → Repos → Services → Runtime → UI
禁止：
  - UI直接依赖Repos
  - Services直接访问DB（必须通过Repo）
  - 跨服务调用（使用消息队列）
```

详见：`.harness/constraints/architecture.yaml`

## 3. 编码规范

- **格式化**：使用Prettier，配置见 `.prettierrc`
- **Lint**：ESLint + 自定义规则，见 `.eslintrc.agent.js`
- **命名**：
  - 文件：kebab-case
  - 类：PascalCase
  - 函数/变量：camelCase
  - 常量：UPPER_SNAKE_CASE

详见：`docs/guides/coding-standards.md`

## 4. 工作流程

### 4.1 开发任务
```
1. 接收任务 → 分析需求
2. 检查相关代码 → 设计方案
3. 实现功能 → 编写测试
4. 运行测试 → 修复问题
5. 提交PR → 等待审查
```

### 4.2 重构任务
```
1. 分析现有代码结构
2. 识别改进点（使用熵管理工具）
3. 设计重构方案
4. 小步重构 → 每步验证
5. 更新文档 → 提交PR
```

### 4.3 Bug修复
```
1. 复现问题（必须）
2. 定位根因
3. 编写回归测试
4. 实现修复
5. 验证修复 + 副作用检查
6. 提交PR
```

## 5. 工具使用指南

### 代码相关
- `update_api_endpoint`：更新API端点
- `create_service`：创建新的服务
- `add_database_migration`：数据库迁移
- `run_tests`：执行测试套件

### Git相关
- `create_feature_branch`：创建功能分支
- `commit_changes`：提交变更（自动生成消息）
- `create_pr`：创建Pull Request

### CI/CD
- `check_ci_status`：检查CI状态
- `rerun_failed_tests`：重跑失败的测试

详见：`.harness/tools/`

## 6. 常见问题

### Q1: 测试失败怎么办？
```
1. 分析失败日志
2. 区分：代码问题 vs 环境问题
3. 如果是环境问题 → 重跑测试
4. 如果是代码问题 → 修复代码
5. 修复后验证：本地测试通过 → 提交
```

### Q2: 如何处理依赖冲突？
```
1. 检查package.json冲突
2. 使用 yarn resolutions 或 npm overrides
3. 验证：编译通过 + 测试通过
4. 更新依赖文档
```

### Q3: 文档如何更新？
```
1. 代码变更时同步更新相关文档
2. 更新 CHANGELOG.md
3. 如果是API变更 → 更新 docs/api/
4. 如果是架构变更 → 更新 docs/architecture/decisions/
```

## 7. 联系人与资源

- **技术负责人**：Alice（架构决策）
- **代码审查**：Bob（PR审查）
- **DevOps**：Charlie（部署相关）

**重要文档**：
- 架构决策记录：`docs/architecture/decisions/`
- API契约：`docs/api/contracts/`
- 运维手册：`docs/ops/runbook.md`

---

_本文件是Agent的主要入口，请保持简洁（<100行）。详细信息通过链接提供。_
```

### 8.4 工具定义示例

#### `.harness/tools/code-tools.yaml`

```yaml
tools:
  - name: "update_api_endpoint"
    description: |
      更新API端点的实现
      
      适用场景：
      ✅ 修改现有API的逻辑
      ✅ 添加新的请求/响应字段
      ✅ 修改错误处理逻辑
      
      不适用场景：
      ❌ 创建新的API端点（使用 create_api_endpoint）
      ❌ 删除API端点（需人工确认）
    
    parameters:
      endpoint:
        type: string
        description: "API路径，如 /api/users/:id"
      changes:
        type: object
        description: "变更内容，包含要修改的字段"
      reason:
        type: string
        description: "变更原因，用于commit message"
    
    returns:
      success:
        - modified_files: "修改的文件列表"
        - affected_tests: "影响的测试文件"
        - validation_steps: "建议的验证步骤"
      failure:
        - error_code: "错误代码"
        - fix_suggestion: "修复建议"
        - related_docs: "相关文档链接"
    
    examples:
      - description: "修改用户API的返回字段"
        params:
          endpoint: "/api/users/:id"
          changes:
            response_fields:
              add:
                - name: "lastLoginAt"
                  type: "Date"
              modify:
                - name: "name"
                  new_type: "string"
          reason: "添加最后登录时间字段"
        
        expected_output:
          success: true
          modified_files:
            - "src/services/user.service.ts"
            - "src/types/user.types.ts"
          affected_tests:
            - "tests/unit/user.service.test.ts"
          validation_steps:
            - "运行单元测试：npm test user.service"
            - "检查API文档是否需要更新"

  - name: "create_service"
    description: |
      创建新的服务层模块
      
      遵循架构约束：
      - 放置在 src/services/ 目录
      - 实现接口定义在 src/types/
      - 依赖注入通过构造函数
      
    parameters:
      service_name:
        type: string
        description: "服务名称，PascalCase"
      methods:
        type: array
        description: "服务方法列表"
      dependencies:
        type: array
        description: "依赖的其他服务或Repo"
    
    returns:
      success:
        - created_files: "创建的文件列表"
        - next_steps: "后续建议步骤"
      
    examples:
      - description: "创建订单服务"
        params:
          service_name: "OrderService"
          methods:
            - name: "createOrder"
              params: ["userId", "items"]
              return_type: "Promise<Order>"
            - name: "cancelOrder"
              params: ["orderId"]
              return_type: "Promise<void>"
          dependencies:
            - "IUserRepository"
            - "IProductRepository"
            - "IPaymentGateway"

  - name: "run_tests"
    description: |
      执行测试套件
      
      自动处理：
      - 测试失败时分析日志
      - 环境问题自动重试
      - 生成测试报告
      
    parameters:
      scope:
        type: string
        enum: ["unit", "integration", "e2e", "all"]
        description: "测试范围"
      files:
        type: array
        optional: true
        description: "指定测试文件（可选）"
    
    returns:
      success:
        - pass_rate: "通过率"
        - coverage: "代码覆盖率"
        - duration: "执行时长"
      failure:
        - failed_tests: "失败的测试列表"
        - error_analysis: "错误分析"
        - fix_suggestions: "修复建议"
```

### 8.5 CI/CD流程设计

#### `.github/workflows/agent-ci.yaml`

```yaml
name: Agent CI Pipeline

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  # Job 1: 快速检查（5分钟内）
  quick-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Environment
        run: |
          npm ci
          npm run setup:test
      
      - name: Lint Check
        run: npm run lint:agent
        
      - name: Type Check
        run: npm run type-check
        
      - name: Unit Tests
        run: npm run test:unit --coverage
        
      - name: Architecture Validation
        run: npm run validate:architecture

  # Job 2: 深度测试（可并行）
  deep-test:
    needs: quick-check
    runs-on: ubuntu-latest
    strategy:
      matrix:
        test-type: [integration, e2e]
    steps:
      - uses: actions/checkout@v3
      
      - name: Run ${{ matrix.test-type }} Tests
        run: npm run test:${{ matrix.test-type }}
        
      - name: Upload Results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results-${{ matrix.test-type }}
          path: test-results/

  # Job 3: Agent评测（关键）
  agent-eval:
    needs: quick-check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Agent Evaluation
        run: |
          npm run eval:run --suite=standard
      
      - name: Check Pass Rate
        run: |
          PASS_RATE=$(cat eval-results/pass_rate.txt)
          if (( $(echo "$PASS_RATE < 0.85" | bc -l) )); then
            echo "❌ Evaluation failed: Pass rate $PASS_RATE < 0.85"
            exit 1
          fi
          echo "✅ Evaluation passed: Pass rate $PASS_RATE"
      
      - name: Upload Eval Results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: eval-results
          path: eval-results/

  # Job 4: 人工审查提示（可选）
  human-review:
    needs: [deep-test, agent-eval]
    runs-on: ubuntu-latest
    if: github.event.pull_request.draft == false
    steps:
      - name: Request Review
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.pulls.createReviewRequest({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: context.issue.number,
              reviewers: ['tech-lead', 'code-reviewer']
            })
```

#### `.github/workflows/entropy-scan.yaml`

```yaml
name: Entropy Management

on:
  schedule:
    - cron: '0 2 * * *'  # 每天凌晨2点
  workflow_dispatch:

jobs:
  entropy-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Document Drift Detection
        run: |
          npm run entropy:check-docs
          if [ -f "entropy-report/doc-drift.json" ]; then
            echo "::warning::Document drift detected"
          fi
      
      - name: Dead Code Analysis
        run: |
          npm run entropy:find-dead-code
          
      - name: Pattern Debt Scan
        run: |
          npm run entropy:scan-patterns
      
      - name: Generate Report
        run: |
          npm run entropy:generate-report
      
      - name: Create PR if needed
        run: |
          if [ -f "entropy-fixes/changes.md" ]; then
            gh pr create \
              --title "[Auto] Entropy fixes - $(date +%Y-%m-%d)" \
              --body-file entropy-fixes/changes.md \
              --label "entropy,automated" \
              --base main
          fi
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 8.6 评测套件设计

#### `evals/tasks/example-task.yaml`

```yaml
task_id: "create-user-service"
category: "service-creation"
difficulty: "medium"

description: |
  创建一个新的用户服务，包含以下功能：
  1. 用户注册（带邮箱验证）
  2. 用户登录（JWT认证）
  3. 密码重置
  
requirements:
  - 遵循服务层架构规范
  - 实现完整的错误处理
  - 编写单元测试（覆盖率 > 80%）
  - 更新相关文档

environment:
  setup_commands:
    - "npm install"
    - "npm run db:migrate:test"
  cleanup_commands:
    - "npm run db:reset:test"
  
  timeout: "30m"

expected_outcome:
  files_created:
    - "src/services/user.service.ts"
    - "src/types/user.types.ts"
    - "tests/unit/user.service.test.ts"
  
  files_modified:
    - "src/types/index.ts"
    - "docs/api/user-api.md"
  
  tests_pass: true
  
  architecture_valid: true
```

#### `evals/scorers/code-scorer.ts`

```typescript
import { EvalTask, EvalResult, Environment } from '@agent/eval-types';

export class CodeScorer {
  async score(task: EvalTask, env: Environment): Promise<EvalResult> {
    const scores: Record<string, number> = {};
    
    // 1. 文件完整性检查（30分）
    scores.file_completeness = await this.checkFiles(task, env);
    
    // 2. 测试通过率（30分）
    scores.test_pass_rate = await this.runTests(env);
    
    // 3. 架构合规性（20分）
    scores.architecture_compliance = await this.checkArchitecture(env);
    
    // 4. 代码质量（20分）
    scores.code_quality = await this.analyzeCodeQuality(env);
    
    // 加权平均
    const totalScore = 
      scores.file_completeness * 0.3 +
      scores.test_pass_rate * 0.3 +
      scores.architecture_compliance * 0.2 +
      scores.code_quality * 0.2;
    
    return {
      score: totalScore,
      breakdown: scores,
      passed: totalScore >= 0.85,
      details: await this.generateDetails(scores, env)
    };
  }
  
  private async checkFiles(task: EvalTask, env: Environment): Promise<number> {
    let score = 0;
    const total = task.expected_outcome.files_created.length + 
                  task.expected_outcome.files_modified.length;
    
    let found = 0;
    for (const file of task.expected_outcome.files_created) {
      if (await env.fileExists(file)) found++;
    }
    for (const file of task.expected_outcome.files_modified) {
      if (await env.fileModified(file)) found++;
    }
    
    return found / total;
  }
  
  private async runTests(env: Environment): Promise<number> {
    const result = await env.executeCommand('npm test -- --json');
    const testResult = JSON.parse(result.stdout);
    
    return testResult.success_percent / 100;
  }
  
  private async checkArchitecture(env: Environment): Promise<number> {
    const result = await env.executeCommand('npm run lint:architecture');
    
    return result.exitCode === 0 ? 1.0 : 0.0;
  }
  
  private async analyzeCodeQuality(env: Environment): Promise<number> {
    const result = await env.executeCommand('npm run lint:quality -- --format json');
    const qualityReport = JSON.parse(result.stdout);
    
    // 基于复杂度、重复代码、代码异味等指标
    return Math.max(0, 1 - (qualityReport.issues.length / 100));
  }
}
```

### 8.7 监控与可观测性

#### Trace收集配置

```typescript
// src/agent/trace-collector.ts
interface Trace {
  trace_id: string;
  task_id: string;
  agent_id: string;
  start_time: Date;
  end_time: Date;
  
  // Prompt相关
  initial_prompt: string;
  context_layers: string[];
  token_usage: {
    prompt: number;
    completion: number;
    total: number;
  };
  
  // 执行过程
  turns: Turn[];
  
  // 工具调用
  tool_calls: ToolCall[];
  
  // 结果
  outcome: "success" | "failure" | "timeout";
  final_state: any;
}

interface Turn {
  turn_id: number;
  agent_reasoning: string;  // 思考过程
  action: string;           // 采取的行动
  tool_used?: string;      // 使用的工具
  observation: string;     // 观察到的结果
  decision_point: boolean; // 是否是关键决策点
}

interface ToolCall {
  tool_name: string;
  parameters: any;
  result: any;
  duration: number;  // 执行时长(ms)
  success: boolean;
}

export class TraceCollector {
  private traces: Map<string, Trace> = new Map();
  
  startTrace(taskId: string, agentId: string): string {
    const traceId = generateUUID();
    this.traces.set(traceId, {
      trace_id: traceId,
      task_id: taskId,
      agent_id: agentId,
      start_time: new Date(),
      turns: [],
      tool_calls: [],
      // ...其他字段初始化
    });
    return traceId;
  }
  
  recordTurn(traceId: string, turn: Turn) {
    const trace = this.traces.get(traceId);
    if (trace) {
      trace.turns.push(turn);
      this.emitEvent('turn_recorded', { traceId, turn });
    }
  }
  
  recordToolCall(traceId: string, toolCall: ToolCall) {
    const trace = this.traces.get(traceId);
    if (trace) {
      trace.tool_calls.push(toolCall);
      this.emitEvent('tool_called', { traceId, toolCall });
    }
  }
  
  endTrace(traceId: string, outcome: Trace['outcome']) {
    const trace = this.traces.get(traceId);
    if (trace) {
      trace.end_time = new Date();
      trace.outcome = outcome;
      
      // 持久化到存储
      this.saveTrace(trace);
      
      // 触发下游处理
      this.emitEvent('trace_completed', trace);
    }
  }
  
  private emitEvent(eventType: string, data: any) {
    // 事件流架构：多路消费
    eventBus.emit(eventType, data);
  }
}
```

#### 监控仪表盘指标

```yaml
实时监控指标:
  - 正在执行的任务数
  - Agent池利用率
  - 平均任务完成时间
  - 当前失败率
  
质量指标:
  - Pass@1通过率
  - Pass@3通过率
  - 评测套件总体通过率
  - 代码覆盖率
  
效率指标:
  - 任务吞吐量（tasks/hour）
  - 平均token消耗
  - 工具调用成功率
  - 人工介入频率
  
熵管理指标:
  - 文档漂移检测数
  - 死代码行数
  - 模式债务评分
  - 重构PR创建频率
```

### 8.8 安全与边界控制

```yaml
安全措施:
  1. 工作空间隔离:
     - 每个任务使用独立worktree
     - 禁止访问工作空间外的文件
     - 敏感文件（.env, credentials）不可见
  
  2. 操作审计:
     - 所有文件操作记录到审计日志
     - 敏感操作（删除、部署）需人工确认
     - 异常行为自动触发告警
  
  3. Prompt Injection防护:
     - 标注用户输入边界（不可信内容）
     - 敏感操作前独立LLM验证
     - 白名单授权机制
  
  4. 故障容错:
     - Provider故障自动切换
     - 任务超时自动终止
     - 崩溃后从断点恢复
  
  5. 资源限制:
     - 最大并发任务数
     - 单任务最大执行时间
     - Token消耗上限
```

---

<a name="实施路线"></a>
## 9. 实施路线图与最佳实践

### 9.1 分层实施路径

#### Level 1：个人开发者（1-2天）

```yaml
核心配置:
  - 基础AGENTS.md（50-100行）
  - Pre-commit钩子（格式化、Lint）
  - 基础测试套件
  - 简单的记忆系统（MEMORY.md）

工具选择:
  - 使用现有Agent工具（Claude Code, Cursor等）
  - 复用开源Linter配置
  - 基础CI（GitHub Actions模板）

预期效果:
  - 减少50%的编码时间
  - 代码质量提升30%
  - 快速验证Harness效果
```

#### Level 2：小团队（1-2周）

```yaml
新增内容:
  - 团队级AGENTS.md（统一规范）
  - 自定义CI流程（Agent专用）
  - 共享Prompt模板库
  - 初步评测套件（20-30个任务）
  - 文档智能体（每日运行）

团队协作:
  - 明确分工：架构师（写Harness）+ 工程师（Review）
  - 定期Harness Review（每周）
  - 失败案例分析会（每月）

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

组织变革:
  - 团队结构：架构组 + Review组 + Agent运维组
  - 工作流程：任务驱动 → Agent执行 → 人工Review
  - 考核指标：从"代码行数"转向"约束质量"

预期效果:
  - 整体效率提升5-10倍
  - 开发周期缩短60%
  - 技术债务持续可控
```

### 9.2 最佳实践清单

#### ✅ DO：应该做的事

```yaml
设计原则:
  ✅ 仓库是唯一真理源
  ✅ 所有规范必须可执行（Lint化）
  ✅ 错误信息包含修复建议
  ✅ 分层文档，渐进式披露
  ✅ 工具设计对应Agent目标

实施原则:
  ✅ 从小规模试点开始
  ✅ 持续收集失败案例
  ✅ 定期审查Trace和评测结果
  ✅ Harness随模型演进更新
  ✅ 保持人类在关键决策环中

监控原则:
  ✅ 优先检查工具和Harness
  ✅ Trace比结果更重要
  ✅ 熵管理持续运行
  ✅ 评测分数下降先查评测系统
```

#### ❌ DON'T：应该避免的坑

```yaml
设计陷阱:
  ❌ 巨型指令文件（难维护、难验证）
  ❌ 仅限人类阅读的文档（Agent不可见）
  ❌ 过度工程化控制流（丧失灵活性）
  ❌ 工具粒度过细（Agent需协调多个工具）
  ❌ 返回完整原始数据（上下文污染）

实施陷阱:
  ❌ 直接调整Prompt而不检查Harness
  ❌ 忽略Trace分析（错失改进机会）
  ❌ 评测集饱和（失去区分度）
  ❌ 环境隔离不足（测试污染）
  ❌ 熵管理缺失（技术债务累积）

监控陷阱:
  ❌ 只看最终结果不看过程
  ❌ 评分器未校准就大规模应用
  ❌ 忽略人工Review的重要性
  ❌ 过度依赖自动化（缺少人工校准）
```

### 9.3 成功指标定义

```yaml
短期指标（1个月）:
  - 任务成功率 > 70%
  - Pass@3通过率 > 85%
  - 人工介入频率 < 20%
  - 平均任务完成时间 < 预期的1.5倍

中期指标（3个月）:
  - 任务成功率 > 80%
  - Pass@1通过率 > 75%
  - 代码覆盖率 > 80%
  - 文档完整度 > 90%
  - PR合并周期 < 1天

长期指标（6个月）:
  - 任务成功率 > 90%
  - Pass@1通过率 > 85%
  - 熵增长率 < 5%/月
  - 团队效率提升 > 5倍
  - 技术债务清理速度 > 产生速度
```

### 9.4 常见问题FAQ

**Q1: 如何判断是否应该使用Harness Engineering？**

```yaml
适用场景:
  ✅ 代码库较大（>10万行）
  ✅ 团队规模适中（5-50人）
  ✅ 有明确的架构规范
  ✅ 任务可拆解、可验证
  ✅ 愿意投入初期建设成本

不适用场景:
  ❌ 非常小的项目（<1000行）
  ❌ 探索性原型开发
  ❌ 缺乏测试文化
  ❌ 架构快速变化中
```

**Q2: 如何平衡自动化与人工控制？**

```yaml
自动化优先:
  - 重复性编码任务
  - 格式化、Lint等规范检查
  - 单元测试编写
  - 文档同步更新

人工必需:
  - 架构决策
  - API设计
  - 安全相关变更
  - 跨团队协调
  - 性能关键路径

渐进式放手:
  - 初期：人工Review 100%
  - 中期：高风险任务人工Review，其他抽检
  - 后期：仅关键决策点人工确认
```

**Q3: 如何处理Agent生成的"坏代码"？**

```yaml
预防措施:
  1. 强化Linter规则（预防坏模式）
  2. 架构约束测试（边界检查）
  3. 代码质量评分器（语义检查）

检测机制:
  1. 熵管理智能体（定期扫描）
  2. 人工Review（关键PR）
  3. 用户反馈收集

修复策略:
  1. 自动生成重构PR
  2. 更新黄金规则（编码进Linter）
  3. 补充评测用例（防止复发）
```

**Q4: 如何应对模型升级？**

```yaml
模型升级策略:
  1. 评测先行：新模型在评测集上的表现
  2. 灰度发布：先在非关键任务使用
  3. Harness瘦身：模型能力提升后简化约束
  4. 回滚机制：出现问题快速切回旧模型

Harness调整:
  - 模型更强 → 减少Prompt细节
  - 模型更快 → 提高并发度
  - 模型更准 → 放宽约束
```

---

<a name="附录"></a>
## 10. 附录：关键资源与参考

### 10.1 核心资源链接

```yaml
官方资源:
  - OpenAI Harness Engineering指南: https://openai.com/zh-Hans-CN/index/harness-engineering/
  - Anthropic Agent设计最佳实践: https://www.anthropic.com/research/building-effective-agents

开源项目:
  - deusyu/harness-engineering: https://github.com/deusyu/harness-engineering
  - ralph-orchestrator: https://github.com/bmad-sim/ralph-orchestrator
  - LangChain Agent工具: https://github.com/langchain-ai/langchain

深度文章:
  - Tw93: 你不知道的Agent: https://tw93.fun/2026-03-21/agent.html
  - 效率悖论解析: （详见GitHub仓库 references/）

工具与框架:
  - Claude Code: Anthropic官方Agent工具
  - Cursor: AI驱动的IDE
  - Continue.dev: 开源AI编程助手
```

### 10.2 技术栈推荐

```yaml
Agent框架:
  - LangChain: 成熟的Agent编排框架
  - AutoGen: 微软多Agent框架
  - CrewAI: 角色扮演式多Agent

编排工具:
  - Temporal: 工作流编排
  - Prefect: 数据流编排
  - Airflow: 任务调度

可观测性:
  - Vector: 日志收集
  - VictoriaMetrics: 时序数据存储
  - Jaeger: 分布式追踪
  - Grafana: 可视化

评测框架:
  - pytest + pytest-benchmark
  - custom eval framework（推荐自建）
```

### 10.3 关键概念速查表

| 概念 | 定义 | 核心要点 |
|------|------|---------|
| Harness | 约束、验证、纠正AI的系统 | 模型是商品，Harness是护城河 |
| Context Engineering | 在正确时间提供正确信息 | 分层加载、按需注入 |
| Architectural Constraints | 代码结构强制规则 | Linter化、CI强制 |
| Entropy Management | 技术债务自动化管理 | 定期扫描、自动重构 |
| ACI | Agent-Computer Interface | 工具对应目标而非操作 |
| Pass@k | k次运行至少一次成功 | 探索能力上限 |
| Pass^k | k次运行全部成功 | 生产可靠性要求 |
| Ralph循环 | 清空上下文的迭代循环 | Fresh Context、Backpressure |
| Trace | 完整执行记录 | 比结果更重要 |

### 10.4 实施检查清单

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
  □ 定期Harness Review机制建立

Level 3 实施检查:
  □ 完整Harness平台上线
  □ 自定义工具集投入使用
  □ 评测集超过100个任务
  □ 可观测性栈完整部署
  □ 熵管理智能体定期运行
  □ 多Agent协作系统可用
```

---

## 结语

Harness Engineering不是银弹，而是一种新的工程范式。它的核心价值在于：

> **让工程师从"写代码"解放出来，转向"设计系统"——这才是AI时代软件工程师的核心竞争力。**

记住三个关键点：

1. **模型是商品，Harness是护城河**
2. **人类掌舵，智能体执行**
3. **验证闭环比单次成功更重要**

现在就开始你的Harness Engineering之旅吧！从创建第一个AGENTS.md开始，逐步构建让AI智能体真正发挥作用的系统。

---

**文档版本历史**：
- v1.0 (2026-03-27): 初始版本，基于OpenAI官方、GitHub实践、Tw93深度文章整理

**贡献者**：
- 内容整理：AI Assistant
- 资料来源：OpenAI、deusyu、Tw93等开源社区贡献者

**许可证**：
- 本文档采用 CC BY-SA 4.0 协议
- 可自由分享、修改，需保留原作者署名

---

_最后更新：2026-03-27_
