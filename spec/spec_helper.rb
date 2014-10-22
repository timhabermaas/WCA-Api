require_relative '../lib/api'
require 'rack/test'

def app
  Api.new(application)
end

def application
  WCAApi.new("redis://localhost:6379/2")
end

def json_response
  JSON.parse(last_response.body)
end

def last_status
  last_response.status
end

RSpec.configure do |c|
  c.before(:all) do
    application.reset_db!
    person_tsv = File.expand_path("../fixtures/persons.tsv", __FILE__)
    results_tsv = File.expand_path("../fixtures/results.tsv", __FILE__)
    single_tsv = File.expand_path("../fixtures/ranks-single.tsv", __FILE__)
    average_tsv = File.expand_path("../fixtures/ranks-average.tsv", __FILE__)
    application.import!(person_tsv, results_tsv, single_tsv, average_tsv)
  end
end
