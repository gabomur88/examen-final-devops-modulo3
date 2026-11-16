# Examen Final DevOps — Módulo 3

**Especialización:** Infraestructura como Código y CI/CD Avanzado  
**Institución:** Educomser  
**Docente:** Ing. Rubén Gonzalo Soria Soria  
**Estudiante:** Gabriel Murillo Rivero  
**Fecha:** 16 de noviembre de 2026

---

## 1. Descripción del proyecto

Proyecto práctico que integra herramientas DevOps para desarrollar, probar, automatizar y desplegar una API REST en Python Flask mediante prácticas de integración continua, infraestructura como código y gestión automatizada de servidores.

El proyecto fue desarrollado como examen final del Módulo 3 de la especialización en Infraestructura como Código y CI/CD Avanzado.

**Tecnologías utilizadas:**

- **Python y Flask:** desarrollo de la API REST.
- **unittest:** pruebas unitarias automatizadas.
- **Terraform:** aprovisionamiento de infraestructura AWS.
- **AWS EC2:** ejecución de la aplicación en Ubuntu Server.
- **Ansible:** instalación, configuración y despliegue automatizado.
- **systemd:** administración del servicio Flask en Linux.
- **Docker y Docker Compose:** ejecución aislada de Jenkins.
- **Jenkins:** integración continua y validaciones automatizadas.
- **Git y GitHub:** control de versiones y repositorio público.

El proyecto incluye tanto el código necesario para reproducir el despliegue como las verificaciones realizadas sobre infraestructura real.

---

## 2. Arquitectura

### 2.1. Integración continua

```text
GitHub
   |
   v
Jenkins (Docker)
   |
   +-- Checkout del repositorio
   |
   +-- Preparar Python y dependencias
   |
   +-- Ejecutar pruebas unitarias
   |
   +-- Inicializar y validar Terraform
   |
   +-- Verificar sintaxis de Ansible
   |
   v
Resultado del Pipeline
SUCCESS / FAILURE
```

### 2.2. Infraestructura y despliegue

```text
Desarrollador (WSL Ubuntu)
          |
          v
       Terraform
          |
          v
      AWS EC2
    Ubuntu 24.04
          |
          | SSH
          v
        Ansible
          |
          +-- Instalar Python
          +-- Crear entorno virtual
          +-- Copiar aplicación Flask
          +-- Instalar dependencias
          +-- Configurar systemd
          +-- Iniciar servicio
          |
          v
     API REST Flask
       Puerto 8080
          |
          +-- GET /
          |
          +-- GET /health
```

El pipeline Jenkins realiza las verificaciones de integración continua.

El aprovisionamiento de infraestructura AWS y el despliegue de la aplicación se ejecutan por separado mediante Terraform y Ansible.

Esta separación permite verificar el código sin crear recursos AWS en cada ejecución del pipeline.

El despliegue real fue completado exitosamente durante el examen.

---

## 3. Estructura del repositorio

```text
.
├── app/
│   ├── main.py
│   ├── requirements.txt
│   └── tests/
│       └── test_basic.py
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── .terraform.lock.hcl
│
├── ansible/
│   ├── inventory
│   ├── playbook.yml
│   └── templates/
│       └── devops-api.service.j2
│
├── jenkins/
│   └── Dockerfile
│
├── docker-compose.yml
├── Jenkinsfile
├── .gitignore
└── README.md
```

**Descripción de los componentes:**

- `app/`: código fuente Flask, dependencias y pruebas.
- `terraform/`: recursos AWS EC2 y reglas de seguridad.
- `ansible/`: configuración automatizada del servidor.
- `jenkins/`: imagen personalizada de Jenkins.
- `docker-compose.yml`: definición del contenedor Jenkins.
- `Jenkinsfile`: etapas de integración continua.
- `.gitignore`: exclusión de archivos temporales y sensibles.
- `README.md`: documentación de implementación y resultados.

---

## 4. Requisitos

Para reproducir el proyecto se necesita:

- Linux o WSL Ubuntu.
- Python 3 con soporte para entornos virtuales.
- Terraform.
- Ansible.
- Git.
- Docker y Docker Compose.
- AWS CLI para administrar credenciales AWS.
- Cuenta AWS con permisos adecuados para EC2 y recursos de red.
- Key Pair EC2 existente en la región `us-east-2`.

