-- Items Types
export type ItemData = {
	Name: string,
}
export type ItemInstance = {
	Tool: Tool,
} & ItemModule
export type ItemModule = {
	Stackable: boolean,
	CustomInfo: { [string]: any }?,
}

return {}
