// userRequest/cs.go

package userRequest

import (
	"context"
	"database/sql"
	"encoding/json"

	"gin-gameManager/models"
	"gin-gameManager/sqlprovider"

	"github.com/denisenkom/go-mssqldb"
)

type RequestCsNameCreate struct {
	PackageName string `json:"packageName" binding:"required"`
}

type RequestCsReward struct {
	PackageName string `json:"packageName" binding:"required"`
	CsName      string `json:"csName" binding:"required"`
}

func CsNameCreate(packageName, ip string) map[string]interface{} {
	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		// result 999 : Database Connection Error
		return H{"result": 999}
	}
	defer db.Close()

	var out_name string
	var rs mssql.ReturnStatus
	_, err := db.ExecContext(context.Background(), "dbo.P_CS_Name_Create",
		sql.Named("packageName", packageName),
		sql.Named("ip", ip),
		sql.Named("out_name", sql.Out{Dest: &out_name}),
		&rs,
	)

	if err != nil {
		// result 901 : Proc ExecContext Error
		return H{"result": 901, "error": err.Error()}
	}

	if rs != 0 {
		return H{"result": int(rs)}
	}

	return H{"result": int(rs), "csName": out_name}
}

func CsReward(packageName, csName string) map[string]interface{} {
	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		// result 999 : Database Connection Error
		return H{"result": 999}
	}
	defer db.Close()

	var rs mssql.ReturnStatus
	rows, err := db.QueryContext(context.Background(), "P_CS_Reward",
		sql.Named("packageName", packageName),
		sql.Named("csName", csName),
		&rs,
	)

	if err != nil {
		// result 902 : Proc QueryContext Error
		return H{"result": 902, "error": err.Error()}
	}

	var itemArray []models.TypeValueObj
	var item models.TypeValueObj
	for rows.Next() {
		var o string
		err = rows.Scan(&o)
		if err != nil {
			// result 903 : Database Query Scan Error
			return H{"result": 903, "error": err.Error()}
		}

		jsonBytes := []byte(o)
		err = json.Unmarshal(jsonBytes, &item)
		if err != nil {
			// result 903 : Database Query Scan Error
			return H{"result": 903, "error": err.Error()}
		}

		itemArray = append(itemArray, item)
	}

	if rs != 0 {
		return H{"result": int(rs)}
	}

	return H{"result": int(rs), "rewards": itemArray}
}