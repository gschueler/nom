require 'nom'
module Nom
    class CLI
        def self.start
            if ARGV.size > 0 && ARGV.include?("-rev")
                nomxml = XML.new(STDIN)
                nomxml.to_nom(STDOUT,!ARGV.include?("-nocolor"),ARGV.include?("-ns"))
            else
                nom = Nom.new(STDIN)
                nom.to_xml(STDOUT)
            end
        end
    end
end