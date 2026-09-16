BEGIN {
    OFS=","

    print "model,run,solver,version,exit_status,exit_code," \
          "obj1,obj2," \
          "iterations,obj_eval,grad_eval,eq_eval,ineq_eval," \
          "eq_jac,ineq_jac,hess_eval," \
          "constraint_violation_unscaled,cpu_ipopt,cpu_nlp," \
          "total_vars,total_eq,total_ineq," \
          "ampl_elapsed_time,ampl_system_time,ampl_user_time,ampl_time," \
          "solve_elapsed_time,solve_system_time,solve_user_time,solve_time," \
          "nvars,snvars,ncons,sncons," \
          "tic,toc"
}

# -------------------------
# Helper functions
# -------------------------
function trim(s) {
    gsub(/^[ \t]+|[ \t]+$/, "", s)
    return s
}

function clean_version(v) {
    sub(/:$/, "", v)
    return v
}

# -------------------------
# Start new block
# -------------------------
/^START:/ {
    model=$2
    run=$5

    solver=version=exit_status=exit_code=""

    # Ipopt
    obj1=obj2=""
    iter=""
    obj_eval=grad_eval=eq_eval=ineq_eval=""
    eq_jac=ineq_jac=hess_eval=""
    constr_viol=""
    cpu_ipopt=cpu_nlp=""
    tot_vars=tot_eq=tot_ineq=""

    # AMPL
    ampl1=ampl2=ampl3=ampl4=""
    solve1=solve2=solve3=solve4=""
    nvars=snvars=ncons=sncons=""
    tic=toc=""
}

# -------------------------
# IPOPT DETECTION
# -------------------------
#/^Ipopt [0-9]+\.[0-9]+\.[0-9]+/ {
#    if (solver=="") {
#        solver="Ipopt"
#        version=clean_version($2)
#    }
#}

# -------------------------
# ✅ FIXED GUROBI DETECTION
# -------------------------
#/^Gurobi [0-9]+\.[0-9]+\.[0-9]+:/ {

    # detect solver + version once
#    if (solver=="") {
#        solver="Gurobi"
#        version=clean_version($2)
#    }

    # ✅ ONLY capture correct exit line
    #if ($0 ~ /solution;/) {

    #    line=$0
    #    sub(/^Gurobi [0-9]+\.[0-9]+\.[0-9]+:[ \t]*/, "", line)

    #    split(line, parts, ";")
    #    exit_status=trim(parts[1])
    #}
#}

/^[[:space:]]*Artelys Knitro [0-9]+\.[0-9]+\.[0-9]+/ { 
  solver="Knitro"
  version=clean_version($3)
}

/^[[:space:]]+RAPOSa v[0-9]+\.[0-9]+\.[0-9]+/ { 
  solver="RAPOSa"
  version=clean_version($2)
}

/^(Ipopt|Gurobi|LOQO|cbc|SCIP|CONOPT|HiGHS|CBC) [0-9]+\.[0-9]+\.[0-9]+:/ { 
  if(solver=="") {
    solver=$1
    version=clean_version($2)
  }
}

/^filterSQP \([0-9]+\):/ { 
  solver=$1
  version=$2
  gsub(/\(|\)|:/, "", version)
}

/^SNOPT [0-9]+\.[0-9]+\.[0-9]+ :/ { 
  solver=$1
  version=clean_version($2)
}

# -------------------------
# IPOPT METRICS
# -------------------------
tot_vars == "" && /Total number of variables/ { tot_vars=$NF }
tot_eq == "" && /Total number of equality constraints/ { tot_eq=$NF }
tot_ineq == "" && /Total number of inequality constraints/ { tot_ineq=$NF }

iter == "" && /Number of Iterations/ { iter=$NF }

obj_eval == "" && /Number of objective function evaluations/ { obj_eval=$NF }
grad_eval == "" &&/Number of objective gradient evaluations/ { grad_eval=$NF }
eq_eval == "" &&/Number of equality constraint evaluations/ { eq_eval=$NF }
ineq_eval == "" &&/Number of inequality constraint evaluations / { ineq_eval=$NF }
eq_jac == "" &&/Number of equality constraint Jacobian evaluations/ { eq_jac=$NF }
ineq_jac == "" &&/Number of inequality constraint Jacobian evaluations/ { ineq_jac=$NF }
hess_eval == "" &&/Number of Lagrangian Hessian evaluations/ { hess_eval=$NF }

constr_viol == "" && /Constraint violation/ { constr_viol=$NF }

# 3.12
cpu_ipopt == "" && /Total CPU secs in IPOPT/ { cpu_ipopt=$NF }
cpu_nlp == "" && /Total CPU secs in NLP function evaluations/ { cpu_nlp=$NF }
# 3.14
cpu_ipopt == "" && /Total seconds in IPOPT \(w\/o function evaluations\)/ { cpu_ipopt=$NF }
cpu_nlp == "" && /Total seconds in NLP function evaluations/ { cpu_nlp=$NF }

# -------------------------
# COMMON FIELDS
# -------------------------
/^OBJ / {
    obj1=$2
    obj2=$3
}

/^AMPL / {
    ampl1=$2; ampl2=$3; ampl3=$4; ampl4=$5
}

/^SOLVE / {
    solve1=$2; solve2=$3; solve3=$4; solve4=$5
}

/^VARS / {
    nvars=$2; snvars=$3
}

/^CONS / {
    ncons=$2; sncons=$3
}

/^STATUS / {
   exit_status=$2
   exit_code=$3
}

/Error: this solver is not allowed to be used via this interface/ { exit_status="XML-RPC rejected" }

# -------------------------
# OUTPUT ROW
# -------------------------
/^END:/ {
    tic=$(NF-3)
    toc=$NF

    q_model="\"" model "\""
    q_solver="\"" solver "\""
    q_exit="\"" exit_status "\""

    print q_model,run,q_solver,version,q_exit,exit_code, \
          obj1,obj2, \
          iter,obj_eval,grad_eval,eq_eval,ineq_eval, \
          eq_jac,ineq_jac,hess_eval, \
          constr_viol,cpu_ipopt,cpu_nlp, \
          tot_vars,tot_eq,tot_ineq, \
          ampl1,ampl2,ampl3,ampl4, \
          solve1,solve2,solve3,solve4, \
          nvars,snvars,ncons,sncons, \
          tic, toc
}
