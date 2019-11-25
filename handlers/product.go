// handlers/product.go

package handlers

import (
	"context"
	"database/sql"
	"fmt"
	"gin-gameManager/sqlprovider"
	"log"
	"net/http"

	"github.com/denisenkom/go-mssqldb"
	"github.com/gin-gonic/gin"
)

func AddProduct(c *gin.Context) {
	projectUID := c.PostForm("projectUID")
	productID := c.PostForm("productID")
	title := c.PostForm("title")
	price := c.PostForm("price")

	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}
	defer db.Close()

	var rs mssql.ReturnStatus
	_, err := db.ExecContext(context.Background(), "dbo.P_Project_Inapp_Create",
		sql.Named("projectUID", projectUID),
		sql.Named("productID", productID),
		sql.Named("title", title),
		sql.Named("price", price),
		&rs,
	)

	if err != nil {
		log.Println("Error creating Employee: ", err.Error())
	}

	if rs != 0 {
		desc := GetErrorDesc(int(rs))
		render(c, gin.H{"url": "../../../", "title": "400 Error", "message": desc}, "page_400.html")
	}

	location := fmt.Sprintf("/project/%s/inapp", projectUID)
	c.Redirect(http.StatusFound, location)
}

func DelProduct(c *gin.Context) {
	projectUID := c.PostForm("projectUID")
	productID := c.PostForm("productID")

	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}
	defer db.Close()

	var rs mssql.ReturnStatus
	_, err := db.ExecContext(context.Background(), "dbo.P_Project_Inapp_Delete",
		sql.Named("projectUID", projectUID),
		sql.Named("productID", productID),
		&rs,
	)

	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	location := fmt.Sprintf("/project/%s/inapp", projectUID)
	c.Redirect(http.StatusFound, location)
}
