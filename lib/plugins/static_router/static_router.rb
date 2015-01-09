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
  class StaticRouter
    def initialize(app, configuration)
      @app = app
    end

    def call(env)
      routes = env[:dione][:database].view(:dione, :routes, key: env['PATH_INFO'])['rows']

      if routes.length == 1
        route = routes.first['value']

        object = env[:dione][:database].reify('id' => route.first)

        env[:dione][:page] = if attachment = route[1]
          object.attachment(attachment)
        else
          object
        end
      end

      @app.call(env)
    end
  end
end

Dione.register_plugin(Dione::StaticRouter)
