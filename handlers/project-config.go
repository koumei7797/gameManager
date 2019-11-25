// handlers/project-config.go

package handlers

import (
	"context"
	"database/sql"
	"fmt"
	"gin-gameManager/sqlprovider"
	"net/http"

	"github.com/denisenkom/go-mssqldb"
	"github.com/gin-gonic/gin"
)

func GetConfig(c *gin.Context) {
	account := getAccount(c)

	project, err := selectProject(c.Param("ProjectUID"))
	if err != nil {
		Error400(c, "../../", err.Error())
		return
	}

	bannerArray := GetBannerArray()

	render(c, gin.H{"url": "../../",
		"account":       account,
		"projectUID":    project.ProjectUID,
		"title":         project.Name,
		"name":          project.Name,
		"packageName":   project.PackageName,
		"image_DataURI": project.Image_DataURI,
		"inappPercent":  project.InappPercent,
		"bannerUID":     project.BannerUID,
		"bannerArray":   bannerArray}, "project-config.html")
}

func SetConfig(c *gin.Context) {
	projectUID := c.PostForm("projectUID")
	editPercent := c.PostForm("edit-percent")
	bannerUID := c.PostForm("banner-select")

	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}
	defer db.Close()

	var isChangePercent = 0
	if len(editPercent) != 0 {
		isChangePercent = 1
	}

	var rs mssql.ReturnStatus
	_, err := db.ExecContext(context.Background(), "dbo.P_Project_Config_Update",
		sql.Named("projectUID", projectUID),
		sql.Named("isChangePercent", isChangePercent),
		sql.Named("inappPercent", editPercent),
		sql.Named("bannerUID", bannerUID),
		&rs,
	)
	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	location := fmt.Sprintf("/project/%s/config", projectUID)
	c.Redirect(http.StatusFound, location)
}
