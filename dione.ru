$:.unshift("#{File.dirname(__FILE__)}/lib")

Dir.glob('core/*.rb') { |f| require f }
Dir.glob('types/*.rb') { |f| require f }
Dir.glob('middleware/*.rb') { |f| require f }

Dione::Middleware.all.each { |m| use m }

run (lambda do |env|
  case page = Dione::Site.route(env)
  when Dione::Attachment
    [200, { 'Content-Type' => page.content_type }, StringIO.new(page.data)]
  when Dione::Object
    page.call(env)
  else
    fail Dione::NotFound, "There's no route for #{env['PATH_INFO']} configured."
  end
end)
