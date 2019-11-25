// main.go

package main

import (
	"gin-gameManager/handlers"
	"gin-gameManager/userRequest"
	"net/http"
	"strings"

	"github.com/gin-contrib/sessions"
	"github.com/gin-contrib/sessions/cookie"
	"github.com/gin-gonic/gin"
)

var router *gin.Engine

func main() {

	handlers.ErrorInit()

	router = gin.Default()
	router.Static("/public", "public")
	router.LoadHTMLGlob("templates/*")

	handlers.LoadBanner()

	initializeRoutes()
	router.Run(":3000")
}

func initializeRoutes() {

	store := cookie.NewStore([]byte("secret"))
	router.Use(sessions.Sessions("mysession", store))

	router.POST("/addProject", ensureLoggedIn(), handlers.AddProject)
	router.POST("/setProject", ensureLoggedIn(), handlers.SetProject)
	router.POST("/delProject", ensureLoggedIn(), handlers.DelProject)
	router.GET("/logout", handlers.Logout)

	accountRoutes := router.Group("/account")
	{
		//accountRoutes.GET("/out", ensureLoggedIn(), handlers.LogOut)
		accountRoutes.GET("/login", handlers.ShowLogin)
		accountRoutes.POST("/login", handlers.Login)
	}

	projectRoutes := router.Group("/project")
	{
		projectRoutes.GET("", ensureLoggedIn(), handlers.ShowProjectListPage)
		projectRoutes.GET("/:ProjectUID", ensureLoggedIn(), handlers.GetProject)
		projectRoutes.GET("/:ProjectUID/billing", ensureLoggedIn(), handlers.GetProjectBilling)

		projectRoutes.GET("/:ProjectUID/inapp", ensureLoggedIn(), handlers.GetProjectIAP)
		projectRoutes.POST("/:ProjectUID/inapp/addProduct", ensureLoggedIn(), handlers.AddProduct)
		projectRoutes.POST("/:ProjectUID/inapp/delProduct", ensureLoggedIn(), handlers.DelProduct)
		projectRoutes.POST("/:ProjectUID/inapp/setJWT", ensureLoggedIn(), handlers.SetProjectJWT)

		projectRoutes.GET("/:ProjectUID/cs/:Page", ensureLoggedIn(), handlers.GetProjectCS)
		projectRoutes.POST("/:ProjectUID/cs/setReward", ensureLoggedIn(), handlers.SetCSReward)
		projectRoutes.POST("/:ProjectUID/cs/setRewardType", ensureLoggedIn(), handlers.SetCSRewardType)
		projectRoutes.GET("/:ProjectUID/cs-detail/:CsName", ensureLoggedIn(), handlers.GetProjectCSDetail)
		projectRoutes.POST("/:ProjectUID/cs-detail", ensureLoggedIn(), handlers.SearchCS)

		projectRoutes.GET("/:ProjectUID/config", ensureLoggedIn(), handlers.GetConfig)
		projectRoutes.POST("/:ProjectUID/config/set", ensureLoggedIn(), handlers.SetConfig)
	}

	bannerRoutes := router.Group("/banner")
	{
		bannerRoutes.GET("", ensureSudo(), handlers.GetBanner)
		bannerRoutes.POST("/add", ensureSudo(), handlers.AddBanner)
		bannerRoutes.POST("/set", ensureSudo(), handlers.SetBanner)
	}

	// game user request
	requestRoutes := router.Group("/request")
	{
		// [ fix : purchase playstore ]
		requestRoutes.POST("/purchasePlaystore", func(c *gin.Context) {
			var json userRequest.PurchasePlaystore
			if err := c.ShouldBindJSON(&json); err != nil {
				// result 401 : 잘못된 요청입니다 (Request 객체 생성불가)
				c.JSON(http.StatusOK, gin.H{"result": 401, "error": err.Error()})
				return
			}

			jwt, err := handlers.SelectAndroidJWT(json.PackageName)
			if err != nil {
				// result 401 : 잘못된 요청입니다 (Request 객체 생성불가)
				c.JSON(http.StatusOK, gin.H{"result": 401, "error": err.Error()})
				return
			}

			if len(jwt) == 0 {
				// result 3401 : [Purchase] AndroidJWT 등록되지 않음
				c.JSON(http.StatusOK, gin.H{"result": 3401, "receiptDesc": json.ReceiptDesc})
				return
			}

			m := userRequest.PlaystoreProcess(
				json.PackageName,
				json.ProductID,
				json.PurchaseToken,
				json.ReceiptDesc,
				c.ClientIP(),
				jwt)

			c.JSON(http.StatusOK, m)
		})

		// [ fix : purchase appstore ]
		requestRoutes.POST("/purchaseAppstore", func(c *gin.Context) {
			var json userRequest.PurchaseAppstore
			if err := c.ShouldBindJSON(&json); err != nil {
				// result 401 : 잘못된 요청입니다 (Request 객체 생성불가)
				c.JSON(http.StatusOK, gin.H{"result": 401, "error": err.Error()})
				return
			}

			m := userRequest.AppstoreProcess(json.PackageName, json.ReceiptData, json.ReceiptDesc, c.ClientIP())
			c.JSON(http.StatusOK, m)
		})

		// [ fix : csNameCreate ]
		requestRoutes.POST("/csNameCreate", func(c *gin.Context) {
			var json userRequest.RequestCsNameCreate
			if err := c.ShouldBindJSON(&json); err != nil {
				// result 401 : 잘못된 요청입니다 (Request 객체 생성불가)
				c.JSON(http.StatusOK, gin.H{"result": 401, "error": err.Error()})
				return
			}

			m := userRequest.CsNameCreate(json.PackageName, c.ClientIP())
			c.JSON(http.StatusOK, m)
		})

		// [ fix : csReward]
		requestRoutes.POST("/csReward", func(c *gin.Context) {
			var json userRequest.RequestCsReward
			if err := c.ShouldBindJSON(&json); err != nil {
				// result 401 : 잘못된 요청입니다 (Request 객체 생성불가)
				c.JSON(http.StatusOK, gin.H{"result": 401, "error": err.Error()})
				return
			}

			m := userRequest.CsReward(json.PackageName, json.CsName)
			c.JSON(http.StatusOK, m)
		})

		// [ fix : config ]
		requestRoutes.POST("/config", func(c *gin.Context) {
			var json userRequest.RequestConfig
			if err := c.ShouldBindJSON(&json); err != nil {
				// result 401 : 잘못된 요청입니다 (Request 객체 생성불가)
				c.JSON(http.StatusOK, gin.H{"result": 401, "error": err.Error()})
				return
			}

			m := userRequest.Config(json.PackageName, c.ClientIP())
			c.JSON(http.StatusOK, m)
		})
	}
}

func ensureSudo() gin.HandlerFunc {
	return func(c *gin.Context) {
		session := sessions.Default(c)
		accountInterface := session.Get("account")
		if accountInterface == nil {
			c.AbortWithStatus(http.StatusUnauthorized)
		}
		account := accountInterface.(string)
		if !strings.Contains(account, "dev") {
			c.AbortWithStatus(http.StatusUnauthorized)
		}
	}
}

// This middleware ensures that a request will be aborted with an error
// if the user is not logged in
func ensureLoggedIn() gin.HandlerFunc {
	return func(c *gin.Context) {
		session := sessions.Default(c)
		accountInterface := session.Get("account")
		if accountInterface == nil {
			c.Redirect(http.StatusFound, "/account/login")
		}
	}
}

// This middleware ensures that a request will be aborted with an error
// if the user is already logged in
func ensureNotLoggedIn() gin.HandlerFunc {
	return func(c *gin.Context) {
		session := sessions.Default(c)
		accountInterface := session.Get("account")
		if accountInterface != nil {
			c.Redirect(http.StatusFound, "/project")
		}
	}
}