{config, ...}: {
  modules.kanidm = {
    enableClient = true;

    clientSettings = {
      uri = "https://auth.stu-dev.me";
    };
  };
}
