package sqlprovider

import (
	"database/sql"
	"fmt"
	"log"
	"net/url"

	_ "github.com/denisenkom/go-mssqldb"
)

type DbMgr interface {
	GetDB() *sql.DB
}

type dbMgr struct {
	dbConnStr string
}

const (
	DB_Name = "GlobalDB"
	DB_ID   = "id"
	DB_PW   = "pw"
	DB_HOST = "127.0.0.1"
	DB_PORT = 1433
)

var Mgr DbMgr = newMgr()

func newMgr() DbMgr {

	// once call
	queryStr := url.Values{}
	queryStr.Add("database", fmt.Sprintf("%s", DB_Name))
	dbURL := &url.URL{
		Scheme:   "sqlserver",
		User:     url.UserPassword(DB_ID, DB_PW),
		Host:     fmt.Sprintf("%s:%d", DB_HOST, DB_PORT),
		RawQuery: queryStr.Encode(),
	}

	dbConnStr := dbURL.String()

	return &dbMgr{dbConnStr: dbConnStr}
}

func open(connStr string) *sql.DB {
	conn, err := sql.Open("sqlserver", connStr)
	if err != nil {
		log.Println(err.Error())
		return nil
	}

	return conn
}

func (mgr *dbMgr) GetDB() *sql.DB {
	return open(mgr.dbConnStr)
}