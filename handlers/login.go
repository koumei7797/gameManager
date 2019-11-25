// handlers/login.go

package handlers

import (
	"fmt"
	"gin-gameManager/sqlprovider"
	"math/rand"
	"net/http"
	"strconv"

	"github.com/gin-contrib/sessions"
	"github.com/gin-gonic/gin"
)

func ShowLogin(c *gin.Context) {
	render(c, gin.H{"url": "../", "title": "Login"}, "login.html")
}

func Login(c *gin.Context) {
	account := c.PostForm("account")
	password := c.PostForm("password")

	if isUserValid(account, password) {
		session := sessions.Default(c)
		session.Set("is_logged_in", true)
		session.Set("account", account)
		session.Save()
		c.Redirect(http.StatusFound, "/project/")
	} else {
		render(c, gin.H{"url": "../", "title": "400 Error", "message": "계정이 존재하지 않거나, 비밀번호가 잘못되었습니다."}, "page_400.html")
	}
}

func Logout(c *gin.Context) {
	// Clear the cookie
	session := sessions.Default(c)
	session.Clear()
	session.Save()

	c.Redirect(http.StatusFound, "/project/")
}

func generateSessionToken() string {
	// We're using a random 16 character string as the session token
	// This is NOT a secure way of generating session tokens
	// DO NOT USE THIS IN PRODUCTION
	return strconv.FormatInt(rand.Int63(), 16)
}

func isUserValid(account, password string) bool {

	db := sqlprovider.Mgr.GetDB()
	if db == nil {
		return false
	}
	defer db.Close()

	query := fmt.Sprintf("SELECT [Password] FROM [T_Account] WHERE [LoginId] = '%s'", account)

	rows, err := db.Query(query)
	if err != nil {
		return false
	}
	defer rows.Close()

	rowCount := 0
	var db_pw string
	for rows.Next() {
		err = rows.Scan(&db_pw)
		if err != nil {
			return false
		}
		rowCount++
	}

	if rowCount == 0 {
		return false
	}

	if password == db_pw {
		return true
	}

	return false
}
