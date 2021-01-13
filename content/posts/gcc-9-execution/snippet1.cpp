#include <algorithm>
#include <chrono>
#include <execution>
#include <iostream>
#include <random>
#include <vector>

namespace t = std::chrono;

int main() {
  int N = 500'000'000;
  std::random_device rng;
  std::mt19937 engine{rng()};
  std::uniform_int_distribution<int> dist{1, 1'000'000};

  auto gen = [&] { return dist(engine); };

  std::vector<int> v(N);

  auto start = t::high_resolution_clock::now();
  std::generate(std::execution::seq, v.begin(), v.end(), gen);
  std::cout << "Seq: " << t::duration<double>(
    t::high_resolution_clock::now() - start).count() << "s\n";

  start = t::high_resolution_clock::now();
  std::generate(std::execution::par, v.begin(), v.end(), gen);
  std::cout << "Par: " << t::duration<double>(
    t::high_resolution_clock::now() - start).count() << "s\n";

  start = t::high_resolution_clock::now();
  std::generate(std::execution::par_unseq, v.begin(), v.end(), gen);
  std::cout << "Par unseq: " << t::duration<double>(
    t::high_resolution_clock::now() - start).count() << "s\n";

  return 0;
}