El sistema donde se ejecuta Ansible debe disponer de conectividad SSH hacia la instancia EC2.

La infraestructura del examen utiliza una instancia `t3.micro` y una AMI de Ubuntu 24.04.

**Importante:** la creación de recursos AWS puede generar cargos según la configuración y los beneficios disponibles en la cuenta.

---

## 5. Ejecutar la aplicación Flask

Desde la raíz del proyecto:

```bash
python3 -m venv .venv
source .venv/bin/activate

pip install -r app/requirements.txt

python3 app/main.py
```

La aplicación queda disponible localmente en:

```text
http://localhost:8080
```

### 5.1. Endpoint principal

Realizar una petición:

```bash
curl -i http://localhost:8080/
```

Respuesta JSON esperada:

```json
{
  "mensaje": "Hola desde DevOps Educomser",
  "modulo": 3
}
```

Código HTTP esperado:

```text
HTTP/1.1 200 OK
```

### 5.2. Endpoint de salud

Ejecutar:

```bash
curl -i http://localhost:8080/health
```

Respuesta esperada:

```json
{
  "status": "ok"
}
```

Código HTTP esperado:

```text
HTTP/1.1 200 OK
```

El endpoint `/health` permite comprobar que la aplicación se encuentra disponible.

---

## 6. Ejecutar las pruebas unitarias

Desde la raíz del proyecto:

```bash
python3 -m unittest discover -s app/tests -p "test_*.py" -v
```

El proyecto incorpora dos pruebas unitarias:

1. `test_inicio`: verifica la ruta principal de la API.
2. `test_health`: verifica el endpoint de salud.

**Resultado obtenido:**

```text
test_health ... ok
test_inicio ... ok

Ran 2 tests

OK
```

Las dos pruebas fueron ejecutadas exitosamente durante el desarrollo del examen.

Estas pruebas también forman parte del pipeline Jenkins.

---

## 7. Infraestructura con Terraform

Terraform define la infraestructura necesaria para ejecutar la aplicación Flask sobre una instancia AWS EC2.

**Región:** `us-east-2` (Ohio).

**Componentes principales:**

- Instancia EC2 Ubuntu 24.04.
- Tipo de instancia `t3.micro`.
- Security Group para controlar conexiones.
- Regla SSH TCP 22.
- Regla HTTP TCP 8080.
- Regla de salida para conexiones desde la instancia.

Las conexiones entrantes SSH y HTTP se restringen a la dirección IPv4 autorizada mediante la variable `admin_cidr`.

### 7.1. Configurar variables

Dentro del directorio `terraform/`, crear un archivo local llamado:

```text
terraform.tfvars
```

Contenido de ejemplo:

```hcl
key_name   = "NOMBRE_DEL_KEY_PAIR"
admin_cidr = "TU_IP_PUBLICA/32"
```

El Key Pair debe existir previamente en AWS dentro de la región `us-east-2`.

Para consultar la IP pública desde Linux:

```bash
curl -4 https://checkip.amazonaws.com
```

La dirección obtenida debe utilizarse con máscara `/32` para restringir el acceso a una sola IPv4.

**Seguridad:** no publicar `terraform.tfvars` ni claves privadas PEM en GitHub.

### 7.2. Inicializar Terraform

Desde la raíz del proyecto:

```bash
cd terraform
terraform init
```

Terraform descargará los proveedores necesarios e inicializará el directorio de trabajo.

### 7.3. Formatear y validar

Ejecutar:

```bash
terraform fmt
terraform validate
```

Resultado esperado:

```text
Success! The configuration is valid.
```

### 7.4. Revisar el plan de infraestructura

Ejecutar:

```bash
terraform plan
```

Durante el examen se obtuvo:

```text
Plan: 5 to add, 0 to change, 0 to destroy.
```

Este resultado confirmó que Terraform estaba preparado para crear cinco recursos AWS.

También puede guardarse un plan para aplicarlo posteriormente:

```bash
terraform plan -out=tfplan
```

### 7.5. Crear infraestructura AWS

Para crear los recursos definidos:

```bash
terraform apply
```

Si anteriormente se guardó un plan:

```bash
terraform apply tfplan
```

Durante el examen se utilizó un plan guardado y se ejecutó exitosamente.

