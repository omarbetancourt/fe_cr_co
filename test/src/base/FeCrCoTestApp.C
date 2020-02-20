//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "FeCrCoTestApp.h"
#include "FeCrCoApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
FeCrCoTestApp::validParams()
{
  InputParameters params = FeCrCoApp::validParams();
  return params;
}

FeCrCoTestApp::FeCrCoTestApp(InputParameters parameters) : MooseApp(parameters)
{
  FeCrCoTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

FeCrCoTestApp::~FeCrCoTestApp() {}

void
FeCrCoTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  FeCrCoApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"FeCrCoTestApp"});
    Registry::registerActionsTo(af, {"FeCrCoTestApp"});
  }
}

void
FeCrCoTestApp::registerApps()
{
  registerApp(FeCrCoApp);
  registerApp(FeCrCoTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
FeCrCoTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  FeCrCoTestApp::registerAll(f, af, s);
}
extern "C" void
FeCrCoTestApp__registerApps()
{
  FeCrCoTestApp::registerApps();
}
