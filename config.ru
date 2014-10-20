require "./lib/api"

single_tsv = File.expand_path("../data/WCA_export_RanksSingle.tsv", __FILE__)
average_tsv = File.expand_path("../data/WCA_export_RanksAverage.tsv", __FILE__)
results_tsv = File.expand_path("../data/WCA_export_Results.tsv", __FILE__)

core = WCAApi.new("redis://localhost:6379/1")
run Api.new(single_tsv, average_tsv, results_tsv, core)
