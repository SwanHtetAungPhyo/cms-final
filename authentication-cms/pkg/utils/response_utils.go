package utils

import (
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/sirupsen/logrus"
)

// APIResponse represents the standard API response structure
type APIResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Errors  interface{} `json:"errors,omitempty"`
}

// ResponseHelper handles HTTP responses
type ResponseHelper struct {
	log *logrus.Logger
}

// NewResponseHelper creates a new ResponseHelper instance
func NewResponseHelper(log *logrus.Logger) *ResponseHelper {
	return &ResponseHelper{log: log}
}

// Success sends a successful response
func (r *ResponseHelper) Success(ctx *fiber.Ctx, data interface{}) error {
	response := APIResponse{
		Success: true,
		Message: "Success",
		Data:    data,
	}
	return ctx.Status(http.StatusOK).JSON(response)
}

// SuccessWithMessage sends a successful response with custom message
func (r *ResponseHelper) SuccessWithMessage(ctx *fiber.Ctx, message string, data interface{}) error {
	response := APIResponse{
		Success: true,
		Message: message,
		Data:    data,
	}
	return ctx.Status(http.StatusOK).JSON(response)
}

// Created sends a 201 Created response
func (r *ResponseHelper) Created(ctx *fiber.Ctx, data interface{}) error {
	response := APIResponse{
		Success: true,
		Message: "Created successfully",
		Data:    data,
	}
	return ctx.Status(http.StatusCreated).JSON(response)
}

// BadRequest sends a 400 Bad Request response
func (r *ResponseHelper) BadRequest(ctx *fiber.Ctx, message string) error {
	if r.log != nil {
		r.log.Warn("Bad request: ", message)
	}
	response := APIResponse{
		Success: false,
		Message: message,
	}
	return ctx.Status(http.StatusBadRequest).JSON(response)
}

// Unauthorized sends a 401 Unauthorized response
func (r *ResponseHelper) Unauthorized(ctx *fiber.Ctx, message string) error {
	if r.log != nil {
		r.log.Warn("Unauthorized access: ", message)
	}
	response := APIResponse{
		Success: false,
		Message: message,
	}
	return ctx.Status(http.StatusUnauthorized).JSON(response)
}

// Forbidden sends a 403 Forbidden response
func (r *ResponseHelper) Forbidden(ctx *fiber.Ctx, message string) error {
	if r.log != nil {
		r.log.Warn("Forbidden access: ", message)
	}
	response := APIResponse{
		Success: false,
		Message: message,
	}
	return ctx.Status(http.StatusForbidden).JSON(response)
}

// NotFound sends a 404 Not Found response
func (r *ResponseHelper) NotFound(ctx *fiber.Ctx, message string) error {
	if r.log != nil {
		r.log.Warn("Not found: ", message)
	}
	response := APIResponse{
		Success: false,
		Message: message,
	}
	return ctx.Status(http.StatusNotFound).JSON(response)
}

// InternalServerError sends a 500 Internal Server Error response
func (r *ResponseHelper) InternalServerError(ctx *fiber.Ctx, message string, err error) error {
	if r.log != nil {
		if err != nil {
			r.log.WithError(err).Error("Internal server error: ", message)
		} else {
			r.log.Error("Internal server error: ", message)
		}
	}
	response := APIResponse{
		Success: false,
		Message: "Internal server error",
	}
	return ctx.Status(http.StatusInternalServerError).JSON(response)
}

// ValidationError sends a validation error response
func (r *ResponseHelper) ValidationError(ctx *fiber.Ctx, errors interface{}) error {
	if r.log != nil {
		r.log.Warn("Validation error: ", errors)
	}
	response := APIResponse{
		Success: false,
		Message: "Validation failed",
		Errors:  errors,
	}
	return ctx.Status(http.StatusBadRequest).JSON(response)
}

// ErrorResponse sends a custom error response
func (r *ResponseHelper) ErrorResponse(ctx *fiber.Ctx, statusCode int, message string) error {
	if r.log != nil {
		r.log.Warnf("Error response [%d]: %s", statusCode, message)
	}
	response := APIResponse{
		Success: false,
		Message: message,
	}
	return ctx.Status(statusCode).JSON(response)
}

// Conflict sends a 409 Conflict response
func (r *ResponseHelper) Conflict(ctx *fiber.Ctx, message string) error {
	if r.log != nil {
		r.log.Warn("Conflict: ", message)
	}
	response := APIResponse{
		Success: false,
		Message: message,
	}
	return ctx.Status(http.StatusConflict).JSON(response)
}

// NoContent sends a 204 No Content response
func (r *ResponseHelper) NoContent(ctx *fiber.Ctx) error {
	return ctx.SendStatus(http.StatusNoContent)
}

// Utility functions without ResponseHelper (stateless)

// SendSuccess sends a successful response (stateless)
func SendSuccess(ctx *fiber.Ctx, data interface{}) error {
	response := APIResponse{
		Success: true,
		Message: "Success",
		Data:    data,
	}
	return ctx.Status(http.StatusOK).JSON(response)
}

// SendError sends an error response (stateless)
func SendError(ctx *fiber.Ctx, statusCode int, message string) error {
	response := APIResponse{
		Success: false,
		Message: message,
	}
	return ctx.Status(statusCode).JSON(response)
}

// SendValidationError sends a validation error response (stateless)
func SendValidationError(ctx *fiber.Ctx, errors interface{}) error {
	response := APIResponse{
		Success: false,
		Message: "Validation failed",
		Errors:  errors,
	}
	return ctx.Status(http.StatusBadRequest).JSON(response)
}
