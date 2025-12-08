const API = "http://localhost:3000/api";

async function backup(tipo) {
  const res = await fetch(`${API}/backups/${tipo}`, {
    method: "POST",
    headers: {
      "Authorization": "Bearer " + localStorage.getItem("token")
    }
  });

  const data = await res.json();
  document.getElementById("msg").innerText = data.message;
}
