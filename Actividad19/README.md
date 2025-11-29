# Actividad: Arquitectura y desarrollo de microservicios con Docker (base) y Kubernetes

## Conceptualización de microservicios

### Evolución Arquitectónica

> **Monolito -> SOA -> Microservicios**

La transición hacia los microservicios no fue inmediata, sino una respuesta a las limitaciones de modelos anteriores:

**1. Monolito:** Todo el código (UI, lógica de negocio, acceso a datos) vive en una sola unidad desplegable. Comunicación interna mediante llamadas a funciones en memoria. Simple al inicio, pero caótico al crecer.

**2. SOA (Arquitectura Orientada a Servicios):** Introdujo la idea de separar servicios, pero dependía fuertemente de un ESB (Enterprise Service Bus) centralizado. Esto generaba un "monolito distribuido" donde la lógica de integración era pesada y centralizada (pipes inteligentes).

**3. Microservicios:** Descentralización total. Se eliminan los ESB en favor de "smart endpoints and dumb pipes" (protocolos ligeros como HTTP/REST o gRPC). Cada servicio es autónomo y posee sus propios datos.

### Análisis de Casos Reales

Se presentan dos casos prácticos (e-commerce en Black Friday y SaaS multi-tenant) que ilustran los desafíos y soluciones al migrar de un monolito a microservicios.

#### Caso A: El E-commerce ante Picos Estacionales (Black Friday)

En un escenario de e-commerce bajo la presión extrema del Black Friday, la arquitectura monolítica ha demostrado ser un punto de fallo crítico, tal como lo evidenció Walmart durante su caída histórica en el Black Friday de 2012. En aquel incidente, el acoplamiento excesivo impidió escalar solo las partes más demandadas, obligando a replicar toda la aplicación ineficientemente. Para resolver esto, la industria adoptó el modelo pionero de Amazon, que abandonó su monolito "Obidos" a favor de una arquitectura orientada a servicios (SOA). Este cambio redefine el sistema como una colección de unidades de despliegue independientes, donde cada microservicio gestiona una única capacidad de negocio (como "Catálogo" o "Carrito") y expone su funcionalidad mediante un contrato de API definido.

Bajo este diseño basado en DDD (Domain-Driven Design), se establecen límites contextuales claros que permiten al servicio de "Búsqueda" escalar masivamente sin afectar al de "Facturación". Sin embargo, esta distribución introduce desafíos de red y seguridad. Para mitigarlos, es vital implementar un API Gateway que centralice el acceso y estrategias de observabilidad profunda (métricas, logs y trazas distribuidas). Aunque se pierde la simplicidad del monolito, se gana la resiliencia que permitió a Amazon realizar millones de despliegues anuales sin interrumpir el servicio, eliminando el miedo a tumbar toda la tienda en el día de más ventas.

#### Caso B: SaaS Multi-tenant (Entorno B2B Crítico)

Para un proveedor de SaaS B2B, el mayor riesgo del monolito es la falta de aislamiento, ejemplificado por el problema del "Noisy Neighbor" (vecino ruidoso). Un caso de estudio fundamental es la migración de Atlassian (Jira/Confluence), quienes tuvieron que descomponer su monolito para manejar más de 100,000 instancias de clientes en una arquitectura multi-tenant en la nube. Sin este aislamiento, una consulta pesada de un solo cliente grande podía saturar la memoria compartida y bloquear el acceso al resto. Al migrar a microservices, la prioridad es la "autonomía del inquilino" (Tenant Context); si el servicio de "Reportes" cae para un cliente, el núcleo de la aplicación sigue operativo para los demás.

No obstante, la fragmentación de la base de datos elimina las transacciones ACID globales. La solución arquitectónica, implementada rigurosamente por gigantes como Salesforce, implica el uso de Governor Limits para prevenir abusos de recursos y patrones de Sagas para orquestar la consistencia de datos entre servicios. Además, el uso estricto de Contract Testing asegura que un cambio para un cliente no rompa la funcionalidad de otro. Aunque la orquestación vía Kubernetes añade complejidad operativa, el resultado es una plataforma robusta donde la estabilidad de un cliente empresarial no depende del comportamiento de sus vecinos.