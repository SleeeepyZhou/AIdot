# <center>AIdot</center>
<p align="center">
  <a href="https://github.com/SleeeepyZhou/AIdot">
	<img src="./addons/AIdot/Res/Asset/icon.png" width="150" alt="AIdot logo">
  </a>
</p>

<div align="center">

[![Moe Counter](https://count.getloli.com/@AIdot?name=AIdot&theme=moebooru)](https://github.com/SleeeepyZhou/AIdot)

</div>

## <center>Multi-Agent framework for Godot</center>

<div align="right">

  by [SleeeepyZhou](https://github.com/SleeeepyZhou)

</div>

### Framework

```mermaid
flowchart LR
    subgraph Coordination
		C[AgentCoordinator]
	end
    subgraph MultiAgent System
        subgraph Agent
            A[Agent1]
            subgraph Action
                T[Action]
                AgentTools --> T
            end
            subgraph Perception
                P[Perception]
                P3[...] --> P
            end
            subgraph Memory
                M1[Short] --> M2[Long]
            end
            subgraph Planning
                S[TaskSystem]
                S3[...] <--> S
            end
            A <==> T
            P ==> A
            M1 <==> A
            M2 --> A
            S <==> A
        end
        A <--> C
        A1[Agent2] <--> C
        A2[Agent3] <--> C
        A3[...] <--> C
    end
    subgraph Model
		M[Model]
		Pool --> M
	end
	M --> A
    subgraph Toolbox
        direction LR
		T0[Tools] --> AgentTools
		t[Interpreter]
		T4[...] --> t
		T0 <--> t
		t --> T4
	end
    subgraph ENV[Environment]
        direction TB
        PHYS[Physics]
        UI[Game UI]
    end
    ENV --> Perception
    Action --> ENV
	
```

### Dependent
[Godot-AIUtils](https://github.com/SleeeepyZhou/Godot-AIUtils) by SleeeepyZhou Apache-2.0

### Thanks
This project learns from the renowned Multi-Agent framework [Camel](https://www.camel-ai.org), 
and thanks to [Guohao Li](https://github.com/lightaime) and [Camel-AI](https://github.com/camel-ai) team.

[LLM Powered Autonomous Agents](https://lilianweng.github.io/posts/2023-06-23-agent/) from [Lilian Weng](https://github.com/lilianweng)
