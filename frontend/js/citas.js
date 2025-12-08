const API = "http://localhost:3000/api";

async function guardarCita() {
  const data = {
    idPaciente: +document.getElementById("idPaciente").value,
    idMedico: +document.getElementById("idMedico").value,
    fecha: document.getElementById("fecha").value,
    hora: document.getElementById("hora").value
  };

  const res = await fetch(`${API}/citas/programar`, {
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
