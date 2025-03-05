
```diff
AIdot/
├── Lib/                                # 核心框架
│   ├── Agent/
│   │   ├── Core/                       # 基础组件
│   │   │   ├── BaseAgent.gd            # 继承Node，存储ID、状态等
│   │   │   └── ChatAgent.gd            # 继承BaseAgent，最简单的对话Agent
│   │   └── Abilities/                  # 能力组件（可插拔）
│   │       ├── Perception/
│   │       │   ├── Perception.gd       # 感知器集成
│   │       │   ├── Perception2D.gd     # 继承Area2D实现碰撞等感知
│   │       │   └── AudioSensor2D.gd    # 继承AudioListener2D实现声音感知
│   │       ├── Memory/
│   │       │   ├── Memory.gd           # Memory集成，集成记忆方法
│   │       │   ├── Short.gd            # 短记忆
│   │       │   └── Long.gd             # 长记忆
│   │       ├── Action/
│   │       │   ├── Func.gd             # Function Call
│   │       │   └── Interpreter.gd      # 代码Interpreter
│   │       └── Planning/
│   │           ├── State.gd            # 状态
│   │           ├── Scheduler.gd        # 任务队列
│   │           └── TaskSystem.gd       # 任务管理系统
│   ├── Model/                          # 模型接口
│   │   ├── API_Adapter                 # API适配
│   │   │   ├── API.gd                  # API统一接口
│   │   │   └── Pool.gd                 # 调用线程池
│   │   ├── LLM.gd                      # LLM类
│   │   └── VLM.gd                      # VLM类
│   └── Tools/
│       ├── ToolCore.gd                 # 工具基类
│       └── Modules/                    # 具体工具实现
│           ├── WebSearch/
│           │   ├── modinf.json         # 工具信息
│           │   └── WebSearch.gd
│           ├── Paint/
│           │   ├── modinf.json         # 工具信息
│           │   └── StableDiffusion.gd
│           └── GameAPI/
│               ├── modinf.json
│               └── Key.gd
├── Res/
│   ├── Agents/                         # Agent预设
│   │   ├── RPG_Guard.gd                # 预设的警卫Agent
│   │   └── RPG_Guard.tscn
│   ├── Data/                           # 各类数据文件
│   │   └── sys_prompt.json             # 预设Prompt数据
│   └── UI/                             # 框架专用UI素材
│       └── Icon.png                    # 项目图标
├── Utils/
│   ├── ImageEncoder.gd                 # 图片转Base64
│   └── Log.gd                          # 日志工具
└── Main/                               # 演示与集成
	├── Autoloads/                      # 自动加载单例
	│   ├── AgentCoordinator.gd         # Agent协调中心
	│   └── Toolbox.gd                  # 全局工具访问入口
	└── Demo/                           # 示例场景
		└── Demo.tscn
```


```mermaid
flowchart TB
	classDef model fill:#E3F2FD,stroke:#BBDEFB;
	classDef env fill:#F8BBD0,stroke:#F48FB1;

	subgraph ENV[Environment]
		direction TB
		PHYS[Physics] -->|Data| SENSOR[Sensor System]
		UI[Game UI] -->|Player Input| EVENT[Event Bus]
	end
	ENV[Game World] ==> Perception
	T ==> ENV
	subgraph M[Model Layer]
		direction TB
		MADAPTER[API Adapter] --> MAPI1[...]
		MADAPTER --> MAPI2[Gemini]
		MADAPTER --> MAPI3[HuggingFace]
		MTHREAD[Thread Pool] -->|Async Call| MADAPTER
	end

	subgraph Toolbox[Toolbox System]
		direction TB
		subgraph Interface[API]
			API[Toolbox API Gateway]
		end
		subgraph Core
			Loader[Mod Loader]
			Registry[Tool Registry]
			Pool[Tool Pool]
			Interpreter[Code Interpreter]
		end
		subgraph Mod
			direction TB
			T1[Search] --> Pool
			T2[Move] --> Pool
			T3[Paint] --> Pool
			T4[...] --> Pool
		end
		subgraph Security
			Sandbox[Execution Sandbox]
			Auth[Permission Validator]
		end
		subgraph Storage
			Cache[Response Cache]
			Hotfix[Hot Reload Watchdog]
		end

		API --> Loader
		API --> Registry
		API --> Pool
		API --> Interpreter
		Loader -->|Loading| Registry
		Registry -->|Metadata| Pool
		Interpreter -->|Safety| Sandbox
		Sandbox --> Auth
		Pool <-->|Reuse| Interpreter
		Hotfix -->|File monitor| Loader
		Cache <-->|Cache| API
		Security -->|Cache| API
	end
		classDef core fill:#F5F5F5,stroke:#BDBDBD;
		classDef security fill:#FFEBEE,stroke:#FFCDD2;
		classDef storage fill:#E3F2FD,stroke:#BBDEFB;
		classDef interface fill:#F0F4C3,stroke:#DCE775;
		class Interface interface
		class Core core
		class Security security
		class Storage storage

	subgraph MultiAgent
		subgraph Agent
			direction TB
			T[Action]
			A[Agent1]
			T <--> API
			subgraph Perception
				P[Perception]
				P1[Perception2D] --> P
				P2[AudioSensor2D] --> P
				P3[...] --> P
			end
			subgraph MEM[Memory]
				M1[Short] --> M2[Long]
			end
			subgraph Planning
				S[TaskSystem]
				S1[State] <--> S
				S2[Scheduler] <--> S
				S3[...] <--> S
			end
			A <==> T
			P ==>|Feedback| A
			M1 <==> A
			M2 --> A
			S <==> A
		end
		A1[Agent2]
		A2[Agent3]
		A3[...]
	end
	subgraph Coordination
		C[AgentCoordinator]
		A1 <--> C
		A2 <--> C
		A3 <--> C
	end
	M --> A
	M --> A1
	M --> A2
	M --> A3
	A <--> C

	class ENV env
	class MEM,M model
```
