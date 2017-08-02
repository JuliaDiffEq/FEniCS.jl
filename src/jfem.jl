
#These are the commands to define the Fem class, and assemble the Matrix in Julia
#full documentation of the API from FEniCS can be found in the link below
#http://fenics.readthedocs.io/projects/ufl/en/latest/api-doc/ufl.html
#Tests for these can be found in the test_jfem.jl file.


using FEniCS

@fenicsclass FunctionSpace

FunctionSpace(mesh::Mesh, family::Union{String,Symbol}, degree::Int) = FunctionSpace(fenics.FunctionSpace(mesh.pyobject, family, degree))
#add more functionspace functions?
export FunctionSpace

@fenicsclass Argument
Argument(V,number,part::Union{String,Symbol} = nothing) = Argument(fenics.Argument(V.pyobject, number, part=part))
TrialFunction(V::FunctionSpace) = Argument(fenics.TrialFunction(V.pyobject))
TestFunction(V::FunctionSpace) = Argument(fenics.TestFunction(V.pyobject))

export TrialFunction
export TestFunction

@fenicsclass Constant

Constant(x::Real) = Constant(fenics.Constant(x, name="Constant($x)"))
export Constant

@fenicsclass Expression
Expression(cppcode::String;element=nothing, cell=nothing, domain=nothing, degree=nothing, name=nothing, label=nothing, mpi_comm=nothing) = Expression(fenics.Expression(cppcode=cppcode,
element=element,cell=cell, domain=domain, degree=degree, name=name, label=label, mpi_comm=mpi_comm))
#do these all need to be Args or Expression??
inner(u::Union{Expression,Argument}, v::Union{Expression,Argument}) = Expression(fenics.inner(u.pyobject, v.pyobject))
outer(u::Union{Expression,Argument}, v::Union{Expression,Argument}) = Expression(fenics.outer(u.pyobject, v.pyobject))
dot(u::Union{Expression,Argument}, v::Union{Expression,Argument}) = Expression(fenics.dot(u.pyobject, v.pyobject))
grad(u::Union{Expression,Argument}) = Expression(fenics.grad(u.pyobject))
nabla_grad(u::Argument) = Expression(fenics.nabla_grad(u.pyobject))
cross(u::Union{Expression,Argument}, v::Union{Expression,Argument}) = Expression(fenics.cross(u.pyobject, v.pyobject))
export inner,grad, nabla_grad,outer,dot,cross
#TODO : CHECK OUTER ,DOT (needs linalg.dot)

@fenicsclass Measure
#cant find the docs for these.
dx = Measure(fenics.dx)
ds = Measure(fenics.ds)
dS = Measure(fenics.dS)
dP = Measure(fenics.dP)
export dx, ds,dS,dP


#https://github.com/FEniCS/ufl/blob/master/ufl/measure.py
@fenicsclass Form
*(expr::Union{Expression,Argument}, measure::Measure) = Form(measure.pyobject[:__rmul__](expr.pyobject) )
*(expr::Union{Expression,Argument}, expr2::Union{Expression,Argument}) = Expression(expr.pyobject[:__mul__](expr2.pyobject) )
+(measure1::Measure, measure2::Measure) = Form(measure1.pyobject[:__add__](measure2.pyobject) ) #does this need to be expr?
#do we need to export + *?


@fenicsclass Matrix
#assemble(assembly_item::Form)=Matrix(fenics.assemble(assembly_item.pyobject))
assemble(assembly_item::Form;tensor=nothing, form_compiler_parameters=nothing, add_values=false, finalize_tensor=true, keep_diagonal=false, backend=nothing) = Matrix(
fenics.assemble(assembly_item.pyobject,tensor=tensor,form_compiler_parameters=form_compiler_parameters,add_values=add_values,finalize_tensor=finalize_tensor,keep_diagonal=keep_diagonal,backend=backend))#this gives as PETScMatrix of appopriate dimensions
export assemble

#https://fenicsproject.org/olddocs/dolfin/1.6.0/python/programmers-reference/cpp/fem/DirichletBC.html
@fenicsclass BoundaryCondition
DirichletBC(V::FunctionSpace,g::Expression,sub_domain,method="topological",check_midpoint=true)=BoundaryCondition(fenics.DirichletBC(V.pyobject,g.pyobject,method=method,check_midpoint=check_midpoint))#look this up with example
#this class wont be exported until the function boundary has been "fixed"
@fenicsclass sub_domain
#https://fenicsproject.org/olddocs/dolfin/2016.2.0/python/programmers-reference/compilemodules/subdomains/CompiledSubDomain.html
CompiledSubDomain(cppcode::String)  = sub_domain(fenics.CompiledSubDomain(cppcode))
export CompiledSubDomain


DirichletBCtest(V::FunctionSpace,g,sub_domain)=BoundaryCondition(fenics.DirichletBC(V.pyobject,g,sub_domain))#look this up with example also removed type from g(Should be expression)

V = FunctionSpace(mesh, "P", 1)

bc1 = DirichletBCtest(V, 1, "on_boundary")

