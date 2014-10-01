require 'sinatra'
require 'csv'
require 'json'

class Api < Sinatra::Base
  set :show_exceptions, true

  def initialize(person_tsv, single_tsv, average_tsv, results_tsv)
    @competitors = load_array_from_csv(person_tsv)
    @single_results = load_array_from_csv(single_tsv)
    @average_results = load_array_from_csv(average_tsv)
    @competitions = Hash.new { |h, k| h[k] = Set.new }
    load_from_csv(results_tsv) do |row|
      @competitions[row[7]] << row[0]
    end

    super()
  end

  get "/competitors/:id/?" do
    id = params[:id]
    result = @competitors.find { |p| p[0] == id }
    result = result + [@competitions[id].size]
    JSON.generate({person: hashify_person(result)})
  end

  get "/competitors/?" do
    q = params[:q]
    result = @competitors.select { |p| p[0].start_with?(q) }.map { |p| hashify_person(p) }
    JSON.generate({competitors: result})
  end

  get "/competitors/:id/records" do
    singles = @single_results.select { |r| r[0] == params[:id] }.map { |r| hashify_record(r) }

    return status 404 if singles.empty?

    averages = @average_results.select { |r| r[0] == params[:id] }.map { |r| hashify_record(r) }
    temp = Hash.new { |h, k| h[k] = {} }
    singles.group_by { |r| r[:eventId] }.each do |event, times|
      temp[event][:single] = times.first[:time]
    end
    averages.group_by { |r| r[:eventId] }.each do |event, times|
      temp[event][:average] = times.first[:time]
    end
    JSON.generate({records: temp})
  end

  private
    def hashify_record(record)
      {
        eventId: record[1],
        time: record[2].to_i,
      }
    end

    def hashify_person(person)
      {
        id: person[0],
        name: person[2],
        country: person[3],
        gender: person[4],
        competition_count: person[5],
      }
    end

    def load_from_csv(file)
      CSV.foreach(file, col_sep: "\t") do |row|
        yield row
      end
    end

    def load_array_from_csv(file)
      result = []
      load_from_csv(file) do |row|
        result << row
      end
      result.shift
      result
    end
end
