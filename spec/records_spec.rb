require 'spec_helper'

describe "records endpoint" do
  include Rack::Test::Methods

  describe "GET /records/333/single" do
    before do
      get "/records/333/single"
    end

    it "returns 200 Ok" do
      expect(last_status).to eq 200
    end

    let(:records) { json_response["records"] }

    it "returns a list of all record holders, ordered by the result" do
      expect(records.size).to eq 4

      expect(records.first["id"]).to eq "2005AKKE01"
      expect(records.first["name"]).to eq "Erik Akkersdijk"
      expect(records.first["result"]).to eq 708

      expect(records[1]["id"]).to eq "2003BRUC01"
      expect(records[1]["name"]).to eq "Ron van Bruchem"
      expect(records[1]["result"]).to eq 871

      expect(records.last["id"]).to eq "2011RAHM01"
      expect(records.last["name"]).to eq "Abdul Rahman"
      expect(records.last["result"]).to eq 4647
    end
  end

  describe "GET /records/333/average" do
    before do
      get "/records/333/average"
    end

    it "returns 200 Ok" do
      expect(last_status).to eq 200
    end

    let(:records) { json_response["records"] }

    it "returns a list of all record holders, ordered by the result" do
      expect(records.size).to eq 2

      expect(records.first["id"]).to eq "2005AKKE01"
      expect(records.first["name"]).to eq "Erik Akkersdijk"
      expect(records.first["result"]).to eq 931

      expect(records[1]["id"]).to eq "2003BRUC01"
      expect(records[1]["name"]).to eq "Ron van Bruchem"
      expect(records[1]["result"]).to eq 1262
    end
  end
end
