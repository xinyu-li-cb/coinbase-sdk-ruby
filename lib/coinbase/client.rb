=begin
#Coinbase Platform API

#This is the OpenAPI 3.0 specification for the Coinbase Platform APIs, used in conjunction with the Coinbase Platform SDKs.

The version of the OpenAPI document: 0.0.1-alpha
Contact: yuga.cohler@coinbase.com
Generated by: https://openapi-generator.tech
Generator version: 7.6.0

=end

# Common files
require 'coinbase/client/api_client'
require 'coinbase/client/api_error'
require 'coinbase/client/version'
require 'coinbase/client/configuration'

# Models
Coinbase::Client.autoload :Address, 'coinbase/client/models/address'
Coinbase::Client.autoload :AddressBalanceList, 'coinbase/client/models/address_balance_list'
Coinbase::Client.autoload :AddressList, 'coinbase/client/models/address_list'
Coinbase::Client.autoload :Asset, 'coinbase/client/models/asset'
Coinbase::Client.autoload :Balance, 'coinbase/client/models/balance'
Coinbase::Client.autoload :BroadcastTradeRequest, 'coinbase/client/models/broadcast_trade_request'
Coinbase::Client.autoload :BroadcastTransferRequest, 'coinbase/client/models/broadcast_transfer_request'
Coinbase::Client.autoload :BuildStakingOperationRequest, 'coinbase/client/models/build_staking_operation_request'
Coinbase::Client.autoload :CreateAddressRequest, 'coinbase/client/models/create_address_request'
Coinbase::Client.autoload :CreateServerSignerRequest, 'coinbase/client/models/create_server_signer_request'
Coinbase::Client.autoload :CreateTradeRequest, 'coinbase/client/models/create_trade_request'
Coinbase::Client.autoload :CreateTransferRequest, 'coinbase/client/models/create_transfer_request'
Coinbase::Client.autoload :CreateWalletRequest, 'coinbase/client/models/create_wallet_request'
Coinbase::Client.autoload :CreateWalletRequestWallet, 'coinbase/client/models/create_wallet_request_wallet'
Coinbase::Client.autoload :Error, 'coinbase/client/models/error'
Coinbase::Client.autoload :EthereumValidator, 'coinbase/client/models/ethereum_validator'
Coinbase::Client.autoload :FaucetTransaction, 'coinbase/client/models/faucet_transaction'
Coinbase::Client.autoload :Feature, 'coinbase/client/models/feature'
Coinbase::Client.autoload :FetchStakingRewards200Response, 'coinbase/client/models/fetch_staking_rewards200_response'
Coinbase::Client.autoload :FetchStakingRewardsRequest, 'coinbase/client/models/fetch_staking_rewards_request'
Coinbase::Client.autoload :GetStakingContextRequest, 'coinbase/client/models/get_staking_context_request'
Coinbase::Client.autoload :GetValidator200Response, 'coinbase/client/models/get_validator200_response'
Coinbase::Client.autoload :GetValidator200ResponseValidator, 'coinbase/client/models/get_validator200_response_validator'
Coinbase::Client.autoload :NativeEthStakingContext, 'coinbase/client/models/native_eth_staking_context'
Coinbase::Client.autoload :PartialEthStakingContext, 'coinbase/client/models/partial_eth_staking_context'
Coinbase::Client.autoload :SeedCreationEvent, 'coinbase/client/models/seed_creation_event'
Coinbase::Client.autoload :SeedCreationEventResult, 'coinbase/client/models/seed_creation_event_result'
Coinbase::Client.autoload :ServerSigner, 'coinbase/client/models/server_signer'
Coinbase::Client.autoload :ServerSignerEvent, 'coinbase/client/models/server_signer_event'
Coinbase::Client.autoload :ServerSignerEventEvent, 'coinbase/client/models/server_signer_event_event'
Coinbase::Client.autoload :ServerSignerEventList, 'coinbase/client/models/server_signer_event_list'
Coinbase::Client.autoload :ServerSignerList, 'coinbase/client/models/server_signer_list'
Coinbase::Client.autoload :SignatureCreationEvent, 'coinbase/client/models/signature_creation_event'
Coinbase::Client.autoload :SignatureCreationEventResult, 'coinbase/client/models/signature_creation_event_result'
Coinbase::Client.autoload :SignedVoluntaryExitMessageMetadata, 'coinbase/client/models/signed_voluntary_exit_message_metadata'
Coinbase::Client.autoload :StakingContext, 'coinbase/client/models/staking_context'
Coinbase::Client.autoload :StakingContextContext, 'coinbase/client/models/staking_context_context'
Coinbase::Client.autoload :StakingOperation, 'coinbase/client/models/staking_operation'
Coinbase::Client.autoload :StakingOperationMetadata, 'coinbase/client/models/staking_operation_metadata'
Coinbase::Client.autoload :StakingReward, 'coinbase/client/models/staking_reward'
Coinbase::Client.autoload :StakingRewardFormat, 'coinbase/client/models/staking_reward_format'
Coinbase::Client.autoload :Trade, 'coinbase/client/models/trade'
Coinbase::Client.autoload :TradeList, 'coinbase/client/models/trade_list'
Coinbase::Client.autoload :Transaction, 'coinbase/client/models/transaction'
Coinbase::Client.autoload :TransactionType, 'coinbase/client/models/transaction_type'
Coinbase::Client.autoload :Transfer, 'coinbase/client/models/transfer'
Coinbase::Client.autoload :TransferList, 'coinbase/client/models/transfer_list'
Coinbase::Client.autoload :User, 'coinbase/client/models/user'
Coinbase::Client.autoload :ValidatorList, 'coinbase/client/models/validator_list'
Coinbase::Client.autoload :ValidatorListData, 'coinbase/client/models/validator_list_data'
Coinbase::Client.autoload :Wallet, 'coinbase/client/models/wallet'
Coinbase::Client.autoload :WalletList, 'coinbase/client/models/wallet_list'

# APIs
Coinbase::Client.autoload :AddressesApi, 'coinbase/client/api/addresses_api'
Coinbase::Client.autoload :AssetsApi, 'coinbase/client/api/assets_api'
Coinbase::Client.autoload :ExternalAddressesApi, 'coinbase/client/api/external_addresses_api'
Coinbase::Client.autoload :ServerSignersApi, 'coinbase/client/api/server_signers_api'
Coinbase::Client.autoload :StakeApi, 'coinbase/client/api/stake_api'
Coinbase::Client.autoload :TradesApi, 'coinbase/client/api/trades_api'
Coinbase::Client.autoload :TransfersApi, 'coinbase/client/api/transfers_api'
Coinbase::Client.autoload :UsersApi, 'coinbase/client/api/users_api'
Coinbase::Client.autoload :ValidatorsApi, 'coinbase/client/api/validators_api'
Coinbase::Client.autoload :WalletsApi, 'coinbase/client/api/wallets_api'

module Coinbase::Client
  class << self
    # Customize default settings for the SDK using block.
    #   Coinbase::Client.configure do |config|
    #     config.username = "xxx"
    #     config.password = "xxx"
    #   end
    # If no block given, return the default Configuration object.
    def configure
      if block_given?
        yield(Configuration.default)
      else
        Configuration.default
      end
    end
  end
end
