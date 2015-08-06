before_session = Proc.new do |out, target, _pry_|
  Dir["**/lib/**/*.rb"].each do |path|
    $: << path unless !File.exist?(path) || $:.include?(path)
  end
end
Pry.config.hooks.add_hook(:before_session, before_session) do
  puts "Welcome to active_nutrition pry session"
end
