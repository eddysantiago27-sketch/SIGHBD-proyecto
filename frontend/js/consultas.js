const API = "http://localhost:3000/api";

async function guardarConsulta() {
  const data = {
    idCita: +document.getElementById("idCita").value,
    diagnostico: document.getElementById("diag").value,
    tratamiento: document.getElementById("trat").value
  };

  const res = await fetch(`${API}/consultas/registrar`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + localStorage.getItem("token")
    },
    body: JSON.stringify(data)
  });

  const json = await res.json();
  document.getElementById("msg").innerText = json.message;
}
