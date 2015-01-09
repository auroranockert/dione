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

module Dione
  class NotFound < StandardError; end

  class DioneHandler
    def initialize(app, configuration)
      @app, @configuration = app, configuration

      @database = Dione::Database.new(@configuration['database'])
    end

    def call(env)
      env[:dione] = {
        configuration: @configuration,
        database: @database,
        site: @database.reify('id' => @configuration['site'])
      }

      @app.call(env)
    rescue Dione::NotFound
      [404, { 'Content-Type' => 'text/plain' }, StringIO.new("Sorry, could not be found")]
    end
  end
end
