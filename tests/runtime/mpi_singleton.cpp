// SPDX-License-Identifier: Apache-2.0
// A singleton diagnostic, not an MPI implementation or full ABI validation.
#include <mpi.h>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <string>
#ifdef _WIN32
#include <windows.h>
#endif

static std::string escaped(const std::string &s) {
  static const char hex[] = "0123456789abcdef";
  std::string out;
  for (unsigned char c : s) {
    if (c == '"' || c == '\\') { out += '\\'; out += static_cast<char>(c); }
    else if (c < 32) { out += "\\u00"; out += hex[c >> 4]; out += hex[c & 15]; }
    else { out += static_cast<char>(c); }
  }
  return out;
}
static void check(int rc, const char *where) {
  if (rc != MPI_SUCCESS) {
    char text[MPI_MAX_ERROR_STRING] = {};
    int n = 0;
    MPI_Error_string(rc, text, &n);
    throw std::runtime_error(std::string(where) + ": " + std::string(text, n));
  }
}
static std::string loaded_msmpi() {
#ifdef _WIN32
  HMODULE module = GetModuleHandleW(L"msmpi.dll");
  if (!module) return "";
  std::wstring path(32768, L'\0');
  DWORD n = GetModuleFileNameW(module, path.data(), static_cast<DWORD>(path.size()));
  if (n == 0 || n >= path.size()) return "";
  path.resize(n);
  int bytes = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, path.data(),
                                  static_cast<int>(path.size()), nullptr, 0, nullptr, nullptr);
  if (bytes <= 0) return "";
  std::string utf8(bytes, '\0');
  if (WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, path.data(),
      static_cast<int>(path.size()), utf8.data(), bytes, nullptr, nullptr) != bytes) return "";
  return utf8;
#else
  return "";
#endif
}
int main(int argc, char **argv) {
  bool initialized = false;
  try {
    int provided = -1;
    int init_rc = MPI_Init_thread(&argc, &argv, MPI_THREAD_SINGLE, &provided);
    if (init_rc != MPI_SUCCESS) throw std::runtime_error("MPI_Init_thread failed");
    initialized = true;
    check(MPI_Comm_set_errhandler(MPI_COMM_WORLD, MPI_ERRORS_RETURN), "error handler");
    int rank = -1, size = -1;
    check(MPI_Comm_rank(MPI_COMM_WORLD, &rank), "rank");
    check(MPI_Comm_size(MPI_COMM_WORLD, &size), "size");
    if (rank != 0 || size != 1) throw std::runtime_error("This probe requires exactly one rank");
    MPI_Comm comm = MPI_COMM_NULL;
    check(MPI_Comm_dup(MPI_COMM_WORLD, &comm), "comm dup");
    int send = 7, recv = -1;
    check(MPI_Allreduce(&send, &recv, 1, MPI_INT, MPI_SUM, comm), "allreduce");
    if (recv != send) throw std::runtime_error("allreduce result mismatch");
    check(MPI_Bcast(&recv, 1, MPI_INT, 0, comm), "broadcast");
    recv = -1;
    check(MPI_Allgather(&send, 1, MPI_INT, &recv, 1, MPI_INT, comm), "allgather");
    if (recv != send) throw std::runtime_error("allgather result mismatch");
    recv = -1;
    check(MPI_Alltoall(&send, 1, MPI_INT, &recv, 1, MPI_INT, comm), "alltoall");
    if (recv != send) throw std::runtime_error("alltoall result mismatch");
    MPI_Datatype pair = MPI_DATATYPE_NULL;
    check(MPI_Type_contiguous(2, MPI_DOUBLE, &pair), "type contiguous");
    check(MPI_Type_commit(&pair), "type commit");
    double a[2] = {1.25, -3.5}, b[2] = {};
    check(MPI_Sendrecv(a, 1, pair, 0, 11, b, 1, pair, 0, 11, comm, MPI_STATUS_IGNORE), "self sendrecv");
    if (a[0] != b[0] || a[1] != b[1]) throw std::runtime_error("derived type result mismatch");
    check(MPI_Type_free(&pair), "type free");
    check(MPI_Barrier(comm), "barrier");
    char version[MPI_MAX_LIBRARY_VERSION_STRING] = {};
    int n = 0;
    check(MPI_Get_library_version(version, &n), "library version");
    std::string dll = loaded_msmpi();
    check(MPI_Comm_free(&comm), "comm free");
    int final_rc = MPI_Finalize();
    initialized = false;
    if (final_rc != MPI_SUCCESS) throw std::runtime_error("MPI_Finalize failed");
#ifdef _WIN32
    const char *native_windows = "true";
#else
    const char *native_windows = "false";
#endif
    std::cout << "{\"status\":\"pass\",\"rank\":" << rank << ",\"size\":" << size
      << ",\"native_windows\":" << native_windows
      << ",\"pointer_bits\":" << sizeof(void*) * 8
      << ",\"thread_support\":" << provided
      << ",\"mpi_library\":\"" << escaped(std::string(version, n))
      << "\",\"msmpi_module\":\"" << escaped(dll) << "\"}\n";
    return EXIT_SUCCESS;
  } catch (const std::exception &e) {
    std::cerr << "MPI probe failed: " << e.what() << '\n';
    if (initialized) MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
    return EXIT_FAILURE;
  }
}
