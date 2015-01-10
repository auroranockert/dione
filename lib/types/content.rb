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

require 'redcarpet'

module Dione
  module LiquidContent
    def self.render(content, document)
      Liquid::Template.parse(content).render(document)
    end
  end

  module MarkdownContent
    def self.render(content, _)
      Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(content)
    end
  end

  module RawContent
    def self.render(content, _)
      content
    end
  end

  class Content < Dione::Object
    type 'dione/content'

    def format
      self['format']
    end

    def content
      self.attachment(self['content']).content
    end

    def render(_, document)
      case format = self.format
      when 'html-fragment' then Dione::RawContent
      when 'markdown' then Dione::MarkdownContent
      when 'liquid' then Dione::LiquidContent
      else
        fail Dione::NotFound, "Content format #{format} not supported"
      end.render(self.content, document)
    end
  end
end
