# Despliegue En Azure VPS

Repositorio de entrega:

`https://github.com/AugustoReyes21/jose-augusto-reyes-samayoa-invoice-processor`

Llave SSH local creada para la VM:

- privada: `/Users/adriar/.ssh/azure_jose_augusto_reyes_samayoa`
- publica: `/Users/adriar/.ssh/azure_jose_augusto_reyes_samayoa.pub`

## 1. Crear la VPS en Azure con llaves

En la maquina local:

```bash
export RESOURCE_GROUP="rg-jose-augusto-reyes-samayoa"
export LOCATION="eastus"
export VM_NAME="vm-jose-augusto-reyes-samayoa"
export ADMIN_USER="azureuser"
export SSH_PUBLIC_KEY="$HOME/.ssh/azure_jose_augusto_reyes_samayoa.pub"

az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username "$ADMIN_USER" \
  --authentication-type ssh \
  --ssh-key-values "$SSH_PUBLIC_KEY" \
  --public-ip-sku Standard

az vm open-port --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --port 22
az vm open-port --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --port 80
az vm open-port --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --port 443
```

Obtener IP publica:

```bash
az vm list-ip-addresses \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" \
  --output tsv
```

## 2. Entrar por SSH a la VPS

```bash
ssh -i ~/.ssh/azure_jose_augusto_reyes_samayoa azureuser@IP_PUBLICA
```

## 3. Instalar Docker en Ubuntu

En la VPS:

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER && newgrp docker
docker --version
docker compose version
```

## 4. Ejecutar los comandos de validacion de la imagen

En la VPS:

```bash
docker run --name nginx -d -p 80:80 nginx
docker ps
docker stop nginx
docker rm nginx
```

## 5. Crear la Deployment Key para GitHub

En la VPS:

```bash
ssh-keygen -t ed25519 -C "deploy@jose-augusto-reyes-samayoa" -f ~/.ssh/github_deploy_key
cat ~/.ssh/github_deploy_key.pub
```

Agrega esa llave publica en GitHub:

- Repo `Settings`
- `Deploy keys`
- `Add deploy key`

Luego configura SSH en la VPS:

```bash
cat <<'EOF' >> ~/.ssh/config
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_deploy_key
  IdentitiesOnly yes
EOF

chmod 600 ~/.ssh/config
```

## 6. Clonar el repo en la VPS

```bash
git clone git@github.com:AugustoReyes21/jose-augusto-reyes-samayoa-invoice-processor.git
cd jose-augusto-reyes-samayoa-invoice-processor
cp .env.example .env
```

## 7. Editar `.env` con nano

```bash
nano .env
```

Contenido minimo recomendado:

```dotenv
OPENAI_API_KEY=tu_openai_api_key
DATABASE_URL=./data/invoices.db
UPLOADS_DIR=./uploads
API_PORT=3001
NEXT_PUBLIC_API_URL=/api
OPENAI_MODEL=gpt-4.1-mini
DB_DRIVER=sqlite
PUBLIC_IP=IP_PUBLICA
```

## 8. Levantar Docker Compose

```bash
docker compose up -d --build
docker compose ps
docker compose logs -f api webapp nginx
```

## 9. Verificacion

```bash
curl -k https://IP_PUBLICA/api/
curl -k -I https://IP_PUBLICA
```

## 10. Nota sobre HTTPS

Este proyecto ya no usa `Caddyfile` ni requiere `DOMAIN`.

Se expone en `443` con Nginx usando un certificado autofirmado generado dentro del contenedor. Eso permite usar HTTPS por IP publica, pero el navegador mostrara advertencia de confianza.

Let's Encrypt sigue requiriendo un dominio real apuntando a la VPS.
