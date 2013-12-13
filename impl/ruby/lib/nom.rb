require 'strscan'
require 'rexml/document'
require 'colorize'

# @author Greg Schueler
module Nom

# Handles converting Nom input to XML
class Nom
    @@istr = "    "
    def Nom.istr
        @@istr
    end
    @rparent

    # Create a new object
    # @param [IO] input IO stream
    def initialize(io)
        @rparent={:subs => [], :indent => -1,:text => [],:attrs => {},:comments => []}
        
        #todo guess at contents xml or nom
        parse_nom(io)
    end

    # Parse the input text
    # @param [IO] input IO stream
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
                        a,val = tok.split('=',2)
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
    
    # Write the XML to a stream
    # @param [IO] Output IO stream
    def to_xml(io)
        doc = REXML::Document.new        
        render_xml(@rparent,doc).write(io,2)
        io.puts
    end

    # Convert the parsed Nom data to XML
    # @param [Hash] Nom data structure
    # @param [REXML::Document] Document to add XML data to
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

# Handles converting XML input to Nom
class XML
    @doc

    # Create a new object from XML input
    # @param [IO] Input XML IO stream
    def initialize(io)
        @doc=parse_xml(io)
    end

    # Parse the XML input
    # @param [IO] Input XML IO stream
    def parse_xml(io)
        REXML::Document.new(io)
    end

    # Write Nom text to an IO stream
    # @param [IO] Output IO stream
    def to_nom(io,color=false)
        ns = {}
        @doc.root.namespaces.each {|k,v| ns[v]=k }
        io<<"# nom\n"
        render_nom(@doc.root,0,ns,io,color)
    end

    # Return whether the XML input was valid
    # @return [Boolean] true if XML was parseable
    def valid?
        nil!=@doc
    end
    def color(str,color,docolor=false)
        if docolor
            str.colorize(color)
        else
            str
        end
    end

    # Write Nom to IO stream
    # @param [REXML::Element] Element to render
    # @param [int] Indent level
    # @param [{String => String}] Namespace definitions
    # @param [IO] Output IO stream
    def render_nom(elem,indent,ns,io,color=false)
        pref=Nom.istr * indent
        io<<pref
        name=elem.name
        nameout=name
        if elem.namespace != "" && ns[elem.namespace] != "xmlns"
            nameout=ns[elem.namespace]
            nameout+=":"
            nameout+=name
        end
        io<<self.color(nameout,:blue,color)
        nlines=[]
        elem.attributes.each do |k,v|
            if v.include?(" ")
                nlines<< "#{Nom.istr}@"+self.color(k,:green,color)+" "+self.color(v,:red,color)
            else
                io<<" "+self.color(k+"",:green,color)+"="+self.color(v+"",:red,color)
            end
        end
        nline=nil
        if elem.text
            elem.text.each_line do |line|
                line.chomp!
                line.strip!
                if line!=""
                    if !nline && !line.include?("=")
                        nline=line.chomp
                    else
                        nlines<<"#{Nom.istr}:#{line.chomp}"
                    end
                end
            end
            if nline
                io<<" #{nline}"
            end
        end
        io<<"\n"
        nlines.each do |line|
            io<<pref
            io<<line
            io<<"\n"
        end
        elem.elements.each do |el|
            render_nom(el,indent+1,ns,io,color)
        end
    end
end
end

