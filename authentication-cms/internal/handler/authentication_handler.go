package handler

import (
	"github.com/gofiber/fiber/v2"
	models "github.com/omop/cms/authentication/internal/model"
	"github.com/omop/cms/authentication/internal/service"
	"github.com/omop/cms/authentication/pkg/utils"
	"github.com/sirupsen/logrus"
)

type CMSAuthHandler struct {
	log        *logrus.Logger
	authSrv    service.Service
	respHelper *utils.ResponseHelper
}

func NewCMSAuthHandler(log *logrus.Logger, authSrv service.Service) *CMSAuthHandler {
	return &CMSAuthHandler{log: log, authSrv: authSrv}
}

func (c *CMSAuthHandler) SignIn(ctx *fiber.Ctx) error {
	var req *models.SignInReq
	if err := ctx.BodyParser(&req); err != nil {
		return c.respHelper.BadRequest(ctx, "Invalid request body format")
	}
	if req == nil {
		return c.respHelper.BadRequest(ctx, "Request body is required")
	}

	return c.respHelper.Success(ctx, models.TokenResp{})
}

func (c *CMSAuthHandler) SignUp(ctx *fiber.Ctx) error {
	var req *models.RegisterReq
	if err := ctx.BodyParser(&req); err != nil {
		return c.respHelper.BadRequest(ctx, "Invalid request body format")
	}

	return c.respHelper.Success(ctx, models.TokenResp{})
}

func (c *CMSAuthHandler) SignOut(ctx *fiber.Ctx) error {
	// revoke token in redis

	return c.respHelper.Success(ctx, models.TokenResp{})
}

func (c *CMSAuthHandler) RefreshToken(ctx *fiber.Ctx) error {
	return c.respHelper.Success(ctx, models.TokenResp{})
}

func (c *CMSAuthHandler) Verify(ctx *fiber.Ctx) error {
	return c.respHelper.BadRequest(ctx, "Invalid request body format")
}

func (c *CMSAuthHandler) MFASetup(ctx *fiber.Ctx) error {
	return c.respHelper.Success(ctx, models.TokenResp{})
}

func (c *CMSAuthHandler) MFA(ctx *fiber.Ctx) error {
	return c.respHelper.Success(ctx, models.TokenResp{})
}
