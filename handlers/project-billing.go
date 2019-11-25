// handlers/project-billing.go

package handlers

import (
	"fmt"
	"gin-gameManager/models"
	"gin-gameManager/sqlprovider"
	"net/http"
	"sort"

	"github.com/gin-gonic/gin"
)

func selectPurchaseQuery(projectUID int) ([]models.ProjectBilling, []models.ProjectBillingChart, error) {
	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		return nil, nil, nil
	}
	defer db.Close()

	query := fmt.Sprintf("SELECT A.[ProjectUID], A.[ProductID], A.[OrderID], A.[ErrorCode], A.[IP], A.[RegTime], B.[Price] FROM [T_Purchase] AS A INNER JOIN [T_Project_InApp] AS B ON A.[ProjectUID] = B.[ProjectUID] AND A.[ProductID] = B.[ProductID] WHERE A.[ProjectUID] = %d ORDER BY A.[RegTime] ASC", projectUID)

	rows, err := db.Query(query)
	if err != nil {
		return nil, nil, err
	}
	defer rows.Close()

	var item models.ProjectBilling
	var array []models.ProjectBilling
	var arrayChart []models.ProjectBillingChart

	for rows.Next() {
		err = rows.Scan(&item.ProjectUID, &item.ProductID, &item.OrderID, &item.ErrorCode, &item.IP, &item.RegTime, &item.Price)
		if err != nil {
			return nil, nil, err
		}
		array = append(array, item)

		var check bool = false
		for i := range arrayChart {
			if arrayChart[i].ProductID == item.ProductID {
				arrayChart[i].Count++
				check = true
			}
		}

		if !check {
			p := models.ProjectBillingChart{ProductID: item.ProductID, Price: item.Price, Count: 1}
			arrayChart = append(arrayChart, p)
		}
	}

	sort.Sort(models.ByPrice(arrayChart))
	return array, arrayChart, nil
}

func GetProjectBilling(c *gin.Context) {
	account := getAccount(c)

	project, err := selectProject(c.Param("ProjectUID"))
	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}
	billingArray, billingChart, err := selectPurchaseQuery(project.ProjectUID)
	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	render(c, gin.H{"url": "../../",
		"account":       account,
		"projectUID":    project.ProjectUID,
		"title":         project.Name,
		"name":          project.Name,
		"packageName":   project.PackageName,
		"image_DataURI": project.Image_DataURI,
		"billingArray":  billingArray,
		"billingChart":  billingChart}, "project-billing.html")
}
