package main


func TestPurchase(t *testing.T) {

	project, _ := handlers.GlobalSelect(6)

	purchaseToken := string("TestToken")

	purchase.PlaystoreProcess(project[0].PackageName, "test_gold_1000", purchaseToken, "receiptDesc", project[0].Android_JWT)
}
*/
