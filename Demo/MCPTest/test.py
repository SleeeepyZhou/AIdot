from mcp.server.fastmcp import FastMCP
mcp = FastMCP("Test_MCP")

@mcp.tool() # MCP tool identification
async def example_func(example_arg: str) -> str:
    """Please provide a description of the function here.

    Args:
        example_arg: Describe the input here.
    """
    # Here is the specific function of the function.
    print(example_arg)
    return example_arg # Return a string.


if __name__ == "__main__":
    mcp.run(transport='stdio')