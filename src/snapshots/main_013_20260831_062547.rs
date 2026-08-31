// Date: Thu Aug 31 2026

// Project: Learning Chapter 13
// Goal: Using closure: implementing FnOnce closure
// Dependency: Without dependency

// rustc 1.100.0-nightly (17fd5b8a3 2026-08-28)
// binary: rustc
// commit-hash: 17fd5b8a37b6667b6cc137f3cc35f09759768a3b
// commit-date: 2026-08-28
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
// os: Fedora 44.0.0 [64-bit]

// Kernel Version: 7.1.10-200.fc44.x86_64
// Firmware Version: 71CN51WW(V1.21)

use Select::{Invalid, Valid};

fn main() {
    println!("\n");

    let message_one = String::from("I am Junior Rustacean ...");
    let message_two = String::from("I am Junior C++ Developer ...");

    let raphael = Valid(String::from("Rust Developer"));
    let result_one = raphael.unwrap_or_else(|| {
        println!("I capture message_one form my environment ...");
        message_one
    });

    println!("value of result_one is: {}", result_one);

    println!("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");

    let samuel = Invalid;
    let result_two = samuel.unwrap_or_else(|| {
        println!("I capture message_two form my environment ...");
        message_two
    });

    println!("value of result_two is: {}", result_two);

    println!("\nThe End ...\n");
}

enum Select<T> {
    Valid(T),
    Invalid,
}

impl<T> Select<T> {
    fn unwrap_or_else<F>(self, f: F) -> T
    where
        F: FnOnce() -> T,
    {
        match self {
            Self::Valid(x) => x,
            Self::Invalid => f(),
        }
    }
}
