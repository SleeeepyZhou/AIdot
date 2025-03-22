## Future solutions:   

- [ ] 各级UI

#### Agents  
- [ ] 关系网系统

#### ModelLayer  
- [ ] 每个Model的UI图标  
- [ ] 流式传输支持  
- [ ] ModelLayer性能优化  

#### Memory  
- [ ] RAG原生支持  

#### Tools  
- [ ] 支持Godot本地MCP服务  

#### Perception  
- [ ] 支持更多感知能力  

#### Planning  
- [ ] 任务管理  


```mermaid
---
displayMode: compact
---
gantt
	title 开发日志 2025-03上(整体框架简单实现)
	dateFormat  YYYY-MM-DD
	section Design
		休整 :done, 2025-03-01, 2d
		架构设计 :done, 2025-03-03, 2d
		记忆模块设计 :done, 2025-03-07, 4d
		MCP兼容设计 :active, 2025-03-12, 3d
	section Model Layer
		工具重构 :done, 2025-03-04, 2d
		示例API集成 :done, 2025-03-06, 3d
		VLM :done, 2025-03-09, 1d
	section Agent
		ChatAgent :active, 2025-03-09, 4d
	section Memory
		记忆类 :active, 2025-03-06, 3d
		短记忆 :active, 2025-03-09, 3d
		长记忆 :active, 2025-03-12, 3d
	section Action
	section Perception
	section Planning
	section Tools
		MCP :active, 2025-03-12, 1d
		ToolBox :active, 2025-03-13, 2d
```

```mermaid
---
displayMode: compact
---
gantt
	title 开发日志 2025-03下(整体框架简单实现)
	dateFormat  YYYY-MM-DD
	总时长 :active, 2025-03-15, 16d
	section Design
		休整 :done, 2025-03-15, 1d
		Other :done, 2025-03-16, 5d
		Perception :active, 2025-03-17, 2d
		MCP Design :active, 2025-03-19, 3d
	section Model Layer
	section Agent
	section Memory
	section Perception
	section Planning
	section Tools
		MCP :active, 2025-03-20, 2d
```