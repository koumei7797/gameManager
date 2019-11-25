// handlers/project-cs.go

package handlers

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"gin-gameManager/models"
	"gin-gameManager/sqlprovider"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/denisenkom/go-mssqldb"
	"github.com/gin-gonic/gin"
)

func selectCSNameQuery(projectUID int, csName string) []models.ProjectCS {
	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		return nil
	}
	defer db.Close()

	query := fmt.Sprintf("SELECT [CsName], [IP], [RegTime] FROM T_CS WHERE [ProjectUID] = %d AND [CsName] like '%s%s%s'", projectUID, "%", csName, "%")
	rows, err := db.Query(query)
	if err != nil {
		return nil
	}
	defer rows.Close()

	var item models.ProjectCS
	var array []models.ProjectCS

	for rows.Next() {
		err = rows.Scan(&item.CsName, &item.IP, &item.RegTime)
		if err != nil {
			return nil
		}
		item.ProjectUID = projectUID
		array = append(array, item)
	}

	return array
}

// CS 페이징 쿼리
func selectCSQuery(projectUID, requestPage int) (models.PageInfo, []models.ProjectCS) {

	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		return models.PageInfo{}, nil
	}
	defer db.Close()

	query := fmt.Sprintf("SELECT COUNT(*) FROM T_CS WHERE [ProjectUID] = %d", projectUID)
	rows, err := db.Query(query)
	if err != nil {
		return models.PageInfo{}, nil
	}
	defer rows.Close()

	var count int
	for rows.Next() {
		err = rows.Scan(&count)
		if err != nil {
			return models.PageInfo{}, nil
		}
	}

	// 총 페이지 카운트
	totalPageCount := count / COUNT_PER_PAGE
	// 시작 페이지
	beginPage := (requestPage-1)/COUNT_PER_PAGE*COUNT_PER_PAGE + 1
	// 끝 페이지
	endPage := beginPage + (COUNT_PER_PAGE - 1)
	if endPage > totalPageCount {
		endPage = totalPageCount
	}

	var pageInfo models.PageInfo
	pageInfo.BeginPage = beginPage
	pageInfo.EndPage = endPage
	pageInfo.TotalPage = totalPageCount

	query = fmt.Sprintf("SELECT [CsName], [IP], [RegTime] FROM (SELECT ROW_NUMBER() OVER (ORDER BY RegTime DESC) AS ROW_NUM, * FROM T_CS) A WHERE [ProjectUID] = %d", projectUID)
	query = fmt.Sprintf("%s AND ROW_NUM > (%d * %d)", query, COUNT_PER_PAGE, requestPage-1)
	query = fmt.Sprintf("%s AND ROW_NUM <= (%d * (%d + 1))", query, COUNT_PER_PAGE, requestPage-1)

	rows, err = db.Query(query)
	if err != nil {
		return models.PageInfo{}, nil
	}
	defer rows.Close()

	var item models.ProjectCS
	var array []models.ProjectCS

	for rows.Next() {
		err = rows.Scan(&item.CsName, &item.IP, &item.RegTime)
		if err != nil {
			return models.PageInfo{}, nil
		}
		item.ProjectUID = projectUID
		array = append(array, item)
	}

	return pageInfo, array
}

// CS Detail [ T_CS_Reward ]
func selectCSDetailQuery(projectUID int, csName string) ([]models.ProjectCSReward, error) {

	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		return nil, fmt.Errorf("not found sqlserver")
	}
	defer db.Close()

	query := fmt.Sprintf("SELECT [RewardObj], [InsertedTime], ISNULL([GettingTime],'1900-01-01') AS GettingTime, [Memo] FROM [T_CS_Reward] WHERE [ProjectUID] = %d AND [CsName] = '%s'", projectUID, csName)
	rows, err := db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var array []models.ProjectCSReward
	var item models.ProjectCSReward
	for rows.Next() {
		err = rows.Scan(&item.RewardObj, &item.InsertedTime, &item.GettingTime, &item.Memo)
		if err != nil {
			return nil, err
		}
		item.ProjectUID = projectUID
		item.CsName = csName

		if item.GettingTime.Year() == 1900 {
			item.View_Getting = "None"
		} else {
			item.View_Getting = item.GettingTime.Format("2006-01-02 15:04")
		}

		array = append(array, item)
	}

	return array, nil
}

