# Godot 2D 粒子 AI 生成技术实践说明

本文档说明当前项目中这一套“Godot 粒子特效素材标准化 -> AI 理解/检索/生成 -> Godot 可落地还原”的技术实践，是如何在现有仓库结构下完成的。

这套实践当前聚焦于：

- Godot 4
- 以 `GPUParticles2D` 为主的 2D 粒子特效
- 基于本地参考库的理解、检索、组合与还原

它不是“端到端黑盒生成一个特效”的体系，而是一个更可控的、参考驱动的工作流：先把参考素材变成 AI 能理解的知识，再让 AI 在知识约束下生成可落地的 Godot 粒子场景。

## 1. 当前实践目标

当前项目希望解决的问题不是单纯“把一句话变成粒子”，而是把粒子生成这件事拆成几个可控阶段：

1. 把外部粒子素材统一转换成 Godot 可用资源
2. 把这些资源进一步整理成 AI 可读的结构化知识
3. 让 AI 基于这些知识做参考检索、风格选择、层次拆解和参数组织
4. 把 AI 的结果重新落回 Godot 场景、脚本和粒子参数
5. 在 Godot 里实际运行、预览、迭代，而不是停留在文本层

## 2. 当前项目结构与职责

### 2.1 素材导入层

- [addons/particle2dx_importer](D:/workspace/godot-tool/particle2dx_importer/addons/particle2dx_importer)
- [plist/](D:/workspace/godot-tool/particle2dx_importer/plist)

这部分负责把 Cocos2d-x / ParticleDesigner 的 `.plist` 粒子资源导入 Godot。

核心能力：

- 把 `.plist` 转成 Godot 4 的 `GPUParticles2D` 场景
- 恢复嵌入贴图或外部贴图
- 把常见发射参数、颜色、尺寸、重力、半径模式等映射到 Godot

对应文档与脚本：

- [addons/particle2dx_importer/README.md](D:/workspace/godot-tool/particle2dx_importer/addons/particle2dx_importer/README.md)
- [addons/particle2dx_importer/cocos_particle2dx_converter.gd](D:/workspace/godot-tool/particle2dx_importer/addons/particle2dx_importer/cocos_particle2dx_converter.gd)
- [addons/particle2dx_importer/cli_convert.gd](D:/workspace/godot-tool/particle2dx_importer/addons/particle2dx_importer/cli_convert.gd)

这一步完成后，项目得到一批统一格式的 Godot 粒子参考场景，主要放在：

- [particle/](D:/workspace/godot-tool/particle2dx_importer/particle)

这就是后续 AI 实践的“参考语料库”。

### 2.2 参考库标准化层

当前项目没有再做一套单独的数据库服务，而是把标准化直接落在“可解析的 Godot 场景 + 可提炼的知识文件”上。

这里的标准化包含两层：

1. 资源层标准化  
   所有参考特效尽量都落成 Godot `.tscn` 场景，贴图、材质、粒子参数都能从文本场景中直接读取。

2. 语义层标准化  
   通过 Python 脚本扫描 `particle/`，把场景归纳成可检索的结构化知识。

对应脚本：

- [skills/godot-particle-vfx-director/scripts/particle_library.py](D:/workspace/godot-tool/particle2dx_importer/skills/godot-particle-vfx-director/scripts/particle_library.py)
- [skills/godot-particle-vfx-director/scripts/distill_particle_knowledge.py](D:/workspace/godot-tool/particle2dx_importer/skills/godot-particle-vfx-director/scripts/distill_particle_knowledge.py)

#### `particle_library.py` 做了什么

它负责对本地粒子参考库做基础盘点和精确检查，例如：

- 场景里有哪些粒子节点
- 是否用了 shader 粒子
- 是否用了 additive 混合
- 贴图引用是什么
- 主粒子的关键参数是什么

它相当于“参考库索引器”和“单场景检查器”。

常用命令：

```bash
python skills/godot-particle-vfx-director/scripts/particle_library.py inventory
python skills/godot-particle-vfx-director/scripts/particle_library.py inspect particle/flame.tscn
```

#### `distill_particle_knowledge.py` 做了什么

这是当前 AI 理解层最关键的脚本。它会扫描 `particle/` 下的场景，并自动提炼出：

- 特效家族 `family`
- 可复用角色 `role`
- 运动特征 `motion signatures`
- 参数模式 `parameter signatures`
- 推荐搭配关系 `recommended companions`
- 语义标签与设计含义 `semantic tags / design implications`

最终生成两份知识文件：

- [skills/godot-particle-vfx-director/references/particle-knowledge.json](D:/workspace/godot-tool/particle2dx_importer/skills/godot-particle-vfx-director/references/particle-knowledge.json)
- [skills/godot-particle-vfx-director/references/particle-knowledge.md](D:/workspace/godot-tool/particle2dx_importer/skills/godot-particle-vfx-director/references/particle-knowledge.md)

常用命令：

```bash
python skills/godot-particle-vfx-director/scripts/distill_particle_knowledge.py
```

