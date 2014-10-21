require "./lib/api"

core = WCAApi.new("redis://redis/1")
run Api.new(core)
