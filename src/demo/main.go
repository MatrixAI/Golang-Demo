package main

import (
	"fmt"
	"github.com/pelletier/go-toml"
	"demo/utilstring"
)

func main () {
	config, _ := toml.Load(`
        [postgres]
        user = "cmcdragonkai"
        password = "blah"
	`)
	user := config.Get("postgres.user").(string)
	user = utilstring.Reverse(user)
	user = reverse(user)
	fmt.Println(fmt.Sprintf("Hello World %s", user))
}
