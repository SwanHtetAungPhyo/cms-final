CREATE EXTENSION IF NOT EXISTS pgcrypto;


INSERT INTO "CMS_AUTH".public.cms_whole_sys_role (role_id, role_name)
VALUES
    (gen_random_uuid(), 'ROOT_ADMIN'),
    (gen_random_uuid(), 'CMS_CUSTOMER');

INSERT INTO "CMS_AUTH".public.cms_user (cms_user_id, cms_user_name, cms_user_email, password, verified, cms_user_role_id)
VALUES
    (gen_random_uuid(), 'Super Admin', 'superadmin@company.com', 'hashed_password_here', TRUE,
     (SELECT role_id FROM "CMS_AUTH".public.cms_whole_sys_role WHERE role_name = 'ROOT_ADMIN')),
    (gen_random_uuid(), 'System Admin', 'sysadmin@company.com', 'hashed_password_here', TRUE,
     (SELECT role_id FROM "CMS_AUTH".public.cms_whole_sys_role WHERE role_name = 'ROOT_ADMIN'));



-- CTE FOR Insert and verify
WITH new_customers AS (
    INSERT INTO cms_user (
                          cms_user_id,
                          cms_user_name,
                          cms_user_email,
                          cms_name_space,
                          password,
                          cms_user_role_id,
                          verified
        )
        SELECT
            gen_random_uuid(),
            customer_data.name,
            customer_data.email,
            customer_data.namespace,
            crypt(customer_data.password, gen_salt('bf')),
            role.role_id,
            TRUE
        FROM
            (SELECT role_id FROM cms_whole_sys_role WHERE role_name = 'CMS_CUSTOMER') role,
            (VALUES
                 ('John Smith', 'john.smith@company.com', 'john_workspace', 'SecurePassword123!'),
                 ('Sarah Johnson', 'sarah.johnson@company.com', 'sarah_workspace', 'AnotherSecurePass456!')
            ) AS customer_data(name, email, namespace, password)
        RETURNING cms_user_id, cms_user_email
),
purchase_insert AS (
    INSERT INTO  cms_cus_purchase (
                                   relation_id,
                                   cms_cus_id,
                                   system_name,
                                   purchase_date,
                                   created_at
        )
    SELECT
        gen_random_uuid(),
        nc.cms_user_id,
        'LMS'
    FROM new_customers nc
    WHERE nc.cms_user_email = 'john.smith@company.com'
    RETURNING  *
)
SELECT 'Customers created and purchase made' as result;


SELECT
    u.cms_user_name,
    u.cms_user_email,
    u.cms_name_space,
    cwsr.role_name,
    u.verified,
    u.created_at
FROM
    cms_user u
JOIN public.cms_whole_sys_role cwsr on u.cms_user_role_id = cwsr.role_id
WHERE cwsr.role_name = 'CMS_CUSTOMER'
ORDER BY u.created_at DESC;
SELECT
    p.relation_id,
    u.cms_user_name,
    u.cms_user_email,
    p.system_name,
    p.purchase_date
FROM cms_cus_purchase p
         JOIN cms_user u ON p.cms_cus_id = u.cms_user_id
ORDER BY p.purchase_date DESC;