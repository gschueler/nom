package nom

import (
	"bufio"
	"container/list"
	"encoding/xml"
	"fmt"
	"io"
	"strings"
	"unicode"
	"unicode/utf8"
)

const indentStr = "    "

const (
	indent = iota
)

/*
Encode nom as xml
*/
func Encode(r io.Reader, w io.Writer) (err error) {
	context, err := readNom(r)
	if nil != err {
		return err
	}

	return writeNom(context, w)
}

type element struct {
	parent       *element
	name         xml.Name
	startElement xml.StartElement
	text         *list.List
}
type context struct {
	level     int
	baselevel int
	root      *element
	current   *element
}
type nomError struct {
	err string
}

func (err nomError) Error() (str string) {
	return err.err
}

func writeNom(ctx context, w io.Writer) (err error) {
	xo := xml.NewEncoder(w)
	fmt.Println("writeNom: TODO %T", xo)
	return nil
}

// scanIndent is a split function that returns each
// sequence equal to indentStr
func scanIndent(data []byte, atEOF bool) (advance int, token []byte, err error) {
	start := 0
	width := 0
	for read := 0; width < len(data) && width < len(indentStr); width += read {
		var r rune
		r, read = utf8.DecodeRune(data[width:])
		if !unicode.IsSpace(r) {
			break
		}
	}
	if width == 0 {

		return 0, nil, nil
	}
	if width == len(indentStr) {
		return width, data[start:width], nil
	} else if width < len(indentStr) {
		return bufio.ScanWords(data, atEOF)
	}
	return 0, nil, nil
}

func readNom(r io.Reader) (ctx context, err error) {
	ctx = context{0, 0, nil, nil}
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		line := scanner.Text()

		if err = scanner.Err(); nil != err {
			return ctx, err
		}

		err = ctx.readNomLine(line)

		if nil != err {
			return ctx, err
		}
	}

	return ctx, err
}

func (ctx *context) appendText(text string) (err error) {
	if nil == ctx.current {
		return nomError{"No element to append text to"}
	}
	fmt.Println("appendText: %s", text)
	//ctx.current.text << text
	return nil
}
func createElement(parent *element, name string) (elem element) {

	xmlname := xml.Name{"", name}
	elem = element{parent, xmlname, xml.StartElement{xmlname, nil}, list.New()}
	return elem
}
func (ctx *context) appendElement(name string, level int) (err error) {
	relative := level - ctx.baselevel
	diff := relative - ctx.level
	if diff > 1 {
		return nomError{fmt.Sprintf("Element %s is indented incorrectly: %d %d %d", name, diff, ctx.level, level)}
	}
	ctx.level = relative
	fmt.Println("appendElement: ", name, diff, ctx.level)

	if diff < 0 {
		//if negative, pop from list
		for i := diff; i > 0; i-- {
			ctx.current = ctx.current.parent
		}
	}
	element := createElement(ctx.current, name)
	//insert to list
	ctx.current = &element
	if nil == ctx.root {
		ctx.root = ctx.current
	}

	return nil
}
func (ctx *context) appendAttribute(name string, value string) (err error) {
	if nil == ctx.current {
		return nomError{"No element to append text to"}
	}
	fmt.Println("appendAttribute: %s=%s", name, value)
	return nil
}

func (ctx *context) readElementAttrs(r *bufio.Reader) (err error) {
	//todo, read attributes
	line, err := r.ReadString('\n')
	fmt.Println("readElementAttrs: TODO", line)
	return nil
}
func (ctx *context) readLineAttr(r *bufio.Reader, attr string) (err error) {
	//todo, read attribute value
	line, err := r.ReadString('\n')
	fmt.Println("readLineAttrs: TODO ", attr, line)
	return nil
}

func (ctx *context) readNomLine(line string) (err error) {
	//determine indent level
	level := 0
	for strings.HasPrefix(line, indentStr) {
		level++
		line = strings.TrimPrefix(line, indentStr)
	}
	if strings.HasPrefix(line, " ") {
		//trim any whitespace
		line = strings.TrimLeftFunc(line, unicode.IsSpace)
	}

	//level determines context of subsequent data
	//end element

	//determine next read
	if len(strings.TrimFunc(line, unicode.IsSpace)) == 0 {
		return nil
	} else if strings.HasPrefix(line, ":") {
		//line text
		line = strings.TrimLeft(line, ":")
		ctx.appendText(line)
	} else if strings.HasPrefix(line, "@") {
		//line attribute
		line = strings.TrimLeft(line, "@")
		lr := bufio.NewReader(strings.NewReader(line))

		elem, err := lr.ReadString(' ')
		if nil != err {
			return err
		}
		//todo read attribute value
		err = ctx.readLineAttr(lr, elem)
	} else {
		//line element start
		fmt.Println("Before append ", ctx.level)
		if strings.Contains(line, " ") {
			lr := bufio.NewReader(strings.NewReader(line))
			elem, err := lr.ReadString(' ')
			if nil != err {
				return err
			}

			err = ctx.appendElement(elem, level)
			if nil != err {
				return err
			}
			err = ctx.readElementAttrs(lr)
		} else {
			err = ctx.appendElement(line, level)
			if nil != err {
				return err
			}
		}
		fmt.Println("After append ", ctx.level)
	}
	return err
}
