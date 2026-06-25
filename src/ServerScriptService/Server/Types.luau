-- Items Types
export type ItemData = {
	Name: string,
}
export type ItemInstance = {
	Tool: Tool,
} & ItemModule
export type ItemModule = {
	ToolName: string?,
	DisplayName: string?,
	Stackable: boolean,
	CustomInfo: { [string]: any }?,
}

return {}
