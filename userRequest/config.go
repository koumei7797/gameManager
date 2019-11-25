// userRequest/config.go

package userRequest

import (
	"context"
	"database/sql"
	"fmt"
	"gin-gameManager/handlers"
	"gin-gameManager/sqlprovider"
)

// Binding from JSON
type RequestConfig struct {
	PackageName string `json:"packageName" binding:"required"`
}

type ConfigResult struct {
	Percent     int    `json:"percent"`
	BannerUID   int    `json:bannerUID`
	BannerName  string `json:bannerName`
	AndroidUrl  string `json:androidUrl`
	IosUrl      string `json:iosUrl`
	BannerImage []byte `json:bannerImage`
}

func Config(packageName, ip string) map[string]interface{} {
	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		// result 999 : Database Connection Error
		return H{"result": 999}
	}
	defer db.Close()

	query := fmt.Sprintf("SELECT [ProjectUID], [InappPercent], [BannerUID] FROM [T_Project] WHERE [Delete] = 0 AND [PackageName] = '%s'", packageName)
	rows, err := db.Query(query)
	if err != nil {
		// result 904 : Database Query Error
		return H{"result": 904, "error": err.Error()}
	}
	defer rows.Close()

	var isEmpty = true
	var item ConfigResult
	var projectUID int
	for rows.Next() {
		err = rows.Scan(&projectUID, &item.Percent, &item.BannerUID)
		if err != nil {
			// result 903 : Database Query Scan Error
			return H{"result": 903, "error": err.Error()}
		}
		isEmpty = false
	}

	if isEmpty {
		// result 1401 : 존재하지 않는 프로젝트 입니다
		return H{"result": 1401}
	}

	if item.BannerUID != 0 {
		banner := handlers.FindBanner(item.BannerUID)
		item.BannerName = banner.Name
		item.AndroidUrl = banner.Android_URL
		item.IosUrl = banner.IOS_URL
		item.BannerImage = banner.Image
	}

	// Client Login History
	if len(ip) < 16 {
		db.ExecContext(context.Background(), "dbo.P_Client_Login_Insert",
			sql.Named("projectUID", projectUID),
			sql.Named("ip", ip),
		)
	}

	return H{"result": 0,
		"percent":     item.Percent,
		"bannerUID":   item.BannerUID,
		"bannerName":  item.BannerName,
		"androidUrl":  item.AndroidUrl,
		"iosUrl":      item.IosUrl,
		"bannerImage": item.BannerImage}

}
