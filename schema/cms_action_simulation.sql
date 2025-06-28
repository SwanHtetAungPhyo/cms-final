-- Insert initial data
INSERT INTO cms_whole_sys_role (role_name)
VALUES
    ('ROOT_ADMIN'),
    ('CMS_CUSTOMER');

-- Insert admin users
INSERT INTO cms_user (cms_user_name, cms_user_email, password, verified, cms_user_role_id)
VALUES
    ('Super Admin', 'superadmin@company.com',
     crypt('AdminPassword123!', gen_salt('bf')), TRUE,
     (SELECT role_id FROM cms_whole_sys_role WHERE role_name = 'ROOT_ADMIN')),
    ('System Admin', 'sysadmin@company.com',
     crypt('AdminPassword456!', gen_salt('bf')), TRUE,
     (SELECT role_id FROM cms_whole_sys_role WHERE role_name = 'ROOT_ADMIN'));

WITH new_customers AS (
    INSERT INTO cms_user (
                          cms_user_name,
                          cms_user_email,
                          cms_name_space,
                          password,
                          cms_user_role_id,
                          verified
        )
        SELECT
            customer_data.name,
            customer_data.email,
            customer_data.namespace,
            crypt(customer_data.password, gen_salt('bf')),
            (SELECT role_id FROM cms_whole_sys_role WHERE role_name = 'CMS_CUSTOMER'),
            TRUE
        FROM (VALUES
                  ('John Smith', 'john.smith@company.com', 'john_workspace', 'SecurePassword123!'),
                  ('Sarah Johnson', 'sarah.johnson@company.com', 'sarah_workspace', 'AnotherSecurePass456!')
             ) AS customer_data(name, email, namespace, password)
        RETURNING cms_user_id, cms_user_email
),
     purchase_insert AS (
         INSERT INTO cms_cus_purchase (
                                       cms_cus_id,
                                       system_name,
                                       purchase_date
             )
             SELECT
                 nc.cms_user_id,
                 'LMS',
                 CURRENT_TIMESTAMP
             FROM new_customers nc
             WHERE nc.cms_user_email = 'john.smith@company.com'
             RETURNING *
     )
SELECT 'Customers created and purchase made' as result;

SELECT
    u.cms_user_name,
    u.cms_user_email,
    u.cms_name_space,
    r.role_name,
    u.verified,
    u.created_at
FROM cms_user u
         JOIN cms_whole_sys_role r ON u.cms_user_role_id = r.role_id
WHERE r.role_name = 'CMS_CUSTOMER'
ORDER BY u.created_at DESC;


SELECT * FROM  cms_user;




SELECT
    p.relation_id,
    u.cms_user_name,
    u.cms_user_email,
    p.system_name,
    p.purchase_date
FROM cms_cus_purchase p
         JOIN cms_user u ON p.cms_cus_id = u.cms_user_id
ORDER BY p.purchase_date DESC;

SELECT 'd69e2e9e-65ea-47e7-9fe7-7f5b661f069b'::uuid = 'd69e2e9e-65ea-47e7-9fe7-7f5b661f069b'::uuid;
