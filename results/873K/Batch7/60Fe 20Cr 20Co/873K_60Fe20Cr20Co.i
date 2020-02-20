[ICs] # Initial Conditions for the concentration variables
  [c_CrIC]          # % Cr with variations
    type = RandomIC # Random Initial Condition throughout field
    variable = c2   # The variable that is randomly dispersed
    min = 0.199
    max = 0.201
  []

  [c_CoIC]           # % Cr with variations
    type = RandomIC
    variable = c3
    min = 0.199
    max = 0.201
  []
[]

[Mesh]
  type = GeneratedMesh
  dim = 2 # Number of dimensions (2D in this case)
  elem_type = QUAD4 # Type of finite element
  nx = 80 # Number of elements in the x (horizontal) direction
  ny = 80 # Number of elements in the y (vertical) direction
  xmax = 100 # Size of calculated area (nm in this case) in x direction
  ymax = 100 # Size of calculated area (nm in this case) in y direction
[]

[Variables]
  [c2]  # Mole fraction of Cr (unitless)
  []

  [w2]  # Chemical potential of Cr (eV/mol)
  []

  [c3]  # Mole fraction of Co (unitless)
  []

  [w3]  # Chemical potential of Co (eV/mol)
  []
[]

[AuxVariables]
# AuxVariables can solve for additional variables expicitly
  [c1]  # Mole fraction of Fe (unitless)
  []

[]

[AuxKernels]
# AuxKernels block is what is used to solve for the AuxVariables
  [c_Fe]
    type = ParsedAux      # Needs a function expression to solve for c1
    variable = c1         # AuxVariable the function is assigned to
    function = '1.00 - (c2 + c3)'  # Function for computing c1 (composition of Fe)
    args = 'c2 c3'        # Variables used in the function
    execute_on = 'INITIAL TIMESTEP_BEGIN'  # When this object starts in the simulation
  []
[]

[BCs] # Boundary Conditions
# Periodic is when something goes off the screen it appears on the other side
# Ex: Something goes off the right side it will appear again on the left, and vice versa.
# Same from top to bottom and vice versa.
  [Periodic]
    [c_bcs]
      auto_direction = 'x y'
    []
  []
[]

[Kernels]
## Kernels for 1st equation ##
  [dc2dt]
    type = TimeDerivative
    variable = c2
  []

  [kappa_grad_c2]
    type = MatDiffusion
    variable = w2
    v = c2
    diffusivity = kappa_c
  []

# 1st term
  [L22_grad_w2]
    type = MatDiffusion
    variable = c2
    v = w2
    diffusivity = L_22
    args = 'c1 c2 c3'
  []

# 2nd term
  [L23_grad_w3]
    type = MatDiffusion
    variable = c2
    v = w3
    diffusivity = L_23
    args = 'c1 c2 c3'
  []

## Kernels for 2nd equation
  [dc3dt]
    type = TimeDerivative
    variable = c3
  []

  [kappa_grad_c3]
    type = MatDiffusion
    variable = w3
    v = c3
    diffusivity = kappa_c
  []

# 1st term
  [L32_grad_w2]
    type = MatDiffusion
    variable = c3
    v = w2
    diffusivity = L_32
    args = 'c1 c2 c3'
  []

# 2nd term
  [L33_grad_w3]
    type = MatDiffusion
    variable = c3
    v = w3
    diffusivity = L_33
    args = 'c1 c2 c3'
  []

# Extras
  [minus_M_grad_w2]
    type = CoefReaction
    variable = w2
    coefficient = -1.0
  []

  [minus_M_grad_w3]
    type = CoefReaction
    variable = w3
    coefficient = -1.0
  []

  [dFdc2]
    type = CoupledMaterialDerivative
    variable = w2
    v = c2
    f_name = F
    args = 'c1 c2 c3'
  []

  [dFdc3]
    type = CoupledMaterialDerivative
    variable = w3
    v = c3
    f_name = F
    args = 'c1 c2 c3'
  []
[]

[Materials]
# We need to change the length scale to units of nanometers.
# To prevent the values from becoming too large or too small,
# we will also change the energy scale to units of electron volts.
# The conversion from meters to nanometers is 1e+09
# The conversion from joules to electron volts is 6.24150934e+18

# In Table 1: Numerical values used in calculation in Koyoma 2006 paper,
# kappa_c is given as 1.0e-14 (J*m^2/mol)

# The composition gradient coefficient (kappa_c) is assumed to be constant
  [gradient_coef_kappa_c]
    type = GenericFunctionMaterial
    prop_names  = 'kappa_c'
    prop_values = '1.0e-14*6.24150934e+18*1e+09^2*1e-27'
    # eV*nm^2/mol
  []

  [constants]
    type = GenericConstantMaterial
    prop_names = ' p    T    nm_m   eV_J            d      R                 Q_1     Q_2     Q_3     D01     D02     D03     bohr'
    prop_values = '0.4  873  1e+09  6.24150934e+18  1e-27  8.31446261815324  294000  308000  294000  1.0e-4  2.0e-5  1.0e-4  5.7883818012e-5'#eV/T
  []

  [A] #can be parsedAux
    type = ParsedMaterial
    f_name = A
    function = '518/1125 + 11692/15975*(1/p-1)'
    material_property_names = 'p'
  []

  [tau_function]
    type = ParsedMaterial
    f_name = g
    function='if(tau<1, 1-1/A*(79*tau^-1/(140*p)+474/497*(1/p-1)*(tau^3/6+tau^9/135+tau^15/600)), -1/A*(1/10*tau^-5+1/315*tau^-15+1/1500*tau^-25))'
    args = 'c1 c2 c3'
    material_property_names = 'p A tau(c1,c2,c3)'
  []


