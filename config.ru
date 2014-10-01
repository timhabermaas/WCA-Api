require "./lib/api"

person_tsv = File.expand_path("../WCA_export_Persons.tsv", __FILE__)
single_tsv = File.expand_path("../WCA_export_RanksSingle.tsv", __FILE__)
average_tsv = File.expand_path("../WCA_export_RanksAverage.tsv", __FILE__)

run Api.new(person_tsv, single_tsv, average_tsv)
