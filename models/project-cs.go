// models/project-cs.go

package models

import (
	"fmt"
	"time"
)

type ProjectCS struct {
	ProjectUID int       // T_Project Uid
	CsName     string    // 12자리 [A-Z,0-9] 난수
	IP         string    // ipv4 or ipv6
	RegTime    time.Time // 등록 시간
}

type ProjectCSReward struct {
	ProjectUID   int       // T_Project Uid
	CsName       string    // 12자리 [A-Z,0-9] 난수
	RewardObj    string    // 보상 오브젝트 [ Type Value json ]
	InsertedTime time.Time // 지급 시간
	GettingTime  time.Time // 받은 시간
	Memo         string    // 메모

	View_Getting string
}

type PageInfo struct {
	BeginPage int
	EndPage   int
	TotalPage int
}

type TypeValueObj struct {
	Type  string `json:"type"`
	Value int    `json:"value"`
}

func (p PageInfo) String() string {
	return fmt.Sprintf("PageInfo ( BeginPage : %d, EndPage : %d, TotalPage : %d)", p.BeginPage, p.EndPage, p.TotalPage)
}

func (p PageInfo) PrevBeginPage() int {
	return p.BeginPage - int(1)
}

func (p PageInfo) NextEndPage() int {
	return p.EndPage + int(1)
}

func (p PageInfo) Pagenation() []int {
	var pageRow = make([]int, p.EndPage-p.BeginPage+1)
	for i := 0; p.BeginPage+int(i) <= p.EndPage; i++ {
		pageRow[i] = p.BeginPage + int(i)
	}
	return pageRow
}
