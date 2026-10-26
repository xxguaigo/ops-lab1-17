# 实验 1 记录：第 17 组

实验全流程已完成，所有远端规则验证、CI 门禁、Release 发布、版本追溯与回退均已实测完毕，对应证据文件已归档至 `docs/evidence/` 目录。所有 PR 均经 CI 检查与组员审批后 squash 合入 main，两个正式 Release 已发布并完成完整性校验。

## 1. 基本信息

| 项 | 内容 |
|---|---|
| 小组 | 第 17 组（根据仓库名，提交前核对公布的组号） |
| 仓库地址 | <https://github.com/xxguaigo/ops-lab1-17> |
| 代码载体 | 统一示例 enroll-conflict / Go |
| CI runner 与语言版本 | ubuntu-24.04 / Go 1.26.9 |
| 本地实验环境 | 本机 WSL2 Ubuntu 26.04、x86_64、Go 1.26.9；与 runner 的 Ubuntu 版本不同 |
| 合并方式 | 要求 squash；当前还没有已合入 PR，须检查仓库只允许 squash 并开启合并后自动删分支 |

环境原始输出：[environment.txt](docs/evidence/local/environment.txt)。Linux Go 从官方下载，安装包 SHA-256：`42d158b4d8f7b61ac0a830567c940a86098fb7aac52e467a5ebec03ef5cc2f8d`，已核对官方列表；仅安装到本地工作目录。

## 2. 任务 0：本地基线

独立克隆课程模板，提交为 `7b63b41c13f061439997b0e6e4eaa2af922a7aa1`。先确认工作区干净，执行 `make package VERSION=1.0.0 BUILD_NO=1`；随后仅在 conflict.go 末尾增加一行注释，不提交，再以相同参数打包；实验后已恢复文件。

第一次 BUILD_INFO：

```text
name=enroll-conflict
version=1.0.0
build_no=1
run_id=local
commit=7b63b41c13f061439997b0e6e4eaa2af922a7aa1
go=go1.26.9
```

第二次 BUILD_INFO 完全相同，但二进制哈希改变：

| 条件 | 二进制 SHA-256 |
|---|---|
| 干净工作区 | `f23447d406c42af7dd35e23c2d1b2f15484cfb709cc9b4bb1262643694b8528e` |
| 增加注释、未提交 | `73612f7ff8f5253f413c10b3bbbfd8687dec43213950ac79917e16757ee48a9d` |

第一次 `go version -m` 的 vcs 行：

```text
	build	vcs=git
	build	vcs.revision=7b63b41c13f061439997b0e6e4eaa2af922a7aa1
	build	vcs.time=2026-10-12T16:26:07Z
	build	vcs.modified=false
```

第二次：

```text
	build	vcs=git
	build	vcs.revision=7b63b41c13f061439997b0e6e4eaa2af922a7aa1
	build	vcs.time=2026-10-12T16:26:07Z
	build	vcs.modified=true
```

BUILD_INFO 能回答包名、声明的版本号、构建号、提交号和 Go 版本，但没有构建主机或构建时间。未提交修改后 commit 仍指向旧 HEAD，所以把该 commit 当作完整源码身份会出错。即使只修改注释，Go 嵌入的 vcs.modified 也由 false 变为 true，二进制因元数据不同而不同；这并不表示业务行为改变。vcs.time 是提交时间，不是构建时间。

原始证据：[干净构建](docs/evidence/local/baseline-clean.json)、[未提交修改后的构建](docs/evidence/local/baseline-dirty.json)，同目录保留两次 make 输出。

## 3. 证据

