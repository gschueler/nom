Gem::Specification.new do |s|
  s.name = %q{nom}
  s.description = %q{nom provides an easy way to view and write XML}
  s.version = "0.0.1"
  s.date = %q{2012-05-12}
  s.summary = %q{nom is no markup XML}
  s.authors=["Greg Schueler"]
  s.email=%q{greg.schueler@gmail.com}
  s.homepage=%q{https://github.com/gschueler/nom}
  s.files = [
    "lib/nom.rb",
    "lib/nom/cli.rb"
  ]
  s.requirements << 'colorize'
  s.executables << 'nom'
  s.require_paths = ["lib"]
end