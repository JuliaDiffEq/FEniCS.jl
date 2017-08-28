
#These are the commands to define the Mesh class in Julia.
#Tests for these can be found in the test_create.jl and test_pycreate.jl

#necessary imports for some specific mesh operations.
@pyimport mshr

@fenicsclass Mesh  #https://fenicsproject.org/olddocs/dolfin/1.5.0/python/programmers-reference/cpp/mesh/Mesh.html
#are converted automatically by PyCall
cell_orientations(mesh::Mesh) = fenicspycall(mesh, :cell_orientations)
#returns cell connectivity
cells(mesh::Mesh) = fenicspycall(mesh, :cells)
#Compute minimum cell diameter.
hmin(mesh::Mesh) = fenicspycall(mesh, :hmin)
#Compute maximum cell diameter.
hmax(mesh::Mesh) = fenicspycall(mesh, :hmax)
init(mesh::Mesh) = fenicspycall(mesh, :init)
init(mesh::Mesh, dim::Int) = fenicspycall(mesh, :init, dim) # version with dims
init_global(mesh::Mesh) = fenicspycall(mesh,:init_global)
#returns coordinates of all vertices
coordinates(mesh::Mesh) = fenicspycall(mesh,:coordinates)
#color
data(mesh::Mesh) = fenicspycall(mesh,:data)
domains(mesh::Mesh) = fenicspycall(mesh, :domains)
geometry(mesh::Mesh) = fenicspycall(mesh,:geometry)
#returns number of cells
num_cells(mesh::Mesh) = fenicspycall(mesh, :num_cells)
#returns number of edges
num_edges(mesh::Mesh) = fenicspycall(mesh, :num_edges)
#Get number of entities of given topological dimension.
num_entities(mesh::Mesh, dim::Int) = fenicspycall(mesh, :num_entities, dim)
#Get number of faces in mesh.
num_faces(mesh::Mesh) = fenicspycall(mesh, :num_faces)
#Get number of facets in mesh.
num_facets(mesh::Mesh) = fenicspycall(mesh, :num_facets)
#Get number of vertices in mesh.
num_vertices(mesh::Mesh) = fenicspycall(mesh, :num_vertices)
#hash(mesh::Mesh) = fenicspycall(Mesh, :hash)
bounding_box_tree(mesh::Mesh) = fenicspycall(mesh,:bounding_box_tree) #this object is a pyobject
#Compute maximum cell inradius.
rmax(mesh::Mesh)=fenicspycall(mesh, :rmax)
#Compute minimum cell inradius.
rmin(mesh::Mesh)=fenicspycall(mesh, :rmin)
#Get number of local entities of given topological dimension.
size(mesh::Mesh, dim::Int) = fenicspycall(mesh, :size, dim) # version with dims
#Returns the ufl cell of the mesh.
ufl_cell(mesh::Mesh)=fenicspycall(mesh, :ufl_cell)
#Returns the ufl Domain corresponding to the mesh.
ufl_domain(mesh::Mesh)=fenicspycall(mesh, :ufl_domain)
#Returns an id that UFL can use to decide if two objects are the same.
ufl_id(mesh::Mesh)=fenicspycall(mesh, :ufl_id)

export cell_orientations,cells,hmin , hmax, init, init_global, coordinates, data,
domains, geometry,num_cells,num_edges,num_entities,num_faces,num_facets,num_vertices, bounding_box_tree,
rmax, rmin, size, ufl_cell , ufl_domain, ufl_id

UnitTriangleMesh() = Mesh(fenics.UnitTriangleMesh())

"""
  Mesh
Mesh is equivanlent to the Mesh function in fenics
"""

#name change
Mesh(path::Union{String,Symbol}) = Mesh(fenics.Mesh(path))

UnitTetrahedronMesh() = Mesh(fenics.UnitTetrahedronMesh())

UnitSquareMesh(nx::Int, ny::Int, diagonal::Union{String,Symbol}="right") = Mesh(fenics.UnitSquareMesh(nx, ny, diagonal))

UnitQuadMesh(nx::Int,ny::Int) = Mesh(fenics.UnitQuadMesh(nx,ny))

UnitIntervalMesh(nx::Int) = Mesh(fenics.UnitIntervalMesh(nx))

UnitCubeMesh(nx::Int, ny::Int, nz::Int) = Mesh(fenics.UnitCubeMesh(nx,ny,nz))

