# KidsAndUs myclassroom web Chart

## Descripción

Proyecto base para desplegar soluciones con stack MEAN. Este chart despliega un mongo, un servidor feathers y un servidor angular.

## Prerequisites
- Kubernetes 1.10+
- Creación de Namespace para los entornos de MR, DEV, PRE i PRO.
- Volúmen persistentes creados
- Instalar el repositorio helm de kidsandus-myclassroom

## Creación de los namespaces
Creación de los espacios de aplicación en el clúster de kubernetes.
```bash
kubectl create namespace kidsandus-myclassroom-mr
kubectl create namespace kidsandus-myclassroom-dev
kubectl create namespace kidsandus-myclassroom-pre
kubecrl create namespace kidsandus-myclassroom-pro
```

## Añadir el helm repo del proyecto
Para poder deployar el proyecto de forma manual.
```bash
helm repo add kidsandus-myclassroom https://registry.quantion.com/chartrepo/kidsandus-myclassroom
```

## Persistencia de datos
Para poder desplegar la solución en los entornos de DEV, PRE i PRO con persistencia de datos, es necesario crear los siguientes volúmentes de datos. 

| Nombre volúmen                                   | tamaño                         |
| ------------------------------------------  | ----------------------------------  |
| datadir-kidsandus-myclassroom-dev-mongodb-primary-0                       | 1 GiB     |
| datadir-kidsandus-myclassroom-pre-mongodb-primary-0                       | 1 GiB     |
| datadir-kidsandus-myclassroom-pro-mongodb-primary-0                       | 1 GiB     |

Nota: el nombre del volúmen debe coincidir con el claim del replicaSet del Mongodb.

## Instalar el Chart

Para instalar el chart con el nombre `kidsandus-myclassroom-dev`:

```bash
helm install --name kidsandus-myclassroom-dev kidsandus-myclassroom/angular-feathers-mongo
```

> **Ayuda**: Para ver el listado de aplicaciones helm desplegadas en kubernetes: `helm list`

## Desinstalar el Chart

Para desinstalar/borra el Chart `kidsandus-myclassroom-dev` desplegado:

```bash
helm delete --purge kidsandus-myclassroom-dev
```
Esta instrucción borra todos los componentes desplegados en kubernetes asociados al Chart del proyecto.

## Configuración

| Parámetro                                   | Descripción                         | Valor por defecto             |
| -----------------------------------  | ----------------------------------  | ----------------------|
| datosProyecto.cliente                | Nombre del cliente                  | nil              |
| datosProyecto.proyecto               | Nombre del proyecto                 | nil               |
| datosProyecto.aplicacion             | Nombre de la aplicación             | nil               |
| datosProyecto.entorno                | Entorno entorno en el qué desplegar | nil                   |
| angular.registry                     | Registry de donde obtener la imagen | registry.quantion.com |
| angular.repository                   | Proyecto/repositoria de imagen      | nil |
| angular.tag                          | Versión de la imagen                | nil                |
| angular.replicas                     | Número de replicas                  | 1                     |
| feathers.registry                    | Registry de donde obtener la imagen | registry.quantion.com | 
| feathers.repository                  | Proyecto/repositoria de imagen      | nil |
| feathers.tag                         | Versión de la imagen                | nil                |
| feathers.replicas                    | Número de replicas                  | 1                     |
| mongodb.database                     | Nombre de la base de datos          | database              |
| mongodb.replicaSet.replicas.secondary | Número de réplicas secundarias     | 2                     |                
| mongodb.replicaSet.replicas.arbiter  | Número de arbitros para elegir master | 1                   |
| mongodb.persistence.enable           | Habilitar persistencia de datos     | enable                |
| mongodb.persistence.size             | Tamaño del volúmen persistente      | 1Gi                   |

A la hora de desplegar, especifica cada parámetro usando el argumento `--set key=value[,key=value]` para instalar. Por ejemplo:
```
helm install --name kidsandus-myclassroom-dev \
--set datosProyecto.cliente=kidsandus,datosProyecto.proyecto=myclassroom \
--set datosProyecto.aplicacion=web,datosProyecto.entorno=dev \
kidsandus-myclassroom/angular-feathers-mongo
```
De forma alternativa, se puede guardar una copiar del fichero Values.yaml con los parámetros modificados e indicarle que se use dicho fichero para la instalación del Chart. Por ejemplo.
```
helm install --name kidsandus-myclassroom-dev -f my-values.yaml kidsandus-myclassroom/angular-feathers-mongo
```

## Dependencias

El Chart desplegado contiene un sub chart de mongodb con parámetros adicionales que se pueden configurar en caso de requerir algun ajuste específico. https://github.com/helm/charts/tree/master/stable/mongodb
