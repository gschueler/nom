# noml

noml is "no XML" or XML without the cursing.

(aka Markdown for XML)

If you *must* produce XML, noml is meant to be the easiest way to do it.

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


Attributes can be specified on the same line as the element name, or on their own line prefixed with '@':

    a this=that
        @that something else

yields:

    <a this='that' that='something else'></a>

Text content can be on the same line, as long as it doesn't look like attribute=value

    a This is all it <looks like>

yields:

    <a>This is all it &lt;looks like&gt;</a>

Text can be on separate lines, just use a colon at the start, an indentation doesn't matter:

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

No need to justify this, but in a basic example document, here are the line counts, and counts of useless characters:

* Noml document
    * non-blank linecount: 135
    * extraneous characters: 2 (separate line attributes)
    * readability: clear

* XML produced:
    * non-blank line count: 196
    * extraneous bracket characters: 252*2 = 504
    * extraneous close tags: 126 (1792 characters)
    * total extraneous characters: 2044
    * readability: fugly

# why not yaml

Yaml and XML don't quite map to each other (see [yaxml](http://yaml.org/xml.html)).  XML has attributes as well as subelements, and can have multiple elements of the same name in the same context. We also want a simple way of expressing textual content, as well as comments.  Yaml is great for expressing structured data, but not great for mapping to XML.

If you *must* produce XML, noml is meant to be the easiest way to do it.

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

    @attribute(:)? <value>

Attributes are added to the previous element, no matter the indentation.

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

# Usage

    groovy noml.groovy [-rev] < file > out

Normal usage inputs noml and produces XML.

Specifying `-rev` will convert XML to noml.

# TODO

* add a reverser to get noml from XML (done)
* config options
* ...profit?