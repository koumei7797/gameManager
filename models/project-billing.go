// models/project-billing.go

package models

import "time"

type ProjectBilling struct {
	ProjectUID int       // T_Project Uid
	ProductID  string    // 인앱코드
	OrderID    string    // 주문번호
	ErrorCode  int16     // 에러코드
	IP         string    // ipv4 or ipv6
	RegTime    time.Time // 등록 시간

	Price int // 설정된 가격 [ 한화, 부가세 포함 ]
}

type ByPrice []ProjectBillingChart

func (a ByPrice) Len() int           { return len(a) }
func (a ByPrice) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a ByPrice) Less(i, j int) bool { return a[i].Price < a[j].Price }

type ProjectBillingChart struct {
	ProductID string // 인앱코드
	Price     int    // 설정된 가격 [ 한화, 부가세 포함 ]
	Count     int    // 수량
}
