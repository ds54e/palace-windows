#include <algorithm>
#include <array>
#include <cstdint>
#include <iostream>
#include <limits>
#include <utility>
#include <vector>

extern "C" {
#include "metislib.h"
}

template <typename T, typename Projection>
bool monotone(const T *values, std::size_t size, Projection projection, bool ascending)
{
    for (std::size_t i = 1; i < size; ++i)
    {
        if (ascending ? projection(values[i]) < projection(values[i - 1])
                      : projection(values[i]) > projection(values[i - 1]))
        {
            return false;
        }
    }
    return true;
}

template <typename T, std::size_t N, typename Pair>
bool same_pairs(const std::array<T, N> &values, std::array<Pair, N> expected)
{
    std::array<Pair, N> actual{};
    for (std::size_t i = 0; i < N; ++i)
    {
        actual[i] = {values[i].key, values[i].val};
    }
    std::sort(actual.begin(), actual.end());
    std::sort(expected.begin(), expected.end());
    return actual == expected;
}

int main()
{
    static_assert(sizeof(idx_t) == 4 && sizeof(real_t) == 4);
    idx_t empty_dummy = 7;
    isorti(0, &empty_dummy);
    isortd(0, &empty_dummy);
    if (empty_dummy != 7) return 1;

    idx_t singleton = std::numeric_limits<idx_t>::min();
    isorti(1, &singleton);
    if (singleton != std::numeric_limits<idx_t>::min()) return 2;

    std::array<idx_t, 8> integers = {
        0, std::numeric_limits<idx_t>::max(), -1, 0,
        std::numeric_limits<idx_t>::min(), 17, -1, 17};
    const auto integer_projection = [](idx_t value) { return value; };
    isorti(integers.size(), integers.data());
    if (!monotone(integers.data(), integers.size(), integer_projection, true)) return 3;
    isortd(integers.size(), integers.data());
    if (!monotone(integers.data(), integers.size(), integer_projection, false)) return 4;

    std::array<real_t, 8> reals = {
        0.0F, std::numeric_limits<real_t>::max(), -1.5F, -0.0F,
        std::numeric_limits<real_t>::lowest(), 17.25F, -1.5F, 17.25F};
    const auto real_projection = [](real_t value) { return value; };
    rsorti(reals.size(), reals.data());
    if (!monotone(reals.data(), reals.size(), real_projection, true)) return 5;
    rsortd(reals.size(), reals.data());
    if (!monotone(reals.data(), reals.size(), real_projection, false)) return 6;

    std::array<ikv_t, 7> integer_pairs = {{{2, 10}, {-3, 7}, {2, -5},
        {std::numeric_limits<idx_t>::max(), 1}, {-3, 8},
        {std::numeric_limits<idx_t>::min(), 9}, {2, 10}}};
    const std::array<std::pair<idx_t, idx_t>, 7> expected_integer_pairs = {{
        {2, 10}, {-3, 7}, {2, -5}, {std::numeric_limits<idx_t>::max(), 1},
        {-3, 8}, {std::numeric_limits<idx_t>::min(), 9}, {2, 10}}};
    const auto integer_key = [](const ikv_t &value) { return value.key; };
    ikvsorti(integer_pairs.size(), integer_pairs.data());
    if (!monotone(integer_pairs.data(), integer_pairs.size(), integer_key, true) ||
        !same_pairs(integer_pairs, expected_integer_pairs)) return 7;
    ikvsortd(integer_pairs.size(), integer_pairs.data());
    if (!monotone(integer_pairs.data(), integer_pairs.size(), integer_key, false) ||
        !same_pairs(integer_pairs, expected_integer_pairs)) return 8;
    ikvsortii(integer_pairs.size(), integer_pairs.data());
    for (std::size_t i = 1; i < integer_pairs.size(); ++i)
    {
        const auto previous = std::make_pair(integer_pairs[i - 1].key, integer_pairs[i - 1].val);
        const auto current = std::make_pair(integer_pairs[i].key, integer_pairs[i].val);
        if (current < previous) return 9;
    }

    std::array<rkv_t, 7> real_pairs = {{{2.0F, 10}, {-3.5F, 7}, {2.0F, -5},
        {std::numeric_limits<real_t>::max(), 1}, {-3.5F, 8},
        {std::numeric_limits<real_t>::lowest(), 9}, {2.0F, 10}}};
    const std::array<std::pair<real_t, idx_t>, 7> expected_real_pairs = {{
        {2.0F, 10}, {-3.5F, 7}, {2.0F, -5},
        {std::numeric_limits<real_t>::max(), 1}, {-3.5F, 8},
        {std::numeric_limits<real_t>::lowest(), 9}, {2.0F, 10}}};
    const auto real_key = [](const rkv_t &value) { return value.key; };
    rkvsorti(real_pairs.size(), real_pairs.data());
    if (!monotone(real_pairs.data(), real_pairs.size(), real_key, true) ||
        !same_pairs(real_pairs, expected_real_pairs)) return 10;
    rkvsortd(real_pairs.size(), real_pairs.data());
    if (!monotone(real_pairs.data(), real_pairs.size(), real_key, false) ||
        !same_pairs(real_pairs, expected_real_pairs)) return 11;

    std::array<uvw_t, 6> edges = {{{2, 1, 90}, {-1, 5, 1}, {2, -3, 4},
        {-1, 5, 2}, {2, -3, 7}, {0, 0, 8}}};
    uvwsorti(edges.size(), edges.data());
    for (std::size_t i = 1; i < edges.size(); ++i)
    {
        if (std::make_pair(edges[i].u, edges[i].v) <
            std::make_pair(edges[i - 1].u, edges[i - 1].v)) return 12;
    }
    std::cout << "{\"status\":\"pass\",\"sort_entry_points\":10,"
                 "\"equal_key_contract\":\"key-only where upstream was key-only\"}\n";
    return 0;
}
