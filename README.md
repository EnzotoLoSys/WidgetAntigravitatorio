# Antigravity Desktop Widget 🪐 (v0.9.9.1)

Un widget de escritorio moderno, ultra liviano y de alto rendimiento para **Google Antigravity IDE**, desarrollado en **C# (.NET 8 + WPF)**.

Monitorea en tiempo real tu consumo de cuota de **Gemini** y de **ChatGPT / Claude (Modelos 3P)** dentro de Antigravity (ventana móvil de 5 horas, cuota semanal y ventana de contexto activa) con sincronización exacta 1:1 respecto al panel oficial del IDE.

---

## ✨ Novedades de la Versión 0.9.9.1

- 👁️‍🗨️ **Auto-Ocultar y Auto-Aparición Inteligente**:
  - Al **cerrar Antigravity IDE**, el widget se oculta automáticamente de forma limpia de tu pantalla para no molestar ni mostrar métricas confusas.
  - Al **abrir nuevamente Antigravity IDE**, el widget detecta el proceso al instante y reaparece automáticamente en su posición con las métricas 100% actualizadas.
  - Se puede activar/desactivar en cualquier momento desde **Preferencias**, el **Menú Contextual** o la **Bandeja del Sistema (Tray)**.
- 🎯 **Eliminación de Métricas Fantasma / Estimaciones Aleatorias**: Cuando el IDE está desconectado, el widget conserva la última cuota real conocida o muestra un estado claro de desconexión sin inventar números estimativos.
- 🤖 **Soporte Simultáneo para Gemini y ChatGPT / Claude (Todo Junto)**: Monitoreo en tiempo real de los límites de 5 horas y semanales para ambos grupos de modelos de Antigravity IDE (`Gemini Flash/Pro` y `GPT-OSS/Claude Sonnet/Opus`).
- 📌 **Integración Nativa con la Barra de Tareas (Taskbar Dock & Lock)**:
  - **Cero parpadeos**: Integración con el Desktop Window Manager (DWM) de Windows mediante `SetTaskbarOwner` (`GWLP_HWNDPARENT`) y estilos extendidos `WS_EX_NOACTIVATE` / `MA_NOACTIVATE`.
  - **Bloqueo de posición**: Deshabilita el arrastre accidental al estar anclado a la barra de herramientas.
  - **Orientación automática**: Cambia automáticamente a formato **Horizontal** al anclar a la barra de tareas.
- 🔄 **Reinicio Rápido de Instancia Única**: Si ejecutas el widget y ya hay una instancia abierta, te da la opción de cerrar el proceso anterior y lanzar la nueva versión al instante.
- 🎛️ **Filtro de Modelos y Métricas**: Toggles independientes en Preferencias y Menú Contextual para elegir qué modelos y qué límites visualizar (Gemini, ChatGPT/Claude, 5h, Semanal, Contexto).

---

## 🚀 Características Principales

- **Sincronización 1:1 en Tiempo Real**: Conexión directa vía IPC/HTTP local con el servicio interno del Language Server de Antigravity IDE (`RetrieveUserQuotaSummary`).
- **3 Modos Visuales**:
  - **Barras compactas**: Indicadores lineales con tiempos de reseteo, porcentaje y conteo de prompts para cada modelo.
  - **Tacómetros radiales (Gauges)**: Anillos circulares con porcentajes dinámicos individuales.
  - **Solo Porcentajes (Chips)**: Tarjetas minimalistas de lectura rápida.
- **2 Orientaciones**:
  - **Horizontal (Fila)** y **Vertical (Columna)**.
  - *Atajo rápido:* Click con la rueda del ratón (**Middle-Click**) para alternar orientación al instante.
- **4 Sliders de Opacidad Independientes (0% - 100%)**:
  - Fondo de la tarjeta / pastilla.
  - Bordes y contornos (gradientes).
  - Gráficos (barras de progreso, anillos, pastillas).
  - Textos y etiquetas numéricas.
