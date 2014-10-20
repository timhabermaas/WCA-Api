require 'redis'
require 'json'

class CompetitorRepository
  def initialize(redis_url)
    @redis = Redis.new(url: redis_url)
  end

  def save!(competitor)
    id = competitor[:id]
    @redis.set("competitors:#{id}", competitor.to_json)

    id.size.times do |i|
      @redis.zadd("competitors:search:#{id[0..i]}", 0, id)
    end
  end

  def attend_comp!(id, comp_id)
    @redis.sadd("competitors:#{id}:comp_ids", comp_id)
  end

  def find(id)
    JSON.parse(@redis.get("competitors:#{id}")).tap do |c|
      c["competition_count"] = @redis.scard("competitors:#{id}:comp_ids")
    end
  end

  def search(id)
    ids = @redis.zrange("competitors:search:#{id}", 0, -1)
    ids.map do |id|
      find(id)
    end
  end
end
