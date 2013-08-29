package xml

import (
	"encoding/xml"
    "io"
    "fmt"
    "regexp"
)
const  indentStr = "   "
var blankRegex *regexp.Regexp

func init(){

    blankRegex = regexp.MustCompile(`^\s+$`)
}

func writeIndent(w io.Writer, x int) {
    for i:=0;i<x;i++ {
        w.Write([]byte(indentStr))
    }
}

func writeAttrs(w io.Writer, attrs []xml.Attr, indent int)( err error) {
    for _,a := range attrs  {
        //TODO: separate line if value contains "="
        // writeIndent(w,indent)
         _,err = w.Write([]byte(fmt.Sprintf("%s=%s ",nameString(a.Name),a.Value)))
        if err!=nil {
            return
        }
    }
    return
}

func nameString(t1 xml.Name) (s string){
    if t1.Space=="" {
        s= t1.Local
    }else {
        s= fmt.Sprintf("%s:%s",t1.Space,t1.Local)
    }
    return
}

func decodeToNom(d *xml.Decoder, w io.Writer) (err error){
    t,err := d.Token()
    indent :=0
    for ; err==nil;  {
        switch t1 := t.(type) {
         case xml.CharData:
            if !blankRegex.MatchString(string(t1)) {
                 writeIndent(w,indent)
                 _,err = w.Write([]byte(fmt.Sprintf("'%s'\n",t)))
            }
         case xml.Comment:
             writeIndent(w,indent)
             _,err = w.Write([]byte(fmt.Sprintf("#%s\n",t)))
         case xml.Directive:
         case xml.ProcInst:
         case xml.StartElement:
             writeIndent(w,indent)
             _,err = w.Write([]byte(fmt.Sprintf("%s",nameString(t1.Name))))
            if err!=nil {
                return
            }
            //write attributes
            if len(t1.Attr)>0 {
                _,err = w.Write([]byte(" "))
                err = writeAttrs(w,t1.Attr,indent)
            }
            _,err = w.Write([]byte("\n"))

             indent++
             
         case xml.EndElement:
             indent--
        }
        if err!=nil {
            return
        }
        // n,err := w.Write(fmt.Sprintf("%s\n",t.Name))
        t,err = d.Token()

    }
    return
}

func Decode(r io.Reader, w io.Writer) (err error){
    //tokenize input xml
    d := xml.NewDecoder(r)
    //write as nom to writer
    err = decodeToNom(d,w)
    return
}