require_relative '../lib/api'
require 'rack/test'

def app
  person_tsv = File.expand_path("../fixtures/persons.tsv", __FILE__)
  single_tsv = File.expand_path("../fixtures/ranks-single.tsv", __FILE__)
  average_tsv = File.expand_path("../fixtures/ranks-average.tsv", __FILE__)
  results_tsv = File.expand_path("../fixtures/results.tsv", __FILE__)
  Api.new(person_tsv, single_tsv, average_tsv, results_tsv)
end

def json_response
  JSON.parse(last_response.body)
end

def last_status
  last_response.status
end
