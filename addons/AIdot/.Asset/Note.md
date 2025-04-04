```mermaid
flowchart TD
    A[需要参与场景树?]
    A -->|Yes| B[需要图形/物理表现?]
    A -->|No| C[需要持久化存储?]
    B -->|Yes| D[Node2D/Sprite2D]
    B -->|No| E[Node]
    C -->|Yes| F[Resource]
    C -->|No| G[需要跨帧存活?]
    G -->|Yes| H[RefCounted]
    G -->|No| I[Object]
```

```diff
AIdot/
├── Lib/                                # 核心框架
│   ├── Agent/
│   │   ├── Core/                       # 基础组件
│   │   │   ├── BaseAgent.gd            # 继承Node，存储ID、状态等
│   │   │   └── ChatAgent.gd            # 继承BaseAgent，最简单对话Agent
│   │   └── Abilities/                  # 能力组件（可插拔）
│   │       ├── Perception/
│   │       │   ├── Perception.gd       # 感知器集成
│   │       │   ├── Perception2D.gd     # 继承Area2D实现碰撞等感知
│   │       │   └── AudioSensor2D.gd    # 继承AudioListener2D实现声音感知
│   │       ├── Memory/
│   │       │   ├── Memory.gd           # Memory集成，集成记忆方法，继承Resource，存储
│   │       │   ├── Short.gd            # 短记忆，继承AgentMemory
│   │       │   ├── RAG                 # Vulkan计算着色器实现
│   │       │   └── Long.gd             # 长记忆，继承AgentMemory
│   │       ├── Action/
│   │       │   ├── Func.gd             # Function Call
│   │       │   └── Interpreter.gd      # 代码Interpreter
│   │       └── Planning/
│   │           ├── State.gd            # 状态机
│   │           ├── Scheduler.gd        # 任务队列
│   │           └── TaskSystem.gd       # 管理系统
│   ├── Model/                          # 模型接口
│   │   ├── API_Adapter                 # API适配，继承BaseModel
│   │   │   ├── DeepSeek.gd
│   │   │   └── OpenAI.gd
│   │   ├── API                         # 统一HTTPRequest
│   │   │   ├── API.gd                  # 基础AIAPI节点
│   │   │   ├── LLM.gd                  # LLM节点，继承AIAPI
│   │   │   └── VLM.gd
│   │   └── Base                        # Model layer核心
│   │       ├── BaseModel.gd            # 基础BaseModel类，继承Resource，存储
│   │       └── ModelType.gd            # ModelType类，支持的模型
│   └── Tools/
│       ├── ToolCore.gd                 # 工具基类
│       └── Modules/                    # 具体工具实现
│           ├── WebSearch/
│           │   ├── modinf.json         # 工具信息
│           │   └── WebSearch.gd
│           ├── Paint/
│           │   ├── modinf.json
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
│   └── UI/                             # 框架UI素材
│       └── Icon.png
├── Utils/
│   ├── ImageEncoder.gd                 # 图片转Base64
│   └── Log.gd                          # 日志工具
└── Main/                               # 演示与集成
    ├── Autoloads/                      # 自动加载单例
    │   ├── AgentCoordinator.gd         # Agent中心
    │   └── Toolbox.gd                  # 全局工具箱
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
        MADAPTER[API Adapter]
        subgraph Model[Model Resource]
            BaseModel
            MAPI1[OpenAI] --> BaseModel
            MAPI2[DeepSeek] --> BaseModel
            MAPI3[...] --> BaseModel
        end
        Model <--> MADAPTER
    end


    subgraph Toolbox[Toolbox System]
        direction TB
        API[Toolbox API Gateway]
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
        Pool <--> Interpreter
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


    MADAPTER <--> A
    MADAPTER <--> A1
    MADAPTER <--> A2
    MADAPTER <--> A3
    A <--> C


    class ENV env
    class MEM,M model
```
