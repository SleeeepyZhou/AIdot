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

<div style="text-align: right;">

  by [SleeeepyZhou](https://github.com/SleeeepyZhou)

</div>

### Framework

```mermaid
flowchart LR
	subgraph Model
		M[Model]
		L1[API] --> M
		L2[Pool] --> L1
	end
	subgraph Toolbox
		T0[Tools]
		T1[Search]
		T2[Move]
		T3[...]
		T1 --> T0
		T2 --> T0
		T3 --> T0
		T4[...] --> t
	end
	subgraph Agent
		A[Agent1]
		T[Action]
		t[Interpreter]
		T <--> T0
		T0 <--> t
		t --> T4
		subgraph Perception
			P[Perception]
			P1[Perception2D] --> P
			P2[AudioSensor2D] --> P
			P3[...] --> P
		end
		subgraph Memory
			M1[Short] --> M2[Long]
		end
		subgraph Planning
			S[TaskSystem]
			S1[State] <--> S
			S2[Scheduler] <--> S
			S3[...] <--> S
		end
		A <==> T
		P ==> A
		M1 <==> A
		M2 --> A
		S <==> A
	end

	subgraph Coordination
		C[AgentCoordinator]
	end
	M --> A
	A <--> C
	A1[Agent2] <--> C
	A2[Agent3] <--> C
	A3[...] <--> C
```

### Dependent
[Godot-AIUtils](https://github.com/SleeeepyZhou/Godot-AIUtils) by SleeeepyZhou Apache-2.0

### Thanks
This project learns from the renowned Multi-Agent framework [Camel](https://github.com/camel-ai/camel), 
and thanks to [Guohao Li](https://github.com/lightaime) and [Camel-AI](https://github.com/camel-ai) team.
