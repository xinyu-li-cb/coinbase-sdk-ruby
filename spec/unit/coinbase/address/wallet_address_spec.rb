# frozen_string_literal: true

describe Coinbase::WalletAddress do
  let(:key) { Eth::Key.new }
  let(:network_id) { :base_sepolia }
  let(:normalized_network_id) { 'base-sepolia' }
  let(:address_id) { key.address.to_s }
  let(:wallet_id) { SecureRandom.uuid }
  let(:model) do
    Coinbase::Client::Address.new(
      network_id: normalized_network_id,
      address_id: address_id,
      wallet_id: wallet_id,
      public_key: key.public_key.compressed.unpack1('H*')
    )
  end
  let(:eth_asset_model) do
    Coinbase::Client::Asset.new(network_id: normalized_network_id, asset_id: 'eth', decimals: 18)
  end
  let(:addresses_api) { instance_double(Coinbase::Client::ExternalAddressesApi) }

  before do
    allow(Coinbase::Client::ExternalAddressesApi).to receive(:new).and_return(addresses_api)
  end

  subject(:address) do
    described_class.new(model, key)
  end

  describe '#initialize' do
    it 'initializes a new Address' do
      expect(address).to be_a(described_class)
    end
  end

  describe '#network_id' do
    it 'returns the network ID' do
      expect(address.network_id).to eq(network_id)
    end
  end

  describe '#id' do
    it 'returns the address ID' do
      expect(address.id).to eq(address_id)
    end
  end

  describe '#wallet_id' do
    it 'returns the wallet ID' do
      expect(address.wallet_id).to eq(wallet_id)
    end
  end

  describe '#key=' do
    let(:unhydrated_address) { described_class.new(model, nil) }

    it 'sets the key' do
      expect { unhydrated_address.key = key }.not_to raise_error
    end

    it 'raises an error if the key is already set' do
      expect { address.key = key }.to raise_error('Private key is already set')
    end
  end

  describe '#can_sign?' do
    it 'returns true if the address has a key' do
      expect(address.can_sign?).to be true
    end

    it 'returns false if the address does not have a key' do
      unhydrated_address = described_class.new(model, nil)
      expect(unhydrated_address.can_sign?).to be false
    end
  end

  describe '#export' do
    let(:private_key) { key.private_hex }

    it 'export private key from address' do
      expect(address.export).to eq(private_key)
    end

    context 'when the address is unhydrated' do
      let(:unhydrated_address) { described_class.new(model, nil) }

      it 'raises an error' do
        expect do
          unhydrated_address.export
        end.to raise_error('Cannot export key without private key loaded')
      end
    end
  end

  describe '#inspect' do
    it 'includes address details' do
      expect(address.inspect).to include(address_id, Coinbase.to_sym(network_id).to_s, wallet_id)
    end

    it 'returns the same value as to_s' do
      expect(address.inspect).to eq(address.to_s)
    end
  end

  it_behaves_like 'an address that supports balance queries'

  it_behaves_like 'an address that supports requesting faucet funds'

  describe '#transfer' do
    let(:balance) { 1_000 }
    let(:amount) { 500 }
    let(:to_address_id) { Eth::Key.new.address.to_s }
    let(:transaction) { instance_double(Coinbase::Transaction, sign: '0x12345') }
    let(:created_transfer) do
      instance_double(Coinbase::Transfer, id: SecureRandom.uuid, transaction: transaction)
    end
    let(:asset_id) { :eth }
    let(:use_server_signer) { false }

    subject(:transfer) { address.transfer(amount, asset_id, to_address_id) }

    before do
      allow(Coinbase).to receive(:use_server_signer?).and_return(use_server_signer)

      allow(addresses_api)
        .to receive(:get_external_address_balance)
        .with(normalized_network_id, address_id, 'eth')
        .and_return(
          Coinbase::Client::Balance.new(
            amount: Coinbase::Asset.from_model(eth_asset_model).to_atomic_amount(balance).to_s,
            asset: eth_asset_model
          )
        )
    end

    context 'when the transfer is successful' do
      before do
        allow(Coinbase::Transfer).to receive(:create).and_return(created_transfer)

        allow(created_transfer).to receive(:broadcast!)

        transfer
      end

      context 'when not using server signer' do
        let(:use_server_signer) { false }

        it 'returns the created transfer' do
          expect(transfer).to eq(created_transfer)
        end

        it 'signs the transaction with the key' do
          expect(transaction).to have_received(:sign).with(key)
        end

        it 'broadcasts the transfer' do
          expect(created_transfer).to have_received(:broadcast!)
        end
      end

      context 'when using server signer' do
        let(:use_server_signer) { true }

        it 'returns the created transfer' do
          expect(transfer).to eq(created_transfer)
        end

        it 'creates the transfer' do
          expect(Coinbase::Transfer).to have_received(:create).with(
            address_id: address_id,
            amount: amount,
            asset_id: asset_id,
            destination: to_address_id,
            network_id: network_id,
            wallet_id: wallet_id
          )
        end

        it 'does not broadcast the transfer' do
          expect(created_transfer).not_to have_received(:broadcast!)
        end

        it 'does not sign the transaction with the key' do
          expect(transaction).not_to have_received(:sign)
        end
      end
    end

    context 'when the balance is insufficient' do
      let(:amount) { balance + 10 }

      it 'raises an InsufficientFundsError' do
        expect do
          address.transfer(amount, asset_id, to_address_id)
        end.to raise_error(Coinbase::InsufficientFundsError)
      end
    end

    context 'when the address cannot sign' do
      let(:unhydrated_address) { described_class.new(model, nil) }

      it 'raises an AddressCannotSignError' do
        expect do
          unhydrated_address.transfer(1, :wei, to_address_id)
        end.to raise_error(Coinbase::AddressCannotSignError)
      end
    end
  end

  describe '#trade' do
    let(:balance) { 1_000 }
    let(:amount) { 500 }
    let(:transactions) do
      [
        instance_double(Coinbase::Transaction, sign: 'signed_payload'),
        instance_double(Coinbase::Transaction, sign: 'approve_signed_payload')
      ]
    end
    let(:created_trade) do
      instance_double(Coinbase::Trade, id: SecureRandom.uuid, transactions: transactions)
    end
    let(:from_asset_id) { :eth }
    let(:normalized_from_asset_id) { 'eth' }
    let(:to_asset_id) { :usdc }
    let(:use_server_signer) { false }

    subject(:trade) { address.trade(amount, from_asset_id, to_asset_id) }

    before do
      allow(addresses_api)
        .to receive(:get_external_address_balance)
        .with(normalized_network_id, address_id, normalized_from_asset_id)
        .and_return(
          Coinbase::Client::Balance.new(
            amount: Coinbase::Asset.from_model(eth_asset_model).to_atomic_amount(balance).to_s,
            asset: eth_asset_model
          )
        )

      allow(Coinbase).to receive(:use_server_signer?).and_return(use_server_signer)
    end

    context 'when the trade is successful' do
      let(:from_asset_id) { :eth }
      let(:amount) { 0.5 }

      before do
        allow(Coinbase::Trade).to receive(:create).and_return(created_trade)

        allow(created_trade).to receive(:broadcast!)

        trade
      end

      context 'when not using server signer' do
        let(:use_server_signer) { false }

        it 'returns the created trade' do
          expect(trade).to eq(created_trade)
        end

        it 'creates the trade' do
          expect(Coinbase::Trade).to have_received(:create).with(
            address_id: address_id,
            amount: amount,
            from_asset_id: from_asset_id,
            to_asset_id: to_asset_id,
            network_id: network_id,
            wallet_id: wallet_id
          )
        end

        it 'signs all of the transactions with the address key' do
          expect(transactions).to all have_received(:sign).with(key)
        end

        it 'broadcasts the trade' do
          expect(created_trade).to have_received(:broadcast!)
        end
      end

      context 'when using server signer' do
        let(:use_server_signer) { true }

        it 'returns the created trade' do
          expect(trade).to eq(created_trade)
        end

        it 'creates the trade' do
          expect(Coinbase::Trade).to have_received(:create).with(
            address_id: address_id,
            amount: amount,
            from_asset_id: from_asset_id,
            to_asset_id: to_asset_id,
            network_id: network_id,
            wallet_id: wallet_id
          )
        end

        it 'does not broadcast the trade' do
          expect(created_trade).not_to have_received(:broadcast!)
        end

        it 'signs none of the transactions with the address key' do
          transactions.each do |transaction|
            expect(transaction).not_to have_received(:sign)
          end
        end
      end
    end

    context 'when the balance is insufficient' do
      let(:amount) { balance + 10 }

      it 'raises an InsufficientFundsError' do
        expect do
          address.trade(amount, from_asset_id, to_asset_id)
        end.to raise_error(Coinbase::InsufficientFundsError)
      end

      it 'does not sign any transaction' do
        transactions.each do |tx|
          expect(tx).not_to have_received(:sign)
        end
      end
    end

    describe 'when the address cannot sign' do
      let(:unhydrated_address) { described_class.new(model, nil) }

      it 'raises an AddressCannotSignError' do
        expect do
          unhydrated_address.trade(12_345, from_asset_id, to_asset_id)
        end.to raise_error(Coinbase::AddressCannotSignError)
      end

      it 'does not sign any transaction' do
        transactions.each do |tx|
          expect(tx).not_to have_received(:sign)
        end
      end
    end
  end

  describe '#transfers' do
    let(:transfer_enumerator) { instance_double(Enumerator) }

    before do
      allow(Coinbase::Transfer)
        .to receive(:list)
        .with(wallet_id: wallet_id, address_id: address_id)
        .and_return(transfer_enumerator)
    end

    it 'lists the transfers' do
      expect(address.transfers).to eq(transfer_enumerator)
    end
  end

  describe '#trades' do
    let(:trade_enumerator) { instance_double(Enumerator) }

    before do
      allow(Coinbase::Trade)
        .to receive(:list)
        .with(wallet_id: wallet_id, address_id: address_id)
        .and_return(trade_enumerator)
    end

    it 'lists the trades' do
      expect(address.trades).to eq(trade_enumerator)
    end
  end
end
