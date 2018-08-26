package demo

import (
	submathpackage "github.com/MatrixAI/Golang-Demo/submathpackage"
	substringpackage "github.com/MatrixAI/Golang-Demo/substringpackage"
	toml "github.com/pelletier/go-toml"
)

func Id(x interface{}) interface{} {
	return x
}

func Add(x int, y int) int {
	return submathpackage.Add(x, y)
}

func Subtract(x int, y int) int {
	return submathpackage.Subtract(x, y)
}

func GiveMeString() string {
	return reverse("what!")
}

func reverse(str string) string {
	return substringpackage.Reverse(str)
}

func UseToml() string {
	config, _ := toml.Load(`
[postgres]
user = "cmcdragonkai"
`)
	user := config.Get("postgres.user").(string)
	return user
}
