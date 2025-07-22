# 🏗️ backendTemplates

Proyecto base en **Node.js + Express** con **arquitectura hexagonal (hexagonal architecture / DDD-inspired)** para iniciar rápidamente backends escalables y organizados.

Incluye dos scripts `.sh` para automatizar la creación de estructura base y nuevas entidades con casos de uso, validaciones y pruebas automatizadas.

---

## 📁 Estructura Base

Este proyecto sigue la arquitectura hexagonal dividiendo las capas en:

- `domain/` → Lógica del negocio, entidades puras.
- `application/` → Casos de uso.
- `infrastructure/` → Adaptadores externos, como repositorios en memoria.
- `interfaces/http/` → Rutas, controladores y middlewares.
- `tests/` → Pruebas automatizadas por capa.

---

## 🔧 Scripts incluidos

### `init-project.sh`

Genera toda la estructura del proyecto, inicializando carpetas, archivos base, configuraciones de ESLint, Prettier y más.

**Uso:**

```bash
./init-project.sh
```

---

### `entity-generator.sh`

Genera automáticamente una entidad completa, con:

- Dominio (`domain/<entity>/<Entity>.js`)
- Repositorio en memoria (`infrastructure/<entity>/`)
- Casos de uso (`application/<entity>/`)
- Validaciones (`application/<entity>/<entity>-validation.js`)
- Controlador y rutas HTTP
- Pruebas automatizadas (`tests/`)

**Opciones disponibles:**

| Opción             | Descripción |
|--------------------|-------------|
| `-y`               | Acepta todo sin preguntar |
| `--json`           | Usa el archivo `./generator/entity-schema.json` como esquema de entidad |
| `--json <file>`    | Usa el archivo JSON especificado como esquema |
| `--schema-dir`     | Lista los esquemas JSON disponibles en `./generator/entity-schemas/` y permite elegir uno |

**Ejemplo de uso:**

```bash
./entity-generator.sh --json ./generator/entity-schemas/user.json
```

Si solo escribes `--json` y presionas Enter, se mostrarán los archivos disponibles en `./generator/entity-schemas/`.

---

## ⚙️ Requisitos

### 🧩 Dependencias necesarias

- `jq` para procesar JSON desde bash.

**Instalación recomendada:**

- **Windows (con Chocolatey):**
  ```bash
  choco install jq
  ```

- **Linux/macOS (manual):**
  ```bash
  sudo apt install jq
  # o
  brew install jq
  ```

---

### 🧹 Formato y permisos

#### Saltos de línea (problemas en VS Code)

Si ves errores como "bad interpreter" o fallos de ejecución en VSCode, puede que los archivos tengan saltos de línea incorrectos. Soluciónalo con:

```bash
dos2unix ./init-project.sh
dos2unix ./entity-generator.sh
```

> Instala `dos2unix` si no lo tienes:
>
> - **Windows (choco):** `choco install dos2unix`
> - **Linux/macOS:** `sudo apt install dos2unix` / `brew install dos2unix`

#### Permisos de ejecución

Asegúrate de que los scripts `.sh` tienen permisos de ejecución:

```bash
chmod +x ./init-project.sh
chmod +x ./entity-generator.sh
```

---

## 🛠️ Recomendaciones

- Usa formateadores como `shfmt` o plugins de shell script en tu editor para mantener limpio tu código bash.
- Añade un `.editorconfig` o asegúrate de tener configurado tu editor para evitar saltos de línea tipo `CRLF` si estás en Windows.
- Ejecuta los tests con `node <path del test>.js` o configura Mocha para correr todos.

---

## 🚧 Estado actual (WIP)

Este proyecto aún está en desarrollo. Algunas funcionalidades pendientes:

- [ ] Migrar de JavaScript a **TypeScript**
- [ ] Soporte para **Docker**
- [ ] Validación de nombres de entidades y atributos
- [ ] Implementación de una base de datos real
- [ ] Middlewares avanzados y autenticación por defecto
- [ ] Generación de documentación automática

---

## 📄 Licencia

MIT

---

¿Querés colaborar? ¡Forkeá el repo, armá tu feature y mandá PR!
