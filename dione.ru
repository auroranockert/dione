# Copyright 2014 Jens Nockert
#
# Licensed under the EUPL, Version 1.1 or – as soon they will be approved by
# the European Commission - subsequent versions of the EUPL (the "Licence"); You
# may not use this work except in compliance with the Licence. You may obtain a
# copy of the Licence at: https://joinup.ec.europa.eu/software/page/eupl
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the Licence is distributed on an "AS IS" basis, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# Licence for the specific language governing permissions and limitations under
# the Licence.

require 'simplecov'

SimpleCov.start 'rails'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")

require 'dione'

configuration = Dione.configuration

use Dione::DioneHandler, configuration

Dione.configuration['middleware'].each do |middleware|
  # Eval here isn't bad, if you can change the config you can also change the
  # actual code, so we're just going to ignore it for now.
  # rubocop:disable Lint/Eval
  use eval(middleware)
  # rubocop:enable Lint/Eval
end

app = lambda do |env|
  if page = env[:dione][:page]
    page.call(env)
  else
    fail Dione::NotFound
  end
end

run app
