# <center>AIdot</center>
<p align="center">
  <a href="https://github.com/SleeeepyZhou/AIdot">
	<img src="./addons/AIdot/Res/UI/icon.png" width="150" alt="AIdot logo">
  </a>
</p>

<!-- <div align="center">

[![Moe Counter](https://count.getloli.com/@AIdot?name=AIdot&theme=moebooru)](https://github.com/SleeeepyZhou/AIdot)

</div> -->

## <center>Multi-Agent framework for Godot</center>

### Framework

<div align="right">

  by [SleeeepyZhou](https://github.com/SleeeepyZhou)

</div>

```mermaid
flowchart LR
	subgraph Agent
		direction LR
		A[Agent]

		subgraph Perception
			P2[Perception2D]
			P2N[...] --> P2
			P3[Perception3D]
			P3N[...] --> P3
		end

		subgraph Memory
			M1[AgentMemory] <--> M2[LongMemory]
		end

		subgraph Planning
			S[TaskSystem]
			S3[...] <--> S
		end

		subgraph Action
			T[Action]
			AgentTools --> T
		end

		P2 ==> A
		P3 ==> A
		M1 <==> A
		S <==> A
		A <==> T
	end

	subgraph ENV[Environment]
		direction TB
		PHYS[Physics]
		UI[Game UI]
	end

	ENV --> Perception
	T --> ENV

	subgraph MultiAgent System
		direction TB
		subgraph Agent Network
			A1[Agent1] <--> C
			A2[Agent2] <--> C
			A4[...] <--> C
			C[AgentCoordinator]
		end

		subgraph Model
			M[Model]
			ModelPool --> M
		end
		M --> A

		subgraph Toolbox
			direction LR
			T0[Tools] --> t[Interpreter]
			t --> GMCP
			subgraph GMCP
				direction LR
				MCP
				T1[GodotMCP]
				T2[...]
			end
			GMCP --> T0
		end
		T0 --> AgentTools

	end

	Agent --> A1
	
```

### Support
Native support [MCP (Model Context Protocol)](https://github.com/modelcontextprotocol) through [MCP-gdscript-SDK]().  

### Dependent
[MCP-gdscript-SDK]() by SleeeepyZhou MIT
[Godot-AIUtils](https://github.com/SleeeepyZhou/Godot-AIUtils) by SleeeepyZhou Apache-2.0  
[MatrixCalc](https://github.com/SleeeepyZhou/MatrixCalc) by SleeeepyZhou MIT

### Thanks
This project learns from the renowned Multi-Agent framework [Camel](https://www.camel-ai.org), and thanks to [Guohao Li](https://github.com/lightaime) and [Camel-AI](https://github.com/camel-ai) team.

The design of the agent learns from [Lilian Weng](https://github.com/lilianweng)'s article [LLM Powered Autonomous Agents](https://lilianweng.github.io/posts/2023-06-23-agent/).  

<p align="center">
  <a href="https://lilianweng.github.io/posts/2023-06-23-agent/">
	<img src="./addons/AIdot/.Asset/LLMPoweredAutonomousAgents.png" height="300" alt="LLM Powered Autonomous Agents">
  </a>
</p>