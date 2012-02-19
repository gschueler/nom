# nom

nom is "no markup" or XML without the cursing.

(aka Markdown for XML)

If you *must* produce XML, nom is meant to be the easiest way to write it by hand.

Beta to see how useful it is.

# what

Write XML documents in a simpler form and then convert them to XML.

Structure is created by indentation, not angle brackets. Increases clarity, reduces noise.

input: 

    a
        b
            c

output:

    <a>
      <b>
        <c></c>
      </b>
    </a>


Attributes can be specified on the same line as the element name, or on their own line, and can be prefixed with '@':

    a this=that
        @that something else
        those=another thing

yields:
    
    <a this='that' that='something else' those='another thing'></a>

Text content can be on the same line, as long as it doesn't contain `attribute=value`

    a This is all it <looks like>

yields:

    <a>This is all it &lt;looks like&gt;</a>

Text can be on separate lines, just use a colon at the start, and indentation doesn't matter:

    a
        b
    :text inside b
        :more text inside b

yields:
    
    <a>
      <b>text inside b
    more text inside b</b>
    </a>

# why

Not sure I need to justify this. Try writing XML by hand.  Try writing nom.

# why not yaml

Yaml and XML don't quite map to each other (see [yaxml](http://yaml.org/xml.html)).  XML has attributes as well as subelements, and can have multiple elements of the same name in the same context. We also want a simple way of expressing textual content, as well as comments.  Yaml is great for expressing structured data, but not great for mapping to XML, nor particularly for writing by hand.

# syntax detail

Empty lines are ignored.

## elements

    element(:)? [attr=value]+ | <text>

Each element is indented by some multiple of 4 space characters, X. If X is greater than the previous line's indentation, this line is a sub element of the previous element.  If X is less than the previous line's indentation, this element is a sub element of next higher element that has a lower indentation.

If the remaining text on the line contains any text like "attribute=value", then these are treated as attributes, and values can be quoted or not, and may contain spaces.

Otherwise the remaining text is treated as text content of the element.

A comment may be added on the same line as an element.

If there is a single top-level element, it is used as the document root element.

If there are multiple top-level elements, they are made subordinate to a default root element.  Currently the default root element is named "root", but this should be an input option.

## Attributes

    @attribute <value>
    @attribute=<value>
    attribute=<value>

Attributes are added to the previous element, no matter the indentation. If you use the `@` sign you do not need an equals sign at the end of the attribute name.

## Comment

    #<text>

Comments can be at any indentation.

If you use two hash charaters, the comment is included as an XML comment in the output:

    ##<xml comment>

## Text content

Either use the `element <text>` format, or specify text on its own line:

    :<text>

Text content is added to the previous element, no matter the indentation.


# Examples

nom:

    script:
    
        @author Greg Schueler
        @date 2/15/2012
        
        title: nom: the story of nom
        
        subtitle: just trying to clean up the world, one bit at a time
        
        scene:  number=1 act=1
        
            setting: type=interior lighting=dark air=hazy

            dialog
                voiceover
                    :Somewhere, on the internet...
            
                speaker name=Greg
                    :What is wrong with the world? Why it so fugly?
                
                speaker name=Anthony
                    :I don't know, Greg. What is your problem?
                    
                speaker name=Greg
                    :I'd like to mock up an XML document in a reasonable way.
                    :But I'd really love not to use the full syntax.
                
            cut-to
                image A lightbulb lighting up.
                                        
            montage style=1980s
                : A man hacks at a keyboard into the wee hours of the night.

            cut-to
                close-up A neon green font on a black terminal screen.
                    : The text says "git push origin master"
            
            cut-to
                close-up A keyboard.
                    : A finger pushes the enter key.
            
            titles: Teh end...

xml:

    <script author='Greg Schueler' date='2/15/2012'>
      <title>nom: the story of nom</title>
      <subtitle>just trying to clean up the world, one bit at a time</subtitle>
      <scene number='1' act='1'>
        <setting type='interior' lighting='dark' air='hazy'></setting>
        <dialog>
          <voiceover>Somewhere, on the internet...</voiceover>
          <speaker name='Greg'>What is wrong with the world? Why it so fugly?</speaker>
          <speaker name='Anthony'>I don't know, Greg. What is your problem?</speaker>
          <speaker name='Greg'>I'd like to mock up an XML document in a reasonable way.
    But I'd really love not to use the full syntax.</speaker>
        </dialog>
        <cut-to>
          <image>A lightbulb lighting up.</image>
        </cut-to>
        <montage style='1980s'> A man hacks at a keyboard into the wee hours of the night.</montage>
        <cut-to>
          <close-up>A neon green font on a black terminal screen.
     The text says "git push origin master"</close-up>
        </cut-to>
        <cut-to>
          <close-up>A keyboard.
     A finger pushes the enter key.</close-up>
        </cut-to>
        <titles>Teh end...</titles>
      </scene>
    </script>

# Usage

    groovy nom.groovy [-rev] < file > out
    ruby nom.rb < file > out

Normal usage takes nom input and produces XML.

Specifying `-rev` will convert XML to nom.

# TODO

* add a reverser to get nom from XML
    * add to groovy impl (done)
    * add to ruby impl
* config options
* ...profit?
