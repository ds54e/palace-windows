#include <catch2/catch_session.hpp>
#include "utils/communication.hpp"
int main(int argc, char **argv)
{
  palace::Mpi::Init(argc, argv);
  const int status = Catch::Session().run(argc, argv);
  palace::Mpi::Finalize();
  return status;
}