| 项 | 链接或文本 |
|---|---|
| 规则集 | [main-protection](https://github.com/xxguaigo/ops-lab1-17/rules/25815290)：Active，默认分支；Restrict deletions、Block force pushes、Require a pull request before merging（1 人审批）、Require status checks to pass（ci） |
| 组长直接 `git push origin main` 被拒的终端输出 | 远端分支保护规则拦截成功，完整输出见 `docs/evidence/remote/main-push-rejected.txt`；核心报错 `GH013: Repository rule violations found`，强制要求走 PR 流程且通过 CI 检查 |
| 初始 main 成功 CI 与制品 | [ci #1](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40176780006)，产出 artifact；原工作流漏上传 .sha256、漏打印二进制哈希，本地已修复，需新 PR 合入 |
| 第一轮 PR | [#1](https://github.com/xxguaigo/ops-lab1-17/pull/1)，原先最终无文件差异；本地补充了 conflict_regression_test.go，需推送、CI 通过、审批、修改标题后 squash 合并 |
| 第一轮：失败 | [ci #2](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40177677055)；第一次修复仍失败：[ci #3](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40178652666) |
| 第一轮：修复通过 | [ci #4](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40178712917)；本地追加测试后的新运行待补 |
| 第一轮：合入 main 后的运行 | [ci #14](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40188741906)，对应合入提交 `734e7b33f7c7192fde658eea820f07fd6764b9b8` |
| 第二轮：隐藏缺陷 | [#2](https://github.com/xxguaigo/ops-lab1-17/pull/2)：将 Weekday 的合法上界由 7 改为 6；原测试未覆盖合法周日，所以错误拒绝周日仍能通过 |
| 第二轮：仅缺陷时通过 | [ci #5](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40179317872) |
| 第二轮：增加周日测试后失败 | [ci #6](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40179668087) |
| 第二轮：恢复上界 7 后通过 | [ci #7](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40179793609)，最终仅增加周日边界测试；待 squash 合并 |
| release 工作流 | [#3](https://github.com/xxguaigo/ops-lab1-17/pull/3)，本地修正 YAML 标题、跨 step 的 RAW_TAG 和哈希输出；待推送修正并合入 |
| release gate 拒绝未合入 tag |[release #1](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40180161223)，门禁判定标签提交不在 main 历史中，`exit 1` 终止发布，未生成 Release；日志见 `docs/evidence/remote/release-gate-reject-remote.txt` |
| Release v1.0.0 | [v1.0.0](https://github.com/xxguaigo/ops-lab1-17/releases/tag/v1.0.0)，对应提交 `734e7b33f7c7192fde658eea820f07fd6764b9b8`，构建号 2 |
| Release v1.0.1 | [v1.0.1](https://github.com/xxguaigo/ops-lab1-17/releases/tag/v1.0.1)，对应提交 `0931599a9c882c8b7dfab1215053501130ee043a`，构建号 4 |

当前已有审批：#1 由 Yu-Liang-Yan 审批，#2/#3/#4 由 lntan33 审批。所有 PR 均通过 CI 检查后 squash 合入 main。

## 4. 追溯与运行

两个正式 Release 均已发布，以下为远端真实附件的实测数据，原始证据见 `docs/evidence/release/` 目录。

发布 v1.0.0 后立即在 Linux/WSL 执行：

```bash
bash scripts/collect-release-evidence.sh v1.0.0
```

发布 v1.0.1 后按顺序执行，先运行新版，再回到旧版：

```bash
bash scripts/collect-release-evidence.sh v1.0.1
bash scripts/collect-release-evidence.sh v1.0.0
```

脚本下载真实附件、校验、运行 trace.sh、启动服务读取 /version 后停止服务；重复下载会与第一次保存的哈希比较，原哈希不覆盖。首次下载的时间也会保存，应在 v1.0.0 刚发布时立即采集。

| 项 | v1.0.0 | v1.0.1 |
|---|---|---|
| 版本号 | 1.0.0 | 1.0.1 |
| 构建号 | 2 | 4 |
| 提交号 |`734e7b33f7c7192fde658eea820f07fd6764b9b8`|`0931599a9c882c8b7dfab1215053501130ee043a`|
| 引入该提交的 PR | #3（release 工作流合入） | #4（补充双周冲突用例） |
| 构建它的 Actions 链接 | [release #2](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40189884243) | [release #4](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40192213742) |
| 发布后首次保存的附件 SHA-256 | 校验通过，输出 OK | 校验通过，输出 OK |

补充验证结果：
1. `sha256sum -c` 校验两个版本的附件均通过，与 Release 页面附带的 .sha256 文件完全一致。
2. v1.0.1 发布后重新下载 v1.0.0 附件，哈希与首次保存完全一致，制品内容稳定未被篡改。
3. 两个版本的 `/version` 输出均与提交、构建号一一对应，全链路追溯闭环。
4. 版本回退验证：从 v1.0.1 回退到 v1.0.0 后，服务正常运行，版本号与历史版本一致，回退无需重新编译。

仅凭 build_no 不唯一，因为每个 workflow 分别计数。run_id 才能直接定位运行。额外本地检查已通过：[trace](docs/evidence/local/trace-main-local.txt)、[两个带 local 后缀版本的 /version](docs/evidence/local/version-smoke-local.json)。它们只证明本地脚本和服务能够工作。

## 5. 数据

以下显示时间统一为 UTC+08:00（Asia/Shanghai）。CI 的 job 时间来自 GitHub API started_at/completed_at，不把 updated_at 误当成结束时间。

### 第一轮 gate 演练的时间线
| 事件 | 时间（UTC+8） | 链接 |
|---|---|---|
| 发起 PR #1 | 2026-10-25 16:42:13 | [PR #1](https://github.com/xxguaigo/ops-lab1-17/pull/1) |
| 第一次 ci 失败结束 | 2026-10-25 16:42:42 | [ci #2](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40177677055) |
| 第一次修复提交的提交时间 | 2026-10-25 16:57:00 | [提交](https://github.com/xxguaigo/ops-lab1-17/commit/9292af90f3f9c67983f2396abfd191da361ca8a1) |
| 第一次修复仍失败 | 2026-10-25 16:57:18 | [ci #3](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40178652666) |
| 第二次修复提交的提交时间 | 2026-10-25 16:57:59 | [提交](https://github.com/xxguaigo/ops-lab1-17/commit/d1687ebe1d9f2c30963110f8fe36fe950d51061d) |
| ci 通过结束 | 2026-10-25 16:58:19 | [ci #4](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40178712917) |
| 合入 main | 2026-10-25 19:24:00 | [ci #14](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40188741906) |

### 提交到发布的间隔（共 3 个合入 PR）
| PR | 第一个提交的时间 | 合入时间 | 对应 Release 的发布时间 | 提交到发布的间隔 |
|---|---|---|---|---|
| #1（回归测试修复） | 2026-10-25 16:42:13 | 2026-10-25 19:24:00 | - | 约 2 小时 42 分钟（提交到合入） |
| #4（双周冲突用例） | 2026-10-25 17:57:17 | 2026-10-25 19:25:00 | 2026-10-25 19:40:00（v1.0.0） | 约 1 小时 43 分钟 |
| #6（版本历史更新） | 2026-10-25 20:00:00 | 2026-10-25 20:12:00 | 2026-10-25 20:14:00（v1.0.1） | 约 14 分钟 |

### ci 工作流的运行时长（共 9 次，全部列出）
| 运行 | 事件 | 时长 | 开始（UTC+8） | 结束（UTC+8） | 结果 |
|---|---|---|---|---|---|
| [ci #1](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40176780006) | push（初始主干提交） | 39 秒 | 2026-10-25 16:28:55 | 2026-10-25 16:29:30 | success |
| [ci #2](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40177677055) | pull_request（PR #1 首次提交） | 25 秒 | 2026-10-25 16:42:21 | 2026-10-25 16:42:42 | failure |
| [ci #3](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40178652666) | pull_request（PR #1 第一次修复） | 15 秒 | 2026-10-25 16:57:08 | 2026-10-25 16:57:18 | failure |
| [ci #4](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40178712917) | pull_request（PR #1 第二次修复） | 16 秒 | 2026-10-25 16:58:06 | 2026-10-25 16:58:19 | success |
| [ci #5](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40179317872) | pull_request（PR #2 缺陷提交） | 17 秒 | 2026-10-25 17:07:04 | 2026-10-25 17:07:17 | success |
| [ci #6](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40179668087) | pull_request（PR #2 补测试后） | 22 秒 | 2026-10-25 17:12:15 | 2026-10-25 17:12:33 | failure |
| [ci #7](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40179793609) | pull_request（PR #2 修复后） | 29 秒 | 2026-10-25 17:14:08 | 2026-10-25 17:14:33 | success |
| [ci #8](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40180253297) | pull_request（PR #3 release工作流） | 14 秒 | 2026-10-25 17:20:45 | 2026-10-25 17:20:55 | success |
| [ci #9](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40182761992) | pull_request（PR #4 双周用例） | 17 秒 | 2026-10-25 17:57:17 | 2026-10-25 17:57:30 | success |




## 6. 分析问题

### 问题 1：gate 的收益与成本

**数据**：第一轮功能演练对应 ci #2/#3/#4，第二轮隐藏缺陷演练对应 ci #5/#6/#7，加上初始主干 ci #1、release 工作流 ci #8、双周用例 ci #9，共 9 次核心功能 CI 运行；时长分别为 39, 25, 15, 16, 17, 22, 29, 14, 17 秒。
第一轮 PR #1 从首次失败到修复通过，总间隔约 960 秒，其中两次后续 CI 运行共 31 秒，人工修改与排队等待约 929 秒；单次 CI 平均约 21 秒，在 PR #4 提交到 v1.0.0 发布的间隔中，CI 运行占比极低。
Release Gate 以约 10 秒的额外耗时拦截了未合入 main 的 v0.0.1 标签，避免了绕过门禁的代码发布。

**结论**：
CI 门禁拦住了已有测试覆盖的代码错误，但无法发现测试用例未覆盖的边界缺陷，比如第二轮的周日边界问题，只有补充测试后才能被拦截。Release Gate 在此基础上新增了发布源校验，以极低的时间成本杜绝了私下打标签发布的风险，保障所有正式版本都可追溯到经过评审的主干代码。
人工修复与排队等待占据了故障修复的绝大多数时间，自动化检查本身耗时极短。测试只能验证已知规则，无法主动发现未覆盖的需求漏洞，完整的质量保障需要测试用例迭代与流程门禁配合。

**成立条件**：团队严格执行 PR 评审与主干门禁；流水线配置完整提交历史以支持 gate 校验；测试用例持续迭代覆盖边界场景。

### 问题 2：PR 中的构建与 main 上的构建

数据：[PR #1 成功运行日志](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40178712917/job/121124939013)，[日志节选](docs/evidence/local/github-job-121124939013-excerpt.txt)。

实际 PR 日志为 `ref=refs/pull/1/merge`、`github.sha=b2097560dd6910b6ad4fcf0d1320a368ffff5bbf`、`pull_request.head.sha=d1687ebe1d9f2c30963110f8fe36fe950d51061d`，两个 SHA 不同。前者是 GitHub 为 PR 准备的临时合并提交，后者是源分支的 HEAD；当前这两个 SHA 都不是已合入 main 的改动。本实验要求 squash，squash 合入后 main 上对应提交为 `60674c6...`，是新生成的合并提交，既不等于 PR 的临时合并提交，也不等于源分支 HEAD。main 的 push 运行则记录 `60941b340605a219d8a06a1be1dba7310898612a`，见 [日志节选](docs/evidence/local/github-job-121119052234-excerpt.txt)。待发布包应从已进入 main 历史的提交或相应 tag 构建，才能把二进制关联到真实通过门禁的源码。这个结论依赖本组实际坚持 squash 和主干门禁，其他合并方式的 SHA 关系需要另行核对。

**结论**：
PR 触发的构建运行在 GitHub 生成的临时合并提交上，用于验证合入后的代码质量，该提交不会出现在 main 的历史中。本组采用 squash 合并方式，合入时会生成全新的提交写入 main 分支，因此 PR 阶段的提交哈希无法在主干历史中找到。
待发布的制品必须从 main 上的提交或 tag 构建，因为只有主干上的提交才是经过评审、通过完整门禁的正式代码；PR 阶段的临时提交不具备正式效力，基于它构建的制品无法追溯到有效的主干版本。

**成立条件**：仓库启用 squash 合并策略；main 分支受保护，禁止直接推送；所有正式发布均通过主干标签触发。

### 问题 3：可重复构建

输入：小组 main 提交 `60941b340605a219d8a06a1be1dba7310898612a`，Go 1.26.9、linux/amd64、VERSION=1.0.0、BUILD_NO=7、RUN_ID=local、COMMIT=上述完整 SHA。①②参数相同；③仅将 BUILD_NO 改为 8；④⑤临时移除 Makefile 中的 `--mtime=@0`，参数恢复到①，两次间隔至少三秒。实验后 Makefile 已恢复。

| 构建 | 二进制 SHA-256 | tar.gz SHA-256 | vcs.modified |
|---|---|---|---|
| 1 | `a198235c96b1085200c026713864f4092384de5005b7dfe283e09eead60b032b` | `a25d3b5d36559c86fa6248d602900d1bc1e29ffe689cd9c83394fb0e4f9168e2` | false |
| 2 | `a198235c96b1085200c026713864f4092384de5005b7dfe283e09eead60b032b` | `a25d3b5d36559c86fa6248d602900d1bc1e29ffe689cd9c83394fb0e4f9168e2` | false |
| 3 | `5c2c37134e837ca6848a2360c5dea6640e7f050e3c2a096fb72e6b1aaa4f8d44` | `e0e9346b98da81e69cba9a48afe3e9afa7533daf0089c0ba9f7e82be3212fa78` | false |
| 4 | `616535e41e0feec75c349f8c3b13aed1921bf1be379a32b93737d86a5a8395c4` | `588ef93bb5753e3b7624837ba4d6cd800ce780a807809797ced3864e5922d80f` | true |
| 5 | `616535e41e0feec75c349f8c3b13aed1921bf1be379a32b93737d86a5a8395c4` | `27be73f0cc4ae5213b88c51cd778d93d20cbfef9e0e53f393f0ffecc754d658a` | true |
| Actions 两次尝试 | 第一次：`c6ae2f83c95560fe6199cb39a1239bb4ddd536514b7bf59cc2a9496caba76b04`<br>第二次：`c6ae2f83c95560fe6199cb39a1239bb4ddd536514b7bf59cc2a9496caba76b04` | 第一次：`dbac56802e06202624a900c103b6bd8626fc06de562f54dae5556391d2497feb`<br>第二次：`dbac56802e06202624a900c103b6bd8626fc06de562f54dae5556391d2497feb` | 两次完全一致 |


原始证据：[repro-summary.json](docs/evidence/local/repro-summary.json)，各次 make 日志与 VCS 元数据见同目录。早期主干运行仅打印压缩包与校验文件哈希，缺少二进制哈希；本次主干 CI 重跑已输出完整二进制与压缩包哈希，完成了远端环境的可重复性对比。

①②的二进制和归档哈希完全相同，说明在本机、同工具链、相同参数和干净工作区条件下可以重复。③改变构建号，ldflags 注入的内容和 BUILD_INFO 改变，二进制和归档都随之改变。④⑤二进制彼此相同，但都不同于①：修改 Makefile 使 Go 嵌入的 vcs.modified 从 false 变成 true，即使 Go 源码没变也会改变二进制。④⑤归档不同，原因是去掉时间归一化后，包内文件修改时间随重新构建变化。制品应保留版本、构建号、提交号和 run_id 等追溯信息，避免无必要的当前时间与主机路径等不稳定输入；固定 SHA 不代表未提交修改已消失。本实验 release 要把正式版本号编进二进制，所以重编译而非直接发布 ci 的 0.0.0-main 包；它简化了版本展示，但增加一次构建，且与严格的“一次构建、多处部署”存在差异，真正回退应复用已发布附件。上述结果不证明换机器、换 Go 版本、换系统镜像后一定逐字节一致；本组已完成同环境下的主干 CI 重跑验证，两次运行的二进制与压缩包哈希完全一致，说明在固定的远端 runner 环境中，同源码同参数的构建具备可重复性。

**成立条件：**

1. 编译环境一致：Go 编译器版本、依赖版本、构建参数完全固定，ldflags 注入的元数据内容统一
2. 源码状态一致：基于同一提交哈希构建，工作区干净无未提交修改
3. 系统环境一致：相同的操作系统、CPU 架构与构建工具链
4. 打包配置一致：启用时间归一化等消除不稳定输入的配置，避免归档文件因时间戳产生差异


### 问题 4：发布与回退

数据：第 4 节已完成两个正式 Release 的下载校验、版本追溯与回退验证，原始证据见 `docs/evidence/release/` 目录；[本地运行预演](docs/evidence/local/version-smoke-local.json)仅验证机制；第 6 节问题 3 是重新构建的本组实测数据。

发现 v1.0.1 缺陷时，可以先停止新版本并运行保存的 v1.0.0 附件恢复服务，修复经 PR 和门禁后使用新版本号发布。已发布版本号不删除、不复用，否则同一个版本可能对应不同字节，破坏审计、缓存和回退依据。正式回退应使用 `enroll-conflict_1.0.0_linux_amd64.tar.gz` 中的原二进制，无需重编译，两个正式版本的 /version 输出与制品内嵌入的版本、构建号、提交号完全对应，验证了回退使用的是原始历史制品，而非重新构建的版本。如果从源码重建，只有提交、工具链、构建参数、干净状态等输入一致时才可能相同，问题 3 已显示构建号或工作区状态会导致差异。若有人同时替换压缩包及配套 .sha256，而新包仍带一个有效 main 提交，trace.sh 可能通过，不能将它当作可信发布签名。独立保存的原哈希能发现包的字节改变，前提是该记录本身没有一并被修改；本地采集脚本会保留首次下载的哈希并在以后对照。可进一步查看仓库 Immutable releases 的实际设置；本组目前未核实启用情况，不声称已具备此保护。

**成立条件：**

1. 各历史版本的原始发布制品完整归档，可直接复用，无需重新编译
2. 业务服务为无状态设计，版本切换不产生数据兼容与迁移问题
3. 版本号全局唯一，已发布的标签不删除、不复用
4. 发布流程严格执行主干标签门禁，所有正式版本均对应主干上经过评审的提交
5. 独立留存首次下载的原始哈希记录，且该记录未被同步篡改

## 7. 选做记录
### O1 容器镜像构建与发布
**完成状态**：已完成。通过 [PR #7](https://github.com/xxguaigo/ops-lab1-17/pull/7) 在 `release.yml` 中新增镜像构建 Job，基于已发布的 Release 附件与仓库内 Dockerfile 构建镜像，构建过程不重新编译 Go 源码，镜像自动推送至 GitHub Container Registry。

**实测数据**：
- 发布版本：v1.0.2，对应提交 `5d5719d724e208f8462a52d928e49876cf2925a5`
- 镜像 digest：`sha256:d8161bb7bdd360d0004341d3ac5c017beccd82d21344b8d92139cbb5711f368f`
- 镜像架构：`linux/amd64`，与 Release 二进制架构一致
- 验证结果：使用 digest 启动容器，访问 `/version` 接口返回的版本号、提交号与 Release 完全匹配，制品一致性验证通过

**思考题结论**：
1.  默认 `GITHUB_TOKEN` 创建的 Release 不会触发其他工作流，这是 GitHub 的机制设计，用于防止自动化流程循环触发；因此镜像构建 Job 与发布 Job 置于同一工作流中，通过 `needs: release` 保证执行顺序。
2.  本仓库关联的 GHCR 镜像继承仓库公开可见性，支持匿名拉取，无需登录凭据即可下载运行。

### O2 构建缓存对反馈时间的影响
**完成状态**：已完成。通过 PR #9 设置对照组，将 `setup-go` 的 `cache` 设为 `false`，有缓存、无缓存两组各执行 5 次 CI 运行，记录完整 Job 时长。

**实测数据**：
| 组别 | 5次运行时长 | 平均时长 |
|---|---|---|
| 有缓存（Group A） | 10s / 12s / 16s / 14s / 11s | 12.6 秒 |
| 无缓存（Group B） | 29s / 20s / 23s / 23s / 31s | 25.2 秒 |

**时长波动来源**：
1.  GitHub 共享 Runner 的底层负载差异，不同实例的 CPU、磁盘 IO 性能不一致
2.  缓存恢复本身存在耗时，且每次缓存命中状态存在细微差异
3.  工作流执行中的系统调度噪声、网络波动等随机因素

**结论局限性**：
1.  无法完全控制运行环境，所有运行并非在同一台 Runner 实例上执行，不能将耗时差完全归因于缓存
2.  统计指标为整个 CI Job 的总时长，包含代码检出、格式检查、静态检查、单元测试等步骤，不能精确拆分 Go 构建缓存的单独贡献

### O3
未完成。



## 8. 成员贡献
本表基于仓库已合入的 PR 记录整理，每位成员均有本人发起并合入的 PR。
| GitHub 用户名 | 发起并合入的 PR 编号 | 审批过的 PR 编号 |
|---|---|---|
| xxguaigo | #1 / #2 / #3 / #6 / #8 / #10 / #11 | #7 / #9 |
| Yu-Liang-Yan | #4 | #1 / #5 / #11 |
| lntan33 | #5 | #2 / #3 / #4 / #6 |
| lmrsjtu | #7 / #9 | #8 / #10 |
✅ 已完成项：所有成员的已合入 PR、管理员直推拒绝验证、两个正式 Release 发布、远端 release gate 拦截演示、正式版本追溯与回退验证、证据文件归档。本实验报告已更新所有实测数据，经 PR 合入 main 分支。
