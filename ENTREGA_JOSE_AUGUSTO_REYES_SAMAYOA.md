# Jose Augusto Reyes Samayoa

## Repositorio GitHub

- URL: https://github.com/AugustoReyes21/jose-augusto-reyes-samayoa-invoice-processor
- Nombre del repo: jose-augusto-reyes-samayoa-invoice-processor

## Cambios realizados

- Se reemplazo `Caddy` por `Nginx`.
- Se elimino la dependencia de `DOMAIN` en `.env`.
- El frontend ahora consume el API usando `/api`.
- Se preparo HTTPS en `443` usando certificado autofirmado para despliegue por IP.
- Se agrego guia de Azure y script para crear la VPS con llaves SSH.

## Validaciones realizadas

- `pnpm install`
- `pnpm build`
- `docker compose --env-file .env.example config`
- `docker compose --env-file .env.example build api webapp nginx`
- `docker compose up -d` con `OPENAI_API_KEY=test`
- `curl -k https://127.0.0.1`
- `curl -k https://127.0.0.1/api/`

## Llave SSH creada para la VM

- Privada: `/Users/adriar/.ssh/azure_jose_augusto_reyes_samayoa`
- Publica: `/Users/adriar/.ssh/azure_jose_augusto_reyes_samayoa.pub`

## Estado de Azure

La parte de codigo y despliegue quedo lista. La creacion real de la VPS por `az` todavia depende de autenticar Azure CLI con una cuenta que tenga una suscripcion accesible.

## Archivos clave

- `docker-compose.yml`
- `docker/nginx/Dockerfile`
- `docker/nginx/start.sh`
- `.env.example`
- `AZURE_VPS_DEPLOYMENT.md`
- `scripts/create-azure-vm.sh`
