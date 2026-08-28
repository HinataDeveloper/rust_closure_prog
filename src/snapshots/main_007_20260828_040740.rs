// Date: Thu Aug 28 2026

// Project: Learning Chapter 13
// Goal: Using closure
// Dependency: Without dependency

// Zed 1.17.2
// Commit: c8e44cfa7bda9b2e22c8d6934d78969352e7f61a
// Version: 1.17.2+stable.349.c8e44cfa7bda9b2e22c8d6934d78969352e7f61a

// rustc 1.100.0-nightly (bff8e12ff 2026-08-26)
// binary: rustc
// commit-hash: bff8e12ff5e6bcd53dfb1dbccdcec80a60a856ed
// commit-date: 2026-08-26
// host: x86_64-unknown-linux-gnu
// release: 1.100.0-nightly
// LLVM version: 23.1.0

// cargo 1.100.0-nightly (e8cb624d5 2026-08-22)
// release: 1.100.0-nightly
// commit-hash: e8cb624d5701824f46a2ec5873cfd59ee3d2f66c
// commit-date: 2026-08-22
// host: x86_64-unknown-linux-gnu
// libgit2: 1.9.6 (sys:0.21.0 vendored)
// libcurl: 8.21.0-DEV (sys:0.4.90+curl-8.21.0 vendored ssl:OpenSSL/3.6.3)
// ssl: OpenSSL 3.6.3 9 Jun 2026
// os: Ubuntu 26.4.0 (resolute) [64-bit]

// Kernel Version: 7.0.0-30-generic
// Firmware Version: 71CN51WW(V1.21)

fn main() {
    println!("\n");

    let example_closure = |x| x;

    // this line specifies (x) data-type after first invocation of example_closure
    let result_one = example_closure(String::from("Hello"));
    println!("value of result is: {}", result_one);

    // encounter with compile time error. because example_closure
    // called for different data-type for the second time.
    let result_two = example_closure(200);

    println!("\nThe End ...\n");
}
