require 'liquid'
require 'mustache'

module Dione
  class Template < Dione::Object
    type 'dione/template'

    def format
      self.document['format']
    end

    def parent
      if self.document['parent']
        self.site.reify(self.document['parent'])
      end
    end

    def template_text
      self.attachment(self.document['template']).data
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
