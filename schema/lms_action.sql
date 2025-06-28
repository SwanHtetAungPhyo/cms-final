CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Truncate tables in correct order to avoid foreign key issues
TRUNCATE TABLE Course, Tenants_Members, namespace_consumer, LMS_USER, Courser_Category, LMS_USER_Role, Tenants CASCADE;

-- Insert roles
INSERT INTO LMS_USER_Role (lms_role_id, lms_role_name)
VALUES
    (gen_random_uuid(), 'LMS_ADMIN'),
    (gen_random_uuid(), 'STUDENT'),
    (gen_random_uuid(), 'INSTRUCTOR');

-- Insert tenants (including a dedicated student tenant)
INSERT INTO Tenants (
    tenant_id,
    namespace,
    cms_owner_id,
    is_active
) VALUES
      ('571bd1a7-0bc9-47b1-bc46-2aae5bf59d6a'::uuid,
       'john_workspace',
       'd69e2e9e-65ea-47e7-9fe7-7f5b661f069b'::uuid,
       TRUE),
      ('672bd2b8-1cd0-58c2-cd57-3bbf6cf60e7b'::uuid,
       'student_consumer_namespace',
       'd69e2e9e-65ea-47e7-9fe7-7f5b661f069b'::uuid,
       TRUE);

-- Insert users with tenant_id for students
INSERT INTO LMS_USER (lms_user_email, password, lms_role_id, address, phone_number, registration_date, tenant_id)
VALUES
    ('lms.admin@company.com',
     crypt('AdminPass123!', gen_salt('bf')),
     (SELECT lms_role_id FROM LMS_USER_Role WHERE lms_role_name = 'LMS_ADMIN'),
     '123 Admin Street, Tech City, TC 12345',
     '+1-555-0101',
     CURRENT_DATE,
     NULL),
    ('student1@company.com',
     crypt('StudentPass123!', gen_salt('bf')),
     (SELECT lms_role_id FROM LMS_USER_Role WHERE lms_role_name = 'STUDENT'),
     '456 Student Ave, Learn City, LC 67890',
     '+1-555-0201',
     CURRENT_DATE,
     '672bd2b8-1cd0-58c2-cd57-3bbf6cf60e7b'::uuid), -- Student tenant
    ('instructor1@company.com',
     crypt('InstructorPass123!', gen_salt('bf')),
     (SELECT lms_role_id FROM LMS_USER_Role WHERE lms_role_name = 'INSTRUCTOR'),
     '789 Teacher Blvd, Edu Town, ET 54321',
     '+1-555-0301',
     CURRENT_DATE,
     NULL),
    ('student2@company.com',
     crypt('StudentPass456!', gen_salt('bf')),
     (SELECT lms_role_id FROM LMS_USER_Role WHERE lms_role_name = 'STUDENT'),
     '321 Learning Lane, Study City, SC 98765',
     '+1-555-0202',
     CURRENT_DATE - INTERVAL '30 days',
     '672bd2b8-1cd0-58c2-cd57-3bbf6cf60e7b'::uuid), -- Student tenant
    ('instructor2@company.com',
     crypt('InstructorPass456!', gen_salt('bf')),
     (SELECT lms_role_id FROM LMS_USER_Role WHERE lms_role_name = 'INSTRUCTOR'),
     '654 Faculty Row, Teach Town, TT 13579',
     '+1-555-0302',
     CURRENT_DATE - INTERVAL '15 days',
     NULL),
    ('student3@company.com',
     crypt('StudentPass789!', gen_salt('bf')),
     (SELECT lms_role_id FROM LMS_USER_Role WHERE lms_role_name = 'STUDENT'),
     '987 Study Street, Knowledge City, KC 24680',
     '+1-555-0203',
     CURRENT_DATE - INTERVAL '7 days',
     '672bd2b8-1cd0-58c2-cd57-3bbf6cf60e7b'::uuid); -- Student tenant

-- Insert tenant members (ONLY non-students can be tenant members)
INSERT INTO Tenants_Members (lms_user_id, tenant_id, is_active)
SELECT
    u.lms_user_id,
    '571bd1a7-0bc9-47b1-bc46-2aae5bf59d6a'::uuid,
    TRUE
FROM LMS_USER u
         JOIN LMS_USER_Role r ON u.lms_role_id = r.lms_role_id
WHERE u.lms_user_email IN ('lms.admin@company.com', 'instructor1@company.com', 'instructor2@company.com')
  AND r.lms_role_name != 'STUDENT'; -- Ensure no students

-- Insert course categories
INSERT INTO Courser_Category (category_name, description, updated_at)
VALUES
    ('Programming', 'Software development and programming languages', CURRENT_TIMESTAMP),
    ('Data Science', 'Data analysis, machine learning, and statistics', CURRENT_TIMESTAMP),
    ('Web Development', 'Frontend and backend web development', CURRENT_TIMESTAMP),
    ('Database Management', 'Database design, SQL, and data modeling', CURRENT_TIMESTAMP),
    ('Cloud Computing', 'Cloud platforms and distributed systems', CURRENT_TIMESTAMP),
    ('Cybersecurity', 'Information security and ethical hacking', CURRENT_TIMESTAMP);

