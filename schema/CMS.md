### **1. Extensions & Enums**

```sql
-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Enum definitions
CREATE TYPE role_type AS ENUM ('ROOT_ADMIN', 'CMS_CUSTOMER');
CREATE TYPE system_type AS ENUM ('LMS', 'EMS');
```

---

### **2. Table Creation**

```sql
-- System-wide roles table
CREATE TABLE cms_whole_sys_role (
    role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name role_type NOT NULL
);

-- CMS users table
CREATE TABLE cms_user (
    cms_user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cms_user_name VARCHAR(100) NOT NULL,
    cms_user_email VARCHAR(150) NOT NULL UNIQUE,
    cms_name_space VARCHAR(100),
    password VARCHAR(90) NOT NULL,
    cms_user_role_id UUID NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cms_user_role
        FOREIGN KEY (cms_user_role_id)
            REFERENCES cms_whole_sys_role(role_id) ON DELETE CASCADE
);

-- Customer purchase table
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
```

---

###  **3. Indexes**

```sql
-- Indexes for cms_user
CREATE INDEX idx_cms_user_email ON cms_user USING HASH (cms_user_email);
CREATE INDEX idx_cms_user_id ON cms_user USING HASH (cms_user_id);
CREATE INDEX idx_cms_user_role ON cms_user(cms_user_role_id);

-- Indexes for cms_whole_sys_role
CREATE INDEX idx_role_id ON cms_whole_sys_role USING HASH (role_id);

-- Indexes for cms_cus_purchase
CREATE INDEX idx_purchase_user ON cms_cus_purchase(cms_cus_id);
CREATE INDEX idx_purchase_date ON cms_cus_purchase(purchase_date);
CREATE INDEX idx_purchase_system ON cms_cus_purchase USING HASH (system_name);
```

---