这一步的意义在于：AI 不再只面对“几十个不知道怎么用的 `.tscn` 文件”，而是面对一套已经被归纳过的知识库。

## 3. AI 理解与检索层是怎么完成的

当前项目的 AI 理解/检索不是通过向量数据库或训练模型完成的，而是通过“结构化知识 + 规则路由 + 场景检查”完成的。

已有知识资产包括：

- [skills/godot-particle-vfx-director/references/library-map.md](D:/workspace/godot-tool/particle2dx_importer/skills/godot-particle-vfx-director/references/library-map.md)
- [skills/godot-particle-vfx-director/references/effect-recipes.md](D:/workspace/godot-tool/particle2dx_importer/skills/godot-particle-vfx-director/references/effect-recipes.md)
- [skills/godot-particle-vfx-director/references/quality-bar.md](D:/workspace/godot-tool/particle2dx_importer/skills/godot-particle-vfx-director/references/quality-bar.md)
- [skills/godot-particle-vfx-director/references/particle-knowledge.md](D:/workspace/godot-tool/particle2dx_importer/skills/godot-particle-vfx-director/references/particle-knowledge.md)
- [skills/godot-particle-vfx-director/references/particle-knowledge.json](D:/workspace/godot-tool/particle2dx_importer/skills/godot-particle-vfx-director/references/particle-knowledge.json)

这些文件分别承担不同角色：

- `library-map.md`  
  负责快速告诉 AI：“想做什么效果，应该先参考哪些场景、哪些贴图。”

- `effect-recipes.md`  
  负责把常见特效拆成层次模板，例如：
  - Hero slash
  - Magic projectile impact
  - Pickup or reward pop
  - Ambient magic source

- `quality-bar.md`  
  负责给 AI 一个审美和质量判断基准，避免只会堆参数。

- `particle-knowledge.json/md`  
  负责提供更细粒度的结构化知识，例如：
  - 哪个场景属于 `reward`
  - 哪个场景适合 `sparkle-breakup`
  - 哪个参数模式更像 `burst`
  - 哪些场景适合作为搭配参考

### 当前 AI 检索方式的本质

当前做法更接近“知识增强的参考检索”，而不是“端到端模型生成”。

具体来说，AI 在生成一个目标特效时，会先做几件事：

1. 明确目标特效的类型和视觉职责  
   例如是攻击刀光、奖励喷泉、魔法冲击、环境循环。

2. 去本地知识文件里找最接近的参考族群  
   例如金币喷泉会命中：
   - `gold`
   - `gold_boom`
   - `fountain`
   - `star*`

3. 决定层次拆分  
   例如“主币流 / 两侧副流 / 爆发金币 / 点状闪光”。

4. 再回到 Godot 粒子参数层做还原

所以这套实践里的“AI 理解”，本质上是：

- 对参考库的语义归纳
- 对特效层次的角色拆解
- 对 Godot 参数模式的可解释组合

## 4. AI 生成层是怎么完成的

当前项目的生成方式不是训练一个专门的 VFX 模型，而是通过以下方式完成：

1. 参考场景重用
2. 贴图复用
3. 层次重组
4. 参数重写
5. 必要时用脚本补充行为逻辑

### 4.1 生成的基本原则

当前项目里，AI 生成遵守的是“参考驱动生成”，而不是“完全从零随机合成”：

- 优先借用本地已有贴图
- 优先借用本地已有运动模式
- 优先借用已有的层次经验
- 把新效果放到 `generated_particles/`
- 不直接污染 `particle/` 参考库

这也是 [skills/godot-particle-vfx-director/SKILL.md](D:/workspace/godot-tool/particle2dx_importer/skills/godot-particle-vfx-director/SKILL.md) 里明确规定的方向。

### 4.2 当前“生成结果”是如何落地的

当前生成产物放在：

- [generated_particles/](D:/workspace/godot-tool/particle2dx_importer/generated_particles)

例如：

- [generated_particles/gold_coin_fountain.tscn](D:/workspace/godot-tool/particle2dx_importer/generated_particles/gold_coin_fountain.tscn)
- [generated_particles/gold_coin_fountain.gd](D:/workspace/godot-tool/particle2dx_importer/generated_particles/gold_coin_fountain.gd)

这个金币喷泉特效就是当前实践的一次完整落地示例：

#### 参考选择

它没有凭空生成，而是复用了本地素材语义：

- `gold_0.png` 作为金币主体贴图
- `blink_0.png` 作为闪光点
- `fountain` 提供“喷泉”这种上抛流动的参考方向
- `gold` / `gold_boom` 提供奖励类视觉语言

#### 层次拆解

它被拆成了多个粒子层：

- `MainCoins`
- `LeftCoins`
- `RightCoins`
- `CoinBurst`
- `Sparkles`
- `BurstSparkles`

#### 参数组织

每一层都不是简单复制，而是分别设置：

- 发射方向
- spread
- amount
- lifetime
- initial velocity
- gravity
- angular velocity
- scale curve
- color ramp

#### 行为控制

除了静态粒子参数，还通过 GDScript 增加了行为节奏：

