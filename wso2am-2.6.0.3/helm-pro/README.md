# helm api manager 
## Ficheros de configuración
1. Descargar los ficheros. Se usará el Patrón 2 de despliegue HELM.
https://github.com/wso2/kubernetes-apim/archive/v2.6.0.6.zip

## Crear Namespace
1. Por defecto wso2 se despliega en el namespace `wso2`. Si se quiere cambiar de namespace será necesario modificar los ficheros de configuración del HELM para que el producto WSO2 lo tenga en cuenta.
```bash
kubectl create namespace wso2
```

## Despliegue de MySQL.
1. Crear un Volúmen persistente de tipo Azure Disk si es necesario y desplegar los volúmenes persistentes.
```bash
kubectl apply -f Persistencia/mysql-wso2-apim-pv.yaml --namespace wso2
kubectl apply -f Persistencia/mysql-wso2-apim-pvc.yaml --namespace wso2
```

2. Desplegar un MySQL con HELM. Tener en cuenta que el fichero Values debemos especificar `existingClaim: mysql-wso2-apim-pvc`que es el que hemos creado. De esta forma, siempre que despleguemos el MySQL se cogerán los datos del disco credo manualmente.
```
helm install --name wso2apim-pattern-2-rdbms-service -f mysql/values.yaml stable/mysql --namespace wso2
```
## Despliegue WSO2
1. Crear los directorios para compartir ficheros de despliegue del api gateway y ISkm en el servidor NFS. Los nombres deben coindidir con
- sharedDeploymentLocationPath: "/export/data/PRO/wso2/apim-shared-server"
- isKMLocationPath: "/export/data/PRO/wso2/apim-is-as-km-shared-server"

2. El administrador de Kubernetes debe desplegar el certificado TLS, en este caso, llamado `bluespace-tls`.
3. Desplegar el HELM
```bash
helm install --name wso2apim  apim-gw-km-with-analytics --namespace wso2
```
5. Acceso al api manager:
- https://api-portal.bluespace.eu/carbon
- https://api-portal.bluespace.eu/publisher
- https://api-portal.bluespace.eu/store