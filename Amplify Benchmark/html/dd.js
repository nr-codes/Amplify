const dropZone = document.getElementById("drop-zone");
const fileInput = document.getElementById("file-input");
const problems = {};

// Prevent default behavior
["dragenter", "dragover", "dragleave", "drop"].forEach(event => {
  dropZone.addEventListener(event, e => e.preventDefault());
});

// Highlight drop area
dropZone.addEventListener("dragover", () => {
  dropZone.classList.add("dragover");
});

dropZone.addEventListener("dragleave", () => {
  dropZone.classList.remove("dragover");
});

// Handle files dropped
dropZone.addEventListener("drop", (e) => {
  dropZone.classList.remove("dragover");
  const files = e.dataTransfer.files;
  handleFiles(files);
});

// Click to upload fallback
dropZone.addEventListener("click", () => fileInput.click());

fileInput.addEventListener("change", () => {
  handleFiles(fileInput.files);
});

// Process files
function handleFiles(files) {
  [...files].forEach(file => {
    const cell = document.getElementById(file.name);
    if(cell) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const text = e.target.result;
        problems[cell.dataset.base][cell.dataset.type] = text;
        cell.style.backgroundColor = lerpHex(0);
      };

      reader.readAsText(file)
    }
  });
}

function createCell(base, type) {
  const cell = document.createElement("div");

  // class
  cell.className = "cell";

  // id (unique)
  cell.id = `${base[0]}.${type}`;

  // data attributes
  cell.dataset.base = base[0];
  if(type === "mod") {
    cell.dataset.type = "model";
  }
  else if(type === "dat") {
    cell.dataset.type = "data";
  }
  else if(type === "run") {
    cell.dataset.type = "commands";
  }

  // text content
  cell.textContent = `${base[0]}.${type}`;

  problems[base[0]] = { ...ampl };

  problems[base[0]].name = base[0];
  problems[base[0]].cat = base[1];
  problems[base[0]].sol = base[2];
  problems[base[0]].runs = base[3];

  return cell;
}

function sendToNeos() {
  const email = document.getElementById("emailInput").value;
  if(email) {
    for (let k in problems) {
      if(problems[k].model && problems[k].data && problems[k].commands) {
        problems[k].email = email;
        benchmark(problems[k]);
      }
    }
    const b = document.getElementById('submitBtn');
    b.disabled = true;
    b.textContent = "Submitted.  Wait for all jobs to finish for results.";
  }
}

const bases = [
  ['acrobot', 'nco', 'ipopt', 10],
  ['cart-pendulum-time', 'nco', 'ipopt', 10],
  ['cart-pendulum-utot', 'nco', 'ipopt', 10],
  ['five-link-mc-kelly', 'nco', 'ipopt', 10],
  ['five-link-phc-kelly', 'nco', 'ipopt', 10],
  ['five-link-tropic', 'nco', 'ipopt', 10],
  ['grasp-cbc', 'milp', 'cbc', 10],
  ['grasp-conopt', 'nco', 'conopt', 10],
  ['grasp-gurobi', 'minco', 'gurobi', 10],
  ['grasp-highs', 'milp', 'highs', 10],
  ['grasp-knitro', 'minco', 'knitro', 10],
  ['grasp-raposa', 'milp', 'raposa', 10],
  ['grasp-scip', 'milp', 'scip', 10],
  ['kinematic-car-conopt', 'nco', 'conopt', 10],
  ['kinematic-car-filter', 'nco', 'filter', 10],
  ['kinematic-car-gurobi', 'nco', 'gurobi', 10],
  ['kinematic-car-ipopt', 'nco', 'ipopt', 10],
  ['kinematic-car-knitro', 'nco', 'knitro', 10],
  ['kinematic-car-lancelot', 'nco', 'lancelot', 10],
  ['kinematic-car-loqo', 'nco', 'loqo', 10],
  ['kinematic-car-minos', 'nco', 'minos', 10],
  ['kinematic-car-snopt', 'nco', 'snopt', 10],
  ['moving-block', 'nco', 'ipopt', 10],
  ['spot-col3', 'nco', 'ipopt', 10],
  ['spot-rk1', 'nco', 'ipopt', 10],
  ['spot-rk4', 'nco', 'ipopt', 10]
];

const types = ["mod", "dat", "run"];
const grid = document.querySelector(".grid");

// Add headers first
["Model", "Data", "Commands"].forEach(header => {
  const div = document.createElement("div");
  div.className = "cell header";
  div.textContent = header;
  grid.appendChild(div);
});

// Add rows
bases.forEach(base => {
  types.forEach(type => {
    grid.appendChild(createCell(base, type));
  });
});
