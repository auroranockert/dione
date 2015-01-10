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

module Dione
  class StaticRouter
    def initialize(app)
      @app = app
    end

    def route(database, path)
      routes = database.view(:dione, :routes, key: path)['rows']

      yield routes.first['value'] if routes.length == 1
    end

    def call(env)
      database = env[:dione][:database]

      self.route(database, env['PATH_INFO']) do |route|
        object = database.reify('id' => route[0])

        env[:dione][:page] = if route.length > 1
          object.attachment(route[1])
        else
          object
        end
      end

      @app.call(env)
    end
  end
end
