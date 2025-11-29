# Actividad: Arquitectura y desarrollo de microservicios con Docker (base) y Kubernetes

## Conceptualización de microservicios

### Evolución Arquitectónica

> **Monolito -> SOA -> Microservicios**

La transición hacia los microservicios no fue inmediata, sino una respuesta a las limitaciones de modelos anteriores:

**1. Monolito:** Todo el código (UI, lógica de negocio, acceso a datos) vive en una sola unidad desplegable. Comunicación interna mediante llamadas a funciones en memoria. Simple al inicio, pero caótico al crecer.

**2. SOA (Arquitectura Orientada a Servicios):** Introdujo la idea de separar servicios, pero dependía fuertemente de un ESB (Enterprise Service Bus) centralizado. Esto generaba un "monolito distribuido" donde la lógica de integración era pesada y centralizada (pipes inteligentes).

**3. Microservicios:** Descentralización total. Se eliminan los ESB en favor de "smart endpoints and dumb pipes" (protocolos ligeros como HTTP/REST o gRPC). Cada servicio es autónomo y posee sus propios datos.

### Análisis de Casos Reales

Se presentan dos casos prácticos que ilustran los desafíos y soluciones al migrar de un monolito a microservicios.

#### Caso A: El E-commerce ante Picos Estacionales (Black Friday)

En un escenario de e-commerce bajo la presión del Black Friday, la arquitectura monolítica muestra rápidamente sus limitaciones críticas. El acoplamiento excesivo impide escalar solo las partes más demandadas, obligando a replicar toda la aplicación (incluso módulos sin uso como "Devoluciones") lo cual dispara los costos operativos ineficientemente. Para resolver esto, la evolución hacia una aplicación de microservicios redefine el sistema como una colección de unidades de despliegue independientes, donde cada servicio gestiona una única capacidad de negocio (como "Catálogo" o "Carrito") y expone su funcionalidad mediante un contrato de API definido.

Bajo este diseño basado en DDD (Domain-Driven Design), se establecen límites contextuales claros que permiten al servicio de "Búsqueda" escalar masivamente sin afectar al de "Facturación". Pero esta distribución introduce desafíos de red y seguridad, ya que la comunicación deja de ser en memoria para depender de la latencia y la fiabilidad de la red. Para mitigar esto, es vital implementar un Gateway que centralice el acceso y estrategias de observabilidad profunda (métricas, logs y trazas con herramientas como Jaeger) para detectar cuellos de botella en tiempo real. Aunque se pierde la simplicidad del monolito, se gana en aislamiento de fallos y autonomía de equipos, permitiendo despliegues continuos sin el miedo a tumbar toda la tienda en el día de más ventas.

#### Caso B: SaaS Multi-tenant (Entorno B2B Crítico)

Para un proveedor de SaaS B2B, el mayor riesgo del monolito es la falta de aislamiento. Una consulta pesada de un solo cliente grande puede saturar la memoria compartida y bloquear el acceso al resto de los inquilinos (noisy neighbor), evidenciando una fragilidad inaceptable. Al migrar a microservicios, la prioridad es la autonomía y el aislamiento de fallos; si el servicio de "Reportes" cae, el núcleo de la aplicación sigue operativo. Aquí, el principio de diseño DRY (Don't Repeat Yourself) se aplica con cautela. Se prefiere una duplicación controlada de código antes que crear librerías compartidas que acoplen artificialmente servicios distintos, evitando que un cambio para un cliente rompa la funcionalidad de otro.

No obstante, la fragmentación de la base de datos trae consigo el reto de la consistencia de datos, pues ya no existen transacciones ACID globales. La solución arquitectónica implica el uso de patrones de Sagas para orquestar cambios complejos entre servicios y el uso estricto de OpenAPI y pruebas de contrato para asegurar que las actualizaciones no violen la compatibilidad. Aunque la orquestación (vía Kubernetes) y el testing distribuido añaden una capa de complejidad operativa significativa, el resultado es una plataforma robusta donde la estabilidad de un cliente no depende del comportamiento de los demás.