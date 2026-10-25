# 实验 1 记录：第 17 组

> 本地整理稿。已实测的本地数据与可核实的 GitHub 历史已填写；“待完成”表示尚未取得相应证据，提交前必须补齐。核查时 PR #1～#4 均未合入，两个正式 Release 均未发布。本地集成与本地服务测试不等同于正式发布。

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
| 管理员直接推送被拒 | **待完成：组长实际操作并粘贴输出。** 本地检查不代替远端规则验证 |
| 初始 main 成功 CI 与制品 | [ci #1](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40176780006)，产出 artifact；原工作流漏上传 .sha256、漏打印二进制哈希，本地已修复，需新 PR 合入 |
| 第一轮 PR | [#1](https://github.com/xxguaigo/ops-lab1-17/pull/1)，原先最终无文件差异；本地补充了 conflict_regression_test.go，需推送、CI 通过、审批、修改标题后 squash 合并 |
| 第一轮：失败 | [ci #2](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40177677055)；第一次修复仍失败：[ci #3](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40178652666) |
| 第一轮：修复通过 | [ci #4](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40178712917)；本地追加测试后的新运行待补 |
| 第一轮：合入 main 后的运行 | **待合入后补链接** |
| 第二轮：隐藏缺陷 | [#2](https://github.com/xxguaigo/ops-lab1-17/pull/2)：将 Weekday 的合法上界由 7 改为 6；原测试未覆盖合法周日，所以错误拒绝周日仍能通过 |
| 第二轮：仅缺陷时通过 | [ci #5](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40179317872) |
| 第二轮：增加周日测试后失败 | [ci #6](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40179668087) |
| 第二轮：恢复上界 7 后通过 | [ci #7](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40179793609)，最终仅增加周日边界测试；待 squash 合并 |
| release 工作流 | [#3](https://github.com/xxguaigo/ops-lab1-17/pull/3)，本地修正 YAML 标题、跨 step 的 RAW_TAG 和哈希输出；待推送修正并合入 |
| release gate 拒绝未合入 tag | **待实际推送测试 tag 后记录 Actions 链接**；当前本地门禁脚本的正反测试均符合预期，但不算远端 tag 演示 |
| Release v1.0.0 | **待发布** |
| Release v1.0.1 | **待 v1.0.0 发布后再合入小改动并发布**；可使用 [#4](https://github.com/xxguaigo/ops-lab1-17/pull/4) 的双周测试作为这次改动 |

当前已有审批：#1 由 Yu-Liang-Yan 审批，#2/#3/#4 由 lntan33 审批。追加修改后须重新核对最新 CI 和审批，不能把本地检查当作远端已通过。

## 4. 追溯与运行

**两个正式 Release 尚未发布，本节正式数据待补。** 不使用本地自建包填充正式 Release 的证据。

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
| 版本号 | 待实测 | 待实测 |
| 构建号 | 待实测 | 待实测 |
| 提交号 | 待实测 | 待实测 |
| 引入该提交的 PR | 待实测 | 待实测 |
| 构建它的 Actions 链接 | 待实测 | 待实测 |
| 发布后首次保存的附件 SHA-256 | 待实测 | 待实测 |

待补：两次 trace.sh 全部输出（退出码 0）、两次正式附件的 /version 输出、v1.0.1 发布后再次下载 v1.0.0 的哈希、ci 和 release 中同构建号各自对应的运行链接。

仅凭 build_no 不唯一，因为每个 workflow 分别计数。run_id 才能直接定位运行。额外本地检查已通过：[trace](docs/evidence/local/trace-main-local.txt)、[两个带 local 后缀版本的 /version](docs/evidence/local/version-smoke-local.json)。它们只证明本地脚本和服务能够工作。

## 5. 数据

以下显示时间统一为 UTC+08:00（Asia/Shanghai）。CI 的 job 时间来自 GitHub API started_at/completed_at，不把 updated_at 误当成结束时间。

第一轮历史时间线：

| 事件 | 时间 | 链接 |
|---|---|---|
| 发起 PR #1 | 2026-10-25 16:42:13 | [PR #1](https://github.com/xxguaigo/ops-lab1-17/pull/1) |
| 第一次 ci 失败结束 | 2026-10-25 16:42:42 | [ci #2](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40177677055) |
| 第一次修复提交的提交时间 | 2026-10-25 16:57:00 | [提交](https://github.com/xxguaigo/ops-lab1-17/commit/9292af90f3f9c67983f2396abfd191da361ca8a1) |
| 第一次修复仍失败 | 2026-10-25 16:57:18 | [ci #3](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40178652666) |
| 第二次修复提交的提交时间 | 2026-10-25 16:57:59 | [提交](https://github.com/xxguaigo/ops-lab1-17/commit/d1687ebe1d9f2c30963110f8fe36fe950d51061d) |
| ci 通过结束 | 2026-10-25 16:58:19 | [ci #4](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40178712917) |
| 合入 main | 待合入 | 待补 |

提交时间不等于推送时间；历史推送准确时间尚未取得，不能冒充已记录。补测试后的运行会在以上历史之后，最终记录须补上。

ci job 的实际执行时长（不含排队；提交前再与 Actions 页面核对 workflow 总时长）：

| 运行 | 事件 | job 时长 | 开始（UTC+8） | 结束（UTC+8） | 结果 |
|---|---|---|---|---|---|
| [ci #1](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40176780006) | push | 35 秒 | 2026-10-25 16:28:55 | 2026-10-25 16:29:30 | success |
| [ci #2](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40177677055) | pull_request | 21 秒 | 2026-10-25 16:42:21 | 2026-10-25 16:42:42 | failure |
| [ci #3](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40178652666) | pull_request | 10 秒 | 2026-10-25 16:57:08 | 2026-10-25 16:57:18 | failure |
| [ci #4](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40178712917) | pull_request | 13 秒 | 2026-10-25 16:58:06 | 2026-10-25 16:58:19 | success |
| [ci #5](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40179317872) | pull_request | 13 秒 | 2026-10-25 17:07:04 | 2026-10-25 17:07:17 | success |
| [ci #6](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40179668087) | pull_request | 18 秒 | 2026-10-25 17:12:15 | 2026-10-25 17:12:33 | failure |
| [ci #7](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40179793609) | pull_request | 25 秒 | 2026-10-25 17:14:08 | 2026-10-25 17:14:33 | success |
| [ci #8](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40180253297) | pull_request | 10 秒 | 2026-10-25 17:20:45 | 2026-10-25 17:20:55 | success |
| [ci #9](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40182761992) | pull_request | 13 秒 | 2026-10-25 17:57:17 | 2026-10-25 17:57:30 | success |

提交到发布的间隔：**至少三个已合入 PR 的首提交时间、合入时间、对应 Release 发布时间和间隔，待真实合入与发布后填写。** 当前没有可计算的正式发布样本，不能用本地构建代替。

## 6. 分析问题

### 问题 1：gate 的收益与成本（部分完成，发布数据待补）

数据：第一轮 ci #2/#3/#4，第二轮 ci #5/#6/#7，以及上表全部九次 ci job。

第一轮测试失败挡住了已有测试能发现的回归；第二轮在没有周日边界测试时 CI 通过，说明门禁只能执行已有规则，不能证明需求全部正确。补测试后 ci #6 失败，恢复合法上界后 ci #7 通过，说明新增测试确实覆盖了这个缺陷。从第一次失败结束到修复成功结束共 937 秒（15 分 37 秒），其间两次后续 ci job 共 23 秒，其余 914 秒包含编辑、提交、推送和排队，无法仅凭这些时间戳精确拆成人工修改时长。九次 job 分别为 35, 21, 10, 13, 13, 18, 25, 10, 13 秒，样本很少且 PR 不打包、main push 打包，不宜混为同一种耗时。审批还需检查需求理解、未覆盖的边界、安全和运维问题；自动测试仍可能漏掉未知缺陷。**待真实发布后补充 CI 在提交到发布间隔中的占比**，结论仅适用于本组小样本和当时共享 runner 的负载。

### 问题 2：PR 中的构建与 main 上的构建（合入结果待补）

数据：[PR #1 成功运行日志](https://github.com/xxguaigo/ops-lab1-17/actions/runs/40178712917/job/121124939013)，[日志节选](docs/evidence/local/github-job-121124939013-excerpt.txt)。

实际 PR 日志为 `ref=refs/pull/1/merge`、`github.sha=b2097560dd6910b6ad4fcf0d1320a368ffff5bbf`、`pull_request.head.sha=d1687ebe1d9f2c30963110f8fe36fe950d51061d`，两个 SHA 不同。前者是 GitHub 为 PR 准备的临时合并提交，后者是源分支的 HEAD；当前这两个 SHA 都不是已合入 main 的改动。本实验要求 squash，它会在 main 上生成新的提交，最终 SHA **待实际 squash 后填写**，不能把当前 PR 的 SHA 预填为 main SHA。main 的 push 运行则记录 `60941b340605a219d8a06a1be1dba7310898612a`，见 [日志节选](docs/evidence/local/github-job-121119052234-excerpt.txt)。待发布包应从已进入 main 历史的提交或相应 tag 构建，才能把二进制关联到真实通过门禁的源码。这个结论依赖本组实际坚持 squash 和主干门禁，其他合并方式的 SHA 关系需要另行核对。

### 问题 3：可重复构建（五次本地实验已完成，Actions Re-run 待补）

输入：小组 main 提交 `60941b340605a219d8a06a1be1dba7310898612a`，Go 1.26.9、linux/amd64、VERSION=1.0.0、BUILD_NO=7、RUN_ID=local、COMMIT=上述完整 SHA。①②参数相同；③仅将 BUILD_NO 改为 8；④⑤临时移除 Makefile 中的 `--mtime=@0`，参数恢复到①，两次间隔至少三秒。实验后 Makefile 已恢复。

| 构建 | 二进制 SHA-256 | tar.gz SHA-256 | vcs.modified |
|---|---|---|---|
| 1 | `a198235c96b1085200c026713864f4092384de5005b7dfe283e09eead60b032b` | `a25d3b5d36559c86fa6248d602900d1bc1e29ffe689cd9c83394fb0e4f9168e2` | false |
| 2 | `a198235c96b1085200c026713864f4092384de5005b7dfe283e09eead60b032b` | `a25d3b5d36559c86fa6248d602900d1bc1e29ffe689cd9c83394fb0e4f9168e2` | false |
| 3 | `5c2c37134e837ca6848a2360c5dea6640e7f050e3c2a096fb72e6b1aaa4f8d44` | `e0e9346b98da81e69cba9a48afe3e9afa7533daf0089c0ba9f7e82be3212fa78` | false |
| 4 | `616535e41e0feec75c349f8c3b13aed1921bf1be379a32b93737d86a5a8395c4` | `588ef93bb5753e3b7624837ba4d6cd800ce780a807809797ced3864e5922d80f` | true |
| 5 | `616535e41e0feec75c349f8c3b13aed1921bf1be379a32b93737d86a5a8395c4` | `27be73f0cc4ae5213b88c51cd778d93d20cbfef9e0e53f393f0ffecc754d658a` | true |
| Actions 两次尝试 | **待修正 CI 合入后，对 main push 运行 Re-run all jobs，并记录两次二进制哈希** | **待记录两次压缩包哈希** | 待检查 |

原始证据：[repro-summary.json](docs/evidence/local/repro-summary.json)，各次 make 日志与 VCS 元数据见同目录。早期 main 运行只打印了压缩包和校验文件的哈希，缺少二进制哈希，不足以补齐 Actions 比较。

①②的二进制和归档哈希完全相同，说明在本机、同工具链、相同参数和干净工作区条件下可以重复。③改变构建号，ldflags 注入的内容和 BUILD_INFO 改变，二进制和归档都随之改变。④⑤二进制彼此相同，但都不同于①：修改 Makefile 使 Go 嵌入的 vcs.modified 从 false 变成 true，即使 Go 源码没变也会改变二进制。④⑤归档不同，原因是去掉时间归一化后，包内文件修改时间随重新构建变化。制品应保留版本、构建号、提交号和 run_id 等追溯信息，避免无必要的当前时间与主机路径等不稳定输入；固定 SHA 不代表未提交修改已消失。本实验 release 要把正式版本号编进二进制，所以重编译而非直接发布 ci 的 0.0.0-main 包；它简化了版本展示，但增加一次构建，且与严格的“一次构建、多处部署”存在差异，真正回退应复用已发布附件。上述结果不证明换机器、换 Go、换系统镜像或不同 run_attempt 的工具环境后一定逐字节一致，Actions 重跑的结果仍待实测。

### 问题 4：发布与回退（机制说明已写，正式运行数据待补）

数据：第 4 节正式证据待取得；[本地运行预演](docs/evidence/local/version-smoke-local.json)仅验证机制；第 6 节问题 3 是重新构建的本组实测数据。

发现 v1.0.1 缺陷时，可以先停止新版本并运行保存的 v1.0.0 附件恢复服务，修复经 PR 和门禁后使用新版本号发布。已发布版本号不删除、不复用，否则同一个版本可能对应不同字节，破坏审计、缓存和回退依据。正式回退应使用 `enroll-conflict_1.0.0_linux_amd64.tar.gz` 中的原二进制，无需重编译，两个正式版本的 /version 输出**待第 4 节操作后粘贴并解释**。如果从源码重建，只有提交、工具链、构建参数、干净状态等输入一致时才可能相同，问题 3 已显示构建号或工作区状态会导致差异。若有人同时替换压缩包及配套 .sha256，而新包仍带一个有效 main 提交，trace.sh 可能通过，不能将它当作可信发布签名。独立保存的原哈希能发现包的字节改变，前提是该记录本身没有一并被修改；本地采集脚本会保留首次下载的哈希并在以后对照。可进一步查看仓库 Immutable releases 的实际设置；本组目前未核实启用情况，不声称已具备此保护。

## 7. 选做记录

O1/O2/O3：未取得完成证据，先完成必做；模板中已有 Dockerfile 不代表完成 O1。

## 8. 成员贡献

本表仅列 GitHub 中已观察到的参与账号；实际组员名单和人数须由小组核对，每位成员都必须有本人发起并合入的 PR。

| GitHub 用户名 | 发起并合入的 PR 编号 | 审批过的 PR 编号 |
|---|---|---|
| xxguaigo | #1/#2/#3 已发起，尚未合入 | 待核对 |
| Yu-Liang-Yan | #4 已发起，尚未合入 | #1 |
| lntan33 | 尚未看到本人发起并合入的 PR；本地 CI 与记录分支可用本人账号发起新 PR | #2/#3/#4 |

**提交前必须完成**：所有成员的已合入 PR、管理员直推拒绝、两个正式 Release、远端 release gate 拒绝演示、正式追溯及回退、三个 PR 的发布间隔、Actions 两次尝试的哈希比较，并将本文件的待完成项更新后经 PR 合入 main。
