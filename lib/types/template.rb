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

require 'liquid'
require 'mustache'

module Dione
  class Template < Dione::Object
    type 'dione/template'

    def format
      self['format']
    end

    def parent
      if self['parent']
        self.site.reify(self['parent'])
      end
    end

    def template_text
      self.attachment(self['template']).data
    end

    def render(env, document)
      content = case self.format
      when 'liquid'
        Liquid::Template.parse(self.template_text).render(document)
      else
        fail Dione::NotFound, "Template language not implemented"
      end

      self.parent ? self.parent.render(env, document.merge('content' => content)) : content
    end
  end
end