BoxMesh(p0, p1, nx::Int, ny::Int, nz::Int)= Mesh(fenics.BoxMesh(p0,p1,nx,ny,nz)) #look at how to define fenics.point

RectangleMesh(p0,p1,nx::Int,ny::Int,diagdir::Union{String,Symbol}="right") = Mesh(fenics.RectangleMesh(p0,p1,nx,ny))




export UnitTriangleMesh, UnitTetrahedronMesh, UnitSquareMesh, UnitQuadMesh,
UnitIntervalMesh, UnitCubeMesh, BoxMesh, RectangleMesh, Mesh

@fenicsclass Geometry

#functions necessary for creating meshes from geometrical objects.
#2D objects below
Circle(centre,radius) = Geometry(mshr.Circle(centre,radius))
Rectangle(corner1,corner2)=Geometry(mshr.Rectangle(corner1,corner2))
Ellipse(centre,horizontal_semi_axis,vertical_semi_axis,fragments)=Geometry(mshr.Ellipse(centre,horizontal_semi_axis,vertical_semi_axis,fragments))

#3d objects below
Box(corner1,corner2) = Geometry(mshr.Box(corner1,corner2))
Cone(top,bottom,bottom_radius,slices::Int)=Geometry(mshr.Cone(top,bottom,bottom_radius,slices))
Sphere(centre,radius) = Geometry(mshr.Sphere(centre,radius))

generate_mesh(geom_object::Geometry,size::Int)=Mesh(mshr.generate_mesh(geom_object.pyobject,size))

+(geom_object1::Geometry, geom_object2::Geometry) = Geometry(geom_object1.pyobject[:__add__](geom_object2.pyobject))
-(geom_object1::Geometry, geom_object2::Geometry) = Geometry(geom_object1.pyobject[:__sub__](geom_object2.pyobject))
*(geom_object1::Geometry, geom_object2::Geometry) = Geometry(geom_object1.pyobject[:__mul__](geom_object2.pyobject))

export Circle,Rectangle,Ellipse,Box,Cone,Sphere,generate_mesh

function pyUnitTriangleMesh()
  pycall(fenics.UnitTriangleMesh::PyObject,PyObject::Type)
end

function pyUnitTetrahedronMesh()
  pycall(fenics.UnitTetrahedronMesh::PyObject,PyObject::Type)
end

function pyUnitCubeMesh(nx::Int, ny::Int, nz::Int)
  pycall(fenics.UnitCubeMesh::PyObject,PyObject::Type,nx,ny,nz)
end

function pyBoxMesh(p0, p1, nx::Int, ny::Int, nz::Int) # look at array types to declare p0,p1
  pycall(fenics.BoxMesh::PyObject,PyObject::Type,p0,p1,nx,ny,nz)
end

function pyRectangleMesh(p0,p1,nx::Int,ny::Int,diagdir::Union{String,Symbol}="right")
  pycall(fenics.RectangleMesh::PyObject,PyObject::Type,p0,p1,nx,ny,diagdir)
end

"""
For the diagdir, the possible options can be found below (these indicate the direction of the diagonals)
  (“left”, “right”, “right/left”, “left/right”, or “crossed”).
"""

function pyUnitSquareMesh(nx::Int,ny::Int,diagdir::Union{String,Symbol}="right")
  pycall(fenics.UnitSquareMesh::PyObject,PyObject::Type,nx,ny,diagdir)
end

function pyUnitQuadMesh(nx::Int,ny::Int)
  pycall(fenics.UnitSquareMesh::PyObject,PyObject::Type,nx,ny)
end #https://fenicsproject.org/olddocs/dolfin/2016.2.0/python/programmers-reference/cpp/mesh/UnitQuadMesh.html
#states that the UnitQuadMesh code is experimental. Nevertheless I plan to add it , and maybe remove it at the final
#iteration

function pyUnitIntervalMesh(nx::Int)
  pycall(fenics.UnitIntervalMesh::PyObject,PyObject::Type,nx)
end

function pyMesh(path::Union{String,Symbol})
  pycall(fenics.Mesh::PyObject,PyObject::Type,path)
end

function Point(point::Vector) #a different data type was suggested. Will Investigate when I return to UK
  pycall(fenics.Point::PyObject,PyObject::Type,point)
end

export pyUnitTriangleMesh, pyUnitTetrahedronMesh, pyUnitSquareMesh, pyUnitQuadMesh,
pyUnitIntervalMesh, pyUnitCubeMesh, pyBoxMesh, pyRectangleMesh,pyMesh, Point
