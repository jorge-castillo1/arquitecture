## Descargar ficheros docker y código

Descargar ficheros docker v.2.6.0.3 y eliminar lo que no se va a usar (sólo se usará dockerfiles/ubuntu)
* https://github.com/wso2/docker-apim/archive/v2.6.0.3.zip

Descargar el código de wso2 de cada versión, moverlo a la carpeta correspondiente donde se encuentra el Dockerfile y descomprimirlo dentro de la correspondiente carpeta `dockerfiles/ubuntu/<producto>/files` de cada producto.

* Wso2am https://bintray.com/wso2/binaryGA/download_file?file_path=wso2am-2.6.0.zip
* wso2iskm https://bintray.com/wso2/binaryGA/download_file?file_path=wso2is-km-5.7.0.zip
* wso2am-analytics https://bintray.com/wso2/binaryGA/download_file?file_path=wso2am-analytics-2.6.0.zip

## Generate Keystores
Seguir los pasos marcados por el producto para generar nuevas keystores. https://docs.wso2.com/display/ADMIN44x/Creating+New+Keystores#CreatingNewKeystores-Creatinganewkeystore
1. Crear un keystore usando un certificado existente. Si el certificado *.crt consiste en 2 ficheros, se tienen que concatenar.
```bash
cat cert\ 6-11-19/4a6838f03b3d5af6.crt cert\ 6-11-19/gd_bundle-g2-g1.crt > certificado.crt 
```
2. Crear un keystore nuevo. Nos podirá que introduzcamos el password que queremos configurar.('B1u3sp4c3')
```bash
openssl rsa -in generated-private-key.txt -outform pem -out bluespace.key
openssl pkcs12 -export -in certificado.crt -inkey bluespace.key -name "wso2carbon"  -out bluespace.pfx
```
Si no se puede arbrir la clave privada porqué se ha guardado con sistemas Windows, se tiene que convertir a ASCII y obtener la clave privada RSA.
```bash
iconv -c -f UTF8 -t ASCII cert.key
openssl rsa -in generated-private-key.txt -outform pem -out bluespace.key
```
3. Convertimos el keystore en formato PKCS12
```bash
keytool -importkeystore -srckeystore bluespace.pfx -srcstoretype pkcs12 -destkeystore bluespace.jks -deststoretype JKS
```

## Importar el certificado en client-truststore
1. Iniciar la imagen docker y copiar el client-truststore.jks original. El fichero se puede encontrar en docker `repository/resources/security/client-truststore.jks`
```bash
cp ../wso2am-2.6.0.3/dockerfiles/apim/files/wso2am-2.6.0/repository/resources/security/client-truststore.jks .
```
2. Exportar clave pública del keysotre nuevo que hemos creade
```bash
keytool -export -alias "wso2carbon" -keystore bluespace.jks -file bluespace.pem
```
3. Eliminar la clave por defecto e Importar la clave pública en el client-truststore.jks 
```bash
keytool -delete -alias wso2carbon -keystore client-truststore.jks -storepass wso2carbon
keytool -import -alias "wso2carbon" -file bluespace.pem -keystore client-truststore.jks -storepass wso2carbon
```
## Copy keystore and client-truststore in dockers
1. Copiar los ficheros bluespace.jks y client-truststore.jks en la carpeta `repository/resources/security`. Se tiene que sobre escribir el fichero client-truststore.jks y eliminar el fichero antiguo wso2carbon.jks.
```bash

## Modificar los ficheros de configuración de wso2.
1. Con un editor de código, modificar los ficheros y Substituir:
* las referencias de wso2carbon.jks a bluespace.jks
* La contraseña de la keystore especificada y del certificado.
* No hace modificar el alias ya que hemos usado el mismo que viene por defecto.
* Si se quiere desplegar en VM con docker-compose, modificar el HOST y contraseña.
* Seguir las indicacinoes de https://docs.wso2.com/display/AM260/Maintaining+Logins+and+Passwords. 

