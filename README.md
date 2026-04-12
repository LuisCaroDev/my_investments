# my_investments

A new Flutter project.

## Configuración de Supabase y Variables de Entorno

Este proyecto utiliza el paquete `envied` para proteger y ofuscar llaves sensibles.

Para configurar las credenciales:
1. Asegúrate de tener o crear el archivo `.env` en la raíz del proyecto.
2. Agrega las variables `SUPABASE_URL` y `SUPABASE_ANON_KEY`.
3. Corre el siguiente comando para [re]generar la clase ofuscada de Dart:
```bash
dart run build_runner build -d
```
