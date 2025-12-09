const API = "http://localhost:3000/api";

async function registrar() {
  const data = {
    nombres: document.getElementById("nombres").value,
    apellidos: document.getElementById("apellidos").value,
    dni: document.getElementById("dni").value,
    fecha_nacimiento: document.getElementById("fecha").value,
    sexo: document.getElementById("sexo").value,
    direccion: document.getElementById("direccion").value
  };

  const res = await fetch(`${API}/pacientes/registrar`, {
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
