function welcome() {
  return call("welcome", [])
  .then(doc => doc.querySelector("string").textContent);
}

function version() {
  return call("version", [])
  .then(doc => doc.querySelector("string").textContent);
}

function ping() {
  return call("ping", [])
  .then(doc => doc.querySelector("string").textContent);
}

function solvers() {
  return call("listAllSolvers", [])
  .then(doc => {
    return Array.from(doc.querySelectorAll("array > data > value > string"))
      .map(n => n.textContent.split(":") )
      .filter(n => n[2].includes("AMPL"));
  });
}

function template(cat, solver) {
  const p = [[cat, "string"], [solver, "string"], ["AMPL", "string"]];
  return call("getSolverTemplate", p)
  .then(doc => doc.querySelector("string").textContent);
}

function status(job, password) {
  const p = [[job, "int"], [password, "string"]];
  return call("getJobStatus", p)
  .then(doc => doc.querySelector("string").textContent);
}

function code(job, password) {
  const p = [[job, "int"], [password, "string"]];
  return call("getCompletionCode", p)
  .then(doc => doc.querySelector("string").textContent);
}

function submit(xml) {
  const p = [[xml, "string"]];
  return call("submitJob", p)
  .then(doc => 
    [doc.querySelector("int").textContent, 
    doc.querySelector("string").textContent]
  );
}

function intermediate(job, password, offset) {
  // check if job is short
  const p = [[job, "int"], [password, "string"], [offset, "int"]];
  return call("getIntermediateResults", p)
  .then(doc => [
    doc.querySelector("int").textContent, 
    atob(doc.querySelector("base64").textContent)
  ]);
}

function final(job, password) {
  p = [[job, "int"], [password, "string"]];
  return call("getFinalResults", p)
  .then(doc => atob(doc.querySelector("base64").textContent));
}
