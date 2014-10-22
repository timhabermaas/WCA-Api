require 'sinatra'
require 'csv'
require 'json'
require_relative './repositories'

class WCAApi
  def initialize(redis_url)
    @redis_url = redis_url
    @competitor_repo = CompetitorRepository.new(redis_url)
  end

  def import!(competitors_tsv, results_tsv, singles_tsv, averages_tsv)
    CSV.foreach(competitors_tsv, headers: true, col_sep: "\t") do |row|
      @competitor_repo.save!({id: row["id"], sub_id: row["subid"], country: row["countryId"], gender: row["gender"], name: row["name"], })
    end
    CSV.foreach(results_tsv, headers: true, col_sep: "\t") do |row|
      @competitor_repo.attend_comp!(row["personId"], row["competitionId"])
    end
    CSV.foreach(singles_tsv, headers: true, col_sep: "\t") do |row|
      @competitor_repo.set_single_record!(row["personId"], row["eventId"], row["best"])
    end
    CSV.foreach(averages_tsv, headers: true, col_sep: "\t") do |row|
      @competitor_repo.set_average_record!(row["personId"], row["eventId"], row["best"])
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

  private
    def generate_json(hash)
      JSON.generate hash
    end
end
