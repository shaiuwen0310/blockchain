package main

import (
	"bytes"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"

	"github.com/DeanThompson/ginpprof"
	"github.com/gin-gonic/gin"
)

type CreateParams struct {
	Uuid  string `json:"uuid"`
	Grp   uint64 `json:"grp"`
	Nodes []Node `json:"nodes"`
}

type Node struct {
	Id  string      `json:"id"`
	T   interface{} `json:"t"`
	Bat uint64      `json:"bat"`
}

type FabricResp struct {
	Context string `json:"context"`
	Txid    string `json:"txid"`
}

var (
	orgData      = make(map[string]interface{})
	out          = make(map[string]interface{})
	fabricResp   FabricResp
	createparams CreateParams
)

func main() {
	gin.SetMode(gin.ReleaseMode)
	r := gin.Default()
	ginpprof.Wrap(r)

	r.POST("/dev/:uuid", func(c *gin.Context) {
		// var createparams CreateParams
		err := c.BindJSON(&createparams)
		if err != nil {
			log.Fatal(err)
		}

		// ====== 將異常溫度打叉 ======
		for i := 0; i < len(createparams.Nodes); i++ {
			switch createparams.Nodes[i].T.(type) {
			case float64:
				if createparams.Nodes[i].T.(float64) > 60.0 {
					createparams.Nodes[i].T = "X"
				}
				break
			}
		}
		jsons, _ := json.Marshal(createparams)
		// ====== 將異常溫度打叉 ======

		// ====== 將接收到的資料組成key value ======
		// var orgData = make(map[string]interface{})
		orgData["values"] = string(jsons)
		orgData["key"] = string(createparams.Uuid)
		orgMapResp, _ := json.Marshal(orgData)
		// ====== 將接收到的資料組成key value ======

		// ====== fabric api request ======
		urlFabric := "http://127.0.0.1:4001/snsrdata/mychannel/snsrdatacc/set/user1/v1"

		var orgJsonStr = []byte(string(orgMapResp))
		req, err := http.NewRequest("POST", urlFabric, bytes.NewBuffer(orgJsonStr))
		req.Header.Set("Content-Type", "application/json")

		client := &http.Client{}
		resp, err := client.Do(req)
		if err != nil {
			panic(err)
		}
		if resp != nil {
			defer resp.Body.Close() // MUST CLOSED THIS
		}
		defer resp.Body.Close()

		// fmt.Println("response Status:", resp.Status)
		// fmt.Println("response Headers:", resp.Header)
		body, _ := ioutil.ReadAll(resp.Body)
		// fmt.Println("response Body:", string(body))
		// ====== fabric api request ======

		// ====== 組成json格式 ======
		// var fabricResp FabricResp
		err = json.Unmarshal(body, &fabricResp)
		if err != nil {
			panic(err)
		}
		// var out = make(map[string]interface{})
		json.Unmarshal([]byte(fabricResp.Context), &out)
		out["txid"] = fabricResp.Txid
		outputJSON, _ := json.Marshal(out)
		// fmt.Println(string(outputJSON))
		// ====== 組成json格式 ======

		// ====== 將資料傳給其他server ======
		urlOtherServer := "http://192.168.101.251:8001/other/server"

		orgJsonStr = []byte(string(outputJSON))
		req, err = http.NewRequest("POST", urlOtherServer, bytes.NewBuffer(outputJSON))
		req.Header.Set("Content-Type", "application/json")

		client = &http.Client{}
		resp, err = client.Do(req)
		if err != nil {
			panic(err)
		}
		if resp != nil {
			defer resp.Body.Close() // MUST CLOSED THIS
		}
		defer resp.Body.Close()

		// fmt.Println("response Status:", resp.Status)
		// fmt.Println("response Headers:", resp.Header)
		body, _ = ioutil.ReadAll(resp.Body)
		// fmt.Println("response Body:", string(body))
		// ====== 將資料傳給其他server ======

		c.JSON(200, gin.H{
			"errno": 0,
			"error": "succ",
		})
	})

	r.Run(":10010")

	// request
	// curl http://localhost:10010/dev/uuid -d @request.json
}
