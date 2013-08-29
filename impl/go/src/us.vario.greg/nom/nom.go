package main

import (
    "us.vario.greg/nom/xml";
    "os"
)

func main() {
	xml.Decode(os.Stdin,os.Stdout)
}
