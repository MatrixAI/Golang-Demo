package main

import (
	"fmt"
	demo "github.com/MatrixAI/Golang-Demo/demopackage"
	substringpackage "github.com/MatrixAI/Golang-Demo/substringpackage"
)

func main() {
	fmt.Println(demo.Id(1))
	fmt.Println(demo.UseToml())
	fmt.Println("hello")
	fmt.Println(substringpackage.Reverse("world"))
}