**Resultado real:**

```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

Terraform creó una instancia EC2 Ubuntu en la región `us-east-2` y sus recursos de seguridad asociados.

### 7.6. Consultar los outputs

Ejecutar:

```bash
terraform output
```

Para obtener únicamente la IP pública:

```bash
terraform output -raw public_ip
```

Los outputs definidos incluyen:

- `instance_id`: identificador de la instancia EC2.
- `public_ip`: dirección IPv4 pública.
- `application_url`: URL de acceso a la API Flask.

### 7.7. Verificar la instancia EC2

La instancia creada fue identificada como:

```text
examen-devops-flask
```

Configuración verificada:

```text
Región: us-east-2
Tipo: t3.micro
Sistema operativo: Ubuntu 24.04
Puerto SSH: 22
Puerto Flask: 8080
```

Se verificó que la instancia estuviera en estado `Running` desde la consola AWS EC2.

### 7.8. Eliminar recursos

Después de completar las pruebas, ejecutar:

```bash
terraform destroy
```

Se debe utilizar el mismo directorio de trabajo, workspace y estado Terraform empleados durante la creación de los recursos.

**Resultado real del examen:**

```text
Destroy complete! Resources: 5 destroyed.
```

Posteriormente se comprobó el estado:

```bash
terraform state list
```

El comando no mostró recursos administrados.

También se ejecutó:

```bash
terraform plan
```

Resultado:

```text
Plan: 5 to add, 0 to change, 0 to destroy.
```

Esto confirma que la infraestructura puede recrearse a partir del código Terraform y que el estado local quedó sin recursos administrados.

**Nota:** un estado Terraform vacío no sustituye una auditoría completa de todos los recursos de una cuenta AWS. En este laboratorio se verificó la eliminación de los cinco recursos administrados por el proyecto.

---

## 8. Automatización con Ansible

Ansible permite configurar automáticamente la instancia EC2 y desplegar la aplicación Flask.

El archivo principal es:

```text
ansible/playbook.yml
```

### 8.1. Tareas del playbook

El playbook realiza las siguientes operaciones:

1. Instalar Python y herramientas necesarias.
2. Crear el directorio `/opt/devops-api`.
3. Copiar el código de Flask.
4. Copiar las dependencias del proyecto.
5. Crear un entorno virtual Python.
6. Instalar las dependencias Python.
7. Configurar los permisos del directorio.
8. Instalar el servicio systemd.
9. Habilitar e iniciar Flask.
10. Reiniciar el servicio cuando se detectan cambios que lo requieren.

El servicio se configura mediante la plantilla:

```text
ansible/templates/devops-api.service.j2
```

### 8.2. Configurar el inventario

Una vez creada la instancia EC2, obtener su IP pública:

```bash
cd terraform
terraform output -raw public_ip
```

Desde la raíz del proyecto, editar:

```text
ansible/inventory
```

Ejemplo:

```ini
[web]
IP_PUBLICA_EC2 ansible_user=ubuntu ansible_ssh_private_key_file=/RUTA/PRIVADA/CLAVE.pem ansible_python_interpreter=/usr/bin/python3
```

Reemplazar:

- `IP_PUBLICA_EC2`: IP pública de la instancia.
- `ubuntu`: usuario SSH de Ubuntu.
- `/RUTA/PRIVADA/CLAVE.pem`: ubicación local del archivo PEM.

El archivo PEM debe mantenerse fuera del repositorio público.

### 8.3. Configurar permisos del archivo PEM

Ejecutar:

```bash
chmod 600 /RUTA/PRIVADA/CLAVE.pem
```

Esto restringe el acceso al archivo de clave privada.

### 8.4. Verificar conexión SSH

Ejecutar:

```bash
ssh -i /RUTA/PRIVADA/CLAVE.pem ubuntu@IP_PUBLICA_EC2
```

Durante el examen se comprobó exitosamente la conexión SSH a la instancia Ubuntu creada por Terraform.

### 8.5. Verificar conexión Ansible

Desde el directorio `ansible/`:

```bash
ansible web -i inventory -m ping
```

**Resultado real obtenido:**

```text
SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Esto confirmó el acceso remoto mediante SSH y la ejecución de Python en la instancia.

### 8.6. Validar el playbook

Ejecutar:

