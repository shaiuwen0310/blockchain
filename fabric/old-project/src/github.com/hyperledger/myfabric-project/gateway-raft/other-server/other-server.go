package main

/*
go build wiki_practice.go
./wiki_practice
*/

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

type CreateParams struct {
	Txid  string `json:"txid"`
	Uuid  string `json:"uuid"`
	Grp   uint64 `json:"grp"`
	Nodes []Node `json:"nodes"`
}

type Node struct {
	Id  string      `json:"id"`
	T   interface{} `json:"t"`
	Bat uint64      `json:"bat"`
}

func main() {

	r := gin.Default()
	r.LoadHTMLGlob("tmpl/*")

	r.POST("/other/server", func(c *gin.Context) {
		var createparams CreateParams
		err := c.BindJSON(&createparams)
		if err != nil {
			log.Fatal(err)
		}
		jsons, _ := json.Marshal(createparams)
		fmt.Println(string(jsons))
		filename := "data.json"
		ioutil.WriteFile("./data/"+filename, jsons, 0600)

		c.JSON(200, gin.H{
			"errno": 0,
			"error": "succ",
		})
	})

	r.GET("/", func(c *gin.Context) {
		filename := "data.json"
		body, _ := ioutil.ReadFile("./data/" + filename)
		fmt.Println(string(body))

		var values CreateParams
		err := json.Unmarshal([]byte(body), &values)
		if err != nil {
			log.Fatal(err)
		}

		c.HTML(http.StatusOK, "index.html", gin.H{
			"txid": values.Txid, "uuid": values.Uuid, "grp": values.Grp, "node": values.Nodes})

	})

	r.Run(":8001")
}
