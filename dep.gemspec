Gem::Specification.new do |s|
  s.name              = "dep"
  s.version           = "0.0.2"
  s.summary           = "Dependencies manager"
  s.description       = "Specify your project's dependencies in one file."
  s.authors           = ["Cyril David", "Michel Martens"]
  s.email             = ["cyx.ucron@gmail.com", "soveran@gmail.com"]
  s.homepage          = "http://github.com/twpil/dep"
  s.files             = ["README", "bin/dep", "lib/dep.rb", "test/dep.rb"]

  s.executables.push("dep")
  s.add_dependency("clap")
end
