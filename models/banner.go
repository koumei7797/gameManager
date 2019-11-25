// models/project-billing.go

package models

import "time"

type Banner struct {
	BannerUID   int       // T_Banner Uid
	Name        string    // 배너 명칭
	Android_URL string    // 안드로이드 App URL
	IOS_URL     string    // iOS App URL
	Image       []byte    // 배너 이미지
	RegTime     time.Time // 등록 시간

	// view element
	Image_DataURI string
}
