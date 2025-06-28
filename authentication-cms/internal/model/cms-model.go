package models

import (
	"github.com/google/uuid"
	"time"
)

// RoleType Enum types
type RoleType string

const (
	RootAdmin   RoleType = "ROOT_ADMIN"
	CMSCustomer RoleType = "CMS_CUSTOMER"
)

type SystemType string

const (
	LMS SystemType = "LMS"
	EMS SystemType = "EMS"
)

// CmsWholeSysRole represents the cms_whole_sys_role table
type CmsWholeSysRole struct {
	RoleID   uuid.UUID `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"role_id"`
	RoleName RoleType  `gorm:"type:role_type;not null" json:"role_name"`
}

func (CmsWholeSysRole) TableName() string {
	return "cms_whole_sys_role"
}

// CmsUser represents the cms_user table
type CmsUser struct {
	CmsUserID     uuid.UUID `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"cms_user_id"`
	CmsUserName   string    `gorm:"type:varchar(100);not null" json:"cms_user_name"`
	CmsUserEmail  string    `gorm:"type:varchar(150);not null;unique" json:"cms_user_email"`
	CmsNameSpace  *string   `gorm:"type:varchar(100)" json:"cms_name_space"`
	Password      string    `gorm:"type:varchar(90);not null" json:"password"`
	CmsUserRoleID uuid.UUID `gorm:"type:uuid;not null" json:"cms_user_role_id"`
	Verified      bool      `gorm:"default:false" json:"verified"`
	CreatedAt     time.Time `gorm:"default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt     time.Time `gorm:"default:CURRENT_TIMESTAMP" json:"updated_at"`

	CmsUserRole CmsWholeSysRole `gorm:"foreignKey:CmsUserRoleID;references:RoleID;constraint:OnDelete:CASCADE" json:"cms_user_role"`

	Purchases []CmsCusPurchase `gorm:"foreignKey:CmsCusID;references:CmsUserID" json:"purchases"`
}

func (CmsUser) TableName() string {
	return "cms_user"
}

// CmsCusPurchase represents the cms_cus_purchase table
type CmsCusPurchase struct {
	RelationID   uuid.UUID  `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"relation_id"`
	CmsCusID     uuid.UUID  `gorm:"type:uuid;not null" json:"cms_cus_id"`
	SystemName   SystemType `gorm:"type:system_type;not null" json:"system_name"`
	PurchaseDate time.Time  `gorm:"not null;default:CURRENT_TIMESTAMP" json:"purchase_date"`
	CreatedAt    time.Time  `gorm:"default:CURRENT_TIMESTAMP" json:"created_at"`

	CmsCustomer CmsUser `gorm:"foreignKey:CmsCusID;references:CmsUserID;constraint:OnDelete:CASCADE" json:"cms_customer"`
}

func (CmsCusPurchase) TableName() string {
	return "cms_cus_purchase"
}
