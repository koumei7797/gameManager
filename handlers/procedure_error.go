// handlers/procedure_error.go

package handlers

import "log"

type ErrorInfo struct {
	Id       int
	Describe string
}

var errInfo []ErrorInfo

func ErrorInit() {
	errInfo = append(errInfo, ErrorInfo{0, "성공"})
	errInfo = append(errInfo, ErrorInfo{401, "잘못된 요청입니다 (Request 객체 생성불가)"})

	errInfo = append(errInfo, ErrorInfo{900, "Proc Exception Error"})
	errInfo = append(errInfo, ErrorInfo{901, "Proc ExecContext Error"})
	errInfo = append(errInfo, ErrorInfo{902, "Proc QueryContext Error"})
	errInfo = append(errInfo, ErrorInfo{903, "Database Query Scan Error"})
	errInfo = append(errInfo, ErrorInfo{904, "Database Query Error"})
	errInfo = append(errInfo, ErrorInfo{999, "Database Connection Error"})

	errInfo = append(errInfo, ErrorInfo{1401, "존재하지 않는 프로젝트 입니다"})
	errInfo = append(errInfo, ErrorInfo{1402, "이미 존재하는 패키지명 입니다"})
	errInfo = append(errInfo, ErrorInfo{1403, "동일한 인앱 상품명이 존재합니다"})
	errInfo = append(errInfo, ErrorInfo{1404, "삭제할 인앱 상품이 존재하지 않습니다"})
	errInfo = append(errInfo, ErrorInfo{1405, "존재하지 않는 배너 입니다"})

	errInfo = append(errInfo, ErrorInfo{2401, "[CS] 존재하지 않는 csName 입니다"})
	errInfo = append(errInfo, ErrorInfo{2402, "[CS] 지급할 아이템이 없습니다"})
	errInfo = append(errInfo, ErrorInfo{2403, "[CS] 존재하지 않는 프로젝트, projectUID 확인이 필요합니다"})

	errInfo = append(errInfo, ErrorInfo{3401, "[Purchase] AndroidJWT 등록되지 않음"})
	errInfo = append(errInfo, ErrorInfo{3402, "[Purchase] 사용할수 없는 AndroidJWT"})
	errInfo = append(errInfo, ErrorInfo{3403, "[Purchase] Api Response Error"})
	errInfo = append(errInfo, ErrorInfo{3404, "[Purchase] 이미 사용한 영수증입니다"})
	errInfo = append(errInfo, ErrorInfo{3405, "[Purchase] 존재하지 않는 productID (상품 추가 필요)"})

	log.Println("handlers.ErrorInit()")
}

func GetErrorDesc(id int) string {
	for _, ve := range errInfo {
		if ve.Id == id {
			return ve.Describe
		}
	}

	return ""
}