# L_22, L_23, L_33 are defined in the Mobility_1, Mobility_2, and Mobility_3
# blocks respectivly. They are given as a function of composition and temperature
# in Equation 14 in Koyama 2006
# L_23 = L_32
  [Mobility_1]
    type = DerivativeParsedMaterial
    f_name = L_22
    material_property_names = 'T   nm_m   eV_J            d      R                 Q_1     Q_2     Q_3     D01     D02     D03'
    function = 'nm_m^2/eV_J/d*((c1*c2*(D01*exp(-Q_1/(R*T))) + (1-c2)^2*(D02*exp(-Q_2/(R*T))) + c2*c3*(D03*exp(-Q_3/(R*T))))*c2/(R*T))'
    args = 'c1 c2 c3'
    derivative_order = 1
  []

  [Mobility_2]
    type = DerivativeParsedMaterial
    f_name = L_23
    material_property_names = 'T    nm_m   eV_J            d      R                 Q_1     Q_2     Q_3     D01     D02     D03'
    function = 'nm_m^2/eV_J/d*((c1*(D01*exp(-Q_1/(R*T))) - (1-c2)*(D02*exp(-Q_2/(R*T))) - (1-c3)*(D03*exp(-Q_3/(R*T))))*c2*c3/(R*T))'
    args = 'c1 c2 c3'
    derivative_order = 1
  []

  [Mobility_4]
    type = DerivativeParsedMaterial
    f_name = L_32
    material_property_names = 'T    nm_m   eV_J            d      R                 Q_1     Q_2     Q_3     D01     D02     D03'
    function = 'nm_m^2/eV_J/d*((c1*(D01*exp(-Q_1/(R*T))) - (1-c2)*(D02*exp(-Q_2/(R*T))) - (1-c3)*(D03*exp(-Q_3/(R*T))))*c2*c3/(R*T))'
    args = 'c1 c2 c3'
    derivative_order = 1
  []

  [Mobility_3] # Good
    type = DerivativeParsedMaterial
    f_name = L_33
    material_property_names = 'T    nm_m   eV_J            d      R                 Q_1     Q_2     Q_3     D01     D02     D03'
    function = 'nm_m^2/eV_J/d*((c1*c3*(D01*exp(-Q_1/(R*T))) + c2*c3*(D02*exp(-Q_2/(R*T))) + (1-c3)^2*(D03*exp(-Q_3/(R*T))))*c3/(R*T))'
    args = 'c1 c2 c3'
    derivative_order = 1
  []

  [CurieTemp] # Good
    type = ParsedMaterial
    f_name = Tc
    function = '1043*c1-311.5*c2+1450*c3+(1650+550*(c2-c1))*c1*c2+590*c1*c3'
    args = 'c1 c2 c3'
  []

  [beta] # Good
    type = ParsedMaterial
    f_name = beta
    function = '(2.22*c1-0.01*c2+1.35*c3-0.85*c1*c2+(2.4127+0.2418*(c3-c1))*c1*c3)'
    args = 'c1 c2 c3'
  []

  [tau]
    type = ParsedMaterial
    f_name = tau
    function = 'T/Tc'
    material_property_names = 'Tc(c1,c2,c3) T'
    args = 'c1 c2 c3'
    outputs = exodus
  []

  [mg_G_alpha] # Good
    type = DerivativeParsedMaterial
    f_name = mg_G
    material_property_names = 'g(c1,c2,c3) beta(c1,c2,c3) T eV_J d R'
    function = '-1*eV_J*d*(R*T*log(beta+1)*g)' #g is a function of tau
    args = 'c2 c3 c1'
    derivative_order = 2
  []

# Below is the second term of Eq 2 of the contribution to the free energy
  [RT_clnc] # Good
    type = DerivativeParsedMaterial
    f_name = RT_clnc
    material_property_names = 'T eV_J d R'
    args = 'c2 c3 c1'
    function = '-1*eV_J*d*(R*T*(c1*log(c1)+c2*log(c2)+c3*log(c3)))'
    derivative_order = 2
  []

# Below is the excess free energy coresponding to the heat of mixing:
# Equation 3 / Third term of Eq 2
  [E_G_alpha] # Good
    type = DerivativeParsedMaterial
    f_name = E_G
    material_property_names = 'T eV_J d'
    function = '-1*eV_J*d*((20500 - 9.68*T)*c1*c2 + (-23669 + 103.9627*T - 12.7886*T*log(T))*c1*c3 + ((24357 - 19.797*T) - 2010*(c3 - c2))*c2*c3)'
    args = 'c2 c3 c1'
    derivative_order = 2
  []

  [G_system]
    type = DerivativeSumMaterial
    block = 0
    f_name = F
    sum_materials = 'RT_clnc E_G mg_G'
    args = 'c1 c2 c3'
    derivative_order = 2
  []
[]

[Preconditioning]
  [coupled]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  scheme = bdf2

  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type  -sub_pc_type '
  petsc_options_value = 'asm       lu'

  l_max_its = 30
  nl_max_its = 10
  l_tol = 1.0e-4
  nl_rel_tol = 1.0e-8
  nl_abs_tol = 1.0e-10
  start_time = 0.0
  dtmin = 1.0e-3

  [TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.7
    growth_factor = 1.3
    dt = 1
  []

  [Adaptivity]
    interval = 2
    refine_fraction = 0.2
    coursen_fraction = 0.3
    max_h_level = 4
  []
[]

[Outputs]
  exodus = true
[]
