// handlers/project-inapp.go

package handlers

import (
	"fmt"
	"gin-gameManager/models"
	"gin-gameManager/sqlprovider"
	"net/http"

	"github.com/gin-gonic/gin"
)

func selectInappQuery(projectUID int) ([]models.ProjectInapp, error) {

	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		return nil, nil
	}
	defer db.Close()

	query := fmt.Sprintf("SELECT [ProjectUID], [ProductID], [Title], [Price] FROM [T_Project_InApp] WHERE [ProjectUID] = %d", projectUID)

	rows, err := db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var array []models.ProjectInapp
	var item models.ProjectInapp
	for rows.Next() {
		err = rows.Scan(&item.ProjectUID, &item.ProductID, &item.Title, &item.Price)
		if err != nil {
			return nil, err
		}
		array = append(array, item)
	}

	return array, nil
}

func GetProjectIAP(c *gin.Context) {
	account := getAccount(c)

	project, err := selectProject(c.Param("ProjectUID"))
	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}
	inappArray, err := selectInappQuery(project.ProjectUID)
	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	render(c, gin.H{"url": "../../",
		"account":          account,
		"projectUID":       project.ProjectUID,
		"title":            project.Name,
		"name":             project.Name,
		"packageName":      project.PackageName,
		"image_DataURI":    project.Image_DataURI,
		"inappArray":       inappArray,
		"json_Android_JWT": project.Json_Android_JWT}, "project-inapp.html")
}
