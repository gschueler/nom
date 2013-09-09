package main

import (
    "us.vario.greg/nom/nom"
    "os"
)

func main() {
    err:=nom.Encode(os.Stdin,os.Stdout)
    if err != nil { panic(err) }
}
