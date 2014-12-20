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
  class RoutingHandler < Dione::Middleware
    priority 10

    def initialize(app)
      @app = app
    end

    def route(env)
    end

    def call(env)
      env['Dione.site'] = Dione::Site.new(ENV['DIONE_DATABASE'])

      routes = env['Dione.site'].database.view('dione/routes', key: env['PATH_INFO'])["rows"].map { |x| x['value'] }

      case routes.length
      when 0
        fail Dione::NotFound, "No route found for path #{env['PATH_INFO']}"
      when 1
        env['Dione.route'] = routes.first
        env['Dione.page'] = env['Dione.site'].reify('id' => env['Dione.route'][0])

        if attachment = env['Dione.route'][1]
          env['Dione.attachment'] = env['Dione.page'].attachment(attachment)
        end

        @app.call(env)
      else
        fail Dione::NotFound, "Multiple routes found for path #{env['PATH_INFO']}"
      end
    end
  end
end
