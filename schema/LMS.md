

##  1. **Type & Table Creation**

```sql
-- ENUM type
CREATE TYPE lms_role_type AS ENUM ('LMS_ADMIN', 'STUDENT', 'INSTRUCTOR');

-- Role table
CREATE TABLE LMS_USER_Role (
    lms_role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lms_role_name lms_role_type NOT NULL UNIQUE
);

-- LMS Users
CREATE TABLE LMS_USER (
    lms_user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lms_user_email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    lms_role_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tenant_id UUID,
    address TEXT,
    phone_number VARCHAR(100),
    registration_date DATE,
    CONSTRAINT fk_lms_user_role FOREIGN KEY (lms_role_id)
        REFERENCES LMS_USER_Role(lms_role_id) ON DELETE RESTRICT,
    CONSTRAINT fk_lms_user_tenant FOREIGN KEY (tenant_id)
        REFERENCES Tenants(tenant_id) ON DELETE SET NULL
);

-- Tenants
CREATE TABLE Tenants (
    tenant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    namespace VARCHAR(255) UNIQUE NOT NULL,
    cms_owner_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Tenant Members
CREATE TABLE Tenants_Members (
    tm_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lms_user_id UUID NOT NULL,
    tenant_id UUID NOT NULL,
    joined_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_tenant_member_user FOREIGN KEY (lms_user_id)
        REFERENCES LMS_USER(lms_user_id) ON DELETE CASCADE,
    CONSTRAINT fk_tenant_member_tenant FOREIGN KEY (tenant_id)
        REFERENCES Tenants(tenant_id) ON DELETE CASCADE,
    UNIQUE(lms_user_id, tenant_id)
);

-- Course Category
CREATE TABLE Courser_Category (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Course
CREATE TABLE Course (
    course_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_title VARCHAR(150) NOT NULL,
    description TEXT,
    instructor_id UUID NOT NULL,
    overall_rating INT,
    course_category UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    owned_by UUID NOT NULL,
    FOREIGN KEY (course_category) REFERENCES Courser_Category(category_id),
    FOREIGN KEY (instructor_id) REFERENCES LMS_USER(lms_user_id),
    FOREIGN KEY (owned_by) REFERENCES Tenants(tenant_id)
);

-- Namespace Consumer
CREATE TABLE namespace_consumer (
    consumer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lms_user_id UUID NOT NULL,
    namespace VARCHAR(255) NOT NULL DEFAULT 'default_consumer_namespace',
    joined_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_namespace_consumer_user FOREIGN KEY (lms_user_id)
        REFERENCES LMS_USER(lms_user_id) ON DELETE CASCADE,
    UNIQUE(lms_user_id, namespace)
);
```

---

##  2. **Indexes**

