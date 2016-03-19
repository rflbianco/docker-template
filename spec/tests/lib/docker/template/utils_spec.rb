# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "rspec/helper"
describe Docker::Template::Utils do
  let :hash do
    {
      :hello => :world,
      :world => :hello
    }
  end

  #

  let :array do
    [
      :hello,
      :world
    ]
  end

  #

  describe "#split" do
    context "when given an array" do
      it "should just return what it got" do
        expect(subject.split([:hello])).to eq [
          :hello
        ]
      end
    end

    #

    context "when given a string" do
      it "should split it by spaces" do
        expect(subject.split("hello world")).to eq [
          "hello", "world"
        ]
      end
    end

    #

    context "when given nil" do
      it "should return a blank array" do
        expect(subject.split(nil)).to eq [

        ]
      end
    end
  end

  #

  describe "#hash_has_any_keys?" do
    context "when given an array object" do
      it "should be true if any keys exist" do
        expect(subject.any_keys?(array, :hello, :world)).to eq(
          true
        )
      end
    end

    #

    context "when given a hash object" do
      it "should be true if any keys exist" do
        expect(subject.any_keys?(hash, :hello, :world)).to eq(
          true
        )
      end
    end
  end

  #

  describe "#deep_merge" do
    it "should handle hashception" do
      hash1 = { :hello => { :world1 => 1 }}
      hash2 = { :hello => {
        :world2 => 2
      }}

      result = subject.deep_merge(hash1, hash2)
      expect(result[:hello]).to include({
        :world2 => 2
      })
    end
  end
end