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
  class Globals
    def initialize(app, ids)
      @app, @ids = app, ids
    end

    def call(env)
      dione = env[:dione]

      globals = dione[:globals] || {}

      @ids.each do |key, id|
        globals[key] = dione[:database].reify('id' => id)
      end

      dione[:globals] = globals

      @app.call(env)
    end
  end
end