```bash
ansible-playbook --syntax-check -i inventory playbook.yml
```

El análisis de sintaxis se completó correctamente.

### 8.7. Desplegar la aplicación Flask

Ejecutar:

```bash
ansible-playbook -i inventory playbook.yml
```

**Resultado real de la primera ejecución:**

```text
PLAY RECAP

ok=11 changed=10 unreachable=0 failed=0
```

Ansible instaló las dependencias, copió los archivos necesarios, configuró systemd y habilitó el servicio Flask.

No se registraron errores de ejecución ni hosts inaccesibles.

### 8.8. Comprobar el despliegue remoto

Una vez ejecutado Ansible, consultar la API:

```bash
curl -i http://IP_PUBLICA_EC2:8080/
```

Resultado real:

```text
HTTP/1.1 200 OK
```

Respuesta:

```json
{
  "mensaje": "Hola desde DevOps Educomser",
  "modulo": 3
}
```

Consultar el endpoint de salud:

```bash
curl -i http://IP_PUBLICA_EC2:8080/health
```

Resultado real:

```text
HTTP/1.1 200 OK
```

Respuesta:

```json
{
  "status": "ok"
}
```

Ambos endpoints fueron comprobados desde WSL Ubuntu. También se verificó el acceso a la aplicación desde un navegador web.

### 8.9. Verificar idempotencia

La idempotencia consiste en ejecutar repetidamente una automatización sin realizar modificaciones innecesarias cuando el sistema ya se encuentra en el estado deseado.

Se ejecutó nuevamente:

```bash
ansible-playbook -i inventory playbook.yml
```

**Resultado real de la segunda ejecución:**

```text
PLAY RECAP

ok=10 changed=0 unreachable=0 failed=0
```

El resultado `changed=0` confirma que Ansible no necesitó modificar nuevamente la configuración de la instancia.

Esta prueba demuestra el comportamiento idempotente del playbook en el entorno utilizado.

### 8.10. Restauración del inventario

Una vez finalizado el despliegue y eliminada la infraestructura AWS, se restauró el archivo `ansible/inventory` como plantilla:

```ini
[web]
# Agregar aquí la IP pública de EC2 antes del despliegue.
# Configurar ansible_user y la ruta del PEM local.
```

Esta configuración permite conservar instrucciones de reproducción sin publicar rutas privadas del entorno local.

---

## 9. Jenkins con Docker Compose

El proyecto incluye una imagen personalizada de Jenkins que proporciona las herramientas necesarias para ejecutar las validaciones de integración continua.

La configuración se encuentra en:

```text
jenkins/Dockerfile
docker-compose.yml
```

### 9.1. Construir e iniciar Jenkins

Desde la raíz del proyecto:

```bash
docker compose up -d --build
```

El servicio se construye utilizando el Dockerfile del directorio `jenkins/`.

### 9.2. Verificar el contenedor

Ejecutar:

```bash
docker compose ps
```

El contenedor debe aparecer en estado `Up`.

Nombre configurado:

```text
examen-devops-jenkins
```

### 9.3. Obtener contraseña inicial

Si se trata de una instalación nueva de Jenkins:

```bash
docker exec examen-devops-jenkins \
  cat /var/jenkins_home/secrets/initialAdminPassword
```

La contraseña inicial permite completar la configuración de Jenkins.

No debe publicarse en GitHub.

### 9.4. Acceder a Jenkins

Desde el navegador:

```text
http://localhost:8083
```

La configuración Docker Compose publica Jenkins en el puerto `8083` del equipo local.

### 9.5. Configurar los plugins

Se deben instalar los plugins necesarios para:

- Pipeline.
- Git.
- Integración con GitHub.
- Gestión de credenciales.
- Visualización de etapas del pipeline.

Las dependencias de plugins deben resolverse mediante el administrador de Jenkins.

### 9.6. Configurar el trabajo Pipeline

Crear un nuevo trabajo de tipo `Pipeline`.

Configuración:

```text
Definition: Pipeline script from SCM

SCM: Git

Repository:
https://github.com/gabomur88/examen-final-devops-modulo3.git

Branch:
*/main

Script Path:
Jenkinsfile
```

Guardar la configuración y ejecutar:

```text
Build Now
```

Durante el examen se configuró Jenkins para recuperar el código desde GitHub y ejecutar las validaciones del proyecto.

