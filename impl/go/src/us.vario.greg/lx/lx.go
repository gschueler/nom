package main

import (
    "us.vario.greg/nom/xml"
    "os"
)

func main() {
	err:=xml.Decode(os.Stdin,os.Stdout)
    if err != nil { panic(err) }
}