-- Insert courses (same as your original)
INSERT INTO Course (
    course_title,
    description,
    instructor_id,
    overall_rating,
    course_category,
    updated_at,
    owned_by
)
SELECT
    'Introduction to PostgreSQL',
    'Learn the fundamentals of PostgreSQL database management system',
    u.lms_user_id,
    4,
    cc.category_id,
    CURRENT_TIMESTAMP,
    '571bd1a7-0bc9-47b1-bc46-2aae5bf59d6a'::uuid
FROM LMS_USER u, Courser_Category cc
WHERE u.lms_user_email = 'instructor1@company.com'
  AND cc.category_name = 'Database Management';

INSERT INTO Course (
    course_title,
    description,
    instructor_id,
    overall_rating,
    course_category,
    updated_at,
    owned_by
)
SELECT
    'Python for Beginners',
    'Learn Python programming from scratch with hands-on examples',
    u.lms_user_id,
    5,
    cc.category_id,
    CURRENT_TIMESTAMP,
    '571bd1a7-0bc9-47b1-bc46-2aae5bf59d6a'::uuid
FROM LMS_USER u, Courser_Category cc
WHERE u.lms_user_email = 'instructor1@company.com'
  AND cc.category_name = 'Programming';

INSERT INTO Course (
    course_title,
    description,
    instructor_id,
    overall_rating,
    course_category,
    updated_at,
    owned_by
)
SELECT
    'Web Development with React',
    'Build modern web applications using React and JavaScript',
    u.lms_user_id,
    4,
    cc.category_id,
    CURRENT_TIMESTAMP,
    '571bd1a7-0bc9-47b1-bc46-2aae5bf59d6a'::uuid
FROM LMS_USER u, Courser_Category cc
WHERE u.lms_user_email = 'instructor2@company.com'
  AND cc.category_name = 'Web Development';

INSERT INTO Course (
    course_title,
    description,
    instructor_id,
    overall_rating,
    course_category,
    updated_at,
    owned_by
)
SELECT
    'Data Analysis with Python',
    'Learn data analysis techniques using Python pandas and numpy',
    u.lms_user_id,
    5,
    cc.category_id,
    CURRENT_TIMESTAMP,
    '571bd1a7-0bc9-47b1-bc46-2aae5bf59d6a'::uuid
FROM LMS_USER u, Courser_Category cc
WHERE u.lms_user_email = 'instructor2@company.com'
  AND cc.category_name = 'Data Science';

INSERT INTO Course (
    course_title,
    description,
    instructor_id,
    overall_rating,
    course_category,
    updated_at,
    owned_by
)
SELECT
    'Cloud Computing Fundamentals',
    'Introduction to cloud computing concepts and AWS services',
    u.lms_user_id,
    4,
    cc.category_id,
    CURRENT_TIMESTAMP,
    '571bd1a7-0bc9-47b1-bc46-2aae5bf59d6a'::uuid
FROM LMS_USER u, Courser_Category cc
WHERE u.lms_user_email = 'instructor1@company.com'
  AND cc.category_name = 'Cloud Computing';

-- Verification queries
SELECT 'Users Created:' as info, COUNT(*) as count FROM LMS_USER;
SELECT 'Tenant Members (Non-Students Only):' as info, COUNT(*) as count FROM Tenants_Members;
SELECT 'Namespace Consumers (Students Only):' as info, COUNT(*) as count FROM namespace_consumer;
SELECT 'Course Categories:' as info, COUNT(*) as count FROM Courser_Category;
SELECT 'Courses Created:' as info, COUNT(*) as count FROM Course;

-- Display all courses with instructor and category details
SELECT
    c.course_title,
    u.lms_user_email as instructor_email,
    cc.category_name,
    c.overall_rating,
    c.created_at
FROM Course c
         JOIN LMS_USER u ON c.instructor_id = u.lms_user_id
         JOIN Courser_Category cc ON c.course_category = cc.category_id
ORDER BY c.created_at;

-- Show students in namespace_consumer
SELECT
    u.lms_user_email,
    nc.namespace,
    nc.joined_date,
    nc.is_active
FROM namespace_consumer nc
         JOIN LMS_USER u ON nc.lms_user_id = u.lms_user_id
ORDER BY nc.joined_date;

-- Show tenant members (should be non-students only)
SELECT
    u.lms_user_email,
    r.lms_role_name,
    t.namespace,
    tm.joined_date
FROM Tenants_Members tm
         JOIN LMS_USER u ON tm.lms_user_id = u.lms_user_id
         JOIN LMS_USER_Role r ON u.lms_role_id = r.lms_role_id
         JOIN Tenants t ON tm.tenant_id = t.tenant_id
ORDER BY tm.joined_date;