---

## 10. Integración continua

El archivo `Jenkinsfile` define las etapas del pipeline.

| Etapa | Actividad |
|---|---|
| Checkout | Obtener código desde GitHub |
| Verificar Python | Preparar entorno virtual e instalar dependencias |
| Pruebas Unitarias | Ejecutar pruebas con unittest |
| Terraform Validate | Inicializar y validar Terraform |
| Ansible Syntax Check | Validar sintaxis del playbook |

### 10.1. Verificación Python

El pipeline utiliza Python para preparar un entorno virtual y descargar las dependencias de Flask.

### 10.2. Pruebas unitarias

Jenkins ejecuta las pruebas de la aplicación mediante unittest.

Se verificaron dos pruebas exitosas.

### 10.3. Validación Terraform

Jenkins ejecuta:

```bash
terraform init -backend=false
terraform fmt -check
terraform validate
```

Esta etapa verifica la configuración sin crear recursos AWS.

### 10.4. Validación Ansible

Jenkins ejecuta:

```bash
ansible-playbook --syntax-check \
  -i inventory playbook.yml
```

Esta etapa comprueba la sintaxis del playbook.

### 10.5. Resultado real

El pipeline fue ejecutado exitosamente desde Jenkins.

**Resultado verificado:**

```text
Jenkins Pipeline #1

Finished: SUCCESS
```

El resultado confirma que las etapas configuradas se ejecutaron satisfactoriamente.

El pipeline de integración continua no crea automáticamente infraestructura AWS.

El despliegue real de EC2 y Flask fue realizado por separado mediante Terraform y Ansible, como se documenta en las secciones anteriores.

---

## 11. Seguridad y buenas prácticas

El proyecto incorpora prácticas de seguridad para proteger archivos sensibles y evitar la publicación de información confidencial.

- Se utiliza `.gitignore` para excluir archivos temporales y sensibles.
- Las claves privadas SSH no se almacenan en GitHub.
- Los archivos `terraform.tfvars` permanecen fuera del repositorio.
- Los estados Terraform no se publican.
- Los archivos de planes Terraform no se publican.
- Las credenciales AWS no se incluyen en archivos `.tf`.
- Se utiliza una IP autorizada con máscara `/32` para SSH y acceso HTTP durante el laboratorio.
- La infraestructura puede revisarse mediante `terraform plan`.
- Los cambios del proyecto se administran mediante Git.
- Jenkins se ejecuta en un entorno Docker propio.
- Ansible automatiza la configuración y permite operaciones idempotentes.
- Los recursos AWS se eliminan una vez completadas las pruebas.

### 11.1. Configuración segura de credenciales AWS

Terraform utiliza el proveedor oficial de AWS para aprovisionar la infraestructura en la región `us-east-2` (Ohio).

Por seguridad, las credenciales de AWS no se almacenan directamente en el código Terraform ni se publican en GitHub.

Para configurar credenciales mediante AWS CLI:

```bash
aws configure
```

Este comando permite introducir:

- AWS Access Key ID.
- AWS Secret Access Key.
- Región predeterminada: `us-east-2`.
- Formato de salida: `json`.

AWS CLI almacena esta configuración localmente fuera del repositorio del proyecto.

### 11.2. Verificar autenticación AWS

Ejecutar:

```bash
aws sts get-caller-identity
```

Este comando permite verificar qué identidad AWS está siendo utilizada.

### 11.3. Utilizar perfiles AWS

También se puede configurar un perfil específico:

```bash
aws configure --profile educomser
```

Seleccionar el perfil desde Linux:

```bash
export AWS_PROFILE=educomser
```

Terraform puede utilizar las credenciales del perfil seleccionado mediante la cadena estándar de credenciales del proveedor AWS.

### 11.4. Buenas prácticas para credenciales

- Nunca publicar AWS Access Keys ni Secret Access Keys.
- No subir archivos PEM al repositorio.
- No colocar credenciales directamente en archivos Terraform.
- Utilizar permisos IAM mínimos.
- Preferir credenciales temporales cuando sea posible, mediante roles IAM o IAM Identity Center.
- No incluir contraseñas ni tokens en el README.
- Evitar almacenar secretos en el historial de comandos o en archivos de configuración versionados.

