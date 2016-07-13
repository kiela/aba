# encoding: UTF-8

require "spec_helper"

describe Aba::Transaction do
  let(:transaction_params) { {
    :account_number => 23432342,
    :transaction_code => 53,
    :amount => 50050,
    :account_name => "John Doe",
    :bsb => "345-453",
    :witholding_amount => 87,
    :indicator => "W",
    :lodgement_reference => "R45343",
    :trace_bsb => "123-234",
    :trace_account_number => "4647642",
    :name_of_remitter => "Remitter"
  } }
  subject(:transaction) { Aba::Transaction.new(transaction_params) }

  describe "#is_credit?" do
    context "when transaction is credit type" do
      it "returns true" do
        subject.transaction_code = described_class::CREDIT_TRANSACTION_CODES.sample

        expect(subject.is_credit?).to be_truthy
      end
    end

    context "when transaction is debit type" do
      it "returns false" do
        subject.transaction_code = described_class::DEBIT_TRANSACTION_CODES.sample

        expect(subject.is_credit?).to be_falsey
      end
    end
  end

  describe "#is_debit?" do
    context "when transaction is debit type" do
      it "returns true" do
        subject.transaction_code = described_class::DEBIT_TRANSACTION_CODES.sample

        expect(subject.is_debit?).to be_truthy
      end
    end

    context "when transaction is credit type" do
      it "returns false" do
        subject.transaction_code = described_class::CREDIT_TRANSACTION_CODES.sample

        expect(subject.is_debit?).to be_falsey
      end
    end
  end

  describe "#amount" do
    context "when no amount was set" do
      before{ subject.amount = nil }

      it "falls back to 0" do
        expect(subject.amount).to eq(0)
      end
    end

    context "when amount was set" do
      before{ subject.amount = 12345 }

      context "when transaction is credit type" do
        before{ subject.transaction_code = 50 }

        it "returns set value" do
          expect(subject.amount).to eq(12345)
        end
      end

      context "when transaction is debit type" do
        before{ subject.transaction_code = 13 }

        it "returns value set as negative" do
          expect(subject.amount).to eq(-12345)
        end
      end
    end
  end

  describe "#to_s" do
    it "should create a transaction row" do
      expect(subject.to_s).to include("1345-453 23432342W530000050050John Doe                        R45343            123-234  4647642Remitter        00000087")
    end
  end

  describe "#valid?" do
    it "should be valid" do
      expect(subject.valid?).to eq true
    end

    it "should not be valid" do
      transaction_params.delete(:bsb)
      expect(subject.valid?).to eq false
      expect(subject.errors).to eq ["bsb format is incorrect"]
    end
  end
end
