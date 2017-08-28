
#this file includes the creation of the various julian meshes, returning true if all of
#them are creates succesfully with no errors

using FEniCS
using PyCall
@pyimport fenics


test_triangle = UnitTriangleMesh()
test_tetrahedron = UnitTetrahedronMesh()
test_interval = UnitIntervalMesh(10)
test_square = UnitSquareMesh(10,10,"crossed")
test_cube = UnitCubeMesh(10,10,10)
test_box = BoxMesh(Point([0.0,0.0,0.0]),Point([1.0,1.0,1.0]),10,10,10)
test_rectangle = RectangleMesh(Point([0.0, 0.0]), Point([10.0, 4.0]), 10, 10)

#the below functions simply check the creation of the objects,
#without (currently) verifying values
x1 = cell_orientations(test_cube)
x2 = cells(test_cube)
x3 = hmin(test_cube)
x4 = hmax(test_cube)
x5 = coordinates(test_cube)
x6 = data(test_cube)
x7 = domains(test_cube)
x8 = geometry(test_cube)
x9 = num_cells(test_cube)
x10 = num_edges(test_cube)
x11 = num_entities(test_cube,1)
x12 = num_faces(test_cube)
x13 = num_facets(test_cube)
x14 = num_vertices(test_cube)
x15 = bounding_box_tree(test_cube)
x16 = init(test_cube)
x17 = init(test_cube,1)
x18 = rmax(test_cube)
x19 = rmin(test_cube)
x20 = size(test_cube,1)
x21 = ufl_cell(test_cube)
x22 = ufl_domain(test_cube)
x23 = ufl_id(test_cube)

circle1=Circle(Point([0.0, 0.0]),3)
circle2=Circle(Point([0.0, 0.0]),4)

mesh1 = generate_mesh(circle1,64)
mesh2= generate_mesh(circle2,64)

circle3 = circle1+circle2
circle4 = circle2-circle1
mesh3 = generate_mesh(circle3,64)
mesh4 = generate_mesh(circle4,64)

Box1=Box(Point([0.0, 0.0,0.0]),Point([1.0, 1.0,1.0]))
Rectangle1 = Rectangle(Point([0.0, 0.0]),Point([1.0, 1.0]))
Ellipse1=Ellipse(Point([0.0, 0.0]),1.0,2.0,10)

Cone1=Cone(Point([0.0, 0.0,0.0]),Point([1.0, 1.0,1.0]),2.0,10)
Sphere1=Sphere(Point([0.0, 0.0,0.0]),3)

BoxMesh_Geom=generate_mesh(Box1,4)
RectangleMesh_Geom= generate_mesh(Rectangle1,4)
ELlipseMesh= generate_mesh(Ellipse1,4)
ConeMesh= generate_mesh(Cone1,4)



#TODO : create a test file that checks that the various functions provide the correct results
true
