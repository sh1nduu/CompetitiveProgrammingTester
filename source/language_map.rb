module LanguageMap
  module_function

  class Language
    def initialize(filename)
      @filename = filename
      @basename = File.basename(filename, '.*')
    end
  end

  class Cpp14 < Language
    def compile
      "g++ #{@filename} -o ./#{@basename} -std=c++14"
    end

    def execute
      "./#{@basename}"
    end
  end

  def get(lang, filename)
    case lang
    when 'c++14'
      Cpp14.new(filename)
    end
  end
end
