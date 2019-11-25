// handlers/banner.go

package handlers

import (
	"context"
	"database/sql"
	"encoding/base64"
	"gin-gameManager/imageupload"
	"gin-gameManager/models"
	"gin-gameManager/sqlprovider"
	"net/http"

	"github.com/denisenkom/go-mssqldb"
	"github.com/gin-gonic/gin"
)

func GetBanner(c *gin.Context) {
	account := getAccount(c)

	render(c, gin.H{"url": "../",
		"account":     account,
		"bannerArray": bannerArray}, "banner.html")
}

func AddBanner(c *gin.Context) {
	name := c.PostForm("name")
	img, err := imageupload.Process(c.Request, "image")
	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	resizeImg, err := img.ThumbnailPNG(420, 97)

	// GDB Get
	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}
	defer db.Close()

	var rs mssql.ReturnStatus
	_, err = db.ExecContext(context.Background(), "dbo.P_Banner_Create",
		sql.Named("name", name),
		sql.Named("image", resizeImg.Data),
		&rs,
	)

	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	// re load
	LoadBanner()

	c.Redirect(http.StatusFound, "/banner")
}

func SetBanner(c *gin.Context) {
	bannerUID := c.PostForm("banner-uid")
	name := c.PostForm("banner-name")
	androidURL := c.PostForm("android-url")
	iosURL := c.PostForm("ios-url")

	var isChangeImage uint8
	var resizeImg *imageupload.Image
	imageData := []byte{}

	_, info, _ := c.Request.FormFile("image")
	if info != nil {
		isChangeImage = 1
		img, err := imageupload.Process(c.Request, "image")
		if err != nil {
			c.AbortWithStatus(http.StatusBadRequest)
		}
		resizeImg, err = img.ThumbnailPNG(420, 97)
		if err != nil {
			c.AbortWithStatus(http.StatusBadRequest)
		}
		imageData = resizeImg.Data
	}

	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}
	defer db.Close()

	var rs mssql.ReturnStatus
	_, err := db.ExecContext(context.Background(), "dbo.P_Banner_Update",
		sql.Named("bannerUID", bannerUID),
		sql.Named("name", name),
		sql.Named("androidURL", androidURL),
		sql.Named("iosURL", iosURL),
		sql.Named("isChangeImage", isChangeImage),
		sql.Named("image", imageData),
		&rs,
	)
	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	// re load
	LoadBanner()

	c.Redirect(http.StatusFound, "/banner")
}

var bannerArray []models.Banner

func GetBannerArray() []models.Banner {
	return bannerArray
}

func FindBanner(bannerUID int) models.Banner {
	for _, ve := range bannerArray {
		if ve.BannerUID == bannerUID {
			return ve
		}
	}

	return models.Banner{}
}

func LoadBanner() {
	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		return
	}
	defer db.Close()

	query := string("SELECT [BannerUID], [Name], [Android_URL], [IOS_URL], [Image], [RegTime] FROM [T_Banner]")

	rows, err := db.Query(query)
	if err != nil {
		return
	}
	defer rows.Close()

	// clear
	bannerArray = nil

	var item models.Banner
	for rows.Next() {
		err = rows.Scan(&item.BannerUID, &item.Name, &item.Android_URL, &item.IOS_URL, &item.Image, &item.RegTime)
		if err != nil {
			return
		}

		item.Image_DataURI = base64.StdEncoding.EncodeToString(item.Image)
		bannerArray = append(bannerArray, item)
	}
}
