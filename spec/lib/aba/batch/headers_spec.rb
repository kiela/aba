# encoding: UTF-8

require "spec_helper"

describe Aba::Batch::Headers do
  subject do
    described_class.new(
      financial_institution: "ABC",
      user_name: "John Doe",
      user_id: "987654",
      description: "Description",
      process_at: "190615"
    )
  end

  describe "#initialize" do
    context "when iterating over given attribute-value pairs" do
      context "when value for an attribute can be assigned" do
        it "assigns value to attribute" do
          bsb = double('bsb')

          instance = described_class.new(bsb: bsb)

          expect(instance.bsb).to eq(bsb)
        end
      end
    end
  end

  describe "#validate!" do
    context "when descriptive record is invalid" do
      it "raises an exception" do
        allow(subject).to receive(:valid?).and_return(false)

        expect{ subject.validate! }.to raise_error(RuntimeError, /invalid/i)
      end
    end
  end

  describe "#to_s" do
    it "validates descriptive record" do
      expect(subject).to receive(:validate!)

      subject.to_s
    end

    context "when no BSB was given" do
      before{ subject.bsb = nil }

      it "returns a string containing the descriptive record without the BSB" do
        expect(subject.to_s).to eq("0                 01ABC       John Doe                  987654Description 190615                                        ")
      end
    end

    context "when BSB was given" do
      before{ subject.bsb = "123-456" }

      it "returns a string containing the descriptive record with the BSB" do
        expect(subject.to_s).to eq("0123-456          01ABC       John Doe                  987654Description 190615                                        ")
      end
    end
  end
end
