# Copyright 2014 Jens Nockert
#
# Licensed under the EUPL, Version 1.1 or – as soon they will be approved by
# the European Commission - subsequent versions of the EUPL (the "Licence");
# You may not use this work except in compliance with the Licence.
# You may obtain a copy of the Licence at: https://joinup.ec.europa.eu/software/page/eupl
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the Licence is distributed on an "AS IS" basis,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the Licence for the specific language governing permissions and
# limitations under the Licence. 

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