```sql
-- LMS_USER
CREATE INDEX idx_lms_user_email ON LMS_USER(lms_user_email);
CREATE INDEX idx_lms_user_role ON LMS_USER(lms_role_id);
CREATE INDEX idx_lms_user_created_at ON LMS_USER(created_at);
CREATE INDEX idx_lms_user_registration_date ON LMS_USER(registration_date);
CREATE INDEX idx_lms_user_phone ON LMS_USER(phone_number);
CREATE INDEX idx_lms_user_role_active ON LMS_USER(lms_role_id, created_at);

-- Tenants
CREATE INDEX idx_tenants_namespace ON Tenants(namespace);
CREATE INDEX idx_tenants_owner ON Tenants(cms_owner_id);
CREATE INDEX idx_tenants_active ON Tenants(is_active);
CREATE INDEX idx_tenants_created_at ON Tenants(created_at);
CREATE INDEX idx_tenants_active_true ON Tenants(tenant_id) WHERE is_active = TRUE;

-- Tenants_Members
CREATE INDEX idx_tenant_members_user ON Tenants_Members(lms_user_id);
CREATE INDEX idx_tenant_members_tenant ON Tenants_Members(tenant_id);
CREATE INDEX idx_tenant_members_joined_date ON Tenants_Members(joined_date);
CREATE INDEX idx_tenant_members_active ON Tenants_Members(is_active);
CREATE INDEX idx_tenant_members_active_user ON Tenants_Members(is_active, lms_user_id);
CREATE INDEX idx_tenant_members_active_tenant ON Tenants_Members(is_active, tenant_id);
CREATE INDEX idx_tenant_members_active_true ON Tenants_Members(lms_user_id, tenant_id) WHERE is_active = TRUE;

-- Course
CREATE INDEX idx_course_instructor ON Course(instructor_id);
CREATE INDEX idx_course_category ON Course(course_category);
CREATE INDEX idx_course_owner ON Course(owned_by);
CREATE INDEX idx_course_title ON Course(course_title);
CREATE INDEX idx_course_created_at ON Course(created_at);
CREATE INDEX idx_course_rating ON Course(overall_rating);
CREATE INDEX idx_course_instructor_category ON Course(instructor_id, course_category);
CREATE INDEX idx_course_owner_category ON Course(owned_by, course_category);

-- Course Category
CREATE INDEX idx_category_name ON Courser_Category(category_name);
CREATE INDEX idx_category_created_at ON Courser_Category(created_at);

-- Namespace Consumer
CREATE INDEX idx_namespace_consumer_user ON namespace_consumer(lms_user_id);
CREATE INDEX idx_namespace_consumer_namespace ON namespace_consumer(namespace);
CREATE INDEX idx_namespace_consumer_active ON namespace_consumer(is_active);
CREATE INDEX idx_namespace_consumer_joined_date ON namespace_consumer(joined_date);
```

---

##  3. **Constraints**

```sql
-- Prevent STUDENT from being tenant members via CHECK (non-deferrable)
ALTER TABLE Tenants_Members
    ADD CONSTRAINT chk_no_student_tenant_members
    CHECK (
        lms_user_id NOT IN (
            SELECT lms_user_id
            FROM LMS_USER u
            JOIN LMS_USER_Role r ON u.lms_role_id = r.lms_role_id
            WHERE r.lms_role_name = 'STUDENT'
        )
    );
```

---

## 4. **Triggers & Functions**

```sql
-- Trigger Function: Prevent student from joining Tenants_Members
CREATE OR REPLACE FUNCTION prevent_student_tenant_membership()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM LMS_USER u
        JOIN LMS_USER_Role r ON r.lms_role_id = u.lms_role_id
        WHERE u.lms_user_id = NEW.lms_user_id
          AND r.lms_role_name = 'STUDENT'
    ) THEN
        RAISE EXCEPTION 'Student cannot be the tenant members';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger Hook
CREATE TRIGGER trg_prevent_student_tenant_membership
BEFORE INSERT OR UPDATE ON Tenants_Members
FOR EACH ROW
EXECUTE FUNCTION prevent_student_tenant_membership();


-- Trigger Function: Auto-assign student to namespace_consumer
CREATE OR REPLACE FUNCTION auto_assign_student_to_namespace_consumer()
RETURNS TRIGGER AS $$
DECLARE
    student_namespace VARCHAR(255);
BEGIN
    IF EXISTS (
        SELECT 1
        FROM LMS_USER_Role r
        WHERE r.lms_role_id = NEW.lms_role_id
          AND r.lms_role_name = 'STUDENT'
    ) THEN
        IF NEW.tenant_id IS NOT NULL THEN
            SELECT namespace INTO student_namespace
            FROM Tenants
            WHERE tenant_id = NEW.tenant_id
              AND is_active = TRUE;

            IF student_namespace IS NOT NULL THEN
                INSERT INTO namespace_consumer (lms_user_id, namespace)
                VALUES (NEW.lms_user_id, student_namespace)
                ON CONFLICT (lms_user_id, namespace) DO NOTHING;
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger Hook
CREATE TRIGGER trg_auto_assign_student_insert
AFTER INSERT ON LMS_USER
FOR EACH ROW
EXECUTE FUNCTION auto_assign_student_to_namespace_consumer();
```

---

