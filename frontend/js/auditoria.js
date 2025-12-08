const API = "http://localhost:3000/api";

async function cargarLogs() {
  const res = await fetch(`${API}/auditoria`, {
    headers: {
      "Authorization": "Bearer " + localStorage.getItem("token")
    }
  });

  const data = await res.json();
  document.getElementById("logs").textContent = JSON.stringify(data, null, 2);
}
