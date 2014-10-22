require 'spec_helper'

describe "competitors endpoint" do
  include Rack::Test::Methods

  describe "GET /competitors/:id" do
    before do
      get "/competitors/2003BRUC01"
    end

    it "returns 200 Ok" do
      expect(last_status).to eq 200
    end

    let(:person) { json_response["competitor"] }

    it "returns the information for that guy" do
      expect(person["name"]).to eq "Ron van Bruchem"
      expect(person["country"]).to eq "Netherlands"
      expect(person["gender"]).to eq "m"
    end

    it "includes the amount of competitions the competitor attended" do
      expect(person["competition_count"]).to eq 110
    end
  end

  describe "GET /competitors?q=2003B" do
    before do
      get "/competitors?q=2003B"
    end

    it "returns all competitors matching that id" do
      expect(json_response["competitors"].size).to eq 15
      ids = json_response["competitors"].map { |p| p["id"] }
      names = json_response["competitors"].map { |p| p["name"] }
      expect(ids).to include "2003BRUC01"
      expect(names).to include "Ron van Bruchem"
    end
  end

  describe "GET /competitors/:id/records" do
    context "competitor exists" do
      before do
        get "/competitors/2003BRUC01/records"
      end

      it "returns a hash containing all records for that person" do
        expect(json_response["records"]["333"]["single"]).to eq 871
        expect(json_response["records"]["333bf"]["single"]).to eq 36256
        expect(json_response["records"]["333bf"]["average"]).to eq nil
        expect(json_response["records"]["333fm"]["single"]).to eq 25
        expect(json_response["records"]["333"]["average"]).to eq 1262
        expect(json_response["records"]["444"]["average"]).to eq 5219
      end
    end

    context "competitor doesn't exist" do
      before do
        get "/competitors/1999FRED02/records"
      end

      it "returns 404 Not Found" do
        expect(last_status).to eq 404
      end
    end
  end
end
