// userRequest/playstore.go

package userRequest

import (
	"context"
	"database/sql"

	"gin-gameManager/sqlprovider"

	"github.com/awa/go-iap/playstore"
	"github.com/denisenkom/go-mssqldb"
	"google.golang.org/api/googleapi"
)

type H map[string]interface{}

// Binding from JSON
type PurchasePlaystore struct {
	PackageName   string `json:"packageName" binding:"required"`
	ProductID     string `json:"productID" binding:"required"`
	PurchaseToken string `json:"purchaseToken" binding:"required"`
	ReceiptDesc   string `json:"receiptDesc"`
}

func PlaystoreProcess(packageName, productID, purchaseToken, receiptDesc, ip string, jsonKey []byte) map[string]interface{} {

	client, err := playstore.New(jsonKey)
	if err != nil {
		// result 3402 : [Purchase] 사용할수 없는 AndroidJWT
		return H{"result": 3402, "error": err.Error(), "receiptDesc": receiptDesc}
	}

	res, err := client.VerifyProduct(context.Background(), packageName, productID, purchaseToken)
	if err != nil {
		resError := err.(*googleapi.Error)
		// result 3403 : [Purchase] Api Response Error
		return H{"result": 3403, "error": resError, "receiptDesc": receiptDesc}
	}

	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		// result 999 : Database Connection Error
		return H{"result": 999, "receiptDesc": receiptDesc}
	}
	defer db.Close()

	var rs mssql.ReturnStatus
	_, err = db.ExecContext(context.Background(), "dbo.P_Purchase_Insert",
		sql.Named("packageName", packageName),
		sql.Named("productID", productID),
		sql.Named("orderID", res.OrderId),
		sql.Named("errorCode", 0),
		sql.Named("ip", ip),
		&rs,
	)

	if err != nil {
		// result 901 : Proc ExecContext Error
		return H{"result": 901, "error": err.Error(), "receiptDesc": receiptDesc}
	}

	return H{"result": int(rs), "orderId": res.OrderId, "productID": productID, "receiptDesc": receiptDesc}
}
