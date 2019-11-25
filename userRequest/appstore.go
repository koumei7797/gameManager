// userRequest/appstore.go

package userRequest

import (
	"context"
	"database/sql"

	"github.com/awa/go-iap/appstore"

	"gin-gameManager/sqlprovider"

	"github.com/denisenkom/go-mssqldb"
)

// Binding from JSON
type PurchaseAppstore struct {
	PackageName string `json:"packageName" binding:"required"`
	ReceiptData string `json:"receiptData" binding:"required"`
	ReceiptDesc string `json:"receiptDesc"`
}

func AppstoreProcess(packageName, receiptData, receiptDesc, ip string) map[string]interface{} {
	client := appstore.New()
	req := appstore.IAPRequest{
		ReceiptData: receiptData,
	}
	res := &appstore.IAPResponse{}
	err := client.Verify(context.Background(), req, res)
	if err != nil {
		return H{"result": 999, "error": err.Error(), "receiptDesc": receiptDesc}
	}

	if res.Status == 0 {

		if res.Receipt.InApp != nil {

			db := sqlprovider.Mgr.GetDB()
			if db == nil {
				// result 999 : Database Connection Error
				return H{"result": 999, "receiptDesc": receiptDesc}
			}
			defer db.Close()

			for i := range res.Receipt.InApp {
				purchaseInfo := res.Receipt.InApp[i]

				var rs mssql.ReturnStatus
				_, err = db.ExecContext(context.Background(), "dbo.P_Purchase_Insert",
					sql.Named("packageName", packageName),
					sql.Named("productID", purchaseInfo.ProductID),
					sql.Named("orderID", purchaseInfo.TransactionID),
					sql.Named("errorCode", res.Status),
					sql.Named("ip", ip),
					&rs,
				)

				if err != nil {
					// result 901 : Proc ExecContext Error
					return H{"result": 901, "error": err.Error(), "receiptDesc": receiptDesc}
				}

				if rs != 0 {
					// fail
					return H{"result": int(rs), "receiptDesc": receiptDesc}
				}

				// success
				return H{"result": res.Status, "transactionID": purchaseInfo.TransactionID, "productID": purchaseInfo.ProductID, "receiptDesc": receiptDesc}
			}
		} else {
			// fail
			return H{"result": 21003, "receiptDesc": receiptDesc}
		}
	}

	// fail
	return H{"result": res.Status, "receiptDesc": receiptDesc}
}
