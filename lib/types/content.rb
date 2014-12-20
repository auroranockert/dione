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

require 'redcarpet'

module Dione
  class Content < Dione::Object
    type 'dione/content'

    def format
      self['format']
    end

    def content
      self.attachment(self['content']).data
    end

    def render(_, document)
      case self.format
      when 'html-fragment'
        self.content
      when 'markdown'
        Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(self.content)
      when 'liquid'
        Liquid::Template.parse(self.content).render(document)
      else
        fail Dione::NotFound, "Content format #{self.format} not supported"
      end
    end
  end
end
