# 素材信源（SOURCES）

本文件说明每日素材从哪里收集、怎么挑选。收集 agent 每天按这里的清单工作；**要增删账号，直接改本文件**（改状态列即可，不必删行），下次收集自动生效。

## 1. X 账号清单

状态取值：`启用`（每天读取）、`查证`（只用来核对说法，不作为素材来源）、`停用`（不读取，保留记录）。

### 公司官方

| 账号 | 类型 | 状态 | 备注 |
|---|---|---|---|
| [@Figure_robot](https://x.com/Figure_robot) | official | 启用 | |
| [@Tesla_Optimus](https://x.com/Tesla_Optimus) | official | 启用 | |
| [@UnitreeRobotics](https://x.com/UnitreeRobotics) | official | 启用 | |
| [@BostonDynamics](https://x.com/BostonDynamics) | official | 启用 | |
| [@agilityrobotics](https://x.com/agilityrobotics) | official | 启用 | |
| [@Apptronik](https://x.com/Apptronik) | official | 启用 | |
| [@physical_int](https://x.com/physical_int) | official | 启用 | |
| [@UBTECHRobotics](https://x.com/UBTECHRobotics) | official | 启用 | |
| [@ABBRobotics](https://x.com/ABBRobotics) | official | 启用 | |
| [@IntrinsicAI](https://x.com/IntrinsicAI) | official | 启用 | |
| [@TheRealNoetix](https://x.com/TheRealNoetix) | official | 启用 | |
| [@DRoboticsDev](https://x.com/DRoboticsDev) | official | 启用 | |

### 研究者 / 创始人

| 账号 | 类型 | 状态 | 备注 |
|---|---|---|---|
| [@DrJimFan](https://x.com/DrJimFan) | researcher | 启用 | |
| [@chelseabfinn](https://x.com/chelseabfinn) | researcher | 启用 | |
| [@svlevine](https://x.com/svlevine) | researcher | 启用 | |
| [@pabbeel](https://x.com/pabbeel) | researcher | 启用 | |
| [@drfeifei](https://x.com/drfeifei) | researcher | 启用 | |
| [@adcock_brett](https://x.com/adcock_brett) | researcher | 启用 | |
| [@adamraudonis](https://x.com/adamraudonis) | researcher | 启用 | |

### 聚合 / 媒体

| 账号 | 类型 | 状态 | 备注 |
|---|---|---|---|
| [@TheHumanoidHub](https://x.com/TheHumanoidHub) | aggregator | 启用 | |
| [@IlirAliu_](https://x.com/IlirAliu_) | aggregator | 启用 | |
| [@RoboDaily](https://x.com/RoboDaily) | aggregator | 启用 | |
| [@therobotreport](https://x.com/therobotreport) | aggregator | 启用 | |
| [@IEEESpectrum](https://x.com/IEEESpectrum) | aggregator | 启用 | |
| [@Humanoid_News](https://x.com/Humanoid_News) | aggregator | 启用 | |
| [@jiqizhixin](https://x.com/jiqizhixin) | aggregator | 启用 | |

### 实验室 / 会议

| 账号 | 类型 | 状态 | 备注 |
|---|---|---|---|
| [@leggedrobotics](https://x.com/leggedrobotics) | lab | 启用 | |
| [@ieee_ras_icra](https://x.com/ieee_ras_icra) | lab | 启用 | |

### 查证账号

用于核对其他帖子里的说法（官方公告、权威媒体等）。目前为空，欢迎补充。

| 账号 | 类型 | 状态 | 备注 |
|---|---|---|---|

### 已停用

| 账号 | 类型 | 状态 | 备注 |
|---|---|---|---|
| @Synced_Global | media | 停用 | 账号不存在 |
| @SyncedTech | media | 停用 | 2023 年后停更 |
| @therobotstudio | media | 停用 | 2026 年 4 月后停更 |
| @engineairobot | official | 停用 | 2026 年 8 月后没发帖 |
| @RoboStrategy | aggregator | 停用 | 多为投资免责声明 |

## 2. 关键词搜索

除上面的账号外，每天在 X 上用这些关键词搜最近约 24 小时、带图片或视频、非转推的帖子（`has:media -is:retweet`）：

- `humanoid robot`
- `embodied AI`
- `人形机器人`
- `具身智能`
- `robotics`

## 3. X 以外的来源（辅助）

只用于补充背景和核实说法，一般不直接提供视频：The Robot Report、IEEE Spectrum Robotics、Robohub、New Atlas、TechCrunch Robotics、ScienceDaily、量子位、Google News（上述关键词）、Hacker News。

## 4. 挑选规则

- 优先：最近 24 小时内、有视频或图片、官方或第一手来源、互动量高的帖子。
- 同一新闻多处转发时合并，保留原始出处；前几天已收过的旧闻不再收。
- 同一家公司每天最多收 2 条左右。每天 5 到 8 条，视频优先。
- 排除：带货、招商、股市、加密货币、梗图和广告，以及疑似 AI 生成的假视频。
- 厂商自述、没有官方确认的数字或说法，写进 `post.md` 的「待核实」，`meta.json` 的 `verify_status` 照实标注。
- 搬运号、个人号发的视频要注明，原始出处找不到时写“来源网络”。