### 11.5. Exclusión de archivos sensibles

El archivo `.gitignore` excluye archivos como:

```gitignore
.venv/
.venv-ci/
__pycache__/
*.pyc
.env
*.pem
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
tfplan
terraform.tfvars
```

El archivo `.terraform.lock.hcl` puede mantenerse versionado para conservar la selección de dependencias del proveedor Terraform.

### 11.6. Ejecución segura de Terraform

Para preparar y revisar la infraestructura:

```bash
cd terraform
terraform init
terraform validate
terraform plan
```

Después de revisar la configuración y aceptar los posibles cargos:

```bash
terraform apply
```

Al finalizar las prácticas:

```bash
terraform destroy
```

La eliminación de recursos evita mantener infraestructura de laboratorio activa innecesariamente.

---

## 12. Estado de las verificaciones

| Componente | Resultado |
|---|---|
| API Flask local | Verificada |
| Pruebas unitarias | 2 pruebas exitosas |
| Terraform init y validate | Exitosos |
| Terraform plan | 5 recursos previstos |
| Terraform apply | 5 recursos creados en AWS |
| EC2 Ubuntu | Instancia t3.micro desplegada |
| Conectividad SSH | Exitosa |
| Ansible ping | SUCCESS / pong |
| Ansible syntax-check | Exitoso |
| Ansible Deploy | ok=11, changed=10, failed=0 |
| API principal `/` | HTTP 200 OK |
| Endpoint `/health` | HTTP 200 OK |
| Acceso desde navegador | Exitoso |
| Idempotencia Ansible | ok=10, changed=0, failed=0 |
| Jenkins Docker | Contenedor funcionando |
| Jenkins Pipeline #1 | SUCCESS |
| Terraform destroy | 5 recursos eliminados |
| Estado Terraform final | Sin recursos administrados |
| Repositorio GitHub | Público y actualizado |

### 12.1. Resultado del despliegue

El 16 de noviembre de 2026 se desplegó exitosamente una API REST Flask sobre una instancia AWS EC2 `t3.micro` con Ubuntu 24.04, utilizando la región `us-east-2`.

Terraform aprovisionó los recursos de infraestructura y configuró las reglas de acceso necesarias.

Ansible realizó la instalación y configuración automatizada del servidor, incluyendo Python, dependencias, entorno virtual y servicio systemd.

Ambos endpoints de la aplicación respondieron correctamente con código HTTP `200 OK`.

También se comprobó el acceso desde un navegador.

### 12.2. Prueba de idempotencia

Se ejecutó el playbook Ansible por segunda vez.

Resultado:

```text
ok=10 changed=0 unreachable=0 failed=0
```

Esto confirmó que la configuración del servidor permanecía en el estado deseado sin necesidad de aplicar cambios adicionales.

### 12.3. Limpieza de infraestructura

Una vez completadas todas las pruebas, se ejecutó:

```bash
terraform destroy
```

Resultado:

```text
Destroy complete! Resources: 5 destroyed.
```

Posteriormente se verificó que el estado Terraform no contenía recursos administrados.

El código de infraestructura permanece en GitHub y permite reproducir el despliegue.

### 12.4. Integración continua

Jenkins recuperó el proyecto desde GitHub y ejecutó exitosamente las etapas configuradas.

Resultado:

```text
Finished: SUCCESS
```

Se validaron las pruebas unitarias, la configuración Terraform y la sintaxis Ansible.

---

## 13. Repositorio y entrega

El proyecto se encuentra publicado en un repositorio público de GitHub:

**Repositorio:**

https://github.com/gabomur88/examen-final-devops-modulo3

El repositorio contiene:

- Código fuente de la aplicación Flask.
- Pruebas unitarias automatizadas.
- Archivos Terraform.
- Playbook y plantillas Ansible.
- Dockerfile de Jenkins.
- Configuración Docker Compose.
- Jenkinsfile de integración continua.
- Documentación de ejecución.
- Resultados de las verificaciones.
- Instrucciones para recrear y eliminar la infraestructura AWS.

Los archivos privados, credenciales y estados de infraestructura no forman parte de la entrega.

**Estado del proyecto:** implementación completada, integración continua verificada, despliegue real comprobado y recursos AWS eliminados.

---

**Examen Final — Módulo 3 | Educomser | 2026**