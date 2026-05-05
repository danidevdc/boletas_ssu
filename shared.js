// shared.js

function getConfig() {
  if (!window.APP_CONFIG) {
    throw new Error("No se encontró APP_CONFIG. Revise config.js.");
  }
  return window.APP_CONFIG;
}

function createSbClient() {
  const cfg = getConfig();
  if (!cfg.SUPABASE_URL || !cfg.SUPABASE_ANON_KEY || cfg.SUPABASE_URL.includes("TU_PROYECTO")) {
    throw new Error("Debe configurar SUPABASE_URL y SUPABASE_ANON_KEY en config.js.");
  }
  return window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY);
}

function qs(name) {
  return new URLSearchParams(window.location.search).get(name);
}

function formatPeriodoLabel(periodo) {
  if (!periodo) return "";
  const meses = {
    "01": "Enero", "02": "Febrero", "03": "Marzo", "04": "Abril",
    "05": "Mayo", "06": "Junio", "07": "Julio", "08": "Agosto",
    "09": "Septiembre", "10": "Octubre", "11": "Noviembre", "12": "Diciembre"
  };
  const m = String(periodo).match(/^(\d{4})-(\d{2})$/);
  if (!m) return periodo;
  return `${meses[m[2]] || m[2]} ${m[1]}`;
}

function setText(id, text) {
  const el = document.getElementById(id);
  if (el) el.textContent = text;
}

function showStatus(id, type, message) {
  const el = document.getElementById(id);
  if (!el) return;
  el.className = "status " + type;
  el.textContent = message;
  el.style.display = "block";
}

function hideStatus(id) {
  const el = document.getElementById(id);
  if (!el) return;
  el.style.display = "none";
}

function textToBytes(text) {
  return new TextEncoder().encode(text);
}

function parseCsv(text) {
  const sample = text.slice(0, 2048);
  const semicolonCount = (sample.match(/;/g) || []).length;
  const commaCount = (sample.match(/,/g) || []).length;
  const delimiter = semicolonCount > commaCount ? ";" : ",";

  const rows = [];
  let current = "";
  let row = [];
  let inQuotes = false;

  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    const next = text[i + 1];

    if (ch === '"' && inQuotes && next === '"') {
      current += '"';
      i++;
    } else if (ch === '"') {
      inQuotes = !inQuotes;
    } else if (ch === delimiter && !inQuotes) {
      row.push(current);
      current = "";
    } else if ((ch === "\n" || ch === "\r") && !inQuotes) {
      if (ch === "\r" && next === "\n") i++;
      row.push(current);
      current = "";
      if (row.some(v => String(v).trim() !== "")) rows.push(row);
      row = [];
    } else {
      current += ch;
    }
  }

  if (current.length > 0 || row.length > 0) {
    row.push(current);
    if (row.some(v => String(v).trim() !== "")) rows.push(row);
  }

  if (rows.length === 0) return [];

  const headers = rows[0].map(h => String(h).trim().toLowerCase());
  return rows.slice(1).map(values => {
    const obj = {};
    headers.forEach((h, idx) => {
      obj[h] = String(values[idx] ?? "").trim();
    });
    return obj;
  });
}

function downloadBlob(blob, filename) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1500);
}
