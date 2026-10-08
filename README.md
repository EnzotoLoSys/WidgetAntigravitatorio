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

## 🛠️ Requisitos de Compilación

- **Windows 10 / 11** (x64)
- **.NET 8.0 SDK** (o superior)

---

## 🚀 Compilación y Publicación

### 1. Compilación de desarrollo:
```powershell
cd AntigravityWidgetNet
dotnet build
```

### 2. Publicar ejecutable standalone para clientes (`AntigravityWidget.exe`):
```powershell
cd AntigravityWidgetNet
dotnet publish -c Release -o ../bin
```

El binario resultante se generará en `bin/AntigravityWidget.exe`. Es **100% standalone y autocontenido**: los clientes finales solo necesitan este archivo y no requieren instalar .NET ni ningún prerequisito en Windows 10 u 11.

---

## 🎮 Controles e Interacción

| Acción | Efecto |
|---|---|
| **Arrastrar (Click Izquierdo)** | Mueve el widget fluidamente por la pantalla. |
| **Doble Click Izquierdo** | Abre la ventana de **Preferencias**. |
| **Click Central (Rueda del Ratón)** | Alterna entre vista **Horizontal** y **Vertical**. |
| **Click Derecho** | Abre el menú contextual con opciones rápidas. |
| **Doble Click en la Bandeja** | Restaura o enfoca el widget. |

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