- 定时 burst
- burst 位置轻微随机
- 独立的 sparkle 爆发
- 单独运行场景时自动居中

这说明当前项目的“生成”已经不是只会产出一个参数文件，而是能把：

- 粒子节点结构
- 材质与贴图
- 曲线和梯度
- 场景脚本行为

一起落成一个可运行的 Godot 特效场景。

## 5. Godot 可落地还原层是怎么完成的

这是当前项目最重要的一层。很多所谓 AI 生成最后只停留在文字描述，但这个项目的目标是把结果真实落到 Godot。

当前落地方式包括：

### 5.1 直接输出 Godot 场景

生成结果以 `.tscn` 保存，可直接打开、实例化、运行：

- `res://generated_particles/*.tscn`

### 5.2 直接输出 Godot 脚本

当单靠粒子参数不够时，附带 `.gd` 脚本控制节奏、布局、事件触发：

- `res://generated_particles/*.gd`

### 5.3 在 Godot 编辑器内预览和验证

项目中有一个浏览界面：

- [main.tscn](D:/workspace/godot-tool/particle2dx_importer/main.tscn)
- [main.gd](D:/workspace/godot-tool/particle2dx_importer/main.gd)

它用于浏览不同来源的特效资源，并在大窗口里预览、拖动特效位置。

这一步的价值在于：

- 不只是生成文件
- 还能在项目内直接观察效果
- 能快速发现“位置不对、节奏不对、视觉不对”的问题

### 5.4 通过 Godot 运行时回路进行人工调优

当前这套实践仍然保留了很重要的一步：人工审片和回调。

也就是说，项目不是把 AI 当成最终审美判断者，而是让 AI 负责：

- 初版构建
- 参考检索
- 参数建议
- 场景落地

而最终效果是否“真好看”，还是通过 Godot 实际运行、截图、调整来完成。

## 6. 这一套技术实践当前已经完成到什么程度

如果按“标准化 -> 理解/检索 -> 生成 -> 落地还原”四步看，当前项目已经具备如下能力：

### 已完成

1. 外部粒子素材导入 Godot  
   已完成，有编辑器插件和 CLI。

2. 本地参考库建立  
   已完成，`particle/` 已经是一套可复用的粒子参考库。

3. 参考库结构化盘点  
   已完成，`particle_library.py` 可直接做 inventory 和 inspect。

4. 参考库知识提炼  
   已完成，`distill_particle_knowledge.py` 能产出 JSON + Markdown 知识库。

5. AI 可读的知识路由  
   已完成，通过 `library-map.md`、`effect-recipes.md`、`particle-knowledge.*` 形成了一套 AI 可以使用的“外部记忆”。

6. 基于参考的 Godot 粒子生成  
   已完成，能生成新的 Godot 特效场景，并放入 `generated_particles/`。

7. Godot 内可运行验证  
   已完成，生成结果可以实际运行和预览。

### 还没有完全自动化的部分

1. 还没有独立的向量检索服务  
   当前检索更多依赖结构化知识文件和规则路由。

2. 还没有统一的 recipe schema / dataset schema 产物留在当前工作树  
   当前版本主要依赖知识文档和脚本，而不是完整的 JSON workflow pipeline。

3. 还没有“自动审美打分 -> 自动回改”的闭环  
   当前质量把控仍然需要人工结合 Godot 预览来完成。

4. 还没有针对贴图生成的专门工具链  
   当前主要优先复用本地贴图；如果贴图不合适，仍然需要额外补图或新建素材。

## 7. 当前这套实践的核心价值

这套实践最重要的价值，不是“AI 完全替代特效设计”，而是：

1. 让 AI 理解你自己的本地特效库
2. 让 AI 不再瞎编，而是基于现有资产做合理组合
3. 让输出结果直接成为 Godot 资产，而不是空描述
4. 让特效生成这件事从不可控，变成可解释、可检查、可迭代

对于项目开发来说，这比“纯 prompt 出图式 VFX”更实用，因为它能稳定接到你的实际工程里。

## 8. 推荐的实际工作流

当前最推荐的使用顺序如下：

1. 用导入插件把 `.plist` 参考资源转成 Godot 粒子场景
2. 把这些参考放进 `particle/`
3. 运行知识提炼脚本，更新参考知识库
4. 根据目标效果，在 `library-map.md` 和 `effect-recipes.md` 里选参考方向
5. 用 AI 先做“层次设计”和“参考选择”
6. 再生成新的 `generated_particles/*.tscn` 和必要的 `.gd`
7. 在 Godot 里运行、预览、截图、调参
8. 效果成熟后，再决定是否把它晋升为新的参考资产

## 9. 一句话总结

当前项目已经完成的是一套“参考驱动、知识增强、可落地到 Godot 的 2D 粒子 AI 生成实践”：

- 用插件完成素材导入
- 用脚本完成参考库知识提炼
- 用知识文件完成 AI 理解与检索
- 用 Godot 场景和脚本完成最终还原

它已经能支持“基于本地参考库生成新特效”的实际工作；只是当前更偏向“强控制的协同生成”，还不是完全自动化的黑盒生产线。

