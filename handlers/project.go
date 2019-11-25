// handlers/project.go

package handlers

import (
	"context"
	"database/sql"
	"encoding/base64"
	"fmt"
	"gin-gameManager/imageupload"
	"gin-gameManager/models"
	"gin-gameManager/sqlprovider"
	"io/ioutil"
	"net/http"
	"strconv"

	"github.com/denisenkom/go-mssqldb"
	"github.com/gin-contrib/sessions"
	"github.com/gin-gonic/gin"
)

const (
	COUNT_PER_PAGE = 10
)

func getAccount(c *gin.Context) string {
	accountInterface := sessions.Default(c).Get("account")
	if accountInterface == nil {
		return ""
	}
	account := accountInterface.(string)
	return account
}

func selectProject(projectUID string) (models.T_Project, error) {
	uid, err := strconv.Atoi(projectUID)
	projectArray, err := selectQuery(uid)
	if err != nil {
		return models.T_Project{}, err
	}

	var project = projectArray[0]
	return project, err
}

func selectQuery(projectUID int) ([]models.T_Project, error) {

	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		return nil, nil
	}
	defer db.Close()

	query := string("SELECT [ProjectUID], [PackageName], [Name], [Platform], [Version], [Image_Data], [Android_JWT], [CSRewardType], [InappPercent], [BannerUID], [LastUpdateTime], [RegTime] FROM [T_Project] WHERE [Delete] = 0")

	if projectUID != 0 {
		query = fmt.Sprintf("%s AND [ProjectUID] = %d", query, projectUID)
	}

	rows, err := db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var projectArray []models.T_Project
	var project models.T_Project
	for rows.Next() {
		// var imgStr string
		err = rows.Scan(&project.ProjectUID, &project.PackageName, &project.Name, &project.Platform, &project.Version,
			&project.Image_Data, &project.Android_JWT, &project.CSRewardType, &project.InappPercent, &project.BannerUID, &project.LastUpdateTime, &project.RegTime)
		if err != nil {
			return nil, err
		}

		project.Image_DataURI = base64.StdEncoding.EncodeToString(project.Image_Data)

		if len(project.Android_JWT) == 0 {
			project.Json_Android_JWT = "Empty"
		} else {
			project.Json_Android_JWT = BytesToString(project.Android_JWT)
		}
		projectArray = append(projectArray, project)
	}

	return projectArray, nil
}

func SelectAndroidJWT(packageName string) ([]byte, error) {
	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		return nil, fmt.Errorf("not found sqlserver")
	}
	defer db.Close()

	query := fmt.Sprintf("SELECT [Android_JWT] FROM [T_Project] WHERE [Delete] = 0 AND [PackageName] = '%s'", packageName)
	rows, err := db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []byte
	for rows.Next() {
		err = rows.Scan(&result)
		if err != nil {
			return nil, err
		}
	}

	return result, nil
}

func ShowProjectListPage(c *gin.Context) {

	projectArray, err := selectQuery(0)
	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	session := sessions.Default(c)
	accountInterface := session.Get("account")
	if accountInterface == nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	account := accountInterface.(string)

	render(c, gin.H{"url": "../", "title": "Project", "account": account, "projectArray": projectArray}, "project-list.html")
}

func AddProject(c *gin.Context) {

	packageName := c.PostForm("packageName")
	appName := c.PostForm("appName")
	platform := c.PostForm("platform")

	img, err := imageupload.Process(c.Request, "image")
	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	resizeImg, err := img.ThumbnailPNG(32, 32)

	// GDB Get
	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}
	defer db.Close()

	var rs mssql.ReturnStatus
	_, err = db.ExecContext(context.Background(), "dbo.P_Project_Create",
		sql.Named("packageName", packageName),
		sql.Named("name", appName),
		sql.Named("platform", platform),
		sql.Named("image_Data", resizeImg.Data),
		&rs,
	)

	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	if rs != 0 {
		desc := GetErrorDesc(int(rs))
		render(c, gin.H{"url": "", "title": "400 Error", "message": desc}, "page_400.html")
	}

	c.Redirect(http.StatusFound, "/project")
}

func SetProject(c *gin.Context) {

	packageName := c.PostForm("set-project-package-name")
	name := c.PostForm("set-project-name")
	version := c.PostForm("set-version")

	var isChangeImage uint8
	imageData := []byte{}

	var resizeImg *imageupload.Image

	_, info, _ := c.Request.FormFile("set-image")
	if info != nil {
		isChangeImage = 1
		img, err := imageupload.Process(c.Request, "set-image")
		if err != nil {
			c.AbortWithStatus(http.StatusBadRequest)
		}
		resizeImg, err = img.ThumbnailPNG(32, 32)
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
	_, err := db.ExecContext(context.Background(), "dbo.P_Project_Update",
		sql.Named("packageName", packageName),
		sql.Named("name", name),
		sql.Named("version", version),
		sql.Named("isChangeImage", isChangeImage),
		sql.Named("image_Data", imageData),
		&rs,
	)
	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	c.Redirect(http.StatusFound, "/project")
}

func DelProject(c *gin.Context) {

	packageName := c.PostForm("del-project-package-name")

	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}
	defer db.Close()

	var rs mssql.ReturnStatus
	_, err := db.ExecContext(context.Background(), "dbo.P_Project_Delete",
		sql.Named("packageName", packageName),
		&rs,
	)

	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	c.Redirect(http.StatusFound, "/project")
}

func SetProjectJWT(c *gin.Context) {
	projectUID := c.PostForm("projectUID")
	androidJwt := []byte{}
	file, info, _ := c.Request.FormFile("set-android-jwt")
	if info != nil {
		bs, err := ioutil.ReadAll(file)
		if err != nil {
			c.AbortWithStatus(http.StatusBadRequest)
		}
		androidJwt = bs
	}

	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}
	defer db.Close()

	var rs mssql.ReturnStatus
	_, err := db.ExecContext(context.Background(), "dbo.P_Project_AndJWT_Update",
		sql.Named("projectUID", projectUID),
		sql.Named("android_jwt", androidJwt),
		&rs,
	)

	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	location := fmt.Sprintf("/project/%s/inapp", projectUID)
	c.Redirect(http.StatusFound, location)
}

func GetProject(c *gin.Context) {
	account := getAccount(c)

	project, err := selectProject(c.Param("ProjectUID"))
	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	render(c, gin.H{"url": "../",
		"account":       account,
		"projectUID":    project.ProjectUID,
		"title":         project.Name,
		"name":          project.Name,
		"packageName":   project.PackageName,
		"image_DataURI": project.Image_DataURI}, "project.html")
}