- **Control de Escala / Zoom**: Ajuste de tamaño fluido del 60% al 140%.
- **Modo Fantasma (Click-Through)**: Permite interactuar con ventanas que estén debajo del widget (`WS_EX_TRANSPARENT`).
- **Bandeja del Sistema (System Tray)**: Menú contextual accesible desde el área de notificación.
- **Temas de Color**: Cyan, Violet y Matrix.

---

## 💻 Requisitos para Usuarios Finales

Para ejecutar `AntigravityWidget.exe`, solo necesitas:
- **Windows 10 / 11** (x64)
- **[.NET 8 Desktop Runtime (x64)](https://dotnet.microsoft.com/download/dotnet/8.0)** oficial de Microsoft.

> [!NOTE]
> **Aviso de Windows SmartScreen**: Al tratarse de un binario pre-release de código abierto sin firma digital corporativa de pago, Windows puede mostrar la pantalla de protección la primera vez. Simplemente pulsa en **"Más información"** y luego en **"Ejecutar de todas formas"**.

---

## 🔬 Telemetría y Funcionamiento

- **Cuotas de Modelos (Gemini y ChatGPT / Claude)**: Se obtienen en tiempo real directamente desde la API IPC local del Language Server de Google Antigravity (`RetrieveUserQuotaSummary`), garantizando exactitud 1:1 con el panel del IDE.
- **Ventana de Contexto**: Se calcula como una aproximación estimada (~4 caracteres por token) basada en el transcript de la sesión activa.
- **Modo Desconectado y Ahorro**: Si el IDE se encuentra cerrado, el widget reduce automáticamente su frecuencia de sondeo (backoff a 10s) para un consumo de CPU nulo y marca los valores con el prefijo `~Est.` para mayor transparencia.

---

## 🛠️ Requisitos de Desarrollo y Compilación

- **Windows 10 / 11** (x64)
- **.NET 8.0 SDK** (o superior)

---

## 🚀 Compilación y Publicación

### 1. Compilación de desarrollo:
```powershell
cd AntigravityWidgetNet
dotnet build
```

### 2. Publicar ejecutable único ultra liviano (`AntigravityWidget.exe`):
```powershell
cd AntigravityWidgetNet
dotnet publish -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true -o ../bin
```

El binario resultante se generará en `bin/AntigravityWidget.exe`.

---

## 🎮 Controles e Interacción

| Acción | Efecto |
|---|---|
| **Arrastrar (Click Izquierdo)** | Mueve el widget fluidamente por la pantalla (deshabilitado si está bloqueado a la barra). |
| **Doble Click Izquierdo** | Abre la ventana modal de **Preferencias** con sliders en vivo. |
| **Click Central (Rueda del Ratón)** | Alterna entre vista **Horizontal** y **Vertical**. |
| **Click Derecho en el Widget** | Menú contextual: modelos visibles, cambiar vistas, fijar a la barra, etc. |
| **Click Derecho en la Bandeja (Tray)** | Acceso a Preferencias, centrado, métricas y **Modo Fantasma**. |
| **Doble Click en la Bandeja** | Restaura o enfoca el widget en el escritorio. |

---

## 📁 Estructura del Proyecto

```
AntigravityWidget/
├── AntigravityWidgetNet/         # Código fuente de la aplicación C# (.NET 8 WPF)
│   ├── Native/
│   │   └── Win32.cs              # Interop P/Invoke, Z-Order DWM, Taskbar Owner y Click-Through
│   ├── Services/
│   │   ├── ConfigService.cs      # Gestión de configuración JSON y autostart
│   │   └── QuotaService.cs       # Telemetría en tiempo real (Gemini + ChatGPT/Claude)
│   ├── App.xaml / App.xaml.cs    # Gestor de instancia única interactivo y System Tray
│   ├── MainWindow.xaml / .cs     # HUD del widget, renderizado multi-modelo y animaciones
│   ├── SettingsWindow.xaml / .cs # Ventana modal de configuración y selección de modelos
│   └── AntigravityWidgetNet.csproj
├── .gitignore
├── LICENSE
└── README.md
```

---

## 📄 Licencia

MIT License.
