package service

import (
	models "github.com/omop/cms/authentication/internal/model"
	"github.com/omop/cms/authentication/internal/repository"
	"github.com/sirupsen/logrus"
)

type (
	Service interface {
		SignIn(req *models.SignInReq) (*models.TokenResp, error)
		SignUp(req *models.RegisterReq) (*models.TokenResp, error)
		SignOut(userID string) error
		RefreshToken(refreshToken string) (*models.TokenResp, error)
		VerifyUser(token string) error
		SetupMFA(userID string) (*models.MFASetupResp, error)
		VerifyMFA(userID string, token string) (*models.TokenResp, error)
	}
	AuthService struct {
		log  *logrus.Logger
		repo repository.Repo
	}
)

func NewAuthService(log *logrus.Logger, repo repository.Repo) *AuthService {
	return &AuthService{log: log, repo: repo}
}

var _ Service = (*AuthService)(nil)
