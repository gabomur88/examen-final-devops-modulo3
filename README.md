# Examen Final DevOps — Módulo 3

**Especialización:** Infraestructura como Código y CI/CD Avanzado  
**Institución:** Educomser  
**Docente:** Ing. Rubén Gonzalo Soria Soria  
**Estudiante:** Gabriel Murillo Rivero

## 1. Descripción del proyecto

Proyecto práctico que integra herramientas DevOps para desarrollar, probar, automatizar y preparar el despliegue de una API REST en Python Flask.

Tecnologías utilizadas:

- **Python y Flask:** desarrollo de la API REST.
- **unittest:** pruebas automatizadas.
- **Terraform:** definición de infraestructura AWS EC2.
- **Ansible:** instalación y configuración de la aplicación.
- **systemd:** gestión del servicio Flask en Linux.
- **Docker y Docker Compose:** ejecución de Jenkins en un entorno independiente.
- **Jenkins:** integración continua.
- **Git y GitHub:** control de versiones y repositorio del proyecto.

## 2. Arquitectura

```text
GitHub
  |
  v
Jenkins (Docker)
  |
  +-- Preparar Python y dependencias
  |
  +-- Ejecutar pruebas unitarias
  |
  +-- Validar Terraform
  |
  +-- Validar Ansible

Flujo de despliegue previsto:

Terraform --> AWS EC2 Ubuntu
                   |
                   v
                 Ansible
                   |
                   v
              Flask + systemd
```

El pipeline de integración continua valida los componentes del proyecto. El aprovisionamiento AWS y el despliegue remoto se realizan por separado mediante los comandos documentados.

## 3. Estructura del repositorio

```text
.
├── app/
│   ├── main.py
│   ├── requirements.txt
│   └── tests/
│       └── test_basic.py
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── .terraform.lock.hcl
├── ansible/
│   ├── inventory
│   ├── playbook.yml
│   └── templates/
│       └── devops-api.service.j2
├── jenkins/
│   └── Dockerfile
├── docker-compose.yml
├── Jenkinsfile
├── .gitignore
└── README.md
```

## 4. Requisitos

Para ejecutar el proyecto se necesita:

- Linux o WSL Ubuntu.
- Python 3 y soporte para entornos virtuales.
- Terraform y Ansible.
- Docker y Docker Compose.
- Una cuenta AWS con permisos adecuados, en caso de desplegar infraestructura.
- Un Key Pair EC2 existente en `us-east-2`.

Las credenciales AWS deben configurarse de forma segura y nunca almacenarse en GitHub.

## 5. Ejecutar la aplicación Flask

Desde la raíz del proyecto:

```bash
python3 -m venv .venv
source .venv/bin/activate

pip install -r app/requirements.txt
python3 app/main.py
```

La aplicación puede comprobarse localmente en:

```text
http://localhost:8080
```

Respuesta esperada en la ruta principal:

```json
{
  "mensaje": "Hola desde DevOps Educomser",
  "modulo": 3
}
```

## 6. Ejecutar las pruebas unitarias

```bash
python3 -m unittest discover -s app/tests -p "test_*.py" -v
```

El proyecto incorpora pruebas de la ruta principal y del endpoint de salud de la aplicación.

Resultado local verificado durante el desarrollo:

```text
Ran 2 tests
OK
```

## 7. Infraestructura con Terraform

La configuración define una instancia EC2 Ubuntu y las reglas de red necesarias para SSH y la API Flask.

Región utilizada: `us-east-2` (Ohio).

### 7.1. Configurar variables

Dentro de `terraform/`, crear el archivo local `terraform.tfvars`:

```hcl
key_name   = "NOMBRE_DEL_KEY_PAIR"
admin_cidr = "TU_IP_PUBLICA/32"
```

El Key Pair debe existir previamente en AWS. No se debe subir la clave privada ni el archivo `terraform.tfvars` al repositorio.

### 7.2. Inicializar Terraform

```bash
cd terraform
terraform init
```

### 7.3. Formatear y validar

```bash
terraform fmt
terraform validate
```

### 7.4. Revisar el plan

```bash
terraform plan
```

Durante el laboratorio se obtuvo:

```text
Plan: 5 to add, 0 to change, 0 to destroy.
```

### 7.5. Crear infraestructura (opcional)

```bash
terraform apply
```

Este comando crea recursos reales en AWS y puede generar cargos. Se debe revisar el plan y confirmar los costos antes de ejecutarlo.

### 7.6. Consultar resultados

```bash
terraform output
terraform output -raw public_ip
```

### 7.7. Eliminar recursos

```bash
terraform destroy
```

Se debe utilizar el mismo directorio y estado Terraform con el que se crearon los recursos.

## 8. Automatización con Ansible

El playbook `ansible/playbook.yml` está preparado para:

