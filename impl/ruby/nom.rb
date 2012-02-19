require 'strscan'
require 'rexml/document'

module Nom
class Nom
    @@istr = "    "
    @rparent
    def initialize(io)
        @rparent={:subs => [], :indent => -1,:text => [],:attrs => {},:comments => []}
        
        #todo guess at contents xml or nom
        parse_nom(io)
    end
    def parse_nom(io)
        ctx=[]
        indent=0
        #@rparent={:subs => [], :indent => -1,:text => [],:attrs => {},:comments => []}
        parent=@rparent
        last=parent
        io.each do |line|
            nindent=0
            line.chomp!
            #puts(line)
            s = StringScanner.new(line)
            while s.scan(/    /) != nil
                nindent+=1
            end
            elem={:subs => [], :indent => nindent, :text => [], :attrs=>{}, :comments => []}
            rindent=nindent - indent
            
            if em=s.scan(/\s{0,3}(\w[\w:_\.-]*?)[:]?(\s+|$)/)
                elem[:tag] = s[1]
                #puts "tag: #{s[1]}"
                rest = s.scan(/[^#]+/)
                if rest != nil
                    elem[:attrtext]=rest
                    attrs={}
                    expectq=nil
                    lastatt=nil
                    rest.split(/ /).each do |tok|
                        a,val = tok.split(/=/,2)
                        if !expectq && a && val
                            if val.size>1 && val[0]==val[-1] && (val[0]=='"'[0] || val[0]=="'"[0])
                                val=val[1..-2]
                            elsif val[0]=='"'[0] || val[0]=="'"[0]
                                expectq=val[0]
                                val=val[1..-1]
                            end
                            attrs[a]=val
                            lastatt=a
                        elsif lastatt
                            attrs[lastatt]<<' '
                            if expectq && tok[-1]==expectq
                                attrs[lastatt]<<tok[0..-2]
                                expectq=nil
                            else
                                attrs[lastatt]<<tok
                            end
                        end
                    end
                    if attrs.size<1
                        elem[:text]<<rest
                    else
                        elem[:attrs].merge!(attrs)
                    end
                end
                if s.post_match != nil
                    elem[:comments]<<s.post_match
                end
                #puts elem.to_a
            elsif s.scan(/\s{0,3}(##?.+)$/)
                if s[1][0]==s[1][1] && s[1][1]=='#'[0]
                    last[:comments]<<s[1]
                end
                next
            elsif s.scan(/\s{0,3}@?(\w[\w:_\.-]*)(=\s*|\s+|$)/)
                mattr=s[1]
                rest = s.scan(/[^#]+/)
                if rest != nil
                    last[:attrs][mattr]=rest.chomp
                end
                if s.post_match != nil
                    last[:comments]<<s.post_match.chomp
                end
                
                #puts "attrs #{last[:tag]}: #{last[:attrs].inspect}"
                next
            elsif s.scan(/\s{0,3}:(.*)?$/)
                last[:text]<<s[1]                
                next
            elsif s.post_match && s.post_match.strip != ""
                last[:text]<<s.post_match
                next
            else
                next
            end
            
            if rindent < 0
                #puts "#{rindent} (#{nindent} - #{last[:indent]}): #{elem[:tag]}"
                while nindent <= indent
                    if ctx.size > 0
                        parent = ctx.pop
                        last=parent
                        indent=parent[:indent]
                        #puts "pop #{parent[:tag]}"
                    else
                        indent=0
                        parent=@rparent
                        break
                    
                    end
                end
                ctx << parent
                #puts "popped to #{parent[:tag]}"
            elsif rindent > 0
                #puts "#{rindent}: #{elem[:tag]}"
                parent=last
                ctx<<last
            end
            parent[:subs] << elem
            indent=nindent
            last=elem
        end
        if @rparent[:subs].size == 1
            @rparent = @rparent[:subs][0]
        else
            @rparent[:tag] = "root"
        end
    end
    
    def to_xml(io)
        doc = REXML::Document.new        
        render_xml(@rparent,doc).write(io,2)
        io.puts
    end
    def render_xml(obj,doc)
        elem=REXML::Element.new(obj[:tag])
        if obj[:text].size > 0 
            elem.text=obj[:text].join("\n")
        end

        obj[:comments].each do |comment|
            comment.scan(/^##(.*)$/){ |m|
                elem << REXML::Comment.new(m[0])
            }
        end

        if obj[:attrs]
            elem.add_attributes(obj[:attrs])
        end
        obj[:subs].each do |sub|
            render_xml(sub,elem)
        end
        doc<<elem
        doc
    end
end
end

nom = Nom::Nom.new(STDIN)
nom.to_xml(STDOUT)