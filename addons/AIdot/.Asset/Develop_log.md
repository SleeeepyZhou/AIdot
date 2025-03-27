## Future solutions:   

- [ ] 各级UI

#### Agents  
- [ ] 关系网
- [ ] Godot助手

#### ModelLayer  
- [x] 每个Model的UI图标  
- [ ] 流式传输支持  
- [x] ModelLayer性能优化  

#### Memory  
- [ ] RAG原生支持  

#### Tools  
- [x] MCP接入
- [ ] 支持Godot本地MCP服务(GodotTool)  
- [ ] CallTool性能优化

#### Perception  
- [ ] 支持更多感知能力  

#### Planning  
- [ ] 任务管理  


```mermaid
---
displayMode: compact
---
gantt
	title 开发日志 2025-03(整体框架简单实现)
	dateFormat  YYYY-MM-DD
	section Design
		Rest :done, 2025-03-01, 2d
		Design :done, 2025-03-03, 2d
		Memory :done, 2025-03-07, 4d
		MCP Compatible :done, 2025-03-12, 3d
	section Model Layer
		Rebuilt :done, 2025-03-04, 2d
		Example API :done, 2025-03-06, 3d
		VLM :done, 2025-03-09, 1d
	section Agent
		ChatAgent :active, 2025-03-09, 4d
	section Memory
		Agent Memory :active, 2025-03-06, 3d
		Short :done, 2025-03-09, 3d
		Long :active, 2025-03-12, 3d
	section Tools
		MCP :done, 2025-03-12, 1d
		ToolBox :active, 2025-03-13, 2d
```

```mermaid
---
displayMode: compact
---
gantt
	title 开发日志 2025-03(整体框架简单实现)
	dateFormat  YYYY-MM-DD
	section Design
		Rest :done, 2025-03-15, 1d
		Other work :done, 2025-03-16, 7d
		Perception :active, 2025-03-17, 2d
		MCP Design :done, 2025-03-19, 3d
		Planning :active, 2025-03-24, 2d
		Maodot :active, 2025-03-22, 4d
		Doc :active, 2025-03-28, 3d
	section Model Layer
		NewModel :active, 2025-03-28, 2d
	section Agent
		MultiAgent :active, 2025-03-24, 6d
		Maodot :active, 2025-03-27, 4d
	section Memory
	section Perception
	section Planning
	section Tools
		MCPClient :active, 2025-03-20, 3d
		ToolBag :done, 2025-03-23, 2d
		Tool Support :done, 2025-03-25, 3d
```