
# Azure VM + Keycloak + OAuth2 Proxy + Nginx + Postgres

## Overview
This project provisions an Azure environment hosting:
- **Keycloak** for identity and access management
- **PostgreSQL** as Keycloak’s database
- **OAuth2 Proxy** for integrating Keycloak authentication with a static website
- **Nginx** serving a protected static page

The setup uses:
- **Terraform** for all infrastructure provisioning
- **Ansible** for VM configuration and container deployment
- **Docker Compose** for running containers
- **GitHub Actions** for fully automated apply, deploy, and destroy pipelines

## Component Choices

### Infrastructure
- **Azure Resource Group, Public IP, NSG, VM** – Minimal cloud footprint to run containers securely
- **NSG Rules** – Allow inbound:
  - `22` – SSH administration
  - `80` – HTTP redirect to HTTPS
  - `443` – HTTPS to Nginx
  - `8080` – Optional debug / HTTP testing
  - `8443` – Keycloak HTTPS
- **Remote Terraform Backend** – Azure Storage Account + Blob Container for storing state

### Container Services
- **PostgreSQL** – Official `postgres:14` image, reliable Keycloak database
- **Keycloak** – Official `quay.io/keycloak/keycloak:20.0.3` image, configured for HTTPS
- **OAuth2 Proxy** – `quay.io/oauth2-proxy/oauth2-proxy` for OIDC integration between Nginx and Keycloak
- **Nginx** – `nginx:alpine` serving static HTML, configured to require authentication via OAuth2 Proxy

---

## Why Not Other Components?
- **AKS / Kubernetes** – Overkill for single-VM test scenario
- **Managed Database** – Containerized Postgres reduces cost and simplifies testing
- **Application Gateway / Front Door** – Nginx with TLS termination is sufficient

---

## Network Configuration
- **Public IP** assigned to VM
- **NSG inbound rules**:
  - `22` – SSH administration
  - `80` – HTTP redirect to HTTPS
  - `443` – HTTPS to Nginx
  - `8080` – Optional for HTTP testing
  - `8443` – Keycloak HTTPS admin/UI

---

## Container Environment Choice
**Docker Compose** chosen for:
- Minimal setup complexity
- Easy orchestration for 4 services on one VM
- Ansible integration via templates and commands

---

## GitHub Actions Workflows

### terraform-apply
1. Bootstrap Terraform backend in Azure Storage
2. Provision:
   - Resource Group
   - Public IP
   - Network Security Group
   - Virtual Network & Subnet
   - Linux VM
3. Output public IP & admin username

### ansible-deploy
1. SSH into VM
2. Install Docker Engine + Compose plugin
3. Generate TLS certificates
4. Deploy Postgres, Keycloak, OAuth2 Proxy, Nginx via `docker compose`
5. Configure Keycloak realm, client, and test user
6. Restart stack with updated OAuth2 Proxy client secret

### terraform-destroy
1. Destroy main infrastructure
2. Destroy backend Terraform storage (if desired)
3. Force delete Resource Group if still present

---

## How It Works
1. User accesses `https://<vm_ip>/`
2. Nginx `auth_request` sends sub-request to OAuth2 Proxy
3. OAuth2 Proxy redirects to Keycloak login
4. Keycloak authenticates user against its realm
5. On success, OAuth2 Proxy passes request back to Nginx
6. Nginx serves static HTML page

---

## Possible Extensions
- Use Let's Encrypt for automatic TLS certificates
- Use a managed PostgreSQL service for convenience
- Automate Keycloak user creation from a file or script
- AKS migration for scale

---

## Running the Project

### Prerequisites
- Azure subscription (**Free Tier** works)
- GitHub repository **secrets** set:
  - `AZURE_CREDENTIALS`
  - `SSH_PUBLIC_KEY`
  - `SSH_PRIVATE_KEY`
  - `KC_ADMIN_USER`
  - `KC_ADMIN_PASS`
- GitHub repository **variables** set:
  - `BACKEND_RG`
  - `BACKEND_SA`
  - `BACKEND_CN`
  - `BACKEND_KEY`
  - `TF_LOCATION`
  - `VM_ADMIN_USERNAME`

### Steps
1. Run `terraform-apply` workflow
2. Run `ansible-deploy` workflow
3. Visit `https://<public_ip>/` in browser and log in
4. Run `terraform-destroy` workflow to clean up

---

## Architecture

```mermaid
flowchart TB
    subgraph Azure
        RG[Resource Group]
        NSG[Network Security Group]
        PIP[Public IP]
        VM[Linux VM]
    end

    subgraph VM
        Docker[Docker Engine]
        Postgres[PostgreSQL Container]
        Keycloak[Keycloak Container]
        O2P[OAuth2 Proxy Container]
        Nginx[Nginx Container]
    end

    User[Browser] -->|HTTPS 443| Nginx
    Nginx -->|auth_request| O2P
    O2P -->|OIDC flow| Keycloak
    Keycloak -->|JDBC| Postgres

