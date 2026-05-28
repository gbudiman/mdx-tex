# frozen_string_literal: true

module MdxTex
  module CoreExt
    module String
      def to_textile(**options)
        MdxTex.to_textile(markdown: self, **options)
      end

      def to_markdown
        MdxTex.to_markdown(textile: self)
      end
    end
  end
end

String.include(MdxTex::CoreExt::String)
