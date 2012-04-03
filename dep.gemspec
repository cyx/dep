Gem::Specification.new do |s|
  s.name              = "dep"
  s.version           = "1.0.1"
  s.summary           = "Dependencies manager"
  s.description       = "Specify your project's dependencies in one file."
  s.authors           = ["Cyril David", "Michel Martens"]
  s.email             = ["cyx.ucron@gmail.com", "soveran@gmail.com"]
  s.homepage          = "http://twpil.github.com/dep"
  s.files             = ["README.1", "bin/dep", "lib/dep.rb", "test/dep.rb"]

  s.executables.push("dep")
  s.add_dependency("clap", "~> 0.0.2")
end