func SearchCS(c *gin.Context) {
	account := getAccount(c)
	csName := c.PostForm("csName")

	project, err := selectProject(c.Param("ProjectUID"))
	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	//log.Print(project, account)

	csArray := selectCSNameQuery(project.ProjectUID, csName)
	pageInfo := models.PageInfo{}
	pageInfo.BeginPage = 1
	pageInfo.EndPage = 0
	pageInfo.TotalPage = 0

	render(c, gin.H{"url": "../../../",
		"account":           account,
		"projectUID":        project.ProjectUID,
		"title":             project.Name,
		"name":              project.Name,
		"packageName":       project.PackageName,
		"image_DataURI":     project.Image_DataURI,
		"csRewardTypeArray": strings.Split(project.CSRewardType, ","),
		"csArray":           csArray,
		"pageInfo":          pageInfo,
		"page":              1}, "project-cs.html")
}

func GetProjectCS(c *gin.Context) {
	account := getAccount(c)

	project, err := selectProject(c.Param("ProjectUID"))
	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	page, err := strconv.Atoi(c.Param("Page"))
	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}

	pageInfo, csArray := selectCSQuery(project.ProjectUID, page)

	render(c, gin.H{"url": "../../../",
		"account":           account,
		"projectUID":        project.ProjectUID,
		"title":             project.Name,
		"name":              project.Name,
		"packageName":       project.PackageName,
		"image_DataURI":     project.Image_DataURI,
		"csRewardTypeArray": strings.Split(project.CSRewardType, ","),
		"csArray":           csArray,
		"pageInfo":          pageInfo,
		"page":              page}, "project-cs.html")
}

func GetProjectCSDetail(c *gin.Context) {
	account := getAccount(c)

	project, err := selectProject(c.Param("ProjectUID"))
	if err != nil {
		Error400(c, "../../../", err.Error())
		return
	}

	csName := c.Param("CsName")
	array, err := selectCSDetailQuery(project.ProjectUID, csName)
	if err != nil {
		Error400(c, "../../../", err.Error())
		return
	}

	time2000, _ := time.Parse(time.RFC3339, "2000-01-01T00:00:00+00:00")

	render(c, gin.H{"url": "../../../",
		"account":           account,
		"projectUID":        project.ProjectUID,
		"title":             project.Name,
		"name":              project.Name,
		"packageName":       project.PackageName,
		"image_DataURI":     project.Image_DataURI,
		"csRewardTypeArray": strings.Split(project.CSRewardType, ","),
		"csDetailArray":     array,
		"csName":            csName,
		"time2000":          time2000}, "project-cs-detail.html")
}

func SetCSReward(c *gin.Context) {
	projectUID := c.PostForm("projectUID")
	csName := c.PostForm("csName")
	typeS := c.PostForm("type")
	value := c.PostForm("value")
	memo := c.PostForm("memo")

	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}
	defer db.Close()

	i, _ := strconv.Atoi(value)
	obj := models.TypeValueObj{typeS, i}
	// Encoding
	jsonBytes, err := json.Marshal(obj)
	if err != nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}
	jsonString := string(jsonBytes)

	var rs mssql.ReturnStatus
	_, err = db.ExecContext(context.Background(), "dbo.P_CS_Reward_Insert",
		sql.Named("projectUID", projectUID),
		sql.Named("csName", csName),
		sql.Named("rewardObj", jsonString),
		sql.Named("memo", memo),
		&rs,
	)

	if err != nil {
		Error400(c, "../../../../", err.Error())
	}

	location := fmt.Sprintf("/project/%s/cs-detail/%s", projectUID, csName)
	c.Redirect(http.StatusFound, location)
}

func SetCSRewardType(c *gin.Context) {
	projectUID := c.PostForm("projectUID")
	rewardType := c.PostForm("rewardType")

	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		c.AbortWithStatus(http.StatusBadRequest)
	}
	defer db.Close()

	rewardType = strings.Replace(rewardType, " ", "", 100)

	var rs mssql.ReturnStatus
	_, err := db.ExecContext(context.Background(), "dbo.P_CS_RewardType_Update",
		sql.Named("projectUID", projectUID),
		sql.Named("rewardType", rewardType),
		&rs,
	)

	if err != nil {
		Error400(c, "../../../", err.Error())
	}

	location := fmt.Sprintf("/project/%s/cs/1", projectUID)
	c.Redirect(http.StatusFound, location)
}
