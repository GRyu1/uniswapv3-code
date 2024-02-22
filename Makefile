.PHONY: test

anvil:
	anvil --code-size-limit 50000

deploy:
	forge script scripts/DeployDevelopment.s.sol --broadcast --fork-url $$ETH_RPC_URL --private-key $$PRIVATE_KEY --code-size-limit 50000

update-abis:
	forge inspect UniswapV3Factory abi > src/abi/Factory.json
	forge inspect UniswapV3Manager abi > src/abi/Manager.json
	forge inspect UniswapV3Pool abi > src/abi/Pool.json
	forge inspect UniswapV3Quoter abi > src/abi/Quoter.json

test:
	forge test --ffi