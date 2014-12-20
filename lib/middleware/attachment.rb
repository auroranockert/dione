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
        body = case env['REQUEST_METHOD']
        when 'GET'
          StringIO.new(attachment.data)
        when 'HEAD'
          StringIO.new('')
        else
          return [405, { 'Allow' => 'GET, HEAD' }, StringIO.new('')]
        end

        [200, { 'Content-Type' => attachment.content_type, 'Content-Length' => attachment.content_length.to_s }, body]
      else
        @app.call(env)
      end
    end
  end
end
