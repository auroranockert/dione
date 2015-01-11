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
    def self.route(database, path)
      routes = database.query(:dione, :routes, key: path)

      return unless routes.length == 1

      object = routes[0]

      if attachment = object['_value']
        object.attachment(attachment)
      else
        object
      end
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      env[:dione].tap do |dione|
        dione[:page] = self.class.route(dione[:database], env['PATH_INFO'])
      end

      @app.call(env)
    end
  end
end
