#$redis = Redis::Namespace.new("esasar", :redis => Redis.new)
$redis = Redis::Namespace.new("esasar", :redis => Redis.new(url: "redis://admin:FZIPUZHUETQYZPOM@sl-us-south-1-portal.7.dblayer.com:27329"))