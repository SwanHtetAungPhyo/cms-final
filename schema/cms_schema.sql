


CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE role_type AS ENUM ('ROOT_ADMIN', 'CMS_CUSTOMER');
CREATE TYPE system_type AS ENUM ('LMS', 'EMS');

CREATE TABLE cms_whole_sys_role (
                                    role_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
                                    role_name role_type NOT NULL
);


CREATE TABLE cms_user (
                          cms_user_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
                          cms_user_name varchar(100) NOT NULL,
                          cms_user_email varchar(150) NOT NULL UNIQUE,
                          cms_name_space varchar(100),
                          password varchar(90) NOT NULL,
                          cms_user_role_id UUID NOT NULL,
                          verified bool DEFAULT FALSE,
                          created_at timestamp DEFAULT CURRENT_TIMESTAMP,
                          updated_at timestamp DEFAULT CURRENT_TIMESTAMP,

                          CONSTRAINT fk_cms_user_role
                              FOREIGN KEY (cms_user_role_id)
                                  REFERENCES cms_whole_sys_role(role_id) ON DELETE CASCADE
);

CREATE TABLE cms_cus_purchase (
                                  relation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                  cms_cus_id UUID NOT NULL,
                                  system_name system_type NOT NULL,
                                  purchase_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

                                  CONSTRAINT fk_cms_purchase_user
                                      FOREIGN KEY (cms_cus_id)
                                          REFERENCES cms_user(cms_user_id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX idx_cms_user_email ON cms_user USING HASH (cms_user_email);
CREATE INDEX idx_cms_user_id ON cms_user USING HASH (cms_user_id);
CREATE INDEX idx_role_id ON cms_whole_sys_role USING HASH (role_id);
CREATE INDEX idx_cms_user_role ON cms_user(cms_user_role_id);
CREATE INDEX idx_purchase_user ON cms_cus_purchase(cms_cus_id);
CREATE INDEX idx_purchase_date ON cms_cus_purchase(purchase_date);
CREATE INDEX idx_purchase_system ON cms_cus_purchase USING HASH (system_name);