1. Instalar Python y herramientas.
2. Crear el directorio de la API.
3. Copiar la aplicación y sus dependencias.
4. Crear un entorno virtual.
5. Instalar los paquetes Python.
6. Configurar el servicio systemd.
7. Habilitar e iniciar la aplicación.

### 8.1. Configurar el inventario

Después de crear EC2, obtener su IP pública mediante Terraform.

Agregar al archivo `ansible/inventory`:

```ini
[web]
IP_PUBLICA_EC2 ansible_user=ubuntu ansible_ssh_private_key_file=/RUTA/PRIVADA/CLAVE.pem
```

Sustituir los valores de ejemplo por los datos reales. El archivo PEM debe permanecer fuera del repositorio público.

### 8.2. Validar Ansible

```bash
cd ansible
ansible-playbook --syntax-check -i inventory playbook.yml
```

### 8.3. Ejecutar el despliegue

```bash
ansible-playbook -i inventory playbook.yml
```

Este último comando requiere una instancia EC2 disponible, conectividad SSH y un inventario configurado.

El despliegue remoto todavía debe verificarse contra una EC2 real para confirmar el funcionamiento de extremo a extremo.

## 9. Jenkins con Docker Compose

El proyecto incluye una imagen personalizada de Jenkins con las herramientas utilizadas en el pipeline.

### 9.1. Construir e iniciar Jenkins

Desde la raíz del proyecto:

```bash
docker compose up -d --build
```

### 9.2. Verificar el contenedor

```bash
docker compose ps
```

### 9.3. Obtener la contraseña inicial

```bash
docker exec examen-devops-jenkins \
  cat /var/jenkins_home/secrets/initialAdminPassword
```

### 9.4. Acceder a Jenkins

```text
http://localhost:8083
```

Instalar los plugins recomendados y configurar un trabajo de tipo Pipeline.

Configuración:

- **Definition:** Pipeline script from SCM
- **SCM:** Git
- **Repository:** https://github.com/gabomur88/examen-final-devops-modulo3.git
- **Branch:** `*/main`
- **Script Path:** `Jenkinsfile`

Ejecutar el trabajo con **Build Now**.

## 10. Integración continua

El `Jenkinsfile` contiene las siguientes etapas:

| Etapa | Actividad |
|---|---|
| Verificar Python | Preparación del entorno virtual |
| Pruebas Unitarias | Ejecución de unittest |
| Terraform Validate | Validación de infraestructura |
| Ansible Syntax Check | Validación del playbook |

**Resultado verificado:** Jenkins Build #1 — `SUCCESS`.

Este resultado confirma la ejecución satisfactoria de las validaciones CI. No equivale a un despliegue AWS ni a una prueba de funcionamiento remoto.

## 11. Seguridad y buenas prácticas

- Se utiliza `.gitignore` para excluir archivos sensibles.
- Las claves privadas SSH no se almacenan en Git.
- Los archivos `terraform.tfvars` y los estados de Terraform permanecen fuera del repositorio.
- La infraestructura puede revisarse con `terraform plan` antes de cualquier despliegue.
- Se utiliza control de versiones mediante GitHub.
- Jenkins dispone de un entorno propio definido con Docker Compose.
- Ansible permite realizar tareas de configuración de manera declarativa e idempotente cuando los módulos y tareas están correctamente diseñados.

## 12. Estado de las verificaciones

| Componente | Resultado |
|---|---|
| API Flask local | Verificada |
| Pruebas unitarias | 2 pruebas exitosas |
| Terraform init y validate | Exitosos |
| Terraform plan | 5 recursos previstos |
| Terraform apply | 5 recursos creados en AWS |
| Ansible syntax-check | Exitoso |
| Ansible Deploy | ok=11, changed=10, failed=0 |
| API principal `/` | HTTP 200 OK |
| Endpoint `/health` | HTTP 200 OK |
| Idempotencia Ansible | ok=10, changed=0, failed=0 |
| Jenkins Docker | Contenedor funcionando |
| Jenkins Pipeline #1 | SUCCESS |
| Terraform destroy | 5 recursos eliminados |
| Estado Terraform final | Sin recursos |

### Resultado del despliegue

El 16 de noviembre de 2026 se desplegó exitosamente
una API REST Flask en AWS EC2 t3.micro, región us-east-2.

Terraform aprovisionó la infraestructura y Ansible
instaló las dependencias y configuró el servicio systemd.

Ambos endpoints respondieron HTTP 200 OK.

La segunda ejecución de Ansible confirmó idempotencia,
con changed=0 y failed=0.

Al finalizar las pruebas, se ejecutó Terraform destroy
para eliminar los cinco recursos creados.

## 13. Repositorio

Código fuente y archivos de configuración:

https://github.com/gabomur88/examen-final-devops-modulo3

---

**Examen Final — Módulo 3 | Educomser | 2026**