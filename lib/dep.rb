module Dep
  class List
    attr :path

    def initialize(path = File.join(Dir.pwd, ".gems"))
      @path = path
    end

    def add(lib)
      remove(lib)
      libraries.push(lib)
    end

    def remove(lib)
      libraries.delete_if { |e| e.name == lib.name }
    end

    def libraries
      @libraries ||= File.readlines(path).map { |line| Lib[line] }
    end

    def missing_libraries
      libraries.reject(&:available?)
    end

    def save
      File.open(path, "w") do |file|
        libraries.each do |lib|
          file.puts lib.to_s
        end
      end
    end
  end

  class Lib < Struct.new(:name, :version)
    def self.[](line)
      if line =~ /^(\S+) -v (\S+)$/
        return new($1, $2)
      else
        abort("Invalid requirement found: #{line}")
      end
    end

    def available?
      Gem::Specification.find_by_name(name, version)
    rescue Gem::LoadError
      return false
    end

    def to_s
      "#{name} -v #{version}"
    end

    def ==(other)
      to_s == other.to_s
    end
  end
end