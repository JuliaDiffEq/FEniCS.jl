#These are the commands to define the Fem class, and assemble the Matrix in Julia
#full documentation of the API from FEniCS can be found in the link below
#http://fenics.readthedocs.io/projects/ufl/en/latest/api-doc/ufl.html
#Tests for these can be found in the test_jfem.jl file.


using FEniCS

@fenicsclass FunctionSpace

#Use Functionspace for scalar fields
FunctionSpace(mesh::Mesh, family::Union{String,Symbol}, degree::Int) = FunctionSpace(fenics.FunctionSpace(mesh.pyobject, family, degree))
#Use VectorFunctionSpace for vector fields
VectorFunctionSpace(mesh::Mesh, family::Union{String,Symbol},degree::Int) = FunctionSpace(fenics.VectorFunctionSpace(mesh.pyobject, family, degree))

export FunctionSpace, VectorFunctionSpace

@fenicsclass Argument
Argument(V,number,part::Union{String,Symbol} = nothing) = Argument(fenics.Argument(V.pyobject, number, part=part))
TrialFunction(V::FunctionSpace) = Argument(fenics.TrialFunction(V.pyobject))
TestFunction(V::FunctionSpace) = Argument(fenics.TestFunction(V.pyobject))


#Below are attributes for the argument *class*
geometric_dimension(expr::Union{Function,Argument}) = fenicspycall(expr, :geometric_dimension)
export geometric_dimension


export Argument,TrialFunction,TestFunction

@fenicsclass Constant
Constant(x::Union{Real,Tuple}) = Constant(fenics.Constant(x, name="Constant($x)"))
export Constant

@fenicsclass Function
Function(V::FunctionSpace) = Function(fenics.Function(V.pyobject))
assign(solution1::Function,solution2 )=fenicspycall(solution1,:assign,solution2.pyobject)

#Access function values through callable
#function (func::fenicsobject)(point)
#    return func.pyobject(point)
#end
export Function,assign
#added assign



@fenicsclass Expression

Expression(cppcode::String;element=nothing, cell=nothing, domain=nothing, degree=nothing, name=nothing, label=nothing, mpi_comm=nothing) = Expression(fenics.Expression(cppcode=cppcode,
element=element,cell=cell, domain=domain, degree=degree, name=name, label=label, mpi_comm=mpi_comm))
Identity(dim::Int) = Expression(fenics.Identity(dim))
inner(u::Union{Expression,Argument,Function}, v::Union{Expression,Argument,Function}) = Expression(fenics.inner(u.pyobject, v.pyobject))
outer(u::Union{Expression,Argument,Function}, v::Union{Expression,Argument,Function}) = Expression(fenics.outer(u.pyobject, v.pyobject))
dot(u::Union{Expression,Argument,Constant,Function}, v::Union{Expression,Argument,Constant,Function}) = Expression(fenics.dot(u.pyobject, v.pyobject))
grad(u::Union{Expression,Argument,Function}) = Expression(fenics.grad(u.pyobject))
nabla_grad(u::Union{Expression,Argument,Function}) = Expression(fenics.nabla_grad(u.pyobject))
nabla_div(u::Union{Expression,Argument,Function}) = Expression(fenics.nabla_div(u.pyobject))
div(u::Union{Expression,Argument,Function}) = Expression(fenics.div(u.pyobject))
cross(u::Union{Expression,Argument,Function}, v::Union{Expression,Argument,Function}) = Expression(fenics.cross(u.pyobject, v.pyobject))
tr(u::Union{Expression,Argument,Function}) = Expression(fenics.tr(u.pyobject))
sqrt(u::Union{Expression,Argument,Function}) = Expression(fenics.sqrt(u.pyobject))
sym(u::Union{Expression,Argument,Function}) = Expression(fenics.sym(u.pyobject))
len(U::Union{Expression,Argument,Function}) = length(U.pyobject)

interpolate(solution1::Function,solution2::Expression) = Function(fenicspycall(solution1,:interpolate,solution2.pyobject))


export Expression,Identity,inner,grad, nabla_grad, nabla_div,div, outer,dot,cross, tr, sqrt, sym, len, interpolate

#Below are attributes for the Expression and Function types
#Computes values at vertex of a mesh for a given Expression / Function, and returns an array
compute_vertex_values(expr::Expression, mesh::Mesh) = fenicspycall(expr, :compute_vertex_values, mesh.pyobject)
compute_vertex_values(expr::Function, mesh::Mesh) = fenicspycall(expr, :compute_vertex_values, mesh.pyobject)

export compute_vertex_values

@fenicsclass Measure
dx = Measure(fenics.dx)
ds = Measure(fenics.ds)
dS = Measure(fenics.dS)
dP = Measure(fenics.dP)
export dx, ds,dS,dP


