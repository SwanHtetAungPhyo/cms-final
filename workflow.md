# Proposal: World Machine Model

# **World**
* **Users:** People who want a ready-made system (e.g., LMS) from the CMS platform.
* **Provider (CMS Owner):** The owner/admin of the CMS who offers the ready-made system.

---

# **Machine**

* Home page of the CMS platform.
* User registration and request submission to CMS Owner (CMS Admin).
* CMS Admin reviews and approves the request.
* After approval, a new subsystem URL is generated:
  `http://www.cms.com/lms/<request-entity-name>/`

---

### Database Architecture

* **Two databases are used:**

    1. **CMS Database**

        * Stores metadata related to the CMS system itself.
        * Stores CMS admin data.
        * Stores data of users who requested LMS subsystems (tracking requests).
    2. **LMS Database (per user request)**

        * Stores all data related to the newly generated LMS instance.
        * All users and content related to that LMS live here.
---
### Routing and Namespace
* Routing is handled by an **API Gateway**.
* The **namespace** corresponds to the specific subsystem name (e.g., LMS instance).
* This allows many LMS instances owned by different users to coexist under the same CMS domain, separated by namespaces.


