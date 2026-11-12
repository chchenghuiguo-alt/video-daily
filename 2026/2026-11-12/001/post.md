# 001 Runway 开源机器人模型 Praxis-1：270 亿参数“世界动作模型”，Apache 2.0 可商用

## 标题

Runway 开源机器人模型 Praxis-1：270 亿参数“世界动作模型”，Apache 2.0 可商用

## 摘要

视频生成公司 Runway（@runwayml）11 月 11 日 23:04（UTC+8）宣布把 Praxis-1 开放给所有人：这是其“世界动作模型”，把视频预训练转成真实机器人的控制，权重以 Apache 2.0 开源，可在自己的硬件上运行和微调（点赞约 436、浏览约 5 万）。Hugging Face 机器人库 LeRobot（@LeRobotHF）同日发布约 30 秒横屏介绍视频，宣布已原生支持，画面包括双臂夹爪整理桌面、“一个检查点适配多种机器人”、“没见过的机器人”成功率 80.0% 对 52.4% 等字幕。Runway 官方新闻稿写明：Praxis-1 是 270 亿参数的混合专家扩散 Transformer，同时预测未来画面和动作；9 月首次发布，此前只给 Noble Machines、Standard Bots、Ultra 等合作伙伴用；在英伟达 RoboLab-120 仿真榜单上成功率 46.2%（1200 回合），高于 FLUX 3 Action 的 42.9%、Cosmos3 Nano 的 36.8% 和 π0.5 的 28.0%；在谷歌 RT-1 机器人上微调后 SimplerEnv 成功率 80.0%，原版 RT-1 策略为 52.4%。权重、推理和微调代码都在 GitHub 与 Hugging Face，从 H100 到机载 Jetson Thor 都能跑。

## 待核实

- 榜单成绩和 RT-1 对比数字都是 Runway 自己公布的评测结果
- 视频是字幕加演示片段的宣传片，没有标注是否加速
- GitHub 说明单卡运行需要至少 80 GB 显存，普通开发者门槛不低

## 素材

- `videos/01.mp4`：视频 1080×608，30.06 秒
- `images/01.jpg`：图片 1200×676
- `images/02.jpg`：图片 1600×1068

## 来源

- X：@runwayml（官方，第一手）、@LeRobotHF（Hugging Face 官方，视频）；Runway 官方新闻稿与研究页、GitHub
- 原帖：https://x.com/runwayml/status/2120533081182577116
- 发布时间：2026-11-11 23:04 (UTC+8)