#https://github.com/FEniCS/ufl/blob/master/ufl/measure.py
@fenicsclass Form

*(expr::Union{Expression,Argument}, measure::Measure) = Form(measure.pyobject[:__rmul__](expr.pyobject) )
*(expr::Union{Expression,Argument,Constant,Form,Function}, expr2::Union{Expression,Argument,Constant,Form,Function}) = Expression(expr.pyobject[:__mul__](expr2.pyobject) )
*(expr::Real, expr2::Union{Expression,Argument,Constant,Form,Function}) = Expression(expr2.pyobject[:__mul__](expr) )
*(expr::Union{Expression,Argument,Constant,Form}, expr2::Real) = Expression(expr.pyobject[:__mul__](expr2) )

+(expr::Union{Expression,Argument,Constant,Form}, expr2::Real) = Expression(expr.pyobject[:__add__](expr2) )
+(expr::Real, expr2::Union{Expression,Argument,Constant,Form,Function}) = Expression(expr2.pyobject[:__add__](expr) )
+(expr::Union{Expression,Argument,Constant,Measure,Form,Function}, expr2::Union{Expression,Argument,Constant,Measure,Form,Function}) = Expression(expr.pyobject[:__add__](expr2.pyobject) )

-(expr::Union{Expression,Argument,Constant,Form}, expr2::Real) = Expression(expr.pyobject[:__sub__](expr2) )
-(expr::Real, expr2::Union{Expression,Argument,Constant,Form,Function}) = Expression(expr2.pyobject[:__sub__](expr) )
-(expr::Union{Expression,Argument,Constant,Measure,Form,Function}, expr2::Union{Expression,Argument,Constant,Measure,Form,Function}) = Expression(expr.pyobject[:__sub__](expr2.pyobject) )

/(expr::Union{Expression,Argument,Constant,Form,Function}, expr2::Real) = Expression(expr.pyobject[:__div__](expr2) )
/(expr::Union{Expression,Argument,Constant,Form,Function}, expr2::Union{Expression,Argument,Constant,Form,Function}) = Expression(expr.pyobject[:__div__](expr2.pyobject) )

function /(expr::Real,expr2::Union{Expression,Argument,Constant,Form,Function})
    x = expr2*expr2
    y = x/expr
    z = expr2/y
    return Expression(z)
end

function Transpose(object::Union{Expression,Constant})
    x = object.pyobject[:T]
    y = Expression(x)
    return y
end
export Transpose

"""
rhs(equation::Expression)
Given a combined bilinear and linear form,
    extract the right hand side (negated linear form part).
    Example::

           a = u*v*dx + f*v*dx
           L = rhs(a) -> -f*v*dx

"""
rhs(equation::Expression)=Expression(fenics.rhs(equation.pyobject))
"""
lhs(equation::Expression)
    Given a combined bilinear and linear form,
    extract the left hand side (bilinear form part).

    Example::

        a = u*v*dx + f*v*dx
        a = lhs(a) -> u*v*dx
"""
lhs(equation::Expression)=Expression(fenics.lhs(equation.pyobject))

export lhs, rhs
#this assembles the matrix from a fenics form
@fenicsclass Matrix

assemble(assembly_item::Union{Form,Expression};tensor=nothing, form_compiler_parameters=nothing, add_values=false, finalize_tensor=true, keep_diagonal=false, backend=nothing) = Matrix(fenics.assemble(assembly_item.pyobject,
tensor=tensor,form_compiler_parameters=form_compiler_parameters,add_values=add_values,finalize_tensor=finalize_tensor,keep_diagonal=keep_diagonal,backend=backend))
export assemble


#I have changed this to Function+Form

#https://fenicsproject.org/olddocs/dolfin/1.6.0/python/programmers-reference/cpp/fem/DirichletBC.html
@fenicsclass sub_domain
@fenicsclass BoundaryCondition
"""
DirichletBC works in a slightly altered way to the original FEniCS.
Instead of defining the function with the required return command,
we define the return command directly (
ie instead of function(x)
                 return x
we simple write "x"
"""
DirichletBC(V::FunctionSpace,g,sub_domain)=BoundaryCondition(fenics.DirichletBC(V.pyobject,g.pyobject,sub_domain))#look this up with example also removed type from g(Should be expression)
export DirichletBC
#https://fenicsproject.org/olddocs/dolfin/2016.2.0/python/programmers-reference/compilemodules/subdomains/CompiledSubDomain.html
CompiledSubDomain(cppcode::String)  = sub_domain(fenics.CompiledSubDomain(cppcode))
export CompiledSubDomain

apply(bcs::BoundaryCondition, matrix::Matrix) = fenicspycall(bcs, :apply, matrix.pyobject)
apply(bcs, matrix::Matrix) = fenicspycall(BoundaryCondition(bcs), :apply, matrix.pyobject)

