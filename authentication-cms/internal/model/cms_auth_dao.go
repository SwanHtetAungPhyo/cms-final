package models

type (
	SignInReq struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}
	MFAReq struct {
		Token string `json:"token"`
	}
	RegisterReq struct {
		Username  string `json:"username"`
		Email     string `json:"email"`
		Password  string `json:"password"`
		NameSpace string `json:"name_space"`
	}
	MFAToken struct {
		Code string `json:"code"`
	}
	TokenResp struct {
		AccessToken  string `json:"access_token"`
		RefreshToken string `json:"refresh_token"`
		ExpiresIn    int64  `json:"expires_in"`
	}
	UserMetaData struct {
	}
)
