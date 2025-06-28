package main

import (
	"fmt"
	"github.com/gofiber/fiber/v2"
	"github.com/joho/godotenv"
	"github.com/omop/cms/authentication/pkg/utils"
	"log"
	"os"
)

func main() {
	if err := godotenv.Load(); err != nil {
		fmt.Println("Error loading .env file")
	}
	err := utils.LogSetUp()
	if err != nil {
		log.Fatal(err.Error())
		return
	}
	logger := utils.GetLogger()
	utils.InitDatabases()
	app := fiber.New()
	logger.Infof("Server started on port %s", os.Getenv("PORT"))
	if err := app.Listen(":8080"); err != nil {
		log.Fatal(err.Error())
	}
}