export apply


function assemble_system(a::Expression,L::Expression,bc)
    A_fenics,b_fenics = fenics.assemble_system(a.pyobject,L.pyobject,bc)
    A  = Matrix(A_fenics)
    b = Matrix(b_fenics)
    return A,b
end

function assemble_system(a::Expression,L::Expression,bc::BoundaryCondition)
    A_fenics,b_fenics = fenics.assemble_system(a.pyobject,L.pyobject,bc)
    A  = Matrix(A_fenics)
    b = Matrix(b_fenics)
    return A,b
end

export assemble_system


"""
 For a full list of supported arguments, and their usage
please refer to http://matplotlib.org/api/pyplot_api.html
not all kwargs have been imported. Should you require any that are not imported
open as issue, and I will attempt to add them.
Deprecate this in a future version
"""
#Geometry has been removed due to errors with mshr.
Plot(in_plot::Union{Mesh,FunctionSpace,Function};alpha=1,animated=false,antialiased=true,color="grey"
,dash_capstyle="butt",dash_joinstyle="miter",dashes="",drawstyle="default",fillstyle="full",label="s",linestyle="solid",linewidth=1
,marker="",markeredgecolor="grey",markeredgewidth="",markerfacecolor="grey"
,markerfacecoloralt="grey",markersize=1,markevery="none",visible=true,title="") =fenics.common[:plotting][:plot](in_plot.pyobject,
alpha=alpha,animated=animated,antialiased=antialiased,color=color,dash_capstyle=dash_capstyle,dash_joinstyle=dash_joinstyle
,dashes=dashes,drawstyle=drawstyle,fillstyle=fillstyle,label=label,linestyle=linestyle,linewidth=linewidth,marker=marker,markeredgecolor=markeredgecolor
,markeredgewidth=markeredgewidth,markerfacecolor=markerfacecolor,markerfacecoloralt=markerfacecoloralt,markersize=markersize,markevery=markevery
,visible=visible,title=title)#the first is the keyword argument, the second is the value
#export Plot



@fenicsclass FiniteElement
"""
This is the FiniteElement class. Attributes/function inputs can be found below,
or via the FEniCS documentation.
This is only a basic implementation. Many of the expected methods are still missing
Arguments
|          family (string/symbol)
|             The finite element family
|          cell
|             The geometric cell
|          degree (int)
|             The polynomial degree (optional)
|          form_degree (int)
|             The form degree (FEEC notation, used when field is
|             viewed as k-form)
|          quad_scheme
|             The quadrature scheme (optional)
|          variant
|             Hint for the local basis function variant (optional)

"""
#look at PLOT for overloading kws
FiniteElement(family::Union{Symbol,String},cell=nothing,degree=nothing,form_degree=nothing,quad_scheme=nothing,variant=nothing) =
FiniteElement(fenics.FiniteElement(family=family, cell=cell, degree=degree, form_degree=form_degree, quad_scheme=quad_scheme,variant=variant))
export FiniteElement

"""
Methods for the FiniteElement class

mapping(self)
 |
 |  reconstruct(self, family=None, cell=None, degree=None)
 |      Construct a new FiniteElement object with some properties
 |      replaced with new values.
 |
 |  shortstr(self)
 |      Format as string for pretty printing.
 |
 |  sobolev_space(self)
 |      Return the underlying Sobolev space.
 |
 |  variant(self)
 |
"""


tetrahedron = fenics.tetrahedron
hexahedron = fenics.hexahedron #matplotlib cannot handle hexahedron elements
triangle = fenics.triangle

export hexahedron, tetrahedron, triangle

family(finiteelement::FiniteElement) = fenicspycall(finiteelement, :family)

cell(finiteelement::FiniteElement) = fenicspycall(finiteelement, :cell)

degree(finiteelement::FiniteElement) = fenicspycall(finiteelement, :degree)

#form_degree(finiteelement::FiniteElement) = fenicspycall(finiteelement, :form_degree)

#quad_scheme(finiteelement::FiniteElement) = fenicspycall(finiteelement, :quad_scheme)

variant(finiteelement::FiniteElement) = fenicspycall(finiteelement, :variant)

reconstruct(finiteelement::FiniteElement, ;family=nothing,cell=nothing,degree=nothing) =
FiniteElement(fenicspycall(finiteelement, :reconstruct, family,cell,degree))

sobolev_space(finiteelement::FiniteElement) = fenicspycall(finiteelement, :sobolev_space)
export family, cell, degree, variant, reconstruct, sobolev_space

FacetNormal(mesh::Mesh)  = Expression(fenics.FacetNormal(mesh.pyobject))

export FacetNormal
