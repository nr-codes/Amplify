const endpoint = "https://neos-server.org:3333";
const ampl = { model: '', data: '', commands: '', comments: '', 
  email: '', cat: '', sol: '', name: ''};

const start_color = 0xffff00;
const end_color = 0x00cc00;

const MAX_SUBMITS = 10; // in line with NEOS FAQ
let num_submits = 0;

function parameters(params) {
  const sep = "\n      ";
  return params.reduce((a, [v, t]) => {
      return a + `${sep}<param><value><${t}>${v}</${t}></value></param>`;
    }, ""
  );
}

function call(name, params) {
  const p = parameters(params);
  const b = `<?xml version="1.0"?>
  <methodCall>
    <methodName>${name}</methodName>
    <params>${p}
    </params>
  </methodCall>`;

  return fetch(endpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'text/xml'
    },
    body: b
  })
  .then(response => {
    if (response.status !== 200) {
      throw new Error('Request failed');
    }

    return response.text();
  })
  .then(xml => {
    //console.log(xml);
    const p = new DOMParser();
    const d = p.parseFromString(xml, "text/xml");
    if(d.querySelector('parsererror')) {
      throw new Error('XML parser error');
    }

    return d;
  })
  .catch(error => console.error(error.message));
}

async function run(prob) {
  const start = performance.now();
  const t = await template(prob.cat, prob.sol);
  const c = { ...ampl , ...prob };
  /*
  if(c.model) {
    c.model = amplify + c.model;
  }
  */

  let d = new DOMParser().parseFromString(t, "text/xml");
  for(const k of ['model', 'data', 'commands', 'comments', 'email']) {
    const e = d.getElementsByTagName(k)[0];
    while(e.firstChild) e.removeChild(e.firstChild);
    e.appendChild(d.createCDATASection(c[k]));
  }

  d = new XMLSerializer().serializeToString(d)
  .replace(/&/g, "&amp;")
  .replace(/</g, "&lt;")
  .replace(/>/g, "&gt;");

  const [j, p] = await submit(d);
  const o = await final(j, p);
  
  const end = performance.now();
  return { ...prob, job: j, pwd: p, out: o, start: start, end: end };
}

function sleep(ms) {
  return new Promise(r => setTimeout(r, ms));
}

function lerpHex(t) {
  const ar = (start_color >> 16) & 0xff;
  const ag = (start_color >> 8) & 0xff;
  const ab = start_color & 0xff;

  const br = (end_color >> 16) & 0xff;
  const bg = (end_color >> 8) & 0xff;
  const bb = end_color & 0xff;

  const rr = Math.round(ar + (br - ar) * t);
  const rg = Math.round(ag + (bg - ag) * t);
  const rb = Math.round(ab + (bb - ab) * t);

  return '#' + ((rr << 16) | (rg << 8) | rb).toString(16).padStart(6, '0');
}

async function benchmark(prob) {
  n = prob.runs;
  for(let i = 1; i <= n; i++) {
    while(num_submits >= MAX_SUBMITS) await sleep(1000);
    ++num_submits;

    run(prob)
    .then(sln => {
      if(num_submits > 0) --num_submits;

      // update web page
      const cells = document.querySelectorAll(`div[data-base="${prob.name}"]`);
      cells.forEach(c => { c.style.backgroundColor = lerpHex(i / n); });

      const d = document.getElementById("neos");
      const p = document.createElement("pre");
      const h = '\n-----------------\n';
      const t = `-- TIC ${sln.start} -- TOC ${sln.end}`;
      const s = `${sln.name} -- RUN ${i} -- JOB ${sln.job} -- PWD ${sln.pwd}`;
      p.textContent = `START: ${s}${h}${sln.out.trim()}${h}END: ${s} ${t}\n\n`;
      d.appendChild(p);
    });
    await sleep(500);
  }
}
