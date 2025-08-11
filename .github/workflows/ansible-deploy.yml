name: ansible-deploy
on:
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

env:
  TF_IN_AUTOMATION: "true"
  ARM_USE_OIDC: "true"

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Azure login
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.7.5

      # read backend cfg from bootstrap state
      - name: Terraform init (bootstrap)
        working-directory: terraform/backend-bootstrap
        run: terraform init

      - name: Read backend outputs
        id: bkend
        working-directory: terraform/backend-bootstrap
        run: |
          echo "RG=$(terraform output -raw backend_resource_group)" >> $GITHUB_OUTPUT
          echo "SA=$(terraform output -raw backend_storage_account)" >> $GITHUB_OUTPUT
          echo "CN=$(terraform output -raw backend_container)" >> $GITHUB_OUTPUT
          echo "KEY=$(terraform output -raw backend_key)" >> $GITHUB_OUTPUT

      - name: Terraform init (main with backend)
        working-directory: terraform
        run: |
          terraform init \
            -backend-config="resource_group_name=${{ steps.bkend.outputs.RG }}" \
            -backend-config="storage_account_name=${{ steps.bkend.outputs.SA }}" \
            -backend-config="container_name=${{ steps.bkend.outputs.CN }}" \
            -backend-config="key=${{ steps.bkend.outputs.KEY }}"

      - name: Get outputs (public_ip, admin_username)
        id: tfout
        working-directory: terraform
        run: |
          echo "PUBLIC_IP=$(terraform output -raw public_ip)" >> $GITHUB_OUTPUT
          echo "ADMIN_USER=$(terraform output -raw admin_username)" >> $GITHUB_OUTPUT

      - name: Setup SSH for Ansible
        run: |
          umask 077
          echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa

      - name: Install Ansible
        run: |
          python3 -m pip install --upgrade pip
          pip install ansible

      - name: Create ephemeral inventory
        run: |
          mkdir -p ansible
          cat > ansible/inventory.ini <<EOF
          [web]
          ${{ steps.tfout.outputs.PUBLIC_IP }} ansible_user=${{ steps.tfout.outputs.ADMIN_USER }} ansible_ssh_private_key_file=~/.ssh/id_rsa
          EOF
          cat ansible/inventory.ini

      - name: Run playbook
        working-directory: ansible
        env:
          KC_ADMIN_USER: ${{ secrets.KC_ADMIN_USER || 'admin' }}
          KC_ADMIN_PASS: ${{ secrets.KC_ADMIN_PASS || 'adminpassword' }}
        run: |
          ansible-playbook -i inventory.ini playbook.yml \
            --extra-vars "vm_ip=${{ steps.tfout.outputs.PUBLIC_IP }} kc_admin_user=$KC_ADMIN_USER kc_admin_pass=$KC_ADMIN_PASS ssl_insecure_skip_verify=false"
