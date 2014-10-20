require_relative './lib/repositories'
require_relative './lib/api'
require 'csv'

task :import do
  filename = `curl --silent https://www.worldcubeassociation.org/results/misc/export.html | grep -E "WCA_export[0-9_]+\.tsv.zip" -o | head -n1`.chomp
  `mkdir -p data`
  puts "Downloading newest TSV export"
  `curl http://www.worldcubeassociation.org/results/misc/#{filename} > data/download.zip`
  `unzip -o data/download.zip -d data`

  app = WCAApi.new('redis://localhost:6379/1')
  app.reset_db!
  persons_tsv = File.expand_path("../data/WCA_export_Persons.tsv", __FILE__)
  results_tsv = File.expand_path("../data/WCA_export_Results.tsv", __FILE__)
  app.import!(persons_tsv, results_tsv)
end
