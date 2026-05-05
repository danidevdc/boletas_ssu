FRONTEND BOLETAS RRHH - GitHub Pages + Supabase
=================================================

ARCHIVOS INCLUIDOS
------------------
index.html              Página del empleado.
admin.html              Página RRHH.
config.js               Configuración de Supabase.
shared.js               Funciones compartidas.
styles.css              Estilos.
supabase_setup.sql      SQL para crear tablas y policies de prueba.

FLUJO
-----
1. RRHH cifra PDFs con el programa Python.
2. El programa genera:
   - archivos .enc
   - supabase_boletas.csv
   - mensajes_whatsapp.csv
3. En Supabase:
   - crear bucket "boletas"
   - ejecutar supabase_setup.sql
   - crear usuario admin en Authentication
4. Subir estos archivos a GitHub.
5. En admin.html:
   - iniciar sesión
   - seleccionar periodo
   - subir archivos .enc
   - importar supabase_boletas.csv
6. En index.html:
   - empleado elige periodo
   - escribe CI y PIN
   - el navegador descarga .enc y lo descifra localmente.

CONFIGURAR SUPABASE
-------------------
1. Crea un proyecto en Supabase.
2. Ve a Project Settings > API.
3. Copia:
   - Project URL
   - anon public key
4. Edita config.js:
   SUPABASE_URL: "https://xxxx.supabase.co"
   SUPABASE_ANON_KEY: "xxxx"
5. Ejecuta supabase_setup.sql en SQL Editor.
6. Crea bucket:
   Storage > New bucket
   Name: boletas
   Public bucket: ON
7. Crea usuario admin:
   Authentication > Users > Add user
   Ejemplo:
   correo: rrhh@demo.com
   contraseña: una contraseña fuerte

IMPORTANTE SOBRE SEGURIDAD
--------------------------
Este paquete es para PILOTO.

Para que el empleado pueda consultar desde GitHub Pages sin backend propio:
- La tabla boletas permite SELECT público.
- La tabla boletas permite UPDATE público para marcar abierto/descargado.
- El bucket boletas es público, pero solo contiene archivos .enc cifrados.

Esto permite probar el flujo, pero para producción se recomienda:
- backend institucional o Supabase Edge Function;
- bucket privado;
- URLs firmadas;
- tracking mediante API;
- autenticación institucional;
- policies más restrictivas.

PERIODO
-------
Usa formato:
2026-05

El link mensual puede ser:
https://TU_USUARIO.github.io/TU_REPO/?periodo=2026-05

El usuario también puede cambiar periodo desde el selector si existen periodos activos.

RUTAS DE ARCHIVOS
-----------------
Si el programa Python genera:
archivo_path = 2026-05/6770063.enc

Entonces en Supabase Storage debe existir:
bucket boletas / 2026-05 / 6770063.enc

En admin.html, si el periodo es 2026-05 y subes 6770063.enc,
se subirá automáticamente como:
2026-05/6770063.enc

GITHUB PAGES
------------
Sube estos archivos a la raíz del repositorio:

index.html
admin.html
config.js
shared.js
styles.css

En GitHub:
Settings > Pages > Deploy from branch > main / root

Luego abre:
https://TU_USUARIO.github.io/TU_REPO/

