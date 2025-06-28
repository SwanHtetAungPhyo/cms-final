package repository

import (
	models "github.com/omop/cms/authentication/internal/model"
	"github.com/sirupsen/logrus"
	"gorm.io/gorm"
)

type (
	Repo interface {
		CreateUser(user *models.CmsUser) error
		GetUserByEmail(email string) (*models.CmsUser, error)
		GetUserByID(id string) (*models.CmsUser, error)
		UpdateUser(user *models.CmsUser) error
		CreateMFAToken(token *models.MFAToken) error
		GetMFAToken(userID string) (*models.MFAToken, error)
		DeleteMFAToken(userID string) error
	}

	AuthRepo struct {
		log    *logrus.Logger
		RootDB *gorm.DB
		LMS_DB *gorm.DB
	}
)

var _ Repo = (*AuthRepo)(nil)

func NewAuthRepo(log *logrus.Logger, rootDB *gorm.DB, LMS_DB *gorm.DB) *AuthRepo {
	return &AuthRepo{
		log:    log,
		RootDB: rootDB,
		LMS_DB: rootDB,
	}
}
