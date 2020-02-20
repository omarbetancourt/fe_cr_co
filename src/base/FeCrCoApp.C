#include "FeCrCoApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
FeCrCoApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  // Do not use legacy DirichletBC, that is, set DirichletBC default for preset = true
  params.set<bool>("use_legacy_dirichlet_bc") = false;

  return params;
}

FeCrCoApp::FeCrCoApp(InputParameters parameters) : MooseApp(parameters)
{
  FeCrCoApp::registerAll(_factory, _action_factory, _syntax);
}

FeCrCoApp::~FeCrCoApp() {}

void
FeCrCoApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAll(f, af, s);
  Registry::registerObjectsTo(f, {"FeCrCoApp"});
  Registry::registerActionsTo(af, {"FeCrCoApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
FeCrCoApp::registerApps()
{
  registerApp(FeCrCoApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
FeCrCoApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  FeCrCoApp::registerAll(f, af, s);
}
extern "C" void
FeCrCoApp__registerApps()
{
  FeCrCoApp::registerApps();
}
