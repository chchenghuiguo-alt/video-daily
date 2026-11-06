# 001 英伟达开源 VFlash：面向 Physical AI 的 System-1 视觉模型，动作解码最高约快 12 倍

## 标题

英伟达开源 VFlash：面向 Physical AI 的 System-1 视觉模型，动作解码最高约快 12 倍

## 摘要

NVIDIA 机器人负责人 Jim Fan（@DrJimFan）11 月 6 日 00:31（UTC+8）发布 VFlash：面向 Physical AI 的 System-1 视觉语言模型。他称多数具身预测（目标定位、机械臂轨迹、稠密 3D 运动）是固定长度浮点向量，不必自回归逐 token 解码，可一次输出整段几何。官方称在 Jetson Thor / DGX Spark 等端侧 GPU 上，动作解码最高约快 12 倍、整体机器人推理约快 5.1 倍，且 3D 轨迹误差可比骨干 VLM 低约 61%。开源论文与代码，项目页 research.nvidia.com/labs/lpr/vflash/。帖子附约 56 秒介绍视频。协同发布见 LPR 的 Zhiding Yu 线程。

## 待核实

- 12×/5.1×/61% 等数字来自官方自述，独立基准与对照设置需看论文
- 项目页：https://research.nvidia.com/labs/lpr/vflash/

## 素材

- `videos/01.mp4`：视频 1080×608，55.91 秒
- `images/01.jpg`：图片 1200×676

## 来源

- X：@DrJimFan（NVIDIA GEAR，第一手）；项目页见 @ZhidingYu 线程
- 原帖：https://x.com/DrJimFan/status/2118380813498892301
- 发布时间：2026-11-06 00:31 (UTC+8)
