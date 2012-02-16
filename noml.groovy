#!/usr/bin/env groovy
//@Grab(group='dom4j', module='dom4j', version='1.6.1')
//import 
import groovy.xml.*


public class DoNoml{
    def List mylist=[]  
    def indent=0
    def istr='    '
    public noml(){
    
    }
    public void processArgs(args){
    
    }
    public void processRev(){
        processRevInput(System.in)
    }
    public processRevInput(input){
        def doc=new XmlParser().parse(input)
        System.out.println(renderNoml(doc,0,[:]))
    }
    public renderNoml(node,indent,nspace,sb=null){
        def pref=istr*indent
        if(!sb){
            sb = new StringBuilder()
        }
        sb<<pref
        def name=node.name()
        if(name instanceof QName){
            def qp=name.prefix?name.prefix+':':''
            sb<<"${qp}${name.localPart}"
            if(!nspace[name.prefix]){
                nspace[name.prefix]=name.namespaceURI
                def op=name.prefix?':'+name.prefix:''
                node.attributes().put("xmlns${op}",name.namespaceURI)
            }
        }else{
            sb<<name
        }
        def nlines=[]
        if(node.attributes()){
            def xattrs=[:]
            node.attributes().each{k,v->
                if(v=~/ /){
                    xattrs[k]=v
                }else{
                    if(k instanceof QName){
                        def qp=k.prefix?k.prefix+':':''
                        sb<<" ${qp}${k.localPart}=${v}"
                        if(!nspace[k.prefix]){
                            nspace[k.prefix]=k.namespaceURI
                            def op=k.prefix?':'+k.prefix:''
                            sb<<" xmlns${op}=${k.namespaceURI}"
                        }
                    }else{
                        sb<<" ${k}=${v}"
                    }
                }
            }
            xattrs.each{k,v->
                if(k instanceof QName){
                    def qp=k.prefix?k.prefix+':':''
                    nlines<<"@${qp}${k.localPart} ${v}"
                    if(!nspace[k.prefix]){
                        nspace[k.prefix]=k.namespaceURI
                        def op=k.prefix?':'+k.prefix:''
                        nlines<<"@xmlns${op} ${k.namespaceURI}"
                    }
                }else{
                    nlines<<"${istr}@${k} ${v}"
                }
            }
            if(node.text()){
                node.text().eachLine{it->
                    nlines<<"${istr}:${it}"
                }
            }
        }else if(node.text()){
            def nline
            node.text().eachLine{it->
                if(!nline){
                    nline=it
                }else{
                    nlines<<"${istr}:${it}"
                }
            }
            sb<<" ${nline}"
        }
        sb<<"\n"
        nlines.each{
            sb<<pref
            sb<<it
            sb<<"\n"
        }
        
        //sub elements
        node.children().each{nnode->
            if(nnode instanceof Node){
                renderNoml(nnode,indent+1,nspace,sb)
            }
        }
        sb.toString()
    }
    public void process(){
        processInput(System.in)
    }
    
    public processInput(input){
        def ctx=[]
        def rparent=[subs:[],indent:-1,text:[],attrs:[:],comments:[]]
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
            
            def m=(line=~/^(\w[\w:_\.-]*?)[:]?(\s+(.*))?$/)
            def mt=(line=~/^:(.*)?$/)
            def mc=(line=~/^#(.*)?$/)
            def ma=(line=~/^@?(\w[\w:_\.-]*)([=]?\s*(.*))$/)
            def elem=[subs:[],indent:nindent,text:[],attrs:[:],comments:[]]
            if(m.matches()){
                elem.tag=m.group(1)
                if(m.groupCount()>2 && m.group(3)){
                    def tval=m.group(3)
                    if(tval.indexOf('#')>=0){
                        def tc=tval.substring(tval.indexOf('#'))
                        tval=tval.replaceAll(/#.*$/,'')
                        if(tc.startsWith('##')){
                            elem.comments<<tc.substring(2)
                        }
                    }
                    elem.attrtext=tval
                }
            }else if(mc.matches()){
                //comment
                if(mc.group(1).startsWith('#')){
                    last.comments<<mc.group(1).substring(1)
                }
                return
            }else if(ma.matches()){
                //attribute
                if(ma.groupCount()>2){
                    last.attrs[ma.group(1)]=ma.group(3)
                }
                return
            }else if(mt.matches()){
                last.text<<mt.group(1)
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
            rparent.tag="root"
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
            def lastatt
            def expectq
            elem.attrtext.split(/ /).each{a->
                def b=a.split(/=/,2)
                if(!expectq && b.length>1 && b[0] && b[1]){
                    def val=b[1]
                    if(val.size()>1 && val[0]==val[-1] && (val[0]=='"' || val[0]=="'")){
                        val=val[1..-2].toString()
                    }else if(val[0]=='"' || val[0]=="'"){
                        expectq=val[0]
                        val=val[1..-1]
                    }
                    att[b[0]]=val
                    lastatt=b[0]
                }else if(a && lastatt){
                    att[lastatt]+=' '
                    if(expectq && a[-1]==expectq){
                        att[lastatt]+=a[0..-2]
                        expectq=null
                    }else{
                        att[lastatt]+=a
                    }
                }
            }
            if(expectq && lastatt){
                //intended lone quote char? unlikely
                //att[lastatt]=expectq+att[lastatt]
            }
            
            if(!att){
                elem.text=[elem.attrtext]+elem.text
            }
        }
        def text =''
        if(elem.text){
            text=elem.text.join("\n")
        }
        xml."${elem.tag}"(att+elem.attrs,text){
            if(elem.comments){
                mkp.comment(elem.comments.join("\n"))
            }
            if(elem.subs){
                elem.subs.each{sub->
                    renderXml(delegate,sub)
                }
            }
        }
    }

}

mynoml=new DoNoml()
if(args.length>0 && args[0]=='-rev'){
    mynoml.processRev()
}else{
    mynoml.process()
}