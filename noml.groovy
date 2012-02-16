#!/usr/bin/env groovy
//@Grab(group='dom4j', module='dom4j', version='1.6.1')
//import 
import groovy.xml.MarkupBuilder
import org.custommonkey.xmlunit.*


public class DoNoml{
    def List mylist=[]  
    def indent=0
    def istr='    '
    public noml(){
    
    }
    public void processArgs(args){
    
    }
    public void process(){
        parseInput(System.in)
    }
    
    public parseInput(input){
        def ctx=[]
        def rparent=[subs:[],indent:-1,text:[],attrs:[:]]
        def parent=rparent
        def last=parent
        input.eachLine{ line->
            def nindent=0
            while(line.startsWith(istr)){
                nindent++
                line=line.substring(istr.size())
            }
            //current indent
            def rindent=(nindent-last.indent)
            
            def m=(line=~/^(\w[\w:_\.-]+?)([:]?\s+(.*))?$/)
            def mt=(line=~/^:(.*)?$/)
            def mc=(line=~/^#(.*)?$/)
            def ma=(line=~/^@(\w[\w:_\.-]+?)([:]?\s+(.*))$/)
            def elem=[subs:[],indent:nindent,text:[],attrs:[:]]
            if(m.matches()){
                elem.tag=m.group(1)
                if(m.groupCount()>2 && m.group(3)){
                    elem.attrtext=m.group(3)
                }
            }else if(mt.matches()){
                last.text<<mt.group(1)
                return
            }else if(mc.matches()){
                //comment
                return
            }else if(ma.matches()){
                //attribute
                if(ma.groupCount()>2){
                    last.attrs[ma.group(1)]=ma.group(3)
                }
                return
            }else if(line.trim()){
                last.text<<line
                return
            }else{
               return
            }
//              System.out.println("indent: ${indent}, nindent: ${nindent}, line: ${elem}")
            if(rindent<0){
//                System.out.println("nindent: ${nindent}, indent: ${indent}")
                //pop until correct indent
                while(nindent<=indent){
                    if(ctx){
                        parent=ctx.pop()
                        last=parent
                        indent=parent.indent
//                         System.out.println("pop, ${parent.tag}, indent: ${indent}")
                    }else{
                        indent=0
                        parent=rparent
                        break
                    }
                }
                ctx<<parent
            }else if(rindent>0){
                
                parent=last
                ctx<<last
            }
            

            parent.subs<<elem
            indent=nindent
            last=elem
        }
        if(rparent.subs.size()==1){
            rparent=rparent.subs[0]
        }else{
            System.out.println("tags: ${rparent.subs*.tag.join(',')}")
            rparent.tag="top"
        }
        System.out.println(renderOutput(rparent))
    }
    public renderOutput(top){
                
        def writer = new StringWriter()
        def xml = new MarkupBuilder(writer)
        renderXml(xml,top)
        return writer.toString()
    }
    public renderXml(xml,elem){
        def att=[:]
        if(elem.attrtext){
            elem.attrtext.split(/ /).each{a->
                def b=a.split(/=/,2)
                if(b.length>1 && b[0] && b[1]){
                    def val=b[1]
                    if(val.size()>1 && val[0]==val[-1] && (val[0]=='"' || val[0]=="'")){
                        val=val[1..-2].toString()
                    }
                    att[b[0]]=val
                }
            }
            
            if(!att){
                elem.text.addAll(elem.attrtext)
            }
        }
        def text =''
        if(elem.text){
            text=elem.text.join("\n")
        }
        xml."${elem.tag}"(att+elem.attrs,text){
            if(elem.subs){
                elem.subs.each{sub->
                    renderXml(delegate,sub)
                }
            }
        }
    }

}

mynoml=new DoNoml()
if(args.length>0){
    mynoml.processArgs(args)
}else{
    mynoml.process()
}