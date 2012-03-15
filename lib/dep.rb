module Dep
  class List
    attr :path

    def initialize(path = File.join(Dir.pwd, ".gems"))
      @path = path
    end

    def add(lib)
      abort("%s already exists" % lib.name) if exist?(lib)

      libraries.push(lib)
    end

    def find(name)
      libraries.detect { |e| e.name == name }
    end

    def exist?(lib)
      libraries.any? { |e| e.name == lib.name }
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

    def dependencies
      Utils.dependencies(self)
    end

    # For use with Gem::Specification and resolving dependencies
    def fullname
      "#{name}-#{version}"
    end

    def ==(other)
      to_s == other.to_s
    end
  end

  module Utils
    def self.dependencies(lib)
      locked = {}

      pending = [lib.fullname]

      until pending.empty? do
        fullname = pending.shift

        spec = Gem::Specification.load(spec_path(fullname))

        next if spec.nil?

        locked[spec.name] = Dep::Lib.new(spec.name, spec.version.to_s)

        spec.runtime_dependencies.each do |dep|
          next if locked[dep.name]

          candidates = dep.matching_specs

          if not candidates.empty?
            pending << candidates.last.full_name
          end
        end
      end

      return locked.values
    end

    def self.spec_path(fullname)
      gemspecs = Gem.path.map do |path|
        File.join(path, "specifications", "%s.gemspec" % fullname)
      end

      gemspecs.detect { |specpath| File.exist?(specpath) }
    end
  end
end
