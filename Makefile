# --- PROJECT
include .env
REMAPPINGS_PATH=./remappings.txt

install:
	@forge install smartcontractkit/chainlink-brownie-contracts@1.1.1  --no-commit

remappings:
	@forge remappings > ${REMAPPINGS_PATH}
	@echo "file : ${REMAPPINGS_PATH}"
	@cat ${REMAPPINGS_PATH}

test-local:
	@forge test --watch -vvv

test-local-gas:
	@forge test --watch -vvv --gas-report

# simulate txns as if they are running Sepolia chain using the configured feed
test-sepolia:
	forge test --watch -vvv --gas-report --fork-url ${SEPOLIA_URL}


# FundMe.getVersion() relies on the Sepolia Chainlink Feed at 0x694AA1769357215DE4FAC081bf1f309aDC325306
# which provides us with the eth2usd conversion rate.
# --fork-url=$RPC_URL will spin up anvil and simluate the SEPOLIA_RPC_URL
# !!! This approach does not require a mock, however, it may incur charges depending on setup !!!
test-price-version:
	forge test --watch -vvvv --gas-report --mt test_price_feed_version --fork-url ${SEPOLIA_URL}

test-coverage:
	@forge coverage --fork-url ${SEPOLIA_URL}



# --- SEPOLIA
sepolia-deploy:
	@forge clean
	@forge script script/DeployFundMe.s.sol --rpc-url=${SEPOLIA_URL} --private-key=${SEPOLIA_PKEY} --broadcast
sepolia-contract-txns:
	@open https://sepolia.etherscan.io/address/${SEPOLIA_CONTRACT}
sepolia-contract-code:
	@open https://sepolia.etherscan.io/address/${SEPOLIA_CONTRACT}#code
sepolia-read:
	@cast call ${SEPOLIA_CONTRACT} "getFeedVersion()" --rpc-url=${SEPOLIA_URL}
sepolia-read-dec:
	@cast call ${SEPOLIA_CONTRACT} "getFeedVersion()" --rpc-url=${SEPOLIA_URL} |cast 2d
