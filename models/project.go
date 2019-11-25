// models/project.go

package models

import "time"

type T_Project struct {
	ProjectUID     int       // T_Project Uid
	PackageName    string    // 게임 패키지 명 [ 영문 ]
	Name           string    // 게임명 [ 영문 or 한글 ]
	Platform       byte      // 플랫폼 [ 1.Android / 2.iOS ]
	Version        int       // App Version
	Image_Data     []byte    // Project Image base64 Decode Data
	Android_JWT    []byte    // 안드로이드 JWT
	CSRewardType   string    // CS Reward Type
	InappPercent   byte      // 전체 상품에 대해 20%, 30%를 적용할 수 있다
	BannerUID      int       // T_Banner Uid
	LastUpdateTime time.Time // 최종 업데이트 시간
	RegTime        time.Time // 등록 시간

	// view element
	Image_DataURI    string
	Json_Android_JWT string
}
