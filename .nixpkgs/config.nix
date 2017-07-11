{ packageOverrides = _ : { unstable = import <unstable> {}; };
  allowUnfreePredicate = with builtins; (pkg: elem (parseDrvName pkg.name).name [
      "skype" # I never managed to make Skype work anyways
    ]);
}
