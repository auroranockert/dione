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
  class AttachmentHandler < Dione::Middleware
    priority 20

    def initialize(app)
      @app = app
    end

    def call(env)
      if attachment = env['Dione.attachment']
        [200, { 'Content-Type' => attachment.content_type }, StringIO.new(attachment.data)]
      else
        @app.call(env)
      end
    end
  end
end
