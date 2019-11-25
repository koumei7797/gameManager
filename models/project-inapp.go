// models/project-inapp.go

package models

type ProjectInapp struct {
	ProjectUID int    // T_Project Uid
	ProductID  string // 인앱코드
	Title      string // 상품명
	Price      int    // 설정된 가격 [ 한화, 부가세 포함 ]
}
