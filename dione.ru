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

require 'pathname'

module ::Dione
  LIB = Pathname.new("#{File.dirname(__FILE__)}/lib")
end

$:.unshift(Dione::LIB)

Pathname.glob("#{File.dirname(__FILE__)}/lib/{core,types,middleware}/*.rb") { |f| require f.relative_path_from(Dione::LIB) }

Dione::Middleware.all.each { |m| use m }

run (lambda { |env| env['Dione.page'].call(env) })
