# Generación de las imagenes docker
## Requisitos
- Estar logeado en el repositorio de bluespace para poder subir las imágenes.
- Copiar los ficheros keystores *.jks que contienen los certificados SSL de bluespace en las carpetas de cada producto `repository/resources/security/`

## Ejecutar el script
```bash
# Difine docker repository base URL
REPO="bluespaceregistry.azurecr.io/api-manager/"
# Generate images
docker build -t ${REPO}wso2am:2.6.0 apim/ --no-cache
docker build -t wso2am-analytics-base:2.6.0 apim-analytics/base/ --no-cache
docker build -t ${REPO}wso2am-analytics-worker:2.6.0 apim-analytics/worker/ --no-cache
docker build -t ${REPO}wso2is-km:5.7.0 is-as-km/ --no-cache

#Push images to repo
docker push ${REPO}wso2am:2.6.0
docker push ${REPO}wso2am-analytics-worker:2.6.0
docker push ${REPO}wso2is-km:5.7.0
```