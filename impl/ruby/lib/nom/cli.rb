require 'nom'
module Nom
    class CLI
        def self.start
            if ARGV.size > 0 && ARGV[0]=="-rev"
                nomxml = XML.new(STDIN)
                nomxml.to_nom(STDOUT)
            else
                nom = Nom.new(STDIN)
                nom.to_xml(STDOUT)
            end
        end
    end
end