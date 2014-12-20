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
  class Attachment
    def initialize(object, name)
      @object, @name = object, name
    end

    def metadata
      @metadata ||= @object.document['attachments'][@name].merge(@object.document['_attachments'][@name])
    end

    def data
      @object.site.database.fetch_attachment(@object.document, @name)
    end

    def content_type
      self.metadata['content_type']
    end
  end
end
