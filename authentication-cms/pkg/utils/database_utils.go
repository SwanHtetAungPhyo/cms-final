package utils

import (
	"fmt"
	"log"
	"os"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var (
	RootDB *gorm.DB
	LMS    *gorm.DB
)

const (
	maxRetries = 5
	retryDelay = 2 * time.Second
)

func InitDatabases() {
	var err error

	rootDSN := os.Getenv("ROOT_DB_DSN")
	lmsDSN := os.Getenv("LMS_DB_DSN")

	if rootDSN == "" || lmsDSN == "" {
		log.Fatal("Environment variables ROOT_DB_DSN or LMS_DB_DSN are not set")
	}
	RootDB, err = connectWithRetry("RootDB", rootDSN)
	if err != nil {
		log.Fatalf("Failed to connect to RootDB after retries: %v", err)
	}
	LMS, err = connectWithRetry("LMS", lmsDSN)
	if err != nil {
		log.Fatalf("Failed to connect to LMS DB after retries: %v", err)
	}

	fmt.Println("✅ Successfully connected to both databases.")
}

func connectWithRetry(name string, dsn string) (*gorm.DB, error) {
	var db *gorm.DB
	var err error

	for attempt := 1; attempt <= maxRetries; attempt++ {
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
		if err == nil {
			fmt.Printf(" Connected to %s (attempt %d)\n", name, attempt)
			return db, nil
		}

		fmt.Printf(" Failed to connect to %s (attempt %d/%d): %v\n", name, attempt, maxRetries, err)
		time.Sleep(retryDelay)
	}

	return nil, fmt.Errorf("could not connect to %s after %d attempts", name, maxRetries)
}
