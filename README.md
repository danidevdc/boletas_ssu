PORTAL BOLETAS RRHH
===================

Resumen
-------
Portal web con dos vistas:
- Empleado: consulta su boleta por CI, PIN y periodo.
- RRHH: carga boletas cifradas, importa CSV y monitorea aperturas/descargas.

Como funciona
-------------
- El PDF se cifra fuera del navegador (programa Python).
- Se sube un archivo .enc a Supabase Storage.
- El empleado descarga el .enc y lo descifra localmente con su CI y PIN.
- El sistema registra apertura y descarga.

Paginas
-------
- index.html: portal de empleados.
- admin.html: panel RRHH (login con Supabase Auth).

Tecnologia
----------
- Frontend estatico (GitHub Pages).
- Supabase (Auth, Database, Storage).
- Cifrado y descifrado local en el navegador.

Inicio rapido
-------------
1. Configura Supabase (ver INSTRUCCIONES_INICIALES.md).
2. Edita config.js con tu Project URL y anon key.
3. Sube todo el contenido del repo a GitHub.
4. Activa GitHub Pages (main / root).

Notas de seguridad
------------------
Este proyecto es un piloto. Para produccion, usar backend propio o Edge Functions,
bucket privado y URLs firmadas.

