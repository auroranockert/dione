require 'redcarpet'

module Dione
  class Content < Dione::Object
    type 'dione/content'

    def format
      self.document['format']
    end

    def content
      self.attachment(self.document['content']).data
    end

    def safe_proxy
      ContentProxy.new(self)
    end

    def to_template
      case self.format
      when 'html-fragment'
        self.document['content']
      when 'markdown'
        Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(self.content)
      else
        fail Dione::NotFound, "Content format #{self.format} not supported"
      end
    end
  end
end
