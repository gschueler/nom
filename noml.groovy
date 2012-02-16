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
        def rparent=[subs:[],indent:-1,text:[]]
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
            
            def m=(line=~/^(\w+)(\s+(.*))?$/)
            def elem=[subs:[],indent:nindent,text:[]]
            if(m.matches()){
                elem.tag=m.group(1)
                if(m.groupCount()>1){
                    elem.attrs=m.group(3)
                }
            }else if(line.trim()){
                parent.text<<line
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
        if(elem.attrs){
            elem.attrs.split(/ /).each{a->
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
                elem.text<<elem.attrs
            }
        }
        def text =''
        if(elem.text){
            text=elem.text.join("\n")
        }
        xml."${elem.tag}"(att,text){
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