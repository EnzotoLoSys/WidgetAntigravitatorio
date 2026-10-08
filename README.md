# Antigravity Desktop Widget 🪐

Un widget de escritorio moderno, ultra liviano y de alto rendimiento para **Google Antigravity IDE**, desarrollado en **C# (.NET 8 + WPF)**.

Monitorea en tiempo real tu consumo de cuota de Gemini y modelos asociados (ventana móvil de 5 horas, cuota semanal y ventana de contexto activa) con sincronización exacta 1:1 respecto al panel oficial del IDE.

---

## ✨ Características

- **Sincronización 1:1 en Tiempo Real**: Conexión directa vía IPC/HTTP local con el servicio interno del Language Server de Antigravity IDE (`RetrieveUserQuotaSummary`).
- **3 Modos Visuales**:
  - **Barras compactas**: Indicadores lineales con tiempos de reseteo y conteo de prompts.
  - **Tacómetros radiales (Gauges)**: Anillos circulares con porcentajes interactivos.
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
- **Soporte DPI Nativo**: Arrastre suave sin desfasaje de cursor utilizando Win32 `DragMove()`.
- **Modo Fantasma (Click-Through)**: Permite hacer click a través del widget (`WS_EX_TRANSPARENT`).
- **Bandeja del Sistema (System Tray)**: Integración con notificación en la barra de tareas y control de instancia única vía `Mutex`.
- **Temas de Color**: Cyan, Violet y Matrix.

---

## 💻 Requisitos para Usuarios Finales

Para ejecutar `AntigravityWidget.exe`, solo necesitas:
- **Windows 10 / 11** (x64)
- **[.NET 8 Desktop Runtime (x64)](https://dotnet.microsoft.com/download/dotnet/8.0)** oficial de Microsoft.

> [!NOTE]
> **Aviso de Windows SmartScreen**: Al tratarse de un binario pre-release de código abierto sin firma digital de pago (certificados corporativos anuales), Windows puede mostrar la pantalla de protección la primera vez. Simplemente pulsa en **"Más información"** y luego en **"Ejecutar de todas formas"**.

---

## 🔬 Telemetría y Funcionamiento

- **Cuota de 5 Horas y Semanal**: Se obtiene en tiempo real directamente desde la API IPC local del Language Server de Google Antigravity (`RetrieveUserQuotaSummary`), garantizando exactitud 1:1 con el panel del IDE.
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

El binario resultante se generará en `bin/AntigravityWidget.exe`. Es **ultra liviano y de inicio instantáneo**, requiriendo únicamente el .NET 8 Desktop Runtime estándar de Windows.

---

## 🎮 Controles e Interacción

| Acción | Efecto |
|---|---|
| **Arrastrar (Click Izquierdo)** | Mueve el widget fluidamente por la pantalla (soporte multi-monitor). |
| **Doble Click Izquierdo** | Abre la ventana modal de **Preferencias** con sliders en vivo. |
| **Click Central (Rueda del Ratón)** | Alterna entre vista **Horizontal** y **Vertical**. |
| **Click Derecho en el Widget** | Menú contextual: fijar al frente, alternar modos y estilo. |
| **Click Derecho en la Bandeja (Tray)** | Acceso a Preferencias, centrado, métricas y **activar/desactivar Modo Fantasma**. |
| **Doble Click en la Bandeja** | Restaura o enfoca el widget en el escritorio. |

---

## 📁 Estructura del Proyecto

```
AntigravityWidget/
├── AntigravityWidgetNet/         # Código fuente de la aplicación C# (.NET 8 WPF)
│   ├── Native/
│   │   └── Win32.cs              # Interop P/Invoke para click-through y ventana
│   ├── Services/
│   │   ├── ConfigService.cs      # Gestión de preferencias JSON y autostart
│   │   └── QuotaService.cs       # Telemetría en tiempo real y conexión IPC
│   ├── App.xaml / App.xaml.cs    # Instancia única (Mutex) y System Tray
│   ├── MainWindow.xaml / .cs     # Interfaz HUD del widget y animaciones
│   ├── SettingsWindow.xaml / .cs # Ventana modal de configuración y sliders
│   └── AntigravityWidgetNet.csproj
├── .gitignore
└── README.md
```

---

## 📄 Licencia

MIT License.
