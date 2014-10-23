require 'sinatra'
require 'csv'
require 'json'
require_relative './repositories'

class WCAApi
  def initialize(redis_url)
    @redis_url = redis_url
    @redis = Redis.new(url: redis_url)
    @competitor_repo = CompetitorRepository.new(@redis)
    @record_repo = RecordRepository.new(@redis)
  end

  def measure
    t = Time.now
    yield
    p("Took: #{Time.now - t}")
  end

  def ignore
  end

  def import!(competitors_tsv, results_tsv, singles_tsv, averages_tsv)
    @redis.pipelined do
      CSV.foreach(competitors_tsv, headers: true, col_sep: "\t") do |row|
        @competitor_repo.save!({id: row["id"], sub_id: row["subid"], country: row["countryId"], gender: row["gender"], name: row["name"], })
      end
    end
    comps = Hash.new { |h, k| h[k] = Set.new }
    CSV.foreach(results_tsv, headers: true, col_sep: "\t") do |row|
      comps[row["personId"]] << row["competitionId"]
    end
    @redis.pipelined do
      comps.each do |person, comps|
        @competitor_repo.attend_comps!(person, comps.to_a)
      end
    end
    @redis.pipelined do
      CSV.foreach(singles_tsv, headers: true, col_sep: "\t") do |row|
        @competitor_repo.set_single_record!(row["personId"], row["eventId"], row["best"].to_i)
        @record_repo.add_single_record!(row["personId"], row["eventId"], row["best"].to_i)
      end
    end
    @redis.pipelined do
      CSV.foreach(averages_tsv, headers: true, col_sep: "\t") do |row|
        @competitor_repo.set_average_record!(row["personId"], row["eventId"], row["best"].to_i)
        @record_repo.add_average_record!(row["personId"], row["eventId"], row["best"].to_i)
      end
    end
  end

  def reset_db!
    redis = Redis.new(url: @redis_url)
    redis.flushdb
    redis.quit
  end

  def find_competitor(id)
    @competitor_repo.find(id)
  end

  def search_competitor(id)
    @competitor_repo.search(id)
  end

  def find_records(id)
    @competitor_repo.records(id)
  end

  def list_single_records(event_id)
    @record_repo.list_single_records(event_id).map do |pair|
      {
        competitor: @competitor_repo.find(pair.first),
        result: pair.last.to_i
      }
    end
  end

  def list_average_records(event_id)
    @record_repo.list_average_records(event_id).map do |pair|
      {
        competitor: @competitor_repo.find(pair.first),
        result: pair.last.to_i
      }
    end
  end
end

class Api < Sinatra::Base
  set :show_exceptions, true

  def initialize(core)
    @core = core
    super()
  end

  get "/competitors/:id/?" do
    id = params[:id]
    r = @core.find_competitor(id)
    generate_json({competitor: r})
  end

  get "/competitors/?" do
    result = @core.search_competitor(params[:q])
    generate_json({competitors: result})
  end

  get "/competitors/:id/records" do
    records = @core.find_records(params[:id])

    return status 404 if records.empty?

    generate_json({records: @core.find_records(params[:id])})
  end

  get "/records/:event_id/single" do
    generate_json({records: @core.list_single_records(params[:event_id])})
  end

  get "/records/:event_id/average" do
    generate_json({records: @core.list_average_records(params[:event_id])})
  end

  private
    def generate_json(hash)
      JSON.generate hash
    end
end
