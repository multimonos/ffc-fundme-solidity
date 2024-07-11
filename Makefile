# --- PROJECT
include .env
REMAPPINGS_PATH=./remappings.txt

install:
	@forge install smartcontractkit/chainlink-brownie-contracts@1.1.1  --no-commit

remappings:
	@forge remappings > ${REMAPPINGS_PATH}
	@echo "file : ${REMAPPINGS_PATH}"
	@cat ${REMAPPINGS_PATH}

test-fundme:
	@forge test --watch -vv --gas-report

test-price-version:
	# FundMe.getVersion() relies on the Sepolia Chainlink Feed at 0x694AA1769357215DE4FAC081bf1f309aDC325306
	# which provides us with the eth2usd conversion rate.
	# --fork-url RPC_URL will spin up anvil and simluate the SEPOLIA_RPC_URL
	# !!! This approach does not require a mock, however, it may incur charges depending on setup !!!
	forge test --watch -vvv --gas-report --mt test_price_feed_version --fork-url ${SEPOLIA_URL}

test-coverage:
	@forge coverage --fork-url ${SEPOLIA_URL}


# --- SEPOLIA
#sepolia-deploy:
	#@forge create ./src/FundMe.sol:FundMe --private-key=${SEPOLIA_PKEY} --rpc-url=${SEPOLIA_URL}
#sepolia-contract-txns:
	#@open https://sepolia.etherscan.io/address/0xfa6aef59c7037939638864539b851b64d9273089
#sepolia-contract-code:
	#@open https://sepolia.etherscan.io/address/0xfa6aef59c7037939638864539b851b64d9273089#code
#sepolia-txn:
	#@open https://sepolia.etherscan.io/tx/0xad1cf78c1aac3589e06625504b4c6c16eff451239bf30f6e72eb46b3484a8de6
#sepolia-read:
	#@cast call ${SEPOLIA_CONTRACT} "retrieve()" --rpc-url=${SEPOLIA_URL}


# --- GANACHE
#ganache-deploy:
	#@forge create ./src/05-simple-storage-foundry/SimpleStorage.sol:SimpleStorage --private-key=${GANACHE_PKEY} --rpc-url=${GANACHE_URL}
#ganache-set:
# 	@cast send  "store(uint256)" 666 --rpc-url=${GANACHE} --private-key=${GANACHE_PKEY}


# ANVIL ---
#anvil-read:
	#@cast call ${CONTRACT} "retrieve()" --rpc-url=${ANVIL_URL}
#anvil-read-dec:
	#@cast call ${CONTRACT} "retrieve()" --rpc-url=${ANVIL_URL} |cast 2d
#anvil-write:
	#@cast send ${CONTRACT} "store(uint256)" 666 --rpc-url=${ANVIL_URL} --private-key=${PK3}

