require "./lib/api"

core = WCAApi.new("redis://localhost:6379/1")
run Api.new(core)
