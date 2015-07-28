require 'nom'
module Nom
    class CLI
        def self.start
            if ARGV.size > 0 && ARGV.include?("-rev")
                to_nom
            else
                to_xml
            end
        end
        def self.to_nom
          nomxml = XML.new(STDIN)
          nomxml.to_nom(STDOUT,!ARGV.include?("-nocolor"),ARGV.include?("-ns"))
        end
        def self.to_xml
          nom = Nom.new(STDIN)
          nom.to_xml(STDOUT)
        end
    end
end
