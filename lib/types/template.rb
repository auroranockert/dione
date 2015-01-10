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

require 'liquid'
require 'mustache'

module Dione
  module LiquidTemplate
    def self.render(template, document)
      Liquid::Template.parse(template, error_mode: :strict).render(document)
    end
  end

  class Template < Dione::Object
    type 'dione/template'

    def format
      self['format']
    end

    def template_parent
      parent = self['parent']

      self.database.reify(parent) if parent
    end

    def template_text
      self.attachment(self['template']).content
    end

    def render(env, document)
      content = case format = self.format
      when 'liquid' then Dione::LiquidTemplate
      else
        fail Dione::NotFound, "Template language `#{format}` not implemented"
      end.render(self.template_text, document)

      if parent = self.template_parent
        parent.render(env, document.merge('content' => content))
      else
        content
      end
    end
  end
end
