package utils

import (
	"io"
	"os"
	"path/filepath"
	"time"

	"github.com/sirupsen/logrus"
	"gopkg.in/natefinch/lumberjack.v2"
)

var logger *logrus.Logger

func LogSetUp() error {
	logger = logrus.New()

	logDir := "logs"
	if err := os.MkdirAll(logDir, 0755); err != nil {
		return err
	}

	logFile := filepath.Join(logDir, time.Now().Format("2006-01-02")+".log")

	lumberjackLogger := &lumberjack.Logger{
		Filename:   logFile,
		MaxSize:    10,   // megabytes
		MaxBackups: 30,   // number of backups
		MaxAge:     30,   // days
		Compress:   true, // compress old files
	}

	multiWriter := io.MultiWriter(os.Stdout, lumberjackLogger)
	logger.SetOutput(multiWriter)

	logger.SetFormatter(&logrus.TextFormatter{
		FullTimestamp:   true,
		TimestampFormat: "2006-01-02 15:04:05",
	})

	logger.SetLevel(logrus.InfoLevel)

	return nil
}

func GetLogger() *logrus.Logger {
	return logger
}

// Helper functions for different log levels
func LogInfo(args ...interface{}) {
	logger.Info(args...)
}

func LogError(args ...interface{}) {
	logger.Error(args...)
}

func LogWarn(args ...interface{}) {
	logger.Warn(args...)
}

func LogDebug(args ...interface{}) {
	logger.Debug(args...)
}

func LogFatal(args ...interface{}) {
	logger.Fatal(args...)
}

func LogInfof(format string, args ...interface{}) {
	logger.Infof(format, args...)
}

func LogErrorf(format string, args ...interface{}) {
	logger.Errorf(format, args...)
}

func LogWarnf(format string, args ...interface{}) {
	logger.Warnf(format, args...)
}

func LogDebugf(format string, args ...interface{}) {
	logger.Debugf(format, args...)
}

func LogFatalf(format string, args ...interface{}) {
	logger.Fatalf(format, args...)
